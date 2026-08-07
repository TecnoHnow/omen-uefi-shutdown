# Contributing

Bug reports and hardware compatibility results are especially useful.

Before opening a bug report, run:

```bash
sudo omen-shutdown --doctor
omen-shutdown --status
```

Please include:

- distribution and version
- kernel version (`uname -r`)
- laptop/board model
- boot loader (systemd-boot, GRUB, rEFInd, other)
- firmware/UEFI version if known
- Secure Boot state
- whether normal Linux poweroff leaves heat or battery drain
- whether the UEFI shutdown path actually powers the machine off cold

Do not include serial numbers, UUIDs, personal paths or other identifiers unless they are truly needed.

For shell changes, run:

```bash
bash -n build.sh install.sh uninstall.sh omen-shutdown
```

If ShellCheck is installed:

```bash
shellcheck build.sh install.sh uninstall.sh omen-shutdown
```
