# OMEN UEFI Shutdown

A Linux workaround for machines that appear to power off normally but remain electrically active, warm, or continue draining the battery after shutdown.

Instead of relying on the normal Linux ACPI poweroff path, this project reboots **once** into a tiny x86_64 UEFI application that calls:

```text
ResetSystem(EfiResetShutdown)
```

The normal OS boot entry remains the default. The UEFI shutdown application is selected only for the next boot.

> **Important:** this is a workaround, not a firmware fix. It is intended for systems where normal Linux shutdown has already been shown to leave residual power. Do not assume every shutdown problem has the same cause.

## Known working configuration

The systemd-boot backend has been field-tested on an HP OMEN 16 running Pop!_OS 24.04 with Secure Boot disabled. In that case, ordinary Linux poweroff left the laptop warm and drained the battery, while the UEFI shutdown path produced a cold/full shutdown.

The `efibootmgr`/`BootNext` backend is implemented for GRUB, rEFInd and other bootloader setups, but needs broader field testing across firmware vendors and distributions.

## Requirements

- Linux x86_64
- System booted in UEFI mode
- `efivarfs` available
- Mounted EFI System Partition (ESP)
- Secure Boot disabled in v0.2.1 (the EFI application is not signed yet)
- GNU-EFI + GCC/binutils to build from source
- Either:
  - active `systemd-boot`, or
  - `efibootmgr` for the firmware `BootNext` backend

## Install

```bash
./build.sh
sudo ./install.sh
```

The installer can also build automatically if `build/omen-shutdown.efi` does not exist.

If ESP auto-detection fails:

```bash
sudo ESP=/boot/efi ./install.sh
```

Common build dependencies:

```text
Debian / Ubuntu / Pop!_OS : build-essential binutils gnu-efi
Arch / Manjaro            : base-devel binutils gnu-efi
Fedora / RHEL              : gcc binutils gnu-efi or gnu-efi-devel
openSUSE                    : gcc binutils gnu-efi
```

For non-systemd-boot installations, also install `efibootmgr`.

## Check before the first shutdown

```bash
sudo omen-shutdown --doctor
omen-shutdown --status
```

The diagnostic command is read-only. On systems whose ESP is root-only, running `--doctor` or `--status` without `sudo` reports privileged checks as unverified instead of incorrectly calling the files missing.

## Use

CLI:

```bash
sudo omen-shutdown
```

A desktop launcher is also installed as **OMEN Full Shutdown** (Spanish locale: **Apagado completo OMEN**) when `pkexec` is available.

## What happens

```text
Linux
  │
  ├─ sync filesystems
  ├─ arm one-shot systemd-boot entry OR UEFI BootNext
  └─ reboot
       │
       ▼
UEFI application
       │
       └─ ResetSystem(EfiResetShutdown)
              │
              ▼
         firmware shutdown
```

With systemd-boot, `bootctl set-oneshot` selects the shutdown entry for the next boot only. With the firmware backend, `efibootmgr -n` sets `BootNext`, which is likewise a one-boot override.

## Safety features in v0.2.1

- Does **not** change the permanent/default OS boot entry.
- Refuses to arm an unsigned EFI app when Secure Boot is detected as enabled.
- `omen-shutdown --cancel` clears a pending one-shot/BootNext request.
- If the Linux reboot command fails after arming the one-shot, the script attempts to clear it automatically.
- The uninstaller clears pending one-shot/BootNext state before removing files.
- `omen-shutdown --doctor` provides a read-only diagnostic report for bug reports.

## Cancel a pending shutdown boot

If you arm the mechanism and decide not to reboot:

```bash
sudo omen-shutdown --cancel
```

## Logs

```bash
journalctl -t omen-uefi-shutdown
```

## Uninstall

From the extracted source directory:

```bash
sudo ./uninstall.sh
```

## Secure Boot

v0.2.1 ships source for an unsigned EFI application. Secure Boot support is planned, but automatic key creation/enrollment is deliberately not done by this release.

## Project status

- **systemd-boot backend:** field-tested
- **efibootmgr / BootNext backend:** implemented, needs more real-machine testing
- **x86_64 UEFI:** supported
- **ARM64:** not supported yet
- **Secure Boot:** not supported yet

Please include the output of `sudo omen-shutdown --doctor` when reporting compatibility problems.

## License

MIT. See [LICENSE](LICENSE).

Spanish documentation: [README.es.md](README.es.md)
