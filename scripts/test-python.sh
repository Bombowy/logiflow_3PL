#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "${script_dir}/.." && pwd -P)"
django_root="${repository_root}/backend/django-platform"
python="${django_root}/.venv/bin/python"

[[ -x "$python" ]] || { printf 'Brak interpretera / Missing interpreter: %s\n' "$python" >&2; exit 1; }

export DATABASE_URL=''
"$python" "${django_root}/manage.py" check
(cd -- "$django_root" && "$python" -m pytest -c pytest.ini)
"$python" -m ruff check "$django_root"
