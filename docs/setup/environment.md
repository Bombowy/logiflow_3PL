# Środowisko developerskie

## Audyt z 12 lipca 2026

| Narzędzie | Wykryta wersja | Status |
|---|---:|---|
| Git | 2.51.0.windows.1 | gotowe |
| WinGet | 1.29.280 | gotowe |
| Python Launcher | Python 3.13.5 i 3.10.11 | gotowe |
| Python projektu | 3.13.5 | gotowe |
| .NET SDK | 10.0.301 | zainstalowane podczas konfiguracji |
| Flutter | 3.41.9 Stable | gotowe |
| Dart | 3.11.5 | gotowe |
| Android SDK | 36.1.0 | gotowe |
| VS Code | 1.127.0 | gotowe |
| Docker / Compose | niewykryte | opcjonalna ręczna instalacja w przyszłym etapie |

Polecenie `python` wskazuje globalnie Python 3.10.11. Projekt nie korzysta z tego aliasu: środowisko utworzono przez `py -3.13`, a polecenia wykonuje się przez `.venv\Scripts\python.exe`.

`flutter doctor -v` nie zgłosił problemów. Wykryto Android toolchain, zaakceptowane licencje, podłączone urządzenie Android oraz dostępny emulator toolchain.

## Przygotowanie Python

```powershell
cd backend/django-platform
py -3.13 -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip setuptools wheel
.\.venv\Scripts\python.exe -m pip install -r requirements\dev.txt
```

Nie aktywuj środowiska, jeśli nie jest to potrzebne — bezpośrednia ścieżka interpretera gwarantuje użycie właściwej wersji.

## .NET

Repozytorium przypina SDK 10.0.301 i zezwala na zgodne aktualizacje poprawkowe przez `rollForward: latestPatch`. SDK zainstalowano z oficjalnego źródła WinGet:

```powershell
winget install --id Microsoft.DotNet.SDK.10 --exact --source winget
```

## Flutter

Projekt mobilny używa kanału Stable i platformy Android. Stan środowiska można ponownie sprawdzić poleceniem:

```powershell
flutter doctor -v
```

## Docker

Docker nie jest wymagany na obecnym etapie. Przed dodaniem kontenerów należy zainstalować oficjalny Docker Desktop, zweryfikować `docker version` i `docker compose version`, a następnie udokumentować przyjęty tryb WSL 2 lub Hyper-V.

## Walidacja końcowa z 12 lipca 2026

| Obszar | Wynik |
|---|---|
| Python systemowy przez `py -3.13` | 3.13.5 |
| Python w `.venv` | 3.13.5 |
| `manage.py check` | sukces, 0 problemów |
| `manage.py test` | sukces, 0 testów w pustym szkielecie |
| Ruff | sukces, wszystkie kontrole przeszły |
| .NET SDK | 10.0.301 |
| `dotnet build` | sukces, 0 błędów i 0 ostrzeżeń |
| `dotnet test` | sukces, 1/1 |
| audyt podatności NuGet | brak znanych podatnych pakietów |
| `flutter analyze` | sukces, brak problemów |
| `flutter test` z katalogu aplikacji | sukces, 1/1 |
| Docker / Compose | polecenia niedostępne |

Polecenie `flutter test mobile/warehouse-app` uruchomione z katalogu repozytorium zwraca kod 1, ponieważ Flutter wymaga, aby katalog roboczy zawierał `pubspec.yaml`. Równoważna walidacja wykonana po `Set-Location mobile/warehouse-app` przechodzi poprawnie.

Instalacja .NET została wykryta natychmiast; ponowne uruchomienie terminala ani VS Code nie było potrzebne.
