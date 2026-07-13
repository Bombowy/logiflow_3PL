# LogiFlow 3PL — Warehouse Integration Demo

LogiFlow 3PL to niezależny projekt demonstracyjny inspirowany typowymi procesami operatorów logistycznych 3PL. Repozytorium pokazuje przygotowanie granic technologicznych i lokalnego środowiska dla systemu integracyjnego; nie odwzorowuje rozwiązania żadnej konkretnej firmy.

## Cel

Obecny etap dostarcza wyłącznie profesjonalny szkielet monorepo. Logika zleceń, produktów, operacji magazynowych, integracji, kolejek i stanów magazynowych zostanie dodana w kolejnych etapach.

## Planowane komponenty

- ASP.NET Core Web API — warstwa integracyjna i kontrakty HTTP.
- Django — platforma administracyjna, współdzielone modele oraz konfiguracja przyszłych procesów worker i ETL.
- Flutter — aplikacja mobilna dla pracownika magazynu.
- Kontrakty OpenAPI i komunikatów — wersjonowane granice integracyjne.
- PostgreSQL, SQL Server, Nginx, Docker i Azure — przyszła infrastruktura uruchomieniowa.

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
- opcjonalnie Docker Desktop z Docker Compose do przyszłego etapu infrastruktury.

Szczegóły audytu i przygotowania środowiska znajdują się w [docs/setup/environment.md](docs/setup/environment.md).

## Uruchamianie szkieletów

### Django

```powershell
cd backend/django-platform
py -3.13 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements\dev.txt
Copy-Item ..\..\.env.example .env
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py runserver
```

Health endpoint: `GET http://127.0.0.1:8000/health/`.

Pełną walidację testów Python uruchamia pytest przez skrypt wykonywany z katalogu głównego:

```powershell
.\scripts\test-python.ps1
```

Konfiguracja `pytest.ini` obejmuje `apps`, `tests`, `worker` i `etl`. Standardowe `python manage.py test`, uruchamiane z katalogu projektu Django, pozostaje przydatne dla testów aplikacji Django, ale nie zastępuje pełnej walidacji pytest tych czterech obszarów.

### ASP.NET Core Web API

```powershell
dotnet restore backend/dotnet-api/LogiFlow.sln
dotnet build backend/dotnet-api/LogiFlow.sln
dotnet run --project backend/dotnet-api/src/LogiFlow.Integration.Api
```

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
- ASP.NET Core `net10.0`: działają procesowe endpointy `/health/live` i `/health/ready` oraz test integracyjny HTTP.
- Flutter Android: statyczny ekran startowy przechodzi analizę i test smoke.
- Docker: niewykryty w środowisku i niewymagany do uruchomienia obecnych szkieletów.
- Logika biznesowa i infrastruktura uruchomieniowa: celowo niezaimplementowane.
