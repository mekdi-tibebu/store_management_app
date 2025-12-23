ffrom .models import MaintenanceJob, ComputerSale, Coupon, Subscription, PasswordResetOTP, EmailVerificationOTP, SubscriptionPricingom django.contrib import admin
from .models import MaintenanceJob, ComputerSale, Coupon, Subscription, PasswordResetOTP, EmailVerificationOTP, SubscriptionPricing, SiteSettings

@admin.register(MaintenanceJob)
class MaintenanceJobAdmin(admin.ModelAdmin):
    list_display = ('id', 'customer_name', 'computer_model', 'status', 'date_reported', 'date_completed')
    list_filter = ('status',)
    search_fields = ('customer_name', 'computer_model', 'reported_issue')

@admin.register(ComputerSale)
class ComputerSaleAdmin(admin.ModelAdmin):
    list_display = ('id', 'model', 'price', 'status', 'sale_date')
    list_filter = ('status',)
    search_fields = ('model', 'specs')

@admin.register(Coupon)
class CouponAdmin(admin.ModelAdmin):
    list_display = ['code', 'discount_type', 'discount_value', 'used_count', 'max_uses', 'is_active', 'valid_until']
    list_filter = ['discount_type', 'is_active', 'created_at']
    search_fields = ['code']
    readonly_fields = ['used_count', 'created_at']

@admin.register(Subscription)
class SubscriptionAdmin(admin.ModelAdmin):
    list_display = ('user', 'subscription_type', 'status', 'is_paid', 'payment_amount', 'payment_date', 'is_active_display')
    list_filter = ('subscription_type', 'status', 'is_paid', 'payment_date')
    search_fields = ('user__username', 'user__email')
    readonly_fields = ('created_at', 'updated_at', 'payment_date')
    
    fieldsets = (
        ('User Information', {
            'fields': ('user',)
        }),
        ('Subscription Details', {
            'fields': ('subscription_type', 'status', 'is_paid', 'payment_amount')
        }),
        ('Dates', {
            'fields': ('payment_date', 'expiry_date', 'created_at', 'updated_at')
        }),
        ('Admin Notes', {
            'fields': ('notes',),
            'classes': ('collapse',)
        }),
    )
    
    actions = ['activate_subscriptions', 'deactivate_subscriptions', 'suspend_subscriptions']
    
    def is_active_display(self, obj):
        return obj.is_active()
    is_active_display.boolean = True
    is_active_display.short_description = 'Active'
    
    def activate_subscriptions(self, request, queryset):
        for subscription in queryset:
            subscription.activate()
        self.message_user(request, f"{queryset.count()} subscription(s) activated.")
    activate_subscriptions.short_description = "Activate selected subscriptions"
    
    def deactivate_subscriptions(self, request, queryset):
        queryset.update(status='inactive')
        self.message_user(request, f"{queryset.count()} subscription(s) deactivated.")
    deactivate_subscriptions.short_description = "Deactivate selected subscriptions"
    
    def suspend_subscriptions(self, request, queryset):
        queryset.update(status='suspended')
        self.message_user(request, f"{queryset.count()} subscription(s) suspended.")
    suspend_subscriptions.short_description = "Suspend selected subscriptions"

@admin.register(SubscriptionPricing)
class SubscriptionPricingAdmin(admin.ModelAdmin):
    list_display = ('name', 'amount', 'is_active', 'display_order', 'updated_at')
    list_filter = ('is_active',)
    search_fields = ('name', 'description')
    list_editable = ('amount', 'is_active', 'display_order')
    
    fieldsets = (
        ('Pricing Details', {
            'fields': ('name', 'amount', 'description')
        }),
        ('Display Settings', {
            'fields': ('is_active', 'display_order')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    readonly_fields = ('created_at', 'updated_at')

@admin.register(SiteSettings)
class SiteSettingsAdmin(admin.ModelAdmin):
    """
    Custom admin for SiteSettings singleton model.
    """
    fieldsets = (
        ('Chapa Payment Settings', {
            'fields': ('chapa_secret_key', 'chapa_public_key'),
            'description': 'Configure Chapa API keys for payment processing. If left empty, environment variables will be used as fallbacks.'
        }),
        ('Backend Configuration', {
            'fields': ('backend_url',),
            'description': 'Set your hosted backend URL (e.g., https://store-management-56xj.onrender.com). This is used for payment callback and return URLs. Falls back to BACKEND_URL environment variable if not set.'
        }),
        ('Frontend Configuration', {
            'fields': ('frontend_url',),
            'description': 'Set the URL where users are redirected after payment completion (e.g., https://yourapp.com or http://localhost:53841 for local development).'
        }),
    )

    
    def has_add_permission(self, request):
        # Only allow adding if no instance exists
        return not SiteSettings.objects.exists()
    
    def has_delete_permission(self, request, obj=None):
        # Prevent deletion
        return False

admin.site.register(PasswordResetOTP)
admin.site.register(EmailVerificationOTP)

