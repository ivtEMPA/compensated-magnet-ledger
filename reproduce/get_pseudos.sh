#!/usr/bin/env bash
# Download the PseudoDojo v0.4 PBE scalar-relativistic standard norm-conserving pseudopotentials
# and check them against the files used in the original runs (reproduce/pseudo_checksums.txt).
#
#   bash reproduce/get_pseudos.sh [target_dir]      (default: ./pseudo)
#
# The tarball is unpacked in a temporary folder; only the files this repository needs, and only if both their
# sha256 and md5 match, are copied to target_dir. Files already in target_dir that match are not downloaded again.
# Exit status is non-zero if any file needed by this repository is missing or differs.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${1:-pseudo}"
URL="https://www.pseudo-dojo.org/pseudos/nc-sr-04_pbe_standard_upf.tgz"
SUMS="$HERE/pseudo_checksums.txt"
mkdir -p "$DEST"

sha256() { if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }
md5() { if command -v md5sum >/dev/null; then md5sum "$1" | cut -d' ' -f1; else md5 -q "$1"; fi; }
# matches FILE MD5 SHA256: both sums agree
matches() { [ -f "$1" ] && [ "$(sha256 "$1")" = "$3" ] && [ "$(md5 "$1")" = "$2" ]; }
rows() { grep -v '^[[:space:]]*\(#\|$\)' "$SUMS"; }

need=0
while read -r el file want_md5 zval sha; do matches "$DEST/$file" "$want_md5" "$sha" || need=1; done < <(rows)

if [ $need -ne 0 ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  echo "downloading $URL"
  if command -v curl >/dev/null; then curl -fsSL "$URL" -o "$TMP/dojo.tgz"
  else wget -q "$URL" -O "$TMP/dojo.tgz"; fi
  # refuse archives with absolute paths or '..' components before unpacking anything
  if tar tzf "$TMP/dojo.tgz" | grep -qE '^/|(^|/)\.\.(/|$)'; then
    echo "refusing to unpack: the archive contains absolute or '..' paths" >&2
    exit 1
  fi
  mkdir "$TMP/x"
  tar xzf "$TMP/dojo.tgz" -C "$TMP/x" --no-same-owner
  while read -r el file want_md5 zval sha; do
    # some tarball versions unpack into a sub-folder
    src="$(find "$TMP/x" -type f -name "$file" | head -1)"
    if [ -n "$src" ] && matches "$src" "$want_md5" "$sha"; then cp "$src" "$DEST/$file"; fi
  done < <(rows)
fi

bad=0
while read -r el file want_md5 zval sha; do
  if [ ! -f "$DEST/$file" ]; then echo "MISSING  $file"; bad=1
  elif matches "$DEST/$file" "$want_md5" "$sha"; then echo "ok       $file  sha256 $sha"
  else echo "DIFFERS  $file  got sha256 $(sha256 "$DEST/$file") md5 $(md5 "$DEST/$file")"; bad=1; fi
done < <(rows)
if [ $bad -ne 0 ]; then
  echo "ERROR: at least one pseudopotential is missing or differs from the files used in the original runs;" >&2
  echo "       files that differ in the download were not copied." >&2
  exit 1
fi
echo "all pseudopotentials match the original runs"
