#!/usr/bin/env bash
set -euo pipefail

CONFIG=/etc/omen-uefi-shutdown.conf
LABEL="OMEN UEFI Shutdown"

[[ $EUID -eq 0 ]] || { echo "Run: sudo ./uninstall.sh" >&2; exit 1; }

ESP=""
BOOTNUM=""
if [[ -r "$CONFIG" ]]; then
    # shellcheck disable=SC1090
    source "$CONFIG"
fi

# Clear any pending request first.
if command -v bootctl >/dev/null 2>&1; then bootctl set-oneshot "" >/dev/null 2>&1 || true; fi
if command -v efibootmgr >/dev/null 2>&1; then efibootmgr -N >/dev/null 2>&1 || true; fi

if [[ -n "${BOOTNUM:-}" ]] && command -v efibootmgr >/dev/null 2>&1; then
    if efibootmgr 2>/dev/null | grep -qi "^Boot${BOOTNUM}.*${LABEL}"; then
        efibootmgr -b "$BOOTNUM" -B >/dev/null || true
    fi
fi

if [[ -n "${ESP:-}" ]]; then
    rm -f "$ESP/loader/entries/omen-shutdown.conf"
    rm -f "$ESP/EFI/omen-uefi-shutdown/omen-shutdown.efi"
    rmdir "$ESP/EFI/omen-uefi-shutdown" 2>/dev/null || true
fi

rm -f /usr/local/sbin/omen-shutdown
rm -f /usr/share/applications/omen-uefi-shutdown.desktop
rm -f "$CONFIG"

echo "OMEN UEFI Shutdown has been uninstalled."
