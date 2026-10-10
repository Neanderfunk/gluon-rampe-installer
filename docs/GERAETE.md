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

Abgeglichen mit dem Inventar aller Gluon-2025.1-Geräte (router-werkstatt
`docs/erstinstallation-2025.1.md`, Stand 10.10.2026; dort je Gerät Weg,
Übertragung, Konsole, Links und Quelle). Nichts davon auf Hardware getestet.

### Passt (Ramboot ohne Öffnen, danach Upload)

| Gerät | Target | Hersteller-Weg | Format/Bedingung | RAM |
|---|---|---|---|---|
| D-Link M60 A1 | mediatek-filogic | D-Link-Recovery 192.168.200.1 | D-Link-Header wie M30; Gluons eigenes `-recovery.bin` vermutlich mit dem Config-Mode-Fehler | 512 MB |
| ASUS RT-AX52 | mediatek-filogic | Web-UI 192.168.50.1 | `initramfs.trx` (OpenWrt-ARTIFACT) einsammeln | 256 MB |
| ASUS RT-AX53U | ramips-mt7621 | ASUS-Rescue, TFTP-Server im Gerät 192.168.1.1 | initramfs | 256 MB |
| Genexis Pulse EX400 | ramips-mt7621 | Web-UI / Recovery 192.168.1.1 | OpenWrt-factory ist initramfs mit Inteno-Header; Gluon setzt `factory = false` nur wegen des initramfs-Schalters. Bester neuer Kandidat | 256 MB |
| Zyxel WSM20 | ramips-mt7621 | versteckte Upgrade-Seite | initramfs mit znet-Header; Zyxel-Cloud-Registrierung nötig | 256 MB |
| MikroTik hAP ac2, wAP ac, SXTsq 5 ac, DISC | ipq40xx-mikrotik | Netboot (eigener BOOTP/DHCP- und TFTP-Server) | initramfs; Gluons "factory" ist selbst ein initramfs ohne Config-Mode, daher mitbauen | 128-256 MB |
| MikroTik hAP (951Ui-2nD), mAP lite, wAP, wAP G-5HacT2HnD | ath79-mikrotik | Netboot | wie oben | 64 MB, knapp |
| MikroTik RB750Gr3 | ramips-mt7621 | Netboot | ELF-initramfs | 256 MB |
| AVM FRITZ!Box 3390, 7362 SL, 7412, 7430 | lantiq-xrx200 | `eva_ramboot.py` (FTP 192.168.178.1) | initramfs lzma-komprimiert | 128 MB |
| Netgear WAX218 | qualcommax-ipq807x | Web-UI | `web-ui-factory.fit` (ARTIFACT); Gluon baut für qualcommax kein initramfs | 512 MB |
| OCEDO Koala, Raccoon | ath79-generic | Reset beim Einschalten, Gerät holt per TFTP von 192.168.100.8 | zusätzlich `fw_setenv bootcmd run bootcmd_1` nötig | 128 MB |
| ZTE MF286R | ath79-nand | Exploit im Web-UI, initramfs per `nandwrite` | Weg für die MF286A belegt | 128 MB |
| ASUS Lyra (MAP-AC2200) | ipq40xx-generic | SSH, initramfs per `mtd-write` | | 256 MB |

### Teilweise (Installer ersetzt nur das Zwischenimage)

- **Seriell + TFTP, Konsole außen (Gehäuse bleibt zu):** Enterasys
  WS-AP3705i, WS-AP3710i, WS-AP3715i; Extreme WS-AP3825i, WS-AP3805i,
  WS-AP3915i, AP3935; Siemens WS-AP3610 (initramfs unkomprimiert); Aerohive
  HiveAP 330 (RJ45 mit RS232-Pegel). Der Installer ersetzt "scp + sysupgrade",
  `bootcmd`/`saveenv` bleiben seriell.
- **Seriell, Gehäuse auf:** Sophos AP15, Archer D50, DIR-505, Aerohive
  HiveAP 121, ZTE MF281, Cudy TR3000 v1, TP-Link EAP620 HD.
- **Vorbereitender Schritt fehlt dem Installer:** Aruba AP-303/303H/365/AP11D/AP17
  und Instant On AP11 (`ubiformat`; AP11 zusätzlich apboot-Entsperrung, K5);
  AVM 7520/7530/Repeater 1200/3000 (U-Boot schreiben, `ubirmvol`); ZTE MF289F
  (`ubirmvol`); OCEDO Panda und Sophos RED 15w (`ubirmvol`/`ubiformat`,
  `fw_setenv`). Ein Installer bräuchte je Gerät ein Vorbereitungsskript.
- **Exploit bleibt:** Xiaomi AX3000T, AX3600 (`initramfs-factory.ubi`),
  Mercusys MR90X, ASUS TUF-AX4200/AX6000, ASUS RT-AX59U (kein `initramfs.trx`
  in OpenWrt).
- **Bootloader tauschen:** Aruba AP-32x (Format `.ari`).

### Nicht Kandidat

- **D-Link COVR-X1860:** Gluon baut factory und ein eigenes recovery (squashfs).
- **Ubiquiti EdgeRouter X / X-SFP:** Der 6.6-Kernel passt nicht in den
  3-MB-Kernel-Slot von EdgeOS, OpenWrt 24.10.8 baut kein factory.tar mehr.
  oszilloskops Ursprungsfall ist unter 2025.1 kein Fall für den Installer,
  dafür gibt es die ERX-Migration (router-werkstatt `docs/erx-migration-howto.md`).
- **Cudy:** Stock und Recovery prüfen Cudys Signatur; die Cudy-Zwischenfirmware
  ist schon der Zwischenschritt.
- **GL.iNet, Open-Mesh/Plasma Cloud, devolo, Sophos AP55/100, UniFi, Wavlink,
  AVM mit EVA-Image:** Der Hersteller- oder Bootloader-Weg nimmt das
  Gluon-Image direkt (Kategorie K1d im Inventar).
- **TP-Link mit `-tftp-recovery`/`-bootloader.bin` (mt76x8):** installiert
  Gluon direkt über die TFTP-Recovery.
- **Linksys E8450 (UBI), Xiaomi AX3000T im OpenWrt-U-Boot-Layout:**
  Bootloader-Tausch, das kann der Installer nicht.
- **Meraki MR33, Google WiFi:** Bootloader bzw. Signatur.

### Wahrscheinlich besser in Gluon zu lösen

Linksys MR8300, Netgear WNDR3700 v5, Archer C60 v1 und MikroTik mAP lite/wAP ac
haben `factory = false` ohne erkennbaren Grund, obwohl OpenWrt (teils) ein
brauchbares factory baut.

### Für jedes Rezept zu beachten

Gluon schaltet `TARGET_ROOTFS_INITRAMFS` nur für mediatek-filogic und
ipq40xx-mikrotik ein; ipq40xx-generic, ipq806x, qualcommax und mt7622 brauchen
`ensure_target_config`. Viele Hersteller-Wege wollen ein verpacktes initramfs
(ASUS-TRX, D-Link-Header, Netgear `web-ui-factory.fit`, Xiaomi
`initramfs-factory.ubi`, Aruba `.ari`, Inteno-Header), das OpenWrt als
IMAGES/ARTIFACTS baut. Ob Gluons `extra_images` die ARTIFACTS einsammelt, ist
offen.

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
