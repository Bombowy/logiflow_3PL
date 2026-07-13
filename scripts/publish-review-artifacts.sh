#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "${script_dir}/.." && pwd -P)"
default_destination='/mnt/f/Projekty/LogiFlow_3PL/pliki_z_linuksa'
destination_dir="${LOGIFLOW_WINDOWS_EXPORT_DIR:-$default_destination}"
windows_clone_root='/mnt/f/Projekty/LogiFlow_3PL'

if [[ ! -d /mnt/f ]]; then
    printf 'Błąd: /mnt/f nie jest dostępne. / Error: /mnt/f is unavailable.\n' >&2
    exit 1
fi

destination_parent="$(dirname -- "$destination_dir")"
if [[ ! -d "$destination_parent" || ! -w "$destination_parent" ]]; then
    printf 'Błąd: katalog nadrzędny nie istnieje lub nie jest zapisywalny: %s\n' "$destination_parent" >&2
    printf 'Error: destination parent is missing or not writable: %s\n' "$destination_parent" >&2
    exit 1
fi
mkdir -p -- "$destination_dir"
if [[ ! -w "$destination_dir" ]]; then
    printf 'Błąd: katalog docelowy nie jest zapisywalny / Error: destination is not writable: %s\n' "$destination_dir" >&2
    exit 1
fi

"${script_dir}/export-code-to-txt.sh" >/dev/null

code_export="${repository_root}/logiflow-code.txt"
task_report="${repository_root}/raport_z_polecenia.txt"
if [[ ! -s "$code_export" ]]; then
    printf 'Błąd: brak eksportu kodu lub plik jest pusty. / Error: code export is missing or empty.\n' >&2
    exit 1
fi
if [[ ! -s "$task_report" ]]; then
    printf 'Błąd: raport_z_polecenia.txt nie istnieje lub jest pusty.\n' >&2
    printf 'Error: raport_z_polecenia.txt is missing or empty.\n' >&2
    exit 1
fi

publish_file() {
    local source_path="$1" file_name="$2" target_path temporary_target source_hash target_hash size
    target_path="${destination_dir}/${file_name}"
    temporary_target="$(mktemp --tmpdir="$destination_dir" ".${file_name}.XXXXXX")"
    trap 'rm -f -- "$temporary_target"' RETURN
    cp -- "$source_path" "$temporary_target"
    mv -f -- "$temporary_target" "$target_path"
    trap - RETURN

    source_hash="$(sha256sum -- "$source_path" | cut -d ' ' -f 1)"
    target_hash="$(sha256sum -- "$target_path" | cut -d ' ' -f 1)"
    if [[ "$source_hash" != "$target_hash" ]]; then
        printf 'Błąd: niezgodna suma SHA-256 dla %s. / Error: SHA-256 mismatch for %s.\n' "$file_name" "$file_name" >&2
        exit 1
    fi
    size="$(stat -c '%s' -- "$target_path")"
    printf '%s | %s | %s B | SHA-256: zgodna / verified\n' "$file_name" "$target_path" "$size"
}

publish_file "$code_export" 'logiflow-code.txt'
publish_file "$task_report" 'raport_z_polecenia.txt'

# Lokalna reguła dotyczy wyłącznie metadanych Windowsowego klonu Git.
# The local rule only touches the Windows Git clone metadata.
windows_exclude="${windows_clone_root}/.git/info/exclude"
if [[ -f "$windows_exclude" ]] && ! grep -Fqx '/pliki_z_linuksa/' "$windows_exclude"; then
    printf '\n/pliki_z_linuksa/\n' >>"$windows_exclude"
fi
