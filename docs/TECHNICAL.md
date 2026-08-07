# Technical design

## Why reboot before shutdown?

The Linux runtime cannot directly execute a PE/COFF UEFI application as firmware code. OMEN UEFI Shutdown therefore makes the application the next boot target and asks Linux to reboot normally.

The UEFI application then calls the firmware runtime service:

```c
ResetSystem(EfiResetShutdown, EFI_SUCCESS, 0, NULL)
```

A successful call does not return.

## Backend 1: systemd-boot

The installer creates a Boot Loader Specification Type #1 entry:

```text
title OMEN UEFI Shutdown
efi /EFI/omen-uefi-shutdown/omen-shutdown.efi
```

At shutdown time:

```text
bootctl set-oneshot omen-shutdown.conf
```

This leaves the persistent/default OS selection unchanged.

## Backend 2: firmware BootNext

For systems not currently booted by systemd-boot, the installer creates a dedicated UEFI `Boot####` entry pointing at the EFI application. Runtime then sets only:

```text
BootNext=Boot####
```

using `efibootmgr -n`.

The installer tries to use `efibootmgr --create-only` where supported. On older versions it saves and restores `BootOrder` after creating the entry.

## Failure handling

If arming succeeds but Linux fails to request a reboot, the runtime script attempts to clear the pending one-shot so a later unrelated reboot will not unexpectedly enter the shutdown application.

The explicit recovery command is:

```bash
sudo omen-shutdown --cancel
```
