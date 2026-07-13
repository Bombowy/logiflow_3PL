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
docker compose --env-file "$env_file" -f "$compose_file" down
