"""
Django management command to ensure admin user exists.
Creates admin user with specified credentials if not already present.
"""
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

User = get_user_model()


class Command(BaseCommand):
    help = 'Ensures that an admin user exists in the database'

    def handle(self, *args, **options):
        username = 'admin'
        email = 'admin@example.com'
        password = 'Admin@1221'

        # Check if admin user already exists
        if User.objects.filter(username=username).exists():
            self.stdout.write(
                self.style.WARNING(f'Admin user "{username}" already exists. Skipping creation.')
            )
            return

        # Create superuser
        try:
            User.objects.create_superuser(
                username=username,
                email=email,
                password=password
            )
            self.stdout.write(
                self.style.SUCCESS(f'✅ Successfully created admin user "{username}"')
            )
            self.stdout.write(
                self.style.SUCCESS(f'   Username: {username}')
            )
            self.stdout.write(
                self.style.SUCCESS(f'   Password: {password}')
            )
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'❌ Error creating admin user: {e}')
            )
