from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    MaintenanceJobViewSet,
    ComputerSaleViewSet,
    SoldItemViewSet,
    signup,
    custom_login,
    check_subscription,
    confirm_payment,
    start_payment,
    payment_callback,
    payment_success,
    send_reset_otp,
    verify_reset_otp,
    verify_email,
    resend_verification_code,
    validate_coupon,
    get_subscription_pricing,
)
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

router = DefaultRouter()
router.register(r'maintenance-jobs', MaintenanceJobViewSet)
router.register(r'computer-sales', ComputerSaleViewSet)
router.register(r'sold-items', SoldItemViewSet, basename='solditem')

urlpatterns = [
    path('', include(router.urls)),
    path("check-subscription/", check_subscription, name="check_subscription"),
    path("confirm-payment/", confirm_payment, name="confirm_payment"),
    path("signup/", signup, name="signup"),
    path("login/", custom_login, name="login"),
    path("token/", custom_login, name="token"),  # alias for Flutter
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("start-payment/", start_payment, name="start_payment"),
    path("create-payment/", start_payment, name="create_payment"),  # alias for Flutter call
    path("payment-callback/", payment_callback, name="payment_callback"),
    path("payment-success/", payment_success, name="payment_success"),
    path('send-reset-otp/', send_reset_otp, name='send-reset-otp'),
    path('verify-reset-otp/', verify_reset_otp, name='verify-reset-otp'),
    path('verify-email/', verify_email, name='verify-email'),
    path('resend-verification-code/', resend_verification_code, name='resend-verification-code'),
    path('validate-coupon/', validate_coupon, name='validate-coupon'),
    path('subscription-pricing/', get_subscription_pricing, name='subscription-pricing'),
]