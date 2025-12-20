from django.shortcuts import render

# Create your views here.

from rest_framework import viewsets
from .models import MaintenanceJob, ComputerSale, PasswordResetOTP, SoldItem, EmailVerificationOTP, Coupon, Subscription
from .serializers import MaintenanceJobSerializer, ComputerSaleSerializer, SoldItemSerializer
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
def payment_callback(request):
    """
    Chapa payment callback - called by Chapa after payment
    Verifies payment and activates subscription
    """
    try:
        # Get transaction reference from callback
        tx_ref = request.GET.get('trx_ref') or request.POST.get('trx_ref') or request.GET.get('tx_ref')
        
        if not tx_ref:
            print("❌ No transaction reference in callback")
            return JsonResponse({"error": "No transaction reference"}, status=400)
        
        print(f"🔔 Payment callback received for tx_ref: {tx_ref}")
        
        # Verify payment with Chapa
        headers = {
            "Authorization": f"Bearer {settings.CHAPA_SECRET_KEY}",
        }
        
        verify_url = f"https://api.chapa.co/v1/transaction/verify/{tx_ref}"
        response = requests.get(verify_url, headers=headers, timeout=10)
        
        print(f"📡 Chapa verification response: {response.status_code}")
        print(f"📄 Response body: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            
            if data.get('status') == 'success' and data.get('data', {}).get('status') == 'success':
                # Payment successful - activate subscription
                payment_data = data.get('data', {})
                email = payment_data.get('email')
                amount = payment_data.get('amount')
                
                print(f"✅ Payment verified for {email}, amount: {amount}")
                
                # Find user by email
                try:
                    user = User.objects.get(email=email)
                    
                    # Get or create subscription
                    subscription, created = Subscription.objects.get_or_create(user=user)
                    
                    # Activate subscription
                    subscription.activate(transaction_id=tx_ref)
                    subscription.payment_amount = amount
                    subscription.subscription_type = 'lifetime'
                    subscription.save()
                    
                    print(f"🎉 Subscription activated for user: {user.username}")
                    print(f"   - is_paid: {subscription.is_paid}")
                    print(f"   - status: {subscription.status}")
                    print(f"   - type: {subscription.subscription_type}")
                    
                    return JsonResponse({
                        "status": "success",
                        "message": "Subscription activated successfully"
                    })
                    
                except User.DoesNotExist:
                    print(f"❌ User not found with email: {email}")
                    return JsonResponse({"error": "User not found"}, status=404)
            else:
                print(f"❌ Payment verification failed: {data}")
                return JsonResponse({"error": "Payment verification failed"}, status=400)
        else:
            print(f"❌ Chapa API error: {response.status_code}")
            return JsonResponse({"error": "Failed to verify payment"}, status=500)
            
    except Exception as e:
        print(f"❌ Payment callback error: {str(e)}")
        import traceback
        traceback.print_exc()
        return JsonResponse({"error": str(e)}, status=500)

@csrf_exempt
def payment_success(request):
    """
    Payment success page - redirects to Flutter app
    Also activates subscription as backup
    """
    tx_ref = request.GET.get('tx_ref', '') or request.GET.get('trx_ref', '')
    status_param = request.GET.get('status', 'unknown')
    
    print(f"🎊 Payment success page accessed - tx_ref: {tx_ref}, status: {status_param}")
    
    # Trigger subscription activation
    if tx_ref:
        try:
            # Verify and activate subscription
            headers = {
                "Authorization": f"Bearer {settings.CHAPA_SECRET_KEY}",
            }
            
            verify_url = f"https://api.chapa.co/v1/transaction/verify/{tx_ref}"
            response = requests.get(verify_url, headers=headers, timeout=10)
            
            print(f"🔍 Verifying payment: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                
                if data.get('status') == 'success' and data.get('data', {}).get('status') == 'success':
                    payment_data = data.get('data', {})
                    email = payment_data.get('email')
                    amount = payment_data.get('amount')
                    
                    print(f"✅ Payment data: email={email}, amount={amount}")
                    
                    try:
                        user = User.objects.get(email=email)
                        subscription, created = Subscription.objects.get_or_create(user=user)
                        
                        # Activate subscription
                        subscription.activate(transaction_id=tx_ref)
                        subscription.payment_amount = amount
                        subscription.subscription_type = 'lifetime'
                        subscription.save()
                        
                        print(f"✅ Subscription activated for {user.username}")
                        print(f"   - Created new: {created}")
                        print(f"   - is_paid: {subscription.is_paid}")
                        print(f"   - status: {subscription.status}")
                        
                    except User.DoesNotExist:
                        print(f"❌ User not found: {email}")
        except Exception as e:
            print(f"❌ Error activating subscription: {str(e)}")
            import traceback
            traceback.print_exc()
    
    # For web (Chrome), redirect to the app's payment-success route
    frontend_url = request.GET.get('frontend_url')
    if frontend_url:
        # Use provided frontend URL (e.g., http://localhost:53841/#/)
        # Ensure it ends with / so we can append payment-success
        base_url = frontend_url.rstrip('/')
        if '/#' not in base_url:
             # Assume hash routing for Flutter Web if hash is missing (browser stripped it)
             app_url = f"{base_url}/#/payment-success?tx_ref={tx_ref}&status={status_param}"
        else:
             app_url = f"{base_url}/payment-success?tx_ref={tx_ref}&status={status_param}"
    else:
        # Fallback to localhost if no frontend_url provided
        app_url = f"http://localhost:53841/#/payment-success?tx_ref={tx_ref}&status={status_param}"
    
    return HttpResponse(f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Payment Successful</title>
        <meta http-equiv="refresh" content="2;url={app_url}">
        <style>
            body {{
                font-family: Arial, sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }}
            .container {{
                text-align: center;
                padding: 40px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 20px;
                backdrop-filter: blur(10px);
            }}
            .checkmark {{
                font-size: 80px;
                margin-bottom: 20px;
            }}
            h1 {{
                margin: 0 0 10px 0;
            }}
            p {{
                margin: 10px 0;
                opacity: 0.9;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="checkmark">✓</div>
            <h1>Payment Successful!</h1>
            <p>Thank you for your subscription.</p>
            <p>Your account has been activated.</p>
            <p>Redirecting you back to the app...</p>
        </div>
        <script>
            setTimeout(function() {{
                window.location.href = "{app_url}";
            }}, 2000);
        </script>
    </body>
    </html>
    """)

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def check_subscription(request):
    """Check if the user has an active subscription"""
    user = request.user
    try:
        sub = Subscription.objects.get(user=user)
        is_active = sub.is_active()
        
        return JsonResponse({
            "is_paid": is_active,
            "has_subscription": True,
            "expiry_date": sub.expiry_date.isoformat() if sub.expiry_date else None,
            "days_remaining": (sub.expiry_date - timezone.now()).days if sub.expiry_date and is_active else 0,
        })
    except Subscription.DoesNotExist:
        return JsonResponse({
            "is_paid": False,
            "has_subscription": False,
            "expiry_date": None,
            "days_remaining": 0,
        })


def create_chapa_payment(user, amount, tx_ref, frontend_url=None):
    headers = {
        "Authorization": f"Bearer {CHAPA_SECRET_KEY}",
        "Content-Type": "application/json",
    }
    data = {
        "amount": str(amount),
        "currency": "ETB",
        "email": user.email,
        "first_name": user.first_name or user.username,
        "last_name": user.last_name or "",
        "phone_number": user.profile.phone_number if hasattr(user, 'profile') and user.profile.phone_number else "+251912345678",
        "tx_ref": tx_ref,
        "callback_url": "http://127.0.0.1:8000/api/payment-callback/",
        "return_url": f"http://127.0.0.1:8000/api/payment-success/?tx_ref={tx_ref}" + (f"&frontend_url={frontend_url}" if frontend_url else ""), 
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
    amount = request.data.get("amount", 0)
    coupon_code = request.data.get("coupon_code", "").strip()
    frontend_url = request.data.get("frontend_url")

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

    # Apply coupon if provided
    discount_amount = 0
    final_amount = amount
    coupon = None
    
    if coupon_code:
        try:
            coupon = Coupon.objects.get(code=coupon_code)
            
            if not coupon.is_valid():
                return Response({"error": "Coupon is not valid or has expired"}, status=400)
            
            discount_amount = coupon.calculate_discount(amount)
            final_amount = amount - discount_amount
            
            # Ensure final amount meets minimum
            if final_amount < 5000:
                return Response({"error": "Amount after discount is below minimum (5000 ETB)"}, status=400)
                
        except Coupon.DoesNotExist:
            return Response({"error": "Invalid coupon code"}, status=400)

    tx_ref = f"txn-{user.id}-{int(time.time())}"

    payment_response = create_chapa_payment(user, int(final_amount), tx_ref, frontend_url)
    checkout_url = payment_response.get("data", {}).get("checkout_url")

    if checkout_url:
        # Increment coupon usage if applied
        if coupon:
            coupon.used_count += 1
            coupon.save()
            
        return Response({
            "payment_url": checkout_url,
            "original_amount": amount,
            "discount_amount": discount_amount,
            "final_amount": final_amount
        })
    return Response({"error": "Failed to create payment"}, status=400)

@api_view(["POST"])
def validate_coupon(request):
    """Validate a coupon code and return discount info"""
    coupon_code = request.data.get("coupon_code", "").strip()
    amount = request.data.get("amount", 0)
    
    if not coupon_code:
        return JsonResponse({"error": "Coupon code is required"}, status=400)
    
    try:
        amount = float(amount)
    except (ValueError, TypeError):
        return JsonResponse({"error": "Invalid amount"}, status=400)
    
    try:
        coupon = Coupon.objects.get(code=coupon_code)
        
        if not coupon.is_valid():
            return JsonResponse({
                "valid": False,
                "error": "Coupon is not valid or has expired"
            }, status=200)
        
        if amount < coupon.min_purchase_amount:
            return JsonResponse({
                "valid": False,
                "error": f"Minimum purchase amount is {coupon.min_purchase_amount} ETB"
            }, status=200)
        
        discount_amount = coupon.calculate_discount(amount)
        final_amount = amount - discount_amount
        
        return JsonResponse({
            "valid": True,
            "discount_type": coupon.discount_type,
            "discount_value": float(coupon.discount_value),
            "discount_amount": float(discount_amount),
            "final_amount": float(final_amount),
            "message": f"Coupon applied! You save {discount_amount} ETB"
        })
        
    except Coupon.DoesNotExist:
        return JsonResponse({
            "valid": False,
            "error": "Invalid coupon code"
        }, status=200)


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
        
        # Check if already paid to avoid DB lock
        if sub.is_paid and sub.status == 'active':
             return Response({"message": "Payment already processed"})
             
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

#     return Response({"message": "Subscription activated", "expiry_d    await prefs.remove("pending_tx_ref")

@api_view(["POST"])
@csrf_exempt
def custom_login(request):
    """Custom login that accepts email or username and handles unverified users"""
    # Accept identifier from any of these fields for maximum compatibility
    identifier = (request.data.get("identifier") or 
                 request.data.get("username") or 
                 request.data.get("email"))
    password = request.data.get("password")
    
    if not identifier or not password:
        return JsonResponse({"error": "Username/email and password are required"}, status=400)
    
    # Try to find user by email or username
    user = None
    try:
        # Check if identifier is an email
        if '@' in identifier:
            user = User.objects.get(email=identifier)
        else:
            user = User.objects.get(username=identifier)
    except User.DoesNotExist:
        return JsonResponse({"error": "Invalid credentials"}, status=401)
    
    # Check password
    if not user.check_password(password):
        return JsonResponse({"error": "Invalid credentials"}, status=401)
    
    # Check if user is verified
    if not user.is_active:
        return JsonResponse({
            "error": "Email not verified",
            "email_not_verified": True,
            "email": user.email,
            "message": "Please verify your email before logging in"
        }, status=403)
    
    # Generate JWT tokens
    from rest_framework_simplejwt.tokens import RefreshToken
    refresh = RefreshToken.for_user(user)
    
    return JsonResponse({
        "access": str(refresh.access_token),
        "refresh": str(refresh),
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email
        }
    }, status=200)

@api_view(["POST"])
def signup(request):
    try:
        username = request.data.get("username")
        password = request.data.get("password")
        email = request.data.get("email")

        if not username or not password:
            return JsonResponse({"error": "Username and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        if not email:
            return JsonResponse({"error": "Email is required"}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(username=username).exists():
            return JsonResponse({"error": "Username already exists"}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(email=email).exists():
            return JsonResponse({"error": "Email already exists"}, status=status.HTTP_400_BAD_REQUEST)

        # Create user as inactive until email is verified
        user = User.objects.create_user(
            username=username,
            password=password,
            email=email,
            is_active=False  # Require email verification
        )

        # Generate OTP for email verification
        otp = str(random.randint(1000, 9999))
        expires = timezone.now() + timedelta(minutes=10)
        
        print(f"DEBUG (signup): Generated verification OTP: {otp} for email: {email}")
        
        EmailVerificationOTP.objects.create(
            user=user,
            otp=otp,
            expires_at=expires,
            verified=False
        )

        # Send verification email
        send_mail(
            "Verify Your Email - Computer Shop App",
            f"Welcome {username}!\n\nYour email verification code is: {otp}\n\nThis code will expire in 10 minutes.\n\nIf you didn't create this account, please ignore this email.",
            "storemanagingapp@gmail.com",
            [email],
            fail_silently=False,
        )

        return JsonResponse({
            "message": "Signup successful. Please check your email for verification code.",
            "email": email
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        print(f"Signup error: {str(e)}")
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

@api_view(['GET'])
def get_subscription_pricing(request):
    """Get all active subscription pricing options"""
    from .models import SubscriptionPricing
    
    pricing_options = SubscriptionPricing.objects.filter(is_active=True).order_by('display_order', 'name')
    
    data = []
    for option in pricing_options:
        data.append({
            'id': option.id,
            'name': option.name,
            'amount': float(option.amount),
            'description': option.description,
            'display_order': option.display_order,
        })
    
    return JsonResponse(data, safe=False)

class ComputerSaleViewSet(viewsets.ModelViewSet):
    """
    API endpoint for listing, retrieving, creating, updating, and deleting Computer Sales
    Custom behavior:
    - POST: id is read-only (serializer enforces this)
    - PATCH: when status changes to 'Sold' we decrement quantity and create a SoldItem record.
    """
    queryset = ComputerSale.objects.all()
    serializer_class = ComputerSaleSerializer

    def create(self, request, *args, **kwargs):
        # Ensure client doesn't send 'id' (AutoField). Serializer marks id read-only.
        data = request.data.copy()
        data.pop('id', None)
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def partial_update(self, request, *args, **kwargs):
        """Handle PATCH requests to allow decrementing quantity and recording sold items.
        Supports two operations:
        - If `quantity_sold` is provided (int > 0): attempts to sell that many units.
        - If `status` is provided and == 'Sold' and no quantity_sold: treats as selling 1 unit.
        Returns updated `computer` data and a list `sold_items` created.
        """
        from django.db import transaction

        instance = self.get_object()
        data = request.data.copy()

        # Determine quantity to sell
        qty_to_sell = None
        if 'quantity_sold' in data:
            try:
                qty_to_sell = int(data.get('quantity_sold', 0))
            except (ValueError, TypeError):
                return Response({'error': 'quantity_sold must be an integer'}, status=status.HTTP_400_BAD_REQUEST)

        # If quantity_sold not provided but status == 'Sold', sell 1
        new_status = data.get('status')
        if qty_to_sell is None and new_status and str(new_status).lower() == 'sold':
            qty_to_sell = 1

        if qty_to_sell is not None:
            if qty_to_sell <= 0:
                return Response({'error': 'quantity_sold must be > 0'}, status=status.HTTP_400_BAD_REQUEST)

            if instance.quantity is None:
                instance.quantity = 0

            if instance.quantity < qty_to_sell:
                return Response({'error': 'Not enough stock to sell', 'available': instance.quantity}, status=status.HTTP_400_BAD_REQUEST)

            sold_items = []
            with transaction.atomic():
                # Decrement quantity
                instance.quantity -= qty_to_sell
                if instance.quantity <= 0:
                    instance.quantity = 0
                    instance.status = 'Sold'
                instance.save()

                # Create sold item snapshots (bulk)
                for _ in range(qty_to_sell):
                    sold = SoldItem.objects.create(
                        computer=instance,
                        model=instance.model,
                        specs=instance.specs,
                        sold_price=instance.price,
                    )
                    sold_items.append(sold)

            comp_serializer = self.get_serializer(instance)
            sold_serializer = SoldItemSerializer(sold_items, many=True)
            return Response({
                'computer': comp_serializer.data,
                'sold_items': sold_serializer.data,
            }, status=status.HTTP_200_OK)

        # Otherwise, fallback to default behavior (e.g., editing fields)
        return super().partial_update(request, *args, **kwargs)

    def update(self, request, *args, **kwargs):
        """Handle full updates (PUT). If status is 'Sold' treat as selling one unit unless quantity explicitly set to 0."""
        instance = self.get_object()
        data = request.data.copy()

        new_status = data.get('status')
        new_quantity = data.get('quantity')

        # If status set to Sold and quantity not explicitly zero, treat as single unit sale
        if new_status and str(new_status).lower() == 'sold' and (new_quantity is None or int(new_quantity) > 0):
            if instance.quantity and instance.quantity > 0:
                instance.quantity -= 1
                sold = SoldItem.objects.create(
                    computer=instance,
                    model=instance.model,
                    specs=instance.specs,
                    sold_price=instance.price,
                )
                if instance.quantity <= 0:
                    instance.status = 'Sold'
                    instance.quantity = 0
                instance.save()
                comp_serializer = self.get_serializer(instance)
                sold_serializer = SoldItemSerializer(sold)
                return Response({
                    'computer': comp_serializer.data,
                    'sold_item': sold_serializer.data,
                }, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'No stock available to mark as sold'}, status=status.HTTP_400_BAD_REQUEST)

        return super().update(request, *args, **kwargs)


class SoldItemViewSet(viewsets.ReadOnlyModelViewSet):
    """Read-only endpoint to list sold items (each sold unit snapshot)."""
    queryset = SoldItem.objects.all().order_by('-sold_at')
    serializer_class = SoldItemSerializer


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_to_maintenance(request, sale_id):
    """Create a MaintenanceJob for an existing ComputerSale and mark the computer as in maintenance."""
    try:
        comp = ComputerSale.objects.get(id=sale_id)
    except ComputerSale.DoesNotExist:
        return Response({'error': 'Computer not found'}, status=status.HTTP_404_NOT_FOUND)

    customer_name = request.data.get('customer_name', 'Store')
    reported_issue = request.data.get('reported_issue', 'No issue provided')
    notes = request.data.get('notes', '')

    # Create maintenance job linked to this computer
    job = MaintenanceJob.objects.create(
        customer_name=customer_name,
        computer=comp,
        computer_model=comp.model,
        reported_issue=reported_issue,
        notes=notes,
        status='Pending'
    )

    # Mark computer as in maintenance
    comp.status = 'Maintenance'
    comp.save()

    job_serializer = MaintenanceJobSerializer(job)
    comp_serializer = ComputerSaleSerializer(comp)
    return Response({'maintenance_job': job_serializer.data, 'computer': comp_serializer.data}, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def return_from_maintenance(request, job_id):
    """Mark a MaintenanceJob as completed and return linked computer back to inventory (Available)."""
    try:
        job = MaintenanceJob.objects.get(id=job_id)
    except MaintenanceJob.DoesNotExist:
        return Response({'error': 'Maintenance job not found'}, status=status.HTTP_404_NOT_FOUND)

    # Update job status and completion date
    job.status = 'Completed'
    job.date_completed = timezone.now()
    job.save()

    # If there's a linked computer, mark it available again
    computer = job.computer
    if computer:
        # Only change status if it was Maintenance - avoid overriding Sold/Reserved
        if str(computer.status).lower() == 'maintenance' or computer.status == 'Maintenance':
            computer.status = 'Available'
            computer.save()

    job_serializer = MaintenanceJobSerializer(job)
    comp_serializer = ComputerSaleSerializer(computer) if computer else None
    result = {'maintenance_job': job_serializer.data}
    if comp_serializer:
        result['computer'] = comp_serializer.data

    return Response(result, status=status.HTTP_200_OK)

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

@api_view(['POST'])
@csrf_exempt
def verify_email(request):
    """Verify email address with OTP code"""
    email = request.data.get('email')
    otp = request.data.get('otp')
    
    if not email or not otp:
        return JsonResponse({"error": "Email and OTP are required"}, status=400)
    
    try:
        user = User.objects.get(email=email)
        otp_obj = EmailVerificationOTP.objects.get(user=user, otp=otp, verified=False)
    except (User.DoesNotExist, EmailVerificationOTP.DoesNotExist):
        return JsonResponse({"error": "Invalid OTP or email"}, status=400)
    
    if otp_obj.expires_at < timezone.now():
        return JsonResponse({"error": "OTP has expired. Please request a new code."}, status=400)
    
    # Activate user account
    user.is_active = True
    user.save()
    
    # Mark OTP as verified
    otp_obj.verified = True
    otp_obj.save()
    
    print(f"DEBUG (verify_email): Email verified successfully for {email}")
    
    return JsonResponse({"message": "Email verified successfully! You can now log in."})

@api_view(['POST'])
@csrf_exempt
def resend_verification_code(request):
    """Resend verification code to user's email"""
    email = request.data.get('email')
    
    if not email:
        return JsonResponse({"error": "Email is required"}, status=400)
    
    try:
        user = User.objects.get(email=email)
        
        # Check if already verified
        if user.is_active:
            return JsonResponse({"error": "Email is already verified"}, status=400)
            
    except User.DoesNotExist:
        return JsonResponse({"error": "User not found"}, status=404)
    
    # Generate new OTP
    otp = str(random.randint(1000, 9999))
    expires = timezone.now() + timedelta(minutes=10)
    
    print(f"DEBUG (resend_verification_code): Generated new OTP: {otp} for email: {email}")
    
    # Update or create OTP record
    EmailVerificationOTP.objects.update_or_create(
        user=user,
        defaults={
            "otp": otp,
            "expires_at": expires,
            "verified": False
        }
    )
    
    # Send email
    send_mail(
        "Verify Your Email - Computer Shop App",
        f"Your new email verification code is: {otp}\n\nThis code will expire in 10 minutes.\n\nIf you didn't request this code, please ignore this email.",
        "storemanagingapp@gmail.com",
        [email],
        fail_silently=False,
    )
    
    return JsonResponse({"message": "Verification code sent successfully. Please check your email."})