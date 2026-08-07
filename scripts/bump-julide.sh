#!/usr/bin/env bash
#
# Point the julide cask at the newest published JulIde release.
#
# Idempotent: exits 0 without touching anything if the cask is already current.
# Needs `gh` (authenticated) and `curl`. Run from the tap root.
#
# Deliberately portable to bash 3.2 and a BSD userland so it runs on macOS runners as
# well as Linux: no associative arrays, no `sed -i`, no `sha256sum`. Braced variables
# throughout because `brew style` shellchecks this file with the optional rules on.
set -euo pipefail

REPO="Julideorg/JulIde"
CASK="Casks/julide.rb"

[[ -f "${CASK}" ]] || {
  echo "run me from the tap root (${CASK} not found)" >&2
  exit 1
}

emit() {
  [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "${1}" >>"${GITHUB_OUTPUT}"
  return 0
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${1}" | cut -d' ' -f1
  else
    shasum -a 256 "${1}" | cut -d' ' -f1
  fi
}

# /releases/latest skips drafts and prereleases, which is what we want: JulIde's
# release workflow creates drafts, and only a published stable release should ship.
tag=$(gh api "repos/${REPO}/releases/latest" --jq .tag_name)
version="${tag#v}"
current=$(sed -nE 's/^ *version "([^"]+)".*/\1/p' "${CASK}")

emit "version=${version}"

if [[ "${version}" == "${current}" ]]; then
  echo "julide cask already at ${current}"
  emit "bumped=false"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "${tmp}"' EXIT

# ${1} is the architecture as it appears in the asset name.
download_sha() {
  local asset="julide_${version}_${1}.dmg"
  # -f on purpose: a missing asset means the release is still uploading or the naming
  # changed, and that should be a loud failure rather than a silently skipped bump.
  curl -fsSL --retry 3 -o "${tmp}/${asset}" \
    "https://github.com/${REPO}/releases/download/${tag}/${asset}"
  sha256_of "${tmp}/${asset}"
}

sha_arm=$(download_sha aarch64)
sha_intel=$(download_sha x64)

sed -E \
  -e "s|^( *version ).*|\1\"${version}\"|" \
  -e "s|^( *sha256 arm: *).*|\1\"${sha_arm}\",|" \
  -e "s|^( *intel: *).*|\1\"${sha_intel}\"|" \
  "${CASK}" >"${tmp}/julide.rb"
mv "${tmp}/julide.rb" "${CASK}"

echo "bumped julide ${current} -> ${version}"
emit "bumped=true"
