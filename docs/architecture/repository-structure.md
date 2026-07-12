# Struktura repozytorium

```text
backend/
  dotnet-api/          ASP.NET Core API i testy xUnit
  django-platform/     Django, przyszły worker i ETL
mobile/
  warehouse-app/       aplikacja Flutter dla Androida
contracts/
  openapi/             przyszłe kontrakty HTTP
  messages/            przyszłe schematy komunikatów
infrastructure/
  docker/              przyszła orkiestracja lokalna
  postgres/            przyszła konfiguracja PostgreSQL
  sqlserver/           przyszła konfiguracja SQL Server
  nginx/               przyszła konfiguracja proxy
  azure/               przyszłe zasoby chmurowe
docs/
  adr/                 Architecture Decision Records
  architecture/        dokumentacja architektury
  setup/               instrukcje środowiskowe
scripts/               przenośna automatyzacja PowerShell
```

## Granice komponentów

.NET, Django i Flutter są niezależnymi jednostkami budowania. Nie współdzielą kodu źródłowego ani zależności; przyszła komunikacja ma używać jawnych kontraktów z katalogu `contracts`.

Worker kolejki i ETL pozostają wewnątrz `backend/django-platform`, aby współdzielić konfigurację i przyszłe modele Django, ale będą uruchamiane jako osobne procesy. Nie należy tworzyć dla nich zduplikowanego projektu Python.

Katalogi infrastruktury są obecnie pustymi punktami rozszerzeń. Kontenery, bazy danych, kolejki i zasoby Azure nie są jeszcze skonfigurowane.
