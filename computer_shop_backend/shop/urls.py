from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    MaintenanceJobViewSet,
    ComputerSaleViewSet,
    signup,
    check_subscription,
    confirm_payment,
    start_payment,           # ✅ add this import
    payment_callback,
    payment_success,
    send_reset_otp,
    verify_reset_otp,
)
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

router = DefaultRouter()
router.register(r'maintenance-jobs', MaintenanceJobViewSet)
router.register(r'computer-sales', ComputerSaleViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path("check-subscription/", check_subscription, name="check_subscription"),
    path("confirm-payment/", confirm_payment, name="confirm_payment"),
    path("signup/", signup, name="signup"),
    path("login/", TokenObtainPairView.as_view(), name="login"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("start-payment/", start_payment, name="start_payment"),
    path("create-payment/", start_payment, name="create_payment"),  # alias for Flutter call
    path("payment-callback/", payment_callback, name="payment_callback"),
    path("payment-success/", payment_success, name="payment_success"),
    path('send-reset-otp/', send_reset_otp, name='send-reset-otp'),
    path('verify-reset-otp/', verify_reset_otp, name='verify-reset-otp'),
]