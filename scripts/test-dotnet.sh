#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "${script_dir}/.." && pwd -P)"
solution="${repository_root}/backend/dotnet-api/LogiFlow.sln"

command -v dotnet >/dev/null || { printf 'Brak dotnet / dotnet is unavailable.\n' >&2; exit 1; }
dotnet restore "$solution"
dotnet build "$solution" --no-restore --warnaserror
dotnet test "$solution" --no-build
dotnet list "$solution" package --vulnerable --include-transitive
