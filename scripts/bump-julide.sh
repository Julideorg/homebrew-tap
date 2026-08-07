#!/usr/bin/env bash
#
# Point the julide cask at the newest published JulIde release.
#
# Idempotent: exits 0 without touching anything if the cask is already current.
# Needs `gh` (authenticated) and `curl`. Run from the tap root.
set -euo pipefail

REPO="Julideorg/JulIde"
CASK="Casks/julide.rb"

[[ -f "$CASK" ]] || { echo "run me from the tap root ($CASK not found)" >&2; exit 1; }

# /releases/latest skips drafts and prereleases, which is what we want: JulIde's
# release workflow creates drafts, and only a published stable release should ship.
tag=$(gh api "repos/$REPO/releases/latest" --jq .tag_name)
version="${tag#v}"
current=$(sed -nE 's/^ *version "([^"]+)".*/\1/p' "$CASK")

emit() { [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "$1" >>"$GITHUB_OUTPUT"; return 0; }

if [[ "$version" == "$current" ]]; then
  echo "julide cask already at $current"
  emit "bumped=false"
  emit "version=$current"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

declare -A sha
for a in aarch64 x64; do
  asset="julide_${version}_${a}.dmg"
  # -f on purpose: a missing asset means the release is still uploading or the naming
  # changed, and that should be a loud failure rather than a silently skipped bump.
  curl -fsSL --retry 3 -o "$tmp/$asset" \
    "https://github.com/$REPO/releases/download/$tag/$asset"
  sha[$a]=$(sha256sum "$tmp/$asset" | cut -d' ' -f1)
done

sed -i -E "s|^( *version ).*|\1\"$version\"|" "$CASK"
sed -i -E "s|^( *sha256 arm: *).*|\1\"${sha[aarch64]}\",|" "$CASK"
sed -i -E "s|^( *intel: *).*|\1\"${sha[x64]}\"|" "$CASK"

echo "bumped julide $current -> $version"
emit "bumped=true"
emit "version=$version"
