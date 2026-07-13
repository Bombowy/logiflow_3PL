# LogiFlow 3PL — Warehouse Integration Demo

LogiFlow 3PL to niezależny projekt demonstracyjny inspirowany typowymi procesami operatorów logistycznych 3PL. Repozytorium pokazuje przygotowanie granic technologicznych i lokalnego środowiska dla systemu integracyjnego; nie odwzorowuje rozwiązania żadnej konkretnej firmy.

## Cel

Obecny etap dostarcza wyłącznie profesjonalny szkielet monorepo. Logika zleceń, produktów, operacji magazynowych, integracji, kolejek i stanów magazynowych zostanie dodana w kolejnych etapach.

## Planowane komponenty

- ASP.NET Core Web API — warstwa integracyjna i kontrakty HTTP.
- Django — platforma administracyjna, współdzielone modele oraz konfiguracja przyszłych procesów worker i ETL.
- Flutter — aplikacja mobilna dla pracownika magazynu.
- Kontrakty OpenAPI i komunikatów — wersjonowane granice integracyjne.
- PostgreSQL — główna baza Django w lokalnym środowisku developerskim.
- SQL Server — lokalna symulacja zewnętrznego WMS/ERP.

## Planowany przepływ docelowy

```text
[Flutter Warehouse App]
          |
          | REST/HTTPS
          v
[.NET Integration API]
          |
          | przyszłe komunikaty asynchroniczne
          v
[Python/Django Worker]
          |
          v
[PostgreSQL]
          ^
          |
[Django Business Portal]
```

Planowany przepływ ETL:

```text
[SQL Server / zewnętrzny WMS]
          |
          | ETL
          v
[Python/Django Worker]
          |
          v
[PostgreSQL]
```

Diagramy opisują planowany stan docelowy, a nie obecnie zaimplementowane integracje. Flutter będzie cienkim klientem korzystającym wyłącznie z REST/HTTPS i nie będzie łączył się bezpośrednio z PostgreSQL ani SQL Server. .NET stanowi publiczną warstwę API i integracji. Django Business Portal będzie server-rendered aplikacją dla pracowników. Worker oraz ETL będą osobnymi procesami korzystającymi ze wspólnej konfiguracji i przyszłych modeli Django.

## Wymagane SDK

- Git 2.51 lub nowszy,
- Python 3.13,
- .NET SDK 10 (wersja repozytorium jest przypięta w `global.json`),
- Flutter Stable z Android SDK,
- Docker Desktop z integracją WSL 2 i Docker Compose.

Backend rozwijamy Linux-first w VS Code WSL, w klonie umieszczonym pod `/home`. Klon Windows służy między innymi do pracy z Flutterem; klony synchronizuje wyłącznie Git, nie bezpośrednie kopiowanie plików roboczych. Szczegóły znajdują się w [docs/setup/wsl-development.md](docs/setup/wsl-development.md) i [docs/setup/environment.md](docs/setup/environment.md).

## Uruchamianie szkieletów

### Lokalne bazy w WSL

```bash
cp .env.docker.example .env.docker
# Zastąp przykładowe hasła silnymi, unikalnymi wartościami.
./scripts/infrastructure-up.sh
./scripts/test-infrastructure.sh
```

Instrukcje uruchamiania, zatrzymywania i trwałości danych opisuje [docs/setup/local-infrastructure.md](docs/setup/local-infrastructure.md).
Logiczne nazwy wolumenów z `compose.yaml` są w Dockerze prefiksowane wartością `COMPOSE_PROJECT_NAME`; skrypt zatrzymujący nie usuwa danych.

### Django

WSL/Linux:

```bash
cd backend/django-platform
python3.13 -m venv .venv
./.venv/bin/python -m pip install -r requirements/dev.txt
cp ../../.env.example .env
./.venv/bin/python manage.py check
./.venv/bin/python manage.py runserver
```

Windows PowerShell:

```powershell
cd backend/django-platform
py -3.13 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements\dev.txt
Copy-Item ..\..\.env.example .env
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py runserver
```

Health endpoint: `GET http://127.0.0.1:8000/health/`.
Readiness endpoint bazy: `GET http://127.0.0.1:8000/health/ready/`.

Pełną walidację testów Python uruchamia pytest przez skrypt wykonywany z katalogu głównego:

```bash
./scripts/test-python.sh
```

Wariant Windows / Windows variant: `.\scripts\test-python.ps1`.

Konfiguracja `pytest.ini` obejmuje `apps`, `tests`, `worker` i `etl`. Standardowe `python manage.py test`, uruchamiane z katalogu projektu Django, pozostaje przydatne dla testów aplikacji Django, ale nie zastępuje pełnej walidacji pytest tych czterech obszarów.

### ASP.NET Core Web API

```bash
dotnet restore backend/dotnet-api/LogiFlow.sln
dotnet build backend/dotnet-api/LogiFlow.sln
dotnet run --project backend/dotnet-api/src/LogiFlow.Integration.Api
```

Pełna walidacja w WSL: `./scripts/test-dotnet.sh`. Te same polecenia `dotnet` działają również w PowerShell.

Health endpoints: `GET /health/live` oraz `GET /health/ready`.

### Flutter

```powershell
cd mobile/warehouse-app
flutter pub get
flutter analyze
flutter test
flutter run
```

## Status

- Django 6.0: działa techniczny endpoint `/health/` oraz jego test.
- PostgreSQL 17.10 i SQL Server 2025 CU6 działają lokalnie przez Docker Compose.
- ASP.NET Core `net10.0`: działają procesowe endpointy `/health/live` i `/health/ready` oraz test integracyjny HTTP.
- Flutter Android: statyczny ekran startowy przechodzi analizę i test smoke.
- Docker: Docker Desktop udostępnia Engine do WSL 2; nie instalujemy drugiego Engine w Ubuntu.
- Logika biznesowa pozostaje celowo niezaimplementowana.
