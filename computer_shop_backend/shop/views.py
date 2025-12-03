from django.shortcuts import render

# Create your views here.

from rest_framework import viewsets
from .models import MaintenanceJob, ComputerSale, PasswordResetOTP
from .serializers import MaintenanceJobSerializer, ComputerSaleSerializer
from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from django.http import JsonResponse
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import Subscription
from django.utils import timezone
from datetime import timedelta
import requests
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from django.conf import settings
import time
from django.http import HttpResponse
from django.shortcuts import render, redirect # Import redirect
from django.views.decorators.csrf import csrf_exempt
from django.core.mail import send_mail
from django.core.mail import EmailMessage
from django.utils.crypto import get_random_string
import random
import json

OTP_EXPIRY_MINUTES = 2

# Assuming you have a model to store OTP codes
from .models import PasswordResetOTP

CHAPA_SECRET_KEY = settings.CHAPA_SECRET_KEY

@csrf_exempt
def payment_success(request):
    return render(request, "payment_success.html")

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def check_subscription(request):
    sub, _ = Subscription.objects.get_or_create(user=request.user)
    return Response({
        "is_paid": sub.is_active(),
        "expiry_date": sub.expiry_date,
    })

def create_chapa_payment(user, amount, tx_ref):
    headers = {
        "Authorization": f"Bearer {CHAPA_SECRET_KEY}",
        "Content-Type": "application/json",
    }
    data = {
        "amount": str(amount),
        "currency": "ETB",
        "email": user.email,
        "first_name": user.username,
        "tx_ref": f"txn-{user.id}-{int(time.time())}",
        "callback_url": "https://ace-accordant-obviously.ngrok-free.dev/api/payment-callback/",
        "return_url": "https://ace-accordant-obviously.ngrok-free.dev/payment-success/",
    }
    try:
        r = requests.post(
            "https://api.chapa.co/v1/transaction/initialize",
            headers=headers,
            json=data,
            timeout=10
        )
        print("RAW CHAPA RESPONSE:", r.text)  # 👈 Log raw response
        return r.json()
    except Exception as e:
        print("Chapa Request Failed:", e)
        return {"error": str(e)}

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def start_payment(request):
    """Start a Chapa payment and return the checkout URL"""
    user = request.user
    amount = request.data.get("amount", 0)  # you can set default or dynamic price

    try:
        amount = int(amount)
    except (ValueError, TypeError):
        return Response({"error": "Invalid amount"}, status=status.HTTP_400_BAD_REQUEST)

    # Enforce minimum amount
    if amount < 5000:
        return Response(
            {"error": "Minimum payment amount is 5000"},
            status=status.HTTP_400_BAD_REQUEST
        )

    tx_ref = f"txn-{user.id}-{int(time.time())}"

    response = create_chapa_payment(user, amount, tx_ref)
    checkout_url = response.get("data", {}).get("checkout_url")

    if checkout_url:
        return Response({"payment_url": checkout_url})
    return Response({"error": "Failed to create payment"}, status=400)

# @api_view(["POST"])
# @permission_classes([IsAuthenticated])
# def start_payment(request):
#     """Start a Chapa payment and return the checkout URL"""
#     try:
#         user = request.user
#         amount = request.data.get("amount", 100)

#         print("Starting payment for:", user.username)
#         print("Amount received:", amount)

#         response = create_chapa_payment(user, amount)
#         print("Chapa API Response:", response)

#         checkout_url = response.get("data", {}).get("checkout_url")

#         if checkout_url:
#             return Response({"payment_url": checkout_url})
#         return Response({"error": "Failed to create payment"}, status=400)

#     except Exception as e:
#         import traceback
#         print("❌ ERROR in start_payment:", str(e))
#         traceback.print_exc()
#         return Response({"error": str(e)}, status=500)


