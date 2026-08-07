# Changelog

## 0.2.1 - 2026-08-07

- Fixed false `EFI application not found` and missing systemd-boot entry reports when the ESP is intentionally root-only.
- `--doctor` now reports privileged checks as `INFO` and returns `PARTIAL` when run without enough ESP permissions.
- `--status` now reports privileged ESP checks as `unknown` instead of `NOT FOUND`.
- Documentation now recommends `sudo omen-shutdown --doctor` for complete diagnostics.
- No change to the tested UEFI shutdown path or one-shot boot logic.

## 0.2.0 - 2026-08-07

- Added `omen-shutdown --doctor` read-only diagnostics.
- Added `omen-shutdown --cancel` to clear pending one-shot/BootNext state.
- Added automatic rollback of pending one-shot state if the Linux reboot request fails.
- Added stronger Secure Boot detection using efivars as a fallback.
- Improved desktop integration and portability diagnostics.
- Added English and Spanish documentation.
- Added GitHub CI and issue templates.
- Documented the distinction between the field-tested systemd-boot backend and the still broader-testing-needed `efibootmgr` backend.

## 0.1.0 - 2026-08-07

- Initial UEFI `ResetSystem(EfiResetShutdown)` application.
- systemd-boot one-shot backend.
- `efibootmgr` / `BootNext` backend.
- Source installer, uninstaller and desktop launcher.
