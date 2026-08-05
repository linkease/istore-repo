#!/usr/bin/env bash
set -euo pipefail

source_dir="/projects/repos/tmp"
repo_root=""
dry_run=0

usage() {
    cat <<'USAGE'
Usage: scripts/import-tmp-packages.sh [options]

Import ipk/apk packages from arm64.zip and x86_64.zip into bin/packages and bin/apks.

Options:
  --source-dir DIR  Directory containing arm64.zip and x86_64.zip.
  --repo-root DIR   Repository root to receive bin/packages.
  --dry-run         Print rsync actions without copying files.
  -h, --help        Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --source-dir)
            [ "$#" -ge 2 ] || { echo "missing value for --source-dir" >&2; exit 2; }
            source_dir="$2"
            shift 2
            ;;
        --repo-root)
            [ "$#" -ge 2 ] || { echo "missing value for --repo-root" >&2; exit 2; }
            repo_root="$2"
            shift 2
            ;;
        --dry-run)
            dry_run=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "required command not found: $1" >&2
        exit 1
    }
}

require_cmd unzip
require_cmd rsync
require_cmd mktemp

if [ -z "${repo_root}" ]; then
    require_cmd git
    repo_root="$(git rev-parse --show-toplevel)"
fi

source_dir="$(cd "${source_dir}" && pwd)"
repo_root="$(cd "${repo_root}" && pwd)"

arm_zip="${source_dir}/arm64.zip"
x86_zip="${source_dir}/x86_64.zip"

[ -f "${arm_zip}" ] || { echo "missing archive: ${arm_zip}" >&2; exit 1; }
[ -f "${x86_zip}" ] || { echo "missing archive: ${x86_zip}" >&2; exit 1; }

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

extract_archive() {
    local archive="$1"
    local target="$2"

    mkdir -p "${target}"
    unzip -q "${archive}" -d "${target}"
}

sync_dir() {
    local src="$1"
    local dest="$2"
    local label="$3"
    local -a rsync_args=(-a --ignore-existing --itemize-changes)

    if [ "${dry_run}" -eq 1 ]; then
        rsync_args+=(--dry-run)
    fi

    if [ ! -d "${src}" ]; then
        echo "skip ${label}: source directory not found: ${src}"
        return
    fi

    mkdir -p "${dest}"
    echo "sync ${label}: ${src}/ -> ${dest}/"
    rsync "${rsync_args[@]}" "${src}/" "${dest}/"
}

merge_luci_dir() {
    local src="$1"
    local dest="$2"
    local label="$3"

    if [ ! -d "${src}" ]; then
        echo "skip ${label}: source directory not found: ${src}"
        return
    fi

    mkdir -p "${dest}"
    while IFS= read -r -d '' file; do
        local rel="${file#"${src}/"}"
        local target="${dest}/${rel}"

        if [ -e "${target}" ]; then
            if ! cmp -s "${file}" "${target}"; then
                echo "conflicting luci package content: ${rel}" >&2
                echo "  existing: ${target}" >&2
                echo "  incoming: ${file}" >&2
                exit 1
            fi
            continue
        fi

        mkdir -p "$(dirname "${target}")"
        cp -p "${file}" "${target}"
    done < <(find "${src}" -type f -print0)
}

arm_dir="${tmpdir}/arm64"
x86_dir="${tmpdir}/x86_64"

extract_archive "${arm_zip}" "${arm_dir}"
extract_archive "${x86_zip}" "${x86_dir}"

all_luci_dir="${tmpdir}/all_nas_luci"
merge_luci_dir "${arm_dir}/ipk/nas_luci" "${all_luci_dir}" "arm64 luci all"
merge_luci_dir "${x86_dir}/ipk/nas_luci" "${all_luci_dir}" "x86_64 luci all"

all_apk_luci_dir="${tmpdir}/all_apk_nas_luci"
merge_luci_dir "${arm_dir}/apk/nas_luci" "${all_apk_luci_dir}" "arm64 apk luci all"
merge_luci_dir "${x86_dir}/apk/nas_luci" "${all_apk_luci_dir}" "x86_64 apk luci all"

sync_dir "${all_luci_dir}" "${repo_root}/bin/packages/all/nas_luci" "luci all"
sync_dir "${arm_dir}/ipk/nas" "${repo_root}/bin/packages/aarch64_cortex-a53/nas" "arm64 nas"
sync_dir "${x86_dir}/ipk/nas" "${repo_root}/bin/packages/x86_64/nas" "x86_64 nas"

sync_dir "${all_apk_luci_dir}" "${repo_root}/bin/apks/all/nas_luci" "apk luci all"
sync_dir "${arm_dir}/apk/nas" "${repo_root}/bin/apks/aarch64_generic/nas" "arm64 apk nas"
sync_dir "${x86_dir}/apk/nas" "${repo_root}/bin/apks/x86_64/nas" "x86_64 apk nas"
