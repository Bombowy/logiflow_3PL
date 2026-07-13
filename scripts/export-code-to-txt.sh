#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "${script_dir}/.." && pwd -P)"
output_path="${repository_root}/logiflow-code.txt"

usage() {
    printf 'Użycie / Usage: %s [--output <ścieżka / path>]\n' "$0"
}

while (($# > 0)); do
    case "$1" in
        --output)
            if (($# < 2)) || [[ -z "$2" ]]; then
                printf 'Błąd: --output wymaga ścieżki. / Error: --output requires a path.\n' >&2
                exit 2
            fi
            if [[ "$2" = /* ]]; then
                output_path="$2"
            else
                output_path="${repository_root}/$2"
            fi
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Nieznany argument / Unknown argument: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

output_path="$(realpath -m -- "$output_path")"
mkdir -p -- "$(dirname -- "$output_path")"

# Zamroź listę kandydatów przed utworzeniem pliku wynikowego w repozytorium.
# Freeze the candidate list before creating an output file inside the repository.
candidate_list="$(mktemp --tmpdir 'logiflow-code-candidates.XXXXXX')"
temporary_output=''
cleanup() {
    rm -f -- "$candidate_list"
    if [[ -n "$temporary_output" ]]; then
        rm -f -- "$temporary_output"
    fi
}
trap cleanup EXIT INT TERM HUP
git -C "$repository_root" ls-files --cached --others --exclude-standard -z |
    LC_ALL=C sort -zu >"$candidate_list"

temporary_output="$(mktemp --tmpdir="$(dirname -- "$output_path")" '.logiflow-code.XXXXXX')"

branch="$(git -C "$repository_root" branch --show-current)"
commit_hash="$(git -C "$repository_root" rev-parse HEAD)"
generated_at="$(date --iso-8601=seconds)"
included_count=0
skipped_count=0

{
    printf 'LogiFlow 3PL — Warehouse Integration Demo\n'
    printf 'Eksport kodu do przeglądu / Code review export\n'
    printf 'Utworzono / Generated: %s\n' "$generated_at"
    printf 'Katalog / Repository: %s\n' "$repository_root"
    printf 'Gałąź / Branch: %s\n' "${branch:-DETACHED HEAD}"
    printf 'Commit: %s\n\n' "$commit_hash"
} >"$temporary_output"

should_skip_path() {
    local path="$1" name extension
    name="${path##*/}"
    extension="${name##*.}"
    extension="${extension,,}"

    # Pomijaj sekrety i artefakty nawet przy niepełnym .gitignore.
    # Skip secrets and artifacts even when .gitignore is incomplete.
    [[ "$name" == '.env' ]] && return 0
    [[ "$name" == .env.* && "$name" != *.example ]] && return 0
    [[ "$name" == 'local.properties' || "$name" == 'key.properties' ]] && return 0
    [[ "$path" =~ (^|/)(secrets?|credentials?|\.venv|venv|bin|obj|cache|caches|__pycache__|\.pytest_cache|\.ruff_cache|\.mypy_cache|logs?|artifacts/local)(/|$) ]] && return 0
    [[ "$extension" =~ ^(pem|key|pfx|p12|jks|keystore|cer|crt|db|sqlite|sqlite3|mdb|accdb|log)$ ]] && return 0
    [[ "$name" == 'logiflow-code.txt' || "$name" == 'raport_z_polecenia.txt' ]] && return 0
    [[ "$name" == .logiflow-code.* || "$name" == .logiflow-code.txt.* || "$name" == logiflow-code.txt.tmp* ]] && return 0
    [[ "$path" =~ (^|/)(reports?|raporty)(/|$) ]] && return 0
    return 1
}

# NUL rozdziela ścieżki, więc spacje i znaki specjalne pozostają bezpieczne.
# NUL-delimited paths keep spaces and special characters safe.
while IFS= read -r -d '' relative_path; do
    full_path="${repository_root}/${relative_path}"

    if [[ "$(realpath -m -- "$full_path")" == "$output_path" ]] ||
        [[ ! -f "$full_path" ]] || should_skip_path "$relative_path"; then
        ((skipped_count += 1))
        continue
    fi

    # Odrzuć dane binarne i tekst, którego nie można bezpiecznie zapisać jako UTF-8.
    # Reject binary data and text that cannot be safely emitted as UTF-8.
    if [[ -s "$full_path" ]] && ! grep -Iq '' -- "$full_path"; then
        ((skipped_count += 1))
        continue
    fi
    if ! iconv -f UTF-8 -t UTF-8 -- "$full_path" >/dev/null 2>&1; then
        ((skipped_count += 1))
        continue
    fi

    {
        printf '%*s\n' 100 '' | tr ' ' '='
        printf 'PLIK / FILE: %s\n' "$relative_path"
        printf '%*s\n\n' 100 '' | tr ' ' '='
        sed '1s/^\xEF\xBB\xBF//' -- "$full_path"
        printf '\n\n'
    } >>"$temporary_output"
    ((included_count += 1))
done <"$candidate_list"

{
    printf '%*s\n' 100 '' | tr ' ' '='
    printf 'PODSUMOWANIE / SUMMARY\n'
    printf 'Dołączone pliki / Included files: %d\n' "$included_count"
    printf 'Pominięte pliki / Skipped files: %d\n' "$skipped_count"
} >>"$temporary_output"

mv -f -- "$temporary_output" "$output_path"
temporary_output=''
rm -f -- "$candidate_list"
trap - EXIT INT TERM HUP

printf 'Utworzono eksport / Export created: %s\n' "$output_path"
printf 'Dołączone pliki / Included files: %d\n' "$included_count"
printf 'Pominięte pliki / Skipped files: %d\n' "$skipped_count"
printf 'Przed udostępnieniem sprawdź eksport ręcznie. / Review the export manually before sharing.\n'