@api_view(["GET", "POST"])
def payment_callback(request):
    """Chapa will hit this endpoint after payment"""
    # tx_ref = request.data.get("tx_ref")
    tx_ref = request.data.get("tx_ref") or request.GET.get("trx_ref")
    if not tx_ref:
        return Response({"error": "Transaction reference missing"}, status=400)

    # 🔹 Verify payment with Chapa API
    # headers = {"Authorization": f"Bearer {CHAPA_SECRET_KEY}"}
    # r = requests.get(
    #     f"https://api.chapa.co/v1/transaction/verify/{tx_ref}",
    #     headers=headers
    # )
    # result = r.json()

    # if result.get("status") == "success":
    #     # Activate subscription for the user
    #     user = request.user  # may need to identify via tx_ref
    #     sub, _ = Subscription.objects.get_or_create(user=user)
    #     sub.activate(tx_ref)
    #     return Response({"message": "Payment verified & subscription activated"})

    # return Response({"error": "Payment verification failed"}, status=400)
    try:
        # Assuming format "txn-<user_id>-<timestamp>"
        user_id = int(tx_ref.split("-")[1])
        user = User.objects.get(id=user_id)
    except Exception as e:
        return Response({"error": "Invalid tx_ref or user not found"}, status=400)

    # Verify payment with Chapa
    headers = {"Authorization": f"Bearer {CHAPA_SECRET_KEY}"}
    r = requests.get(f"https://api.chapa.co/v1/transaction/verify/{tx_ref}", headers=headers)
    result = r.json()

    if result.get("status") == "success":
        sub, _ = Subscription.objects.get_or_create(user=user)
        sub.activate(tx_ref)
        return Response({"message": "Payment verified & subscription activated"})

    return Response({"error": "Payment verification failed"}, status=400)

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def confirm_payment(request):
    """
    Verify a Chapa payment and activate subscription.
    Flutter will call this endpoint after checkout.
    """
    tx_ref = request.data.get("tx_ref")
    if not tx_ref:
        return Response({"error": "Transaction reference required"}, status=400)

    # 🔹 Verify payment with Chapa
    headers = {"Authorization": f"Bearer {CHAPA_SECRET_KEY}"}
    verify_url = f"https://api.chapa.co/v1/transaction/verify/{tx_ref}"
    r = requests.get(verify_url, headers=headers)
    result = r.json()

    if result.get("status") == "success":
        # Extract user from request (authenticated user)
        user = request.user
        sub, _ = Subscription.objects.get_or_create(user=user)
        sub.activate(tx_ref)  # Your Subscription model should handle expiry logic

        return Response({
            "status": "success",
            "message": "Payment verified & subscription activated",
            "expiry_date": sub.expiry_date
        })

    return Response({
        "error": "Payment verification failed",
        "details": result
    }, status=status.HTTP_400_BAD_REQUEST)



# Step 2: Confirm payment after callback
# @api_view(["POST"])
# @permission_classes([IsAuthenticated])
# def confirm_payment(request):
#     user = request.user
#     transaction_id = request.data.get("transaction_id")

#     if not transaction_id:
#         return Response({"error": "Transaction ID required"}, status=400)

#     # 🔹 TODO: verify transaction_id with Telebirr API

#     sub, _ = Subscription.objects.get_or_create(user=user)
#     sub.activate(transaction_id)

#     return Response({
#         "message": "Subscription activated",
#         "expiry_date": sub.expiry_date
#     })


# @api_view(["POST"])
# @permission_classes([IsAuthenticated])
# def confirm_payment(request):
#     telebirr_payment_url = "https://app.telebirr.com/pay?transaction_id=12345"
#     return Response({
#         "payment_url": telebirr_payment_url
#     })
#     user = request.user
#     transaction_id = request.data.get("transaction_id")

#     if not transaction_id:
#         return Response({"error": "Transaction ID required"}, status=400)

#     # 🔹 TODO: Verify payment with Telebirr API before confirming
#     sub, _ = Subscription.objects.get_or_create(user=user)
#     sub.activate(transaction_id)

#     return Response({"message": "Subscription activated", "expiry_date": sub.expiry_date})


@api_view(["POST"])
def signup(request):
    try:
        username = request.data.get("username")
        password = request.data.get("password")
        email = request.data.get("email")

        if not username or not password:
            return JsonResponse({"error": "Username and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(username=username).exists():
            return JsonResponse({"error": "Username already exists"}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create_user(
            username=username,
            password=password,
            email=email
        )

        return JsonResponse({"message": "User created successfully"}, status=status.HTTP_201_CREATED)

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

# @api_view(["POST"])
# def login(request):
#     username = request.data.get("username")
#     password = request.data.get("password")

#     user = authenticate(username=username, password=password)
#     if user is not None:
#         # generate or get token
#         token, _ = Token.objects.get_or_create(user=user)
#         return Response({
#             "token": token.key,
#             "username": user.username,
#             "email": user.email,
#         })
#     else:
#         return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(["POST"])
def login(request):
    identifier = request.data.get("identifier")  # Accept email or username in one field
    password = request.data.get("password")

    try:
        if "@" in identifier:
            user_obj = User.objects.get(email=identifier)
            username = user_obj.username
        else:
            username = identifier
    except User.DoesNotExist:
        return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

    user = authenticate(username=username, password=password)

    if user is not None:
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            "token": token.key,
            "username": user.username,
            "email": user.email,
        })
    else:
        return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)


