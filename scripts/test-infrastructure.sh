#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "${script_dir}/.." && pwd -P)"
django_root="${repository_root}/backend/django-platform"
env_file="${repository_root}/.env.docker"
compose_file="${repository_root}/compose.yaml"
python="${django_root}/.venv/bin/python"

command -v docker >/dev/null || { printf 'Brak Docker CLI / Docker CLI is unavailable.\n' >&2; exit 1; }
docker info >/dev/null 2>&1 || { printf 'Docker Engine jest niedostępny / Docker Engine is unavailable.\n' >&2; exit 1; }
[[ -s "$env_file" ]] || { printf 'Brak pliku / Missing file: %s\n' "$env_file" >&2; exit 1; }
[[ -f "$compose_file" ]] || { printf 'Brak pliku / Missing file: %s\n' "$compose_file" >&2; exit 1; }
compose=(docker compose --env-file "$env_file" -f "$compose_file")
for service in postgres sqlserver; do
    container_id="$("${compose[@]}" ps -q "$service")"
    [[ -n "$container_id" ]] || { printf 'Usługa nie działa / Service is not running: %s\n' "$service" >&2; exit 1; }
    [[ "$(docker inspect --format '{{.State.Health.Status}}' "$container_id")" == 'healthy' ]] || {
        printf 'Usługa nie jest healthy / Service is not healthy: %s\n' "$service" >&2
        exit 1
    }
done

"${compose[@]}" exec -T postgres sh -c 'psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1;"'
"${compose[@]}" exec -T sqlserver sh -c '/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" -b'

"$python" "${django_root}/manage.py" check
database_backend="$("$python" "${django_root}/manage.py" shell --no-imports -c 'from django.db import connection; print(connection.vendor)')"
[[ "$database_backend" == 'postgresql' ]] || { printf 'Django nie używa PostgreSQL / Django is not using PostgreSQL.\n' >&2; exit 1; }
"$python" "${django_root}/manage.py" shell --no-imports -c 'from django.db import connection; c=connection.cursor(); c.execute("SELECT 1"); assert c.fetchone()[0] == 1'
"$python" "${django_root}/manage.py" migrate --check
printf 'Testy infrastruktury przeszły / Infrastructure tests passed.\n'
