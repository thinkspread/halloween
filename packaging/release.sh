#!/bin/bash
# Copyright (c) 2026 Jiejing Zhang.
#
# Build, sign and package a release:
#
#   SIGN_ID=<Developer ID Application SHA-1> packaging/release.sh 0.1.0
#
# It does not notarize and never sees a password; it prints the command you
# run yourself.  The tarball is what Homebrew downloads; the zip is what
# notarytool accepts (it refuses tar.gz).  Signing rewrites the binary, so
# both are packed after signing, and the signature is checked on the copy
# unpacked from the tarball, not on the file that was packed.
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="${1:?usage: release.sh <version>   e.g. 0.1.0}"
SIGN_ID="${SIGN_ID:?set SIGN_ID=<Developer ID Application certificate SHA-1>   # security find-identity -v -p codesigning}"

grep -q "let version = \"$VERSION\"" Sources/halloween/main.swift ||
  { echo "Sources/halloween/main.swift does not say version $VERSION"; exit 1; }

swift test
BIN="$(swift build -c release --show-bin-path)/halloween"
rm -f "$BIN"                         # force a link, never a stale binary
swift build -c release
codesign --force --options runtime --timestamp -s "$SIGN_ID" "$BIN"

OUT=dist/halloween-$VERSION
rm -rf dist && mkdir -p "$OUT"
cp "$BIN" README.md README.zh-CN.md LICENSE NOTICE "$OUT/"
TAR=dist/halloween-$VERSION-macos-arm64.tar.gz
ZIP=dist/halloween-$VERSION-macos-arm64.zip
tar -C dist -czf "$TAR" "halloween-$VERSION"
ditto -c -k --keepParent "$OUT/halloween" "$ZIP"

CHECK=$(mktemp -d)
tar -C "$CHECK" -xzf "$TAR"
codesign --verify --strict --verbose=2 "$CHECK/halloween-$VERSION/halloween"
"$CHECK/halloween-$VERSION/halloween" --version | grep -q "halloween $VERSION"
rm -rf "$CHECK"

echo
echo "sha256 (for the formula): $(shasum -a 256 "$TAR" | cut -d' ' -f1)"
echo "notarize:  xcrun notarytool submit $ZIP --keychain-profile thinkspread --wait"