class MaintenanceJobViewSet(viewsets.ModelViewSet):
    """
    API endpoint for listing, retrieving, creating, updating, and deleting Maintenance Jobs
    """
    queryset = MaintenanceJob.objects.all()
    serializer_class = MaintenanceJobSerializer

class ComputerSaleViewSet(viewsets.ModelViewSet):
    """
    API endpoint for listing, retrieving, creating, updating, and deleting Computer Sales
    """
    queryset = ComputerSale.objects.all()
    serializer_class = ComputerSaleSerializer

@api_view(['POST'])
@csrf_exempt
def send_reset_otp(request):
    email = request.data.get("email")

    if not email:
        return Response({"error": "Email is required"}, status=400)

    try:
        user = User.objects.filter(email=email).first()
        if not user:
            return Response({"error": "User with this email does not exist"}, status=404)
    except User.DoesNotExist:
        return Response({"error": "User with this email does not exist"}, status=404)

    # Generate OTP
    otp = str(random.randint(1000, 9999))
    print(f"DEBUG (send_reset_otp): Generated OTP: {otp} for email: {user.email}") # ADD THIS

    # Save or update OTP record
    expires = timezone.now() + timedelta(minutes=3)
    otp_obj, created = PasswordResetOTP.objects.update_or_create(
        user=user,
        defaults={"otp": otp, "expires_at": expires, "verified": False} # Ensure verified is set to False here
    )
    print(f"DEBUG (send_reset_otp): Saved/Updated OTP: {otp_obj.otp}, Expires: {otp_obj.expires_at}, Verified: {otp_obj.verified}") # ADD THIS
    # ...
    # PasswordResetOTP.objects.update_or_create(
    #     user=user,
    #     defaults={"otp": otp, "expires_at": expires}
    # )

    # Send email
    send_mail(
        "Password Reset OTP",
        f"Your OTP is {otp}. It expires in 3 minutes.",
        "storemanagementapp@gmail.com",
        [user.email],
        fail_silently=False,
    )

    return Response({"message": "OTP sent successfully"})

# def verify_otp_and_reset(request):
#     email = request.POST.get('email')
#     otp = request.POST.get('otp')
#     new_password = request.POST.get('new_password')

#     try:
#         user = User.objects.get(email=email)
#         otp_obj = PasswordResetOTP.objects.get(user=user, otp=otp, verified=False)
#     except (User.DoesNotExist, PasswordResetOTP.DoesNotExist):
#         return JsonResponse({"error": "Invalid OTP"}, status=400)

#     if otp_obj.expires_at < timezone.now():
#         return JsonResponse({"error": "OTP expired"}, status=400)

#     user.set_password(new_password)
#     user.save()

#     otp_obj.verified = True
#     otp_obj.save()

#     return JsonResponse({"message": "Password reset successfully"})
@api_view(['POST'])
@csrf_exempt
def verify_reset_otp(request):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid method"}, status=405)

    try:
        data = json.loads(request.body)
        email = data.get('email')
        otp = data.get('otp')
        new_password = data.get('new_password')
    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON"}, status=400)

    if not email or not otp or not new_password:
        return JsonResponse({"error": "Missing parameters"}, status=400)

    try:
        user = User.objects.get(email=email)
        otp_obj = PasswordResetOTP.objects.get(user=user, otp=otp, verified=False)
    except (User.DoesNotExist, PasswordResetOTP.DoesNotExist):
        return JsonResponse({"error": "Invalid OTP"}, status=400)

    if otp_obj.expires_at < timezone.now():
        return JsonResponse({"error": "OTP expired"}, status=400)

    user.set_password(new_password)
    user.save()

    otp_obj.verified = True
    otp_obj.save()

    return JsonResponse({"message": "Password reset successfully"})