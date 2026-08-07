#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT_DIR/src/omen-shutdown.c"
BUILD="$ROOT_DIR/build"
OUT="$BUILD/omen-shutdown.efi"

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "Missing '$1'."; }

[[ "$(uname -m)" == "x86_64" ]] || fail "This release supports x86_64 only."
[[ -f "$SRC" ]] || fail "Source not found: $SRC"

for c in gcc ld objcopy objdump find; do need "$c"; done
[[ -d /usr/include/efi ]] || fail "GNU-EFI headers not found in /usr/include/efi. Install gnu-efi."

find_one() {
    local name="$1" p
    for base in /usr/lib /usr/lib64 /usr/lib32 /lib /lib64; do
        [[ -d "$base" ]] || continue
        p="$(find "$base" -maxdepth 5 -type f -name "$name" -print -quit 2>/dev/null || true)"
        if [[ -n "$p" ]]; then printf '%s\n' "$p"; return 0; fi
    done
    return 1
}

CRT0="$(find_one crt0-efi-x86_64.o || true)"
LDS="$(find_one elf_x86_64_efi.lds || true)"
LIBEFI="$(find_one libefi.a || true)"
LIBGNUEFI="$(find_one libgnuefi.a || true)"

[[ -n "$CRT0" ]] || fail "crt0-efi-x86_64.o not found (GNU-EFI)."
[[ -n "$LDS" ]] || fail "elf_x86_64_efi.lds not found (GNU-EFI)."
[[ -n "$LIBEFI" ]] || fail "libefi.a not found (GNU-EFI)."
[[ -n "$LIBGNUEFI" ]] || fail "libgnuefi.a not found (GNU-EFI)."

LIBDIR="$(dirname "$LIBEFI")"
mkdir -p "$BUILD"
rm -f "$BUILD/omen-shutdown.o" "$BUILD/omen-shutdown.so" "$OUT"

printf 'Building UEFI application...\n'
gcc \
  -I/usr/include/efi \
  -I/usr/include/efi/x86_64 \
  -I/usr/include/efi/protocol \
  -DEFI_FUNCTION_WRAPPER \
  -fpic \
  -ffreestanding \
  -fno-stack-protector \
  -fshort-wchar \
  -mno-red-zone \
  -c "$SRC" \
  -o "$BUILD/omen-shutdown.o"

ld \
  -nostdlib \
  -znocombreloc \
  -T "$LDS" \
  -shared \
  -Bsymbolic \
  "$CRT0" \
  "$BUILD/omen-shutdown.o" \
  -L"$LIBDIR" \
  -lefi \
  -lgnuefi \
  -o "$BUILD/omen-shutdown.so"

objcopy \
  -j .text \
  -j .sdata \
  -j .data \
  -j .dynamic \
  -j .dynsym \
  -j .rel \
  -j .rela \
  -j .reloc \
  --target=efi-app-x86_64 \
  "$BUILD/omen-shutdown.so" \
  "$OUT"

if ! objdump -p "$OUT" 2>/dev/null | grep -qi 'EFI application'; then
    fail "The resulting binary was not recognized as an EFI application."
fi

printf '\nOK: %s\n' "$OUT"
file "$OUT" 2>/dev/null || true
