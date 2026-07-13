# ADR 0001: Development backendu Linux-first

- Status: zaakceptowane
- Data: 2026-07-13

## Decyzja

Backend Django i .NET rozwijamy w VS Code WSL, w osobnym klonie pod `/home`. Flutter pozostaje w środowisku Windows. Klony synchronizuje Git; nie współdzielimy `.venv` ani plików roboczych automatycznie.

Docker Desktop udostępnia Engine przez WSL 2. Nie instalujemy drugiego Engine w Ubuntu.

## Konsekwencje

Skrypty Bash są podstawową automatyzacją backendu w WSL, a istniejące skrypty PowerShell pozostają dostępne w Windows. Każdy system utrzymuje własne zależności i interpreter Python.
