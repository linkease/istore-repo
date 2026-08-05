#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="${repo_root}/scripts/import-tmp-packages.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

src="${tmpdir}/tmp"
work="${tmpdir}/work"
mkdir -p "${src}/arm/ipk/nas" "${src}/arm/ipk/nas_luci" "${src}/arm/apk/nas" "${src}/arm/apk/nas_luci"
mkdir -p "${src}/x86/ipk/nas" "${src}/x86/ipk/nas_luci" "${src}/x86/apk/nas" "${src}/x86/apk/nas_luci"
mkdir -p "${work}/bin/packages/aarch64_cortex-a53/nas"
mkdir -p "${work}/bin/packages/x86_64/nas"
mkdir -p "${work}/bin/packages/all/nas_luci"
mkdir -p "${work}/bin/apks/aarch64_generic/nas"
mkdir -p "${work}/bin/apks/x86_64/nas"
mkdir -p "${work}/bin/apks/all/nas_luci"

printf 'keep-old\n' > "${work}/bin/packages/aarch64_cortex-a53/nas/existing_1_all.ipk"
printf 'keep-old-apk\n' > "${work}/bin/apks/aarch64_generic/nas/existing-1.apk"
printf 'arm-existing\n' > "${src}/arm/ipk/nas/existing_1_all.ipk"
printf 'arm-bin\n' > "${src}/arm/ipk/nas/armbin_1_aarch64_cortex-a53.ipk"
printf 'arm-common\n' > "${src}/arm/ipk/nas/common_1_all.ipk"
printf 'arm-luci\n' > "${src}/arm/ipk/nas_luci/luci-app-demo_1_all.ipk"
printf 'arm-existing-apk\n' > "${src}/arm/apk/nas/existing-1.apk"
printf 'arm-apk\n' > "${src}/arm/apk/nas/armbin-1.apk"
printf 'arm-luci-apk\n' > "${src}/arm/apk/nas_luci/luci-app-demo-1.apk"

printf 'x86-bin\n' > "${src}/x86/ipk/nas/x86bin_1_x86_64.ipk"
printf 'x86-common\n' > "${src}/x86/ipk/nas/common_1_all.ipk"
printf 'arm-luci\n' > "${src}/x86/ipk/nas_luci/luci-app-demo_1_all.ipk"
printf 'x86-apk\n' > "${src}/x86/apk/nas/x86bin-1.apk"
printf 'arm-luci-apk\n' > "${src}/x86/apk/nas_luci/luci-app-demo-1.apk"

(cd "${src}/arm" && 7z a -tzip -mx=0 "${src}/arm64.zip" . >/dev/null)
(cd "${src}/x86" && 7z a -tzip -mx=0 "${src}/x86_64.zip" . >/dev/null)

"${script}" --source-dir "${src}" --repo-root "${work}"

test "$(cat "${work}/bin/packages/aarch64_cortex-a53/nas/existing_1_all.ipk")" = "keep-old"
test "$(cat "${work}/bin/packages/aarch64_cortex-a53/nas/armbin_1_aarch64_cortex-a53.ipk")" = "arm-bin"
test "$(cat "${work}/bin/packages/aarch64_cortex-a53/nas/common_1_all.ipk")" = "arm-common"
test "$(cat "${work}/bin/packages/x86_64/nas/x86bin_1_x86_64.ipk")" = "x86-bin"
test "$(cat "${work}/bin/packages/x86_64/nas/common_1_all.ipk")" = "x86-common"
test "$(cat "${work}/bin/packages/all/nas_luci/luci-app-demo_1_all.ipk")" = "arm-luci"
test "$(cat "${work}/bin/apks/aarch64_generic/nas/existing-1.apk")" = "keep-old-apk"
test "$(cat "${work}/bin/apks/aarch64_generic/nas/armbin-1.apk")" = "arm-apk"
test "$(cat "${work}/bin/apks/x86_64/nas/x86bin-1.apk")" = "x86-apk"
test "$(cat "${work}/bin/apks/all/nas_luci/luci-app-demo-1.apk")" = "arm-luci-apk"

dry="${tmpdir}/dry"
mkdir -p "${dry}"
"${script}" --source-dir "${src}" --repo-root "${dry}" --dry-run >"${tmpdir}/dry-run.log"
test ! -e "${dry}/bin/packages/aarch64_cortex-a53/nas/armbin_1_aarch64_cortex-a53.ipk"
test ! -e "${dry}/bin/apks/aarch64_generic/nas/armbin-1.apk"

printf 'different-luci\n' > "${src}/x86/ipk/nas_luci/luci-app-demo_1_all.ipk"
(cd "${src}/x86" && 7z a -tzip -mx=0 "${src}/x86_64.zip" . >/dev/null)
if "${script}" --source-dir "${src}" --repo-root "${work}" >"${tmpdir}/conflict.log" 2>&1; then
    echo "expected conflicting luci package content to fail" >&2
    exit 1
fi
grep -q "conflicting luci package content: luci-app-demo_1_all.ipk" "${tmpdir}/conflict.log"
