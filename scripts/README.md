# Skrypty / Scripts

Ten katalog zawiera przenośne skrypty Bash i PowerShell automatyzujące pracę lokalną.
This directory contains portable Bash and PowerShell scripts supporting local development.

## Eksport kodu / Code export

Skrypt `export-code-to-txt.ps1` łączy tekstowe pliki projektu w jeden dokument ułatwiający zewnętrzny przegląd kodu.
The `export-code-to-txt.ps1` script combines project text files into one document for external code review.

Uruchomienie z katalogu głównego repozytorium:
Run from the repository root:

```powershell
.\scripts\export-code-to-txt.ps1
```

Domyślnym wynikiem jest `logiflow-code.txt` w katalogu głównym. Własną ścieżkę można wskazać parametrem `-OutputPath`:
The default output is `logiflow-code.txt` in the repository root. Use `-OutputPath` to select another location:

```powershell
.\scripts\export-code-to-txt.ps1 -OutputPath "artifacts\local\code-review.txt"
```

Skrypt respektuje `.gitignore` oraz pomija typowe pliki sekretów i formaty binarne.
The script respects `.gitignore` and skips common secret files and binary formats.

Przed udostępnieniem zawsze ręcznie sprawdź wygenerowany plik pod kątem danych wrażliwych.
Always review the generated file manually for sensitive data before sharing it.

## Eksport kodu w Linux/WSL / Linux/WSL code export

Skrypt `export-code-to-txt.sh` jest linuxowym odpowiednikiem eksportu PowerShell. Zbiera śledzone oraz nieignorowane pliki nieśledzone, filtruje pliki binarne i typowe dane wrażliwe, a wynik zapisuje domyślnie jako `logiflow-code.txt` w katalogu głównym repozytorium.
The `export-code-to-txt.sh` script is the Linux equivalent of the PowerShell export. It collects tracked and non-ignored untracked files, filters binary files and common sensitive data, and writes `logiflow-code.txt` in the repository root by default.

```bash
./scripts/export-code-to-txt.sh
./scripts/export-code-to-txt.sh --output artifacts/local/code-review.txt
```

Ścieżka względna przekazana przez `--output` jest liczona od katalogu głównego repozytorium. Skrypt można uruchomić z dowolnego katalogu.
A relative path passed with `--output` is resolved from the repository root. The script can be run from any directory.

Test regresyjny uruchamia eksport dwukrotnie i sprawdza stabilność liczby sekcji, pojedynczy nagłówek oraz brak plików wynikowych i tymczasowych w eksporcie:
The regression test runs the export twice and verifies a stable section count, a single header, and the absence of output and temporary files in the export:

```bash
./scripts/test-review-artifacts.sh
```

## Publikowanie artefaktów do Windows / Publishing artifacts to Windows

Przed publikacją utwórz niepusty plik `raport_z_polecenia.txt` w katalogu głównym repozytorium. Następnie uruchom:
Create a non-empty `raport_z_polecenia.txt` in the repository root before publishing. Then run:

```bash
./scripts/publish-review-artifacts.sh
```

Skrypt ponownie generuje eksport kodu i kopiuje oba pliki do `/mnt/f/Projekty/LogiFlow_3PL/pliki_z_linuksa`. Docelowy katalog można zmienić zmienną `LOGIFLOW_WINDOWS_EXPORT_DIR`:
The script regenerates the code export and copies both files to `/mnt/f/Projekty/LogiFlow_3PL/pliki_z_linuksa`. Override the destination with `LOGIFLOW_WINDOWS_EXPORT_DIR`:

```bash
LOGIFLOW_WINDOWS_EXPORT_DIR=/mnt/f/inny-katalog ./scripts/publish-review-artifacts.sh
```

Starsze pliki są zastępowane atomowo, a zgodność źródła i celu jest sprawdzana sumą SHA-256.
Older files are atomically replaced, and source-to-destination equality is verified with SHA-256.

Filtry ograniczają ryzyko ujawnienia danych wrażliwych, ale przed publicznym udostępnieniem zawsze ręcznie sprawdź eksport.
Filters reduce the risk of exposing sensitive data, but always inspect the export manually before sharing it publicly.

## Walidacja Python / Python validation

W WSL uruchom `./scripts/test-python.sh`. Skrypt wymusza pusty `DATABASE_URL`, aby system check, pytest i Ruff działały szybko i izolowanie na SQLite.
In WSL run `./scripts/test-python.sh`. It forces an empty `DATABASE_URL` so the system check, pytest, and Ruff run quickly and independently on SQLite.

Walidację .NET w WSL wykonuje `./scripts/test-dotnet.sh`: restore, build z ostrzeżeniami traktowanymi jak błędy, testy i audyt podatności NuGet.
Use `./scripts/test-dotnet.sh` for .NET validation in WSL: restore, build with warnings as errors, tests, and a NuGet vulnerability audit.

## Infrastruktura lokalna / Local infrastructure

Skrypty wymagają lokalnego `.env.docker` utworzonego na podstawie `.env.docker.example` i działają niezależnie od bieżącego katalogu:
The scripts require a local `.env.docker` created from `.env.docker.example` and work independently of the current directory:

```bash
./scripts/infrastructure-up.sh
./scripts/infrastructure-status.sh
./scripts/test-infrastructure.sh
./scripts/infrastructure-down.sh
```

Każdy skrypt sprawdza Linux Docker CLI, Engine, `.env.docker` i `compose.yaml`. `infrastructure-up.sh` uruchamia bazy i czeka do pięciu minut na `healthy`. `test-infrastructure.sh` testuje obie bazy i połączenie Django z PostgreSQL. `infrastructure-down.sh` zatrzymuje usługi bez usuwania named volumes.
Each script checks the Linux Docker CLI, Engine, `.env.docker`, and `compose.yaml`. `infrastructure-up.sh` starts the databases and waits up to five minutes for `healthy`. `test-infrastructure.sh` tests both databases and Django's PostgreSQL connection. `infrastructure-down.sh` stops services without deleting named volumes.

Skrypt `test-python.ps1` uruchamia pełną walidację części Python: Django system check, kompletny zestaw testów pytest oraz Ruff. Przerywa pracę po pierwszym błędzie.
The `test-python.ps1` script runs the complete Python validation suite: Django system check, all pytest tests, and Ruff. It stops after the first failure.

Uruchomienie z katalogu głównego repozytorium:
Run from the repository root:

```powershell
.\scripts\test-python.ps1
```

Skrypt sam ustala katalog repozytorium i używa interpretera `backend/django-platform/.venv/Scripts/python.exe`, dlatego działa również po wywołaniu z innego katalogu.
The script resolves the repository root itself and uses `backend/django-platform/.venv/Scripts/python.exe`, so it also works when invoked from another directory.
