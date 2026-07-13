import os
import subprocess
import sys

from django.conf import settings
from django.test import SimpleTestCase
from django.urls import reverse


class HealthEndpointTests(SimpleTestCase):
    def test_health_returns_service_status(self):
        response = self.client.get(reverse("core:health"))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.json(),
            {"status": "healthy", "service": "django-platform"},
        )


class SecretKeyConfigurationTests(SimpleTestCase):
    @staticmethod
    def load_settings(secret_key):
        environment = os.environ.copy()
        environment["DJANGO_DEBUG"] = "false"
        environment["DJANGO_SECRET_KEY"] = secret_key

        return subprocess.run(
            [sys.executable, "-c", "import config.settings"],
            cwd=settings.BASE_DIR,
            env=environment,
            capture_output=True,
            text=True,
            check=False,
        )

    def test_production_mode_rejects_missing_secret(self):
        result = self.load_settings("")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("A secure DJANGO_SECRET_KEY is required", result.stderr)

    def test_production_mode_rejects_placeholder_secrets(self):
        placeholders = (
            "change-me-for-local-development-only",
            "unsafe-local-development-key",
        )

        for placeholder in placeholders:
            with self.subTest(placeholder=placeholder):
                result = self.load_settings(placeholder)

                self.assertNotEqual(result.returncode, 0)
                self.assertIn(
                    "A secure DJANGO_SECRET_KEY is required",
                    result.stderr,
                )

    def test_production_mode_accepts_non_placeholder_secret(self):
        result = self.load_settings("test-only-non-placeholder-secret")

        self.assertEqual(result.returncode, 0, result.stderr)
