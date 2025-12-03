from django.contrib import admin

# Register your models here.
from .models import MaintenanceJob, ComputerSale

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
