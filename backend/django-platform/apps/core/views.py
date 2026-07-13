from django.db import connection
from django.db.utils import DatabaseError
from django.http import JsonResponse


def health(request):
    return JsonResponse({"status": "healthy", "service": "django-platform"})


def readiness(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
    except DatabaseError:
        return JsonResponse(
            {
                "status": "unavailable",
                "service": "django-platform",
                "database": "unavailable",
            },
            status=503,
        )

    return JsonResponse(
        {
            "status": "ready",
            "service": "django-platform",
            "database": "available",
        }
    )
