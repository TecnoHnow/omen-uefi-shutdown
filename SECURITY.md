# Security

OMEN UEFI Shutdown writes an EFI application to the EFI System Partition and, depending on the backend, writes a one-shot boot variable or a dedicated firmware boot entry.

The project deliberately does not automate Secure Boot key enrollment in v0.2.1.

If you find a vulnerability that could alter permanent boot order unexpectedly, execute arbitrary code as root, or damage EFI variables, please avoid publishing exploit details until a fix is available. Use a private security report on the project hosting platform once the repository is published.
