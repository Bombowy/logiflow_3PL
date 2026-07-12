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

## Uproszczony przepływ

```text
[Systemy klientów]
        |
        v
[.NET Integration API] <----> [Kontrakty]
        |
        v
[Django Platform] <----> [Worker / ETL jako osobne procesy]
        |
        v
[Bazy danych] <--------> [Flutter Warehouse App]
```

Diagram przedstawia planowany kierunek rozwoju, a nie zaimplementowane połączenia.

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
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py runserver
```

### ASP.NET Core Web API

```powershell
dotnet restore backend/dotnet-api/LogiFlow.sln
dotnet build backend/dotnet-api/LogiFlow.sln
dotnet run --project backend/dotnet-api/src/LogiFlow.Integration.Api
```

### Flutter

```powershell
cd mobile/warehouse-app
flutter pub get
flutter analyze
flutter test
flutter run
```

## Status

- Django 6.0: utworzony, system check i test runner działają.
- ASP.NET Core `net10.0`: rozwiązanie buduje się, test xUnit przechodzi.
- Flutter Android: projekt analizuje się bez problemów, test widgetu przechodzi.
- Docker: niewykryty w środowisku i niewymagany do uruchomienia obecnych szkieletów.
- Logika biznesowa i infrastruktura uruchomieniowa: celowo niezaimplementowane.
