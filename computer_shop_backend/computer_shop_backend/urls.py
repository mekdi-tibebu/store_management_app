from django.contrib import admin
# from . import views
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('shop.urls')),  # our API endpoints
    # path("", include("shop.urls")),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # path("signup/", views.signup, name="signup"),
    # path("login/", TokenObtainPairView.as_view(), name="login"),
    # path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]
