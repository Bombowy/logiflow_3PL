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

Flutter jest cienkim klientem i komunikuje się przez REST/HTTPS wyłącznie z publiczną warstwą API/integracji w .NET. Nie ma bezpośredniego dostępu do PostgreSQL ani SQL Server.

Django Business Portal będzie server-rendered aplikacją dla pracowników i będzie korzystać z PostgreSQL. Worker komunikatów oraz ETL pozostają wewnątrz `backend/django-platform`, aby współdzielić konfigurację i przyszłe modele Django, ale będą uruchamiane jako osobne procesy. Nie należy tworzyć dla nich zduplikowanego projektu Python.

Planowany ETL prowadzi z SQL Server lub zewnętrznego WMS przez proces Python/Django Worker do PostgreSQL. Planowana komunikacja z .NET do workera będzie asynchroniczna. Obecnie połączenia te nie są zaimplementowane; działają wyłącznie szkielety oraz endpointy health.

Katalogi infrastruktury są obecnie pustymi punktami rozszerzeń. Kontenery, bazy danych, kolejki i zasoby Azure nie są jeszcze skonfigurowane.
