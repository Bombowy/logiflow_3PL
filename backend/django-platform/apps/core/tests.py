import os
import subprocess
import sys
from unittest.mock import patch

from django.conf import settings
from django.db.utils import DatabaseError
from django.test import SimpleTestCase, TestCase
from django.urls import reverse


class HealthEndpointTests(SimpleTestCase):
    def test_health_returns_service_status(self):
        response = self.client.get(reverse("core:health"))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.json(),
            {"status": "healthy", "service": "django-platform"},
        )


class ReadinessEndpointTests(TestCase):
    def test_readiness_returns_exact_response_when_database_is_available(self):
        response = self.client.get(reverse("core:readiness"))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.json(),
            {
                "status": "ready",
                "service": "django-platform",
                "database": "available",
            },
        )

    @patch("apps.core.views.connection.cursor")
    def test_readiness_hides_database_error(self, cursor):
        sensitive_message = "simulated-sensitive-database-detail"
        cursor.side_effect = DatabaseError(sensitive_message)

        response = self.client.get(reverse("core:readiness"))

        self.assertEqual(response.status_code, 503)
        self.assertEqual(
            response.json(),
            {
                "status": "unavailable",
                "service": "django-platform",
                "database": "unavailable",
            },
        )
        self.assertNotContains(response, sensitive_message, status_code=503)


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
