# Lokalna infrastruktura baz danych

Konfiguracja jest przeznaczona wyłącznie do developmentu. Compose uruchamia PostgreSQL jako główną bazę Django i SQL Server jako symulację zewnętrznego WMS/ERP; nie uruchamia kontenerów aplikacyjnych.

## Obrazy

- PostgreSQL: `postgres:17.10-alpine3.23@sha256:8189a1f6e40904781fc9e2612687877791d21679866db58b1de996b31fc312e4`.
- SQL Server: `mcr.microsoft.com/mssql/server:2025-CU6-ubuntu-24.04@sha256:2cd0aec4a3bfc3cf9205bed3f7922f4c6208f7c767dc62edcee308d0fd7d56d0`.
- `sqlcmd`: `/opt/mssql-tools18/bin/sqlcmd`.

Tagi, digesty i lokalizację narzędzia zweryfikowano na rzeczywistych obrazach z oficjalnych rejestrów 13 lipca 2026.

## Konfiguracja i obsługa

```bash
cp .env.docker.example .env.docker
# Zastąp oba przykładowe hasła losowymi, silnymi wartościami.
docker compose --env-file .env.docker config --quiet
./scripts/infrastructure-up.sh
./scripts/infrastructure-status.sh
./scripts/test-infrastructure.sh
./scripts/infrastructure-down.sh
```

Jeśli port hosta jest zajęty, zmień tylko odpowiednią wartość w ignorowanym `.env.docker`. Lokalny `backend/django-platform/.env` powinien zawierać `DATABASE_URL` zgodny z wybranym portem PostgreSQL. Nie zapisuj sekretów ani pełnych DSN w Git.

Logiczne nazwy Compose to `logiflow_postgres_data` i `logiflow_sqlserver_data`. Docker domyślnie prefiksuje je wartością `COMPOSE_PROJECT_NAME`; dla przykładowego `logiflow3pl` rzeczywiste nazwy to `logiflow3pl_logiflow_postgres_data` i `logiflow3pl_logiflow_sqlserver_data`. Nie zmieniaj nazwy projektu dla istniejącego środowiska, bo Compose podłączyłby inne wolumeny.

Wolumeny zachowują dane między restartami. `infrastructure-down.sh` nie usuwa wolumenów ani nie oferuje automatycznej flagi kasowania. Aby świadomie usunąć wszystkie lokalne dane, wykonaj `docker compose --env-file .env.docker down --volumes`; operacja jest nieodwracalna.
