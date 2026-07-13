#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "${script_dir}/.." && pwd -P)"
export_path="${repository_root}/logiflow-code.txt"

fail() {
    printf 'Błąd testu / Test failure: %s\n' "$1" >&2
    exit 1
}

for script in export-code-to-txt.sh publish-review-artifacts.sh test-review-artifacts.sh; do
    bash -n "${script_dir}/${script}"
done

run_export() {
    "${script_dir}/export-code-to-txt.sh" >/dev/null
    [[ -s "$export_path" ]] || fail 'plik eksportu nie istnieje lub jest pusty / export is missing or empty'

    if grep -q '^PLIK / FILE: \.logiflow-code\.' "$export_path"; then
        fail 'wyeksportowano plik tymczasowy / a temporary export file was included'
    fi
    if grep -q '^PLIK / FILE: logiflow-code\.txt' "$export_path"; then
        fail 'wyeksportowano plik wynikowy / the output file was included'
    fi

    local header_count
    header_count="$(grep -Fxc 'LogiFlow 3PL — Warehouse Integration Demo' "$export_path")"
    [[ "$header_count" -eq 1 ]] || fail 'nagłówek nie występuje dokładnie raz / header does not occur exactly once'
    grep -c '^PLIK / FILE: ' "$export_path"
}

first_section_count="$(run_export)"
second_section_count="$(run_export)"
[[ "$first_section_count" -eq "$second_section_count" ]] ||
    fail 'liczba sekcji zmieniła się między przebiegami / section count changed between runs'

printf 'Test eksportera zakończony powodzeniem; sekcje / Exporter test passed; sections: %s\n' "$second_section_count"
