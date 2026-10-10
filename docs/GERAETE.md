# Geräte

## Wann lohnt der Installer?

Immer dann, wenn Gluon für ein Gerät **kein factory-Image** hat und der Weg
über ein OpenWrt-Zwischenimage führt, das der Hersteller-Weg (Web-UI,
Recovery-Seite, Rescue-Tool) annimmt. Der Installer ersetzt genau dieses
Zwischenimage – statt OpenWrt/LuCI kommt eine Gluon-Seite mit einem Upload.

Nicht nötig, wenn schon der Bootloader oder die Hersteller-Firmware das
Gluon-sysupgrade direkt nimmt (z.B. GL.iNet-U-Boot-Web, Cudys eigene
OpenWrt-Zwischenfirmware).

## Im Zweifel mitbauen

Ist unklar, ob Gluons eigenes factory-Image auf einem Gerät überhaupt
brauchbar ist (Beispiel MikroTik hAP ac2: Gluons "factory" ist dort selbst ein
initramfs, und ein Gluon-initramfs startet ohne `91_installer_initramfs` nie
im Config-Mode), wird das Installer-Image für dieses Gerät mitgebaut
(adorfer 10.10.2026). Ein Installer-Image zu viel kostet nur Bauzeit.

Vollständiges Inventar aller Gluon-2025.1-Geräte mit Weg ab Werk,
Übertragung, Konsole, Links und Installer-Eignung: router-werkstatt
`docs/erstinstallation-2025.1.md`.

## Stand

| Gerät | Target | Weg | Stand |
|---|---|---|---|
| D-Link AQUILA PRO AI M30 A1 | mediatek-filogic | D-Link-Recovery 192.168.200.1, `-recovery.bin` | gebaut, Inhalt geprüft, **Hardware-Test offen** |
| x86-64 | x86-64 | QEMU `-kernel` | Testgerät, Ende-zu-Ende grün |

## Kandidaten (alle ungeprüft)

Aus Gluon v2025.1.3, `factory = false`, und der jeweiligen OpenWrt-Wiki-Seite
zu prüfen. Reihenfolge nach Nutzen.

| Gerät | Target | vermuteter Weg | Anmerkung |
|---|---|---|---|
| D-Link AQUILA PRO AI M60 A1 | mediatek-filogic | wie M30 | Gluon hat dort (noch) ein recovery-Image – vermutlich derselbe initramfs-Config-Mode-Fehler wie bei der M30 |
| D-Link COVR-X1860 A1 | ramips-mt7621 | D-Link-Recovery | Gluon baut `-recovery`; prüfen, ob es ein initramfs ist |
| Ubiquiti EdgeRouter X / X-SFP | ramips-mt7621 | EdgeOS-Upgrade (tar) | oszilloskops Ursprung; braucht ein EdgeOS-taugliches Image statt `-recovery` |
| ASUS RT-AX52, TUF-AX4200, TUF-AX6000, RT-AX53U | mediatek-filogic / ramips-mt7621 | ASUS-Web-UI oder Firmware Restoration nimmt OpenWrt-initramfs | typischer „erst initramfs, dann sysupgrade“-Fall |
| TP-Link-Geräte mit `-tftp-recovery` | ramips-mt76x8 | TFTP | Installer statt OpenWrt-initramfs: bringt nur die Gluon-Seite, spart kein TFTP |
| Ubiquiti UniFi 6 Lite/Plus/LR | div. | SSH + initramfs | kein Weg über eine Web-UI, Nutzen gering |

Nicht Kandidat, soweit bekannt:
- Cudy: Die Web-UI nimmt nur von Cudy signierte Images an. Cudys eigene
  OpenWrt-Zwischenfirmware ist schon der Zwischenschritt.
- GL.iNet: Die U-Boot-Web-UI nimmt das sysupgrade direkt.
- Xiaomi: Der Weg führt über einen Exploit, einen Hersteller-Upload gibt es nicht.
- AVM: EVA per FTP mit eigenem Werkzeug.
- Linksys E8450 (UBI): Der OpenWrt-Installer muss das Flash auf UBI umbauen,
  und genau das kann dieser Installer nicht.

## Ein Gerät ergänzen

1. OpenWrt-Wiki/Geräteseite: welches Image nimmt der Hersteller-Weg?
   Meist `…-initramfs-kernel.bin`, `…-squashfs-recovery.bin` oder ein
   `…-initramfs-factory.*`. Auf ein **initramfs** ist der Installer
   ausgelegt (`91_installer_initramfs`). Nimmt der Hersteller-Weg nur
   squashfs, ist es ohnehin ein Fall für ein normales Gluon-factory-Image.
2. `devices/<gluon-geraetename>.sh` anlegen (Name = erster Parameter von
   `device(...)` in `gluon/targets/<target>`):

   ```sh
   # <Gerät>: <Weg in einem Satz>
   ensure_target_config <target> TARGET_ROOTFS_INITRAMFS
   ensure_extra_image  <target> <gluon-geraet> -squashfs-recovery -recovery .bin
   ```

   `ensure_extra_image` nur, wenn Gluon das Hersteller-Image nicht ohnehin
   einsammelt. Gluon legt es unter `output/images/other/` ab, `build.sh`
   kopiert es nach `out/`.
3. `./build.sh <target> <gluon-geraet>` (bzw. per `contrib/docker/run.sh`).
4. Prüfen, bevor es an Hardware geht:
   - Das Image enthält ein initramfs mit `lib/preinit/91_installer_initramfs`
     (`binwalk`/`unsquashfs` bzw. cpio im Kernel).
   - Bei Hersteller-Headern (z.B. D-Link `DLK6E6110001`): Header wie beim
     OpenWrt-Image.
5. Hardware-Test: Installer einspielen → 192.168.1.1 zeigt die Upload-Seite →
   Community-sysupgrade hochladen → Router bootet in deren Config-Mode.
   Ergebnis in die Tabelle oben.
