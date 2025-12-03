import uuid
from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta

# Create your models here.

class Subscription(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="subscription")
    is_paid = models.BooleanField(default=False)
    transaction_id = models.CharField(max_length=255, blank=True, null=True)
    expiry_date = models.DateTimeField(blank=True, null=True)

    def activate(self, transaction_id):
        self.is_paid = True
        self.transaction_id = transaction_id
        self.expiry_date = timezone.now() + timedelta(days=30)  # configurable
        self.save()

    def is_active(self):
        return self.is_paid and self.expiry_date and self.expiry_date > timezone.now()

    def __str__(self):
        return f"{self.user.username} - {'Active' if self.is_active() else 'Inactive'}"


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
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Available')
    sale_date = models.DateTimeField(null=True, blank=True)  # optional sale date

    def __str__(self):
        return f"{self.model} - {self.status} (${self.price})"

class PasswordResetOTP(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    otp = models.CharField(max_length=4)
    expires_at = models.DateTimeField()
    verified = models.BooleanField(default=False) # <--- THIS LINE IS CRUCIAL

    def is_valid(self):
        return self.expires_at > timezone.now() and not self.verified

    def __str__(self):
        return f"OTP for {self.user.username}"

