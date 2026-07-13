# ADR 0002: Lokalne kontenery baz danych

- Status: zaakceptowane
- Data: 2026-07-13

## Decyzja

Lokalny Compose zawiera wyłącznie PostgreSQL 17.10 Alpine jako główną bazę Django oraz SQL Server 2025 CU6 jako symulację zewnętrznego WMS/ERP. Obrazy są przypięte tagiem i digestem. Dane przechowują named volumes, a wspólna sieć nazywa się `logiflow_backend`.

## Konsekwencje

Django zachowuje fallback SQLite bez `DATABASE_URL`, ale typowy lokalny przebieg integracyjny korzysta z PostgreSQL. SQL Server nie jest jeszcze połączony z logiką aplikacyjną. Konfiguracja jest developerska, nie produkcyjna; sekrety pozostają w ignorowanych plikach lokalnych.
