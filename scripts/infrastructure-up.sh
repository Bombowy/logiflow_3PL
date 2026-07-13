#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "${script_dir}/.." && pwd -P)"
env_file="${repository_root}/.env.docker"
compose_file="${repository_root}/compose.yaml"

command -v docker >/dev/null || { printf 'Brak Docker CLI / Docker CLI is unavailable.\n' >&2; exit 1; }
docker info >/dev/null 2>&1 || { printf 'Docker Engine jest niedostępny / Docker Engine is unavailable.\n' >&2; exit 1; }
[[ -s "$env_file" ]] || { printf 'Brak pliku / Missing file: %s\n' "$env_file" >&2; exit 1; }
[[ -f "$compose_file" ]] || { printf 'Brak pliku / Missing file: %s\n' "$compose_file" >&2; exit 1; }

compose=(docker compose --env-file "$env_file" -f "$compose_file")
"${compose[@]}" config --quiet
"${compose[@]}" up -d

deadline=$((SECONDS + 300))
services=(postgres sqlserver)
while ((SECONDS < deadline)); do
    all_healthy=true
    for service in "${services[@]}"; do
        container_id="$("${compose[@]}" ps -q "$service")"
        health='missing'
        if [[ -n "$container_id" ]]; then
            health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container_id")"
        fi
        [[ "$health" == 'healthy' ]] || all_healthy=false
    done
    if [[ "$all_healthy" == true ]]; then
        printf 'PostgreSQL i SQL Server są healthy / PostgreSQL and SQL Server are healthy.\n'
        exit 0
    fi
    sleep 5
done

printf 'Bazy nie osiągnęły healthy w 5 minut / Databases did not become healthy within 5 minutes.\n' >&2
"${compose[@]}" ps >&2
"${compose[@]}" logs --tail=100 postgres sqlserver >&2
exit 1
