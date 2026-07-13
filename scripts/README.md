# Skrypty / Scripts

Ten katalog jest przeznaczony na przenośne skrypty PowerShell automatyzujące pracę lokalną.
This directory is reserved for portable PowerShell scripts supporting local development.

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

## Walidacja Python / Python validation

Skrypt `test-python.ps1` uruchamia pełną walidację części Python: Django system check, kompletny zestaw testów pytest oraz Ruff. Przerywa pracę po pierwszym błędzie.
The `test-python.ps1` script runs the complete Python validation suite: Django system check, all pytest tests, and Ruff. It stops after the first failure.

Uruchomienie z katalogu głównego repozytorium:
Run from the repository root:

```powershell
.\scripts\test-python.ps1
```

Skrypt sam ustala katalog repozytorium i używa interpretera `backend/django-platform/.venv/Scripts/python.exe`, dlatego działa również po wywołaniu z innego katalogu.
The script resolves the repository root itself and uses `backend/django-platform/.venv/Scripts/python.exe`, so it also works when invoked from another directory.
