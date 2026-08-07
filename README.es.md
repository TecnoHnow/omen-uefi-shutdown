# OMEN UEFI Shutdown

Workaround para Linux destinado a equipos que aparentan apagarse correctamente pero quedan eléctricamente activos, calientes o siguen consumiendo batería después del apagado.

En lugar de depender del apagado ACPI normal de Linux, el proyecto reinicia **una sola vez** hacia una pequeña aplicación UEFI x86_64 que llama directamente a:

```text
ResetSystem(EfiResetShutdown)
```

La entrada normal del sistema operativo sigue siendo la predeterminada. La aplicación de apagado UEFI se selecciona únicamente para el próximo arranque.

> **Importante:** esto es un workaround, no una reparación del firmware. Está pensado para máquinas donde ya se comprobó que el apagado Linux normal deja consumo residual. No todos los problemas de apagado tienen la misma causa.

## Configuración conocida que funciona

El backend de systemd-boot fue probado en una HP OMEN 16 con Pop!_OS 24.04 y Secure Boot desactivado. En ese caso, el `poweroff` normal de Linux dejaba la notebook caliente y consumiendo batería, mientras que el camino UEFI produjo un apagado frío/completo.

El backend `efibootmgr`/`BootNext` está implementado para GRUB, rEFInd y otros cargadores, pero todavía necesita pruebas reales en más firmwares y distribuciones.

## Requisitos

- Linux x86_64
- Arranque en modo UEFI
- `efivarfs` disponible
- EFI System Partition (ESP) montada
- Secure Boot desactivado en v0.2.1 (la aplicación EFI todavía no está firmada)
- GNU-EFI + GCC/binutils para compilar
- Uno de estos mecanismos:
  - `systemd-boot` activo, o
  - `efibootmgr` para usar `BootNext`

## Instalación

```bash
./build.sh
sudo ./install.sh
```

El instalador también puede compilar automáticamente si todavía no existe `build/omen-shutdown.efi`.

Si no detecta la ESP:

```bash
sudo ESP=/boot/efi ./install.sh
```

Dependencias de compilación habituales:

```text
Debian / Ubuntu / Pop!_OS : build-essential binutils gnu-efi
Arch / Manjaro            : base-devel binutils gnu-efi
Fedora / RHEL              : gcc binutils gnu-efi o gnu-efi-devel
openSUSE                    : gcc binutils gnu-efi
```

En instalaciones sin systemd-boot también necesitás `efibootmgr`.

## Comprobación antes del primer apagado

```bash
sudo omen-shutdown --doctor
omen-shutdown --status
```

`--doctor` es solamente lectura: no modifica el arranque. Si la ESP sólo puede ser leída por root, ejecutar `--doctor` o `--status` sin `sudo` muestra esas comprobaciones como no verificadas en vez de informar falsamente que faltan archivos.

## Uso

```bash
sudo omen-shutdown
```

También se instala un lanzador gráfico llamado **Apagado completo OMEN** cuando `pkexec` está disponible.

## Secuencia

```text
Linux
  │
  ├─ sincroniza discos
  ├─ prepara systemd-boot one-shot O UEFI BootNext
  └─ reinicia
       │
       ▼
aplicación UEFI
       │
       └─ ResetSystem(EfiResetShutdown)
              │
              ▼
        apagado del firmware
```

Con systemd-boot, `bootctl set-oneshot` selecciona la entrada sólo para el próximo arranque. Con el backend de firmware, `efibootmgr -n` configura `BootNext`, que también se usa una sola vez.

## Seguridad añadida en v0.2.1

- No cambia permanentemente el sistema operativo predeterminado.
- Se niega a preparar una aplicación EFI sin firma si detecta Secure Boot activo.
- `sudo omen-shutdown --cancel` elimina una solicitud one-shot/BootNext pendiente.
- Si falla el comando de reinicio después de preparar el one-shot, intenta cancelarlo automáticamente.
- El desinstalador limpia cualquier one-shot/BootNext pendiente.
- `omen-shutdown --doctor` genera un diagnóstico para reportar fallas sin modificar nada.

## Cancelar una solicitud pendiente

```bash
sudo omen-shutdown --cancel
```

## Logs

```bash
journalctl -t omen-uefi-shutdown
```

## Desinstalación

Desde la carpeta descomprimida:

```bash
sudo ./uninstall.sh
```

## Estado del proyecto

- **systemd-boot:** probado en una máquina real
- **efibootmgr / BootNext:** implementado, necesita más pruebas en hardware real
- **UEFI x86_64:** soportado
- **ARM64:** todavía no
- **Secure Boot:** todavía no

Para reportar compatibilidad, incluir la salida de:

```bash
sudo omen-shutdown --doctor
```

## Licencia

MIT. Ver [LICENSE](LICENSE).
