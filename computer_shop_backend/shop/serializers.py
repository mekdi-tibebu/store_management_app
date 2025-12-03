# shop/serializers.py
from rest_framework import serializers
from .models import MaintenanceJob, ComputerSale

class MaintenanceJobSerializer(serializers.ModelSerializer):
    class Meta:
        model = MaintenanceJob
        fields = '__all__'
        read_only_fields = ('id',)

class ComputerSaleSerializer(serializers.ModelSerializer):
    class Meta:
        model = ComputerSale
        fields = '__all__'
