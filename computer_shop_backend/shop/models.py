import uuid
from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta

# Create your models here.

class Subscription(models.Model):
    SUBSCRIPTION_TYPE_CHOICES = [
        ('lifetime', 'Lifetime Access'),
        ('monthly', 'Monthly (Legacy)'),
        ('quarterly', 'Quarterly (Legacy)'),
        ('yearly', 'Yearly (Legacy)'),
    ]
    
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('inactive', 'Inactive'),
        ('suspended', 'Suspended'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="subscription")
    subscription_type = models.CharField(
        max_length=20, 
        choices=SUBSCRIPTION_TYPE_CHOICES, 
        default='lifetime'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='inactive'
    )
    is_paid = models.BooleanField(default=False)
    payment_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    payment_date = models.DateTimeField(null=True, blank=True)
    transaction_id = models.CharField(max_length=255, blank=True, null=True)
    expiry_date = models.DateTimeField(null=True, blank=True)  # Only for legacy subscriptions
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    notes = models.TextField(blank=True, help_text="Admin notes about this subscription")

    def is_active(self):
        """Check if subscription is active"""
        if self.status != 'active':
            return False
        
        if not self.is_paid:
            return False
        
        # Lifetime subscriptions never expire
        if self.subscription_type == 'lifetime':
            return True
        
        # Legacy subscriptions check expiry date
        if self.expiry_date:
            return timezone.now() < self.expiry_date
        
        return False

    def activate(self, transaction_id=None):
        """Activate subscription (called after successful payment)"""
        self.is_paid = True
        self.status = 'active'
        self.payment_date = timezone.now()
        
        if transaction_id:
            self.transaction_id = transaction_id
        
        # Set expiry only for legacy subscriptions
        if self.subscription_type != 'lifetime':
            if self.subscription_type == 'monthly':
                self.expiry_date = timezone.now() + timedelta(days=30)
            elif self.subscription_type == 'quarterly':
                self.expiry_date = timezone.now() + timedelta(days=90)
            elif self.subscription_type == 'yearly':
                self.expiry_date = timezone.now() + timedelta(days=365)
        else:
            self.expiry_date = None  # Lifetime has no expiry
        
        self.save()

    def __str__(self):
        return f"{self.user.username} - {self.get_subscription_type_display()} ({self.status})"


class MaintenanceJob(models.Model):
    # Status choices matching Flutter enum
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('InProgress', 'In Progress'),
        ('Completed', 'Completed'),
        ('Cancelled', 'Cancelled'),
    ]

    # id = models.CharField(max_length=50, primary_key=True)  # matches Flutter 'id' string
    # id = models.AutoField(primary_key=True)   # or just remove 'id' field entirely
    # id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)  # auto-generated UUID
    # id = serializers.CharField(read_only=True)
    customer_name = models.CharField(max_length=100)
    computer_model = models.CharField(max_length=100)
    reported_issue = models.TextField()
    date_reported = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Pending')
    notes = models.TextField(null=True, blank=True)          # optional notes
    date_completed = models.DateTimeField(null=True, blank=True)  # optional completion date

    def __str__(self):
        return f"{self.customer_name} - {self.computer_model} ({self.status})"


class ComputerSale(models.Model):
    # Status choices matching Flutter enum
    STATUS_CHOICES = [
        ('Available', 'Available'),
        ('Sold', 'Sold'),
        ('Reserved', 'Reserved'),
    ]

    # id = models.CharField(max_length=50, primary_key=True)  # matches Flutter 'id' string
    # id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    id = models.AutoField(primary_key=True)
    model = models.CharField(max_length=100)
    specs = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.IntegerField(default=1)  # track stock quantity
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Available')
    sale_date = models.DateTimeField(null=True, blank=True)  # optional sale date

    def __str__(self):
        return f"{self.model} - {self.status} (${self.price})"


class SoldItem(models.Model):
    """
    Record each sold unit. Keeps an immutable snapshot of the sale.
    """
    computer = models.ForeignKey(ComputerSale, on_delete=models.SET_NULL, null=True, related_name='sold_items')
    model = models.CharField(max_length=100)
    specs = models.TextField()
    sold_price = models.DecimalField(max_digits=10, decimal_places=2)
    sold_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Sold {self.model} at {self.sold_price} on {self.sold_at}"

class PasswordResetOTP(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    otp = models.CharField(max_length=4)
    expires_at = models.DateTimeField()
    verified = models.BooleanField(default=False) # <--- THIS LINE IS CRUCIAL

    def is_valid(self):
        return self.expires_at > timezone.now() and not self.verified

    def __str__(self):
        return f"OTP for {self.user.username}"

class EmailVerificationOTP(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='email_verification')
    otp = models.CharField(max_length=4)
    expires_at = models.DateTimeField()
    verified = models.BooleanField(default=False)

    def is_valid(self):
        return self.expires_at > timezone.now() and not self.verified

    def __str__(self):
        return f"Email verification OTP for {self.user.username}"

class Coupon(models.Model):
    DISCOUNT_TYPE_CHOICES = [
        ('percentage', 'Percentage'),
        ('fixed', 'Fixed Amount'),
    ]
    
    code = models.CharField(max_length=50, unique=True)
    discount_type = models.CharField(max_length=10, choices=DISCOUNT_TYPE_CHOICES, default='percentage')
    discount_value = models.DecimalField(max_digits=10, decimal_places=2)  # percentage or ETB amount
    min_purchase_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    max_uses = models.IntegerField(default=1)  # -1 for unlimited
    used_count = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    valid_from = models.DateTimeField(default=timezone.now)
    valid_until = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def is_valid(self):
        """Check if coupon is valid"""
        if not self.is_active:
            return False
        if self.max_uses != -1 and self.used_count >= self.max_uses:
            return False
        now = timezone.now()
        if now < self.valid_from:
            return False
        if self.valid_until and now > self.valid_until:
            return False
        return True
    
    def calculate_discount(self, amount):
        """Calculate discount amount"""
        if not self.is_valid():
            return 0
        if amount < self.min_purchase_amount:
            return 0
        
        if self.discount_type == 'percentage':
            discount = (amount * self.discount_value) / 100
        else:
            discount = self.discount_value
        
        # Ensure discount doesn't exceed the amount
        return min(discount, amount)
    
    def __str__(self):
        return f"{self.code} - {self.discount_value}{'%' if self.discount_type == 'percentage' else ' ETB'}"


class SubscriptionPricing(models.Model):
    """Admin-configurable subscription pricing"""
    name = models.CharField(max_length=100, unique=True, help_text="e.g., 'Lifetime Access'")
    amount = models.DecimalField(max_digits=10, decimal_places=2, help_text="Price in ETB")
    description = models.TextField(blank=True, help_text="Description of what's included")
    is_active = models.BooleanField(default=True, help_text="Show this pricing option")
    display_order = models.IntegerField(default=0, help_text="Order to display (lower = first)")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['display_order', 'name']
        verbose_name = 'Subscription Pricing'
        verbose_name_plural = 'Subscription Pricing'
    
    def __str__(self):
        return f"{self.name} - {self.amount} ETB"

