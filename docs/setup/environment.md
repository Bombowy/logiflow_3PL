# Środowisko developerskie

## Środowisko Linux-first

Backend jest rozwijany przez VS Code WSL w repozytorium pod `/home`, nie pod `/mnt`. Python WSL korzysta z `backend/django-platform/.venv/bin/python`; Windows używa własnego interpretera `.venv`. Środowisk wirtualnych nie wolno współdzielić między systemami. W VS Code wybierz interpreter poleceniem `Python: Select Interpreter`; repozytorium celowo nie wymusza ścieżki zależnej od systemu.

Docker Desktop udostępnia Engine przez WSL 2. Nie instaluj drugiego Docker Engine wewnątrz Ubuntu. Flutter pozostaje obsługiwany w Windows.

## Bieżący audyt WSL z 13 lipca 2026

| Narzędzie | Wykryta wersja | Status |
|---|---:|---|
| Python w linuxowym `.venv` | 3.13.14 | gotowe |
| .NET SDK | 10.0.301 | gotowe |
| Docker Engine | 29.6.1 | Docker Desktop przez WSL 2 |
| Docker Compose | 5.2.0 | gotowe |
| PostgreSQL / SQL Server | 17.10 / 2025 CU6 | oba healthy |

Oficjalny Linux CLI Docker Desktop jest dostępny jako `/usr/bin/docker` i rozwiązuje się do binarnego ELF x86-64 w `/mnt/wsl/docker-desktop/cli-tools/usr/bin/docker`.

## Oddzielne środowisko Windows

Ostatni audyt Windows wykrył Python 3.13.5, Flutter 3.41.9 Stable, Dart 3.11.5 i Android SDK 36.1.0. Są to wyniki klonu Windows, nie wersje interpretera używanego w WSL. Flutter i Android pozostają walidowane w Windows.

## Przygotowanie Python

WSL/Linux:

```bash
cd backend/django-platform
python3.13 -m venv .venv
./.venv/bin/python -m pip install --upgrade pip setuptools wheel
./.venv/bin/python -m pip install -r requirements/dev.txt
```

W Windows użyj `py -3.13 -m venv .venv` i `.\.venv\Scripts\python.exe`. Nie aktywuj środowiska, jeśli nie jest to potrzebne — bezpośrednia ścieżka interpretera gwarantuje użycie właściwej wersji.

### Konfiguracja Django

Django opcjonalnie odczytuje `backend/django-platform/.env`. Przykład konfiguracji można skopiować z katalogu głównego:

```bash
cp .env.example backend/django-platform/.env
```

Wariant PowerShell: `Copy-Item .env.example backend/django-platform/.env`.

`DJANGO_DEBUG` domyślnie włącza lokalny tryb developerski. Tylko w tym trybie i tylko przy braku `DJANGO_SECRET_KEY` używany jest jawny fallback `unsafe-local-development-key`. Nie nadaje się on do środowisk współdzielonych ani produkcyjnych. Ustawienie `DJANGO_DEBUG=false` bez bezpiecznego sekretu — również z wartością przykładową — zatrzymuje aplikację z czytelnym błędem konfiguracji.

Bez `DATABASE_URL` używany jest lokalny SQLite w `backend/django-platform/db.sqlite3`. Podanie `DATABASE_URL` zastępuje konfigurację domyślną; lokalny plik `.env` wskazuje na PostgreSQL uruchomiony przez Compose. Nie zapisuj `.env` w Git.

### Testy Python

Pytest jest głównym runnerem kompletnego zestawu testów Python. Konfiguracja `backend/django-platform/pytest.ini` wykrywa testy w `apps`, `tests`, `worker` oraz `etl`. Z katalogu głównego repozytorium uruchom:

```bash
./scripts/test-python.sh
```

Skrypt wykonuje kolejno Django system check, `python -m pytest` i Ruff. W Windows odpowiednikiem jest `.\scripts\test-python.ps1`. Standardowe `python manage.py test` nie zastępuje pełnej walidacji katalogów `worker`, `etl` oraz `tests`.

## .NET

Repozytorium przypina SDK 10.0.301 i przez `rollForward: latestFeature` zezwala na użycie nowszego kompatybilnego feature bandu w ramach .NET 10. Ustawienie nie pozwala przejść na inną główną wersję SDK, a `allowPrerelease` pozostaje wyłączone. SDK zainstalowano z oficjalnego źródła WinGet:

```powershell
winget install --id Microsoft.DotNet.SDK.10 --exact --source winget
```

## Flutter

Projekt mobilny używa kanału Stable i platformy Android. Stan środowiska można ponownie sprawdzić poleceniem:

```powershell
flutter doctor -v
```

## Docker

Instrukcje znajdują się w [local-infrastructure.md](local-infrastructure.md). Używane obrazy:

- `postgres:17.10-alpine3.23@sha256:8189a1f6e40904781fc9e2612687877791d21679866db58b1de996b31fc312e4`,
- `mcr.microsoft.com/mssql/server:2025-CU6-ubuntu-24.04@sha256:2cd0aec4a3bfc3cf9205bed3f7922f4c6208f7c767dc62edcee308d0fd7d56d0`.

Tagi i digesty zweryfikowano przez pobranie z oficjalnych rejestrów 13 lipca 2026. `sqlcmd` w obrazie SQL Server znajduje się pod `/opt/mssql-tools18/bin/sqlcmd`.

Logiczne nazwy wolumenów Compose są prefiksowane wartością `COMPOSE_PROJECT_NAME`; szczegóły i rzeczywiste nazwy bieżącego projektu opisuje [local-infrastructure.md](local-infrastructure.md).

## Walidacja WSL z 13 lipca 2026

| Obszar | Wynik |
|---|---|
| Python w linuxowym `.venv` | 3.13.14 |
| `manage.py check` | sukces, 0 problemów |
| `python -m pytest` | sukces, 6/6 testów kompletnego zestawu Python |
| Ruff | sukces, wszystkie kontrole przeszły |
| .NET SDK | 10.0.301 |
| `dotnet build` | sukces, 0 błędów i 0 ostrzeżeń |
| `dotnet test` | sukces, 2/2 testy integracyjne health endpointów |
| audyt podatności NuGet | brak znanych podatnych pakietów |
| Docker / Compose | Engine 29.6.1, Compose 5.2.0; obie bazy healthy |
