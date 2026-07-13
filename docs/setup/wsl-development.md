# Development Linux-first w WSL

Backend .NET i Django rozwijamy w VS Code uruchomionym przez rozszerzenie WSL. Repozytorium WSL przechowuj pod `/home`, aby uniknąć narzutu i różnic semantyki systemu plików `/mnt`.

Klon Windows i klon WSL są osobne. Synchronizuj je przez zwykły przepływ Git; repozytorium nie zapewnia automatycznej synchronizacji plików roboczych. Eksport do `pliki_z_linuksa` jest artefaktem przeglądowym, nie mechanizmem synchronizacji klonów.

Nie współdziel `.venv` między systemami. W WSL wybierz w VS Code `backend/django-platform/.venv/bin/python`; w Windows wybierz interpreter z windowsowego `.venv`. Ustawienia repozytorium zachowują pytest i formatowanie, ale nie wymuszają ścieżki interpretera.

Docker Desktop dostarcza Engine przez integrację WSL 2. Nie instaluj drugiego Docker Engine w Ubuntu. Flutter i Android SDK pozostają obsługiwane w Windows.

Polecenie `docker` w WSL powinno wskazywać `/usr/bin/docker`, czyli oficjalny Linux ELF CLI udostępniany przez Docker Desktop. Nie używaj `docker.exe`, lokalnych wrapperów ani adapterów. Stan integracji sprawdzisz przez `readlink -f "$(command -v docker)"`, `file` oraz `docker version`.

Walidacja backendu:

```bash
./scripts/test-python.sh
./scripts/test-dotnet.sh
```
