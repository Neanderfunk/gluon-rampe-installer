# Plan: weitere RAMpe-Images

Stand 23.11.2026. Grundlage: `data/geraete-2025.1.json` (main 402307095,
Felder `weg`, `rampe`, `stock_teile`), die veröffentlichte Liste
`other/Gluon-Installer-RAMpe` (Stand 20261115, 86 Dateien) und die unten
genannten Quellen. Aussagen ohne Beleg sind als [abgeleitet] oder [offen]
markiert.

## Grundsatz

Eine RAMpe lohnt sich überall dort, wo heute ein OpenWrt-Zwischenimage,
eine OpenWrt-Shell, `scp` oder LuCI nötig ist, um das Gluon-sysupgrade
aufzuspielen. **Auch dann, wenn davor serielle Arbeit, ein Exploit oder ein
Bootloader-Tausch steht.** Wer die schwierige Vorarbeit geschafft hat,
profitiert davon, dass der Rest nur noch ein Upload im Browser ist: kein
`scp`, keine Shell-Befehle, eine Datei für alle Communities, und die
Vorbereitung (UBI, `fw_setenv`, Bootloader) erledigt ein Skript statt einer
Befehlsliste.

Keine RAMpe also nur, wenn

- schon der Bootloader oder die Hersteller-Firmware das Gluon-sysupgrade
  oder ein Gluon-factory direkt nimmt (es gibt keinen Zwischenschritt),
- der Weg eine Signatur prüft, die nur der Hersteller erfüllt (Cudy-RSA),
- die RAMpe technisch nicht passt (EdgeRouter X: 3-MB-Kernel-Slot).

Die Bewertungen "nein: der Weg braucht ohnehin die Konsole" bzw. "nein:
Installation über die U-Boot-Konsole" in `data/geraete-2025.1.json` folgen
diesem Grundsatz nicht und gehören neu bewertet (siehe Gruppe B).

## Gruppe A: Herstellerteile per After-Build-Hook

Der Buildhost holt die Hersteller-Firmware selbst (URL und SHA256 im Rezept
festgelegt, Ablage in einem Cache außerhalb des Repos). Ein Hook nach dem
Bau schneidet die nötigen Teile heraus und setzt das fertige Image zusammen.

| Gerät | heute in der Anleitung | Hook baut |
|---|---|---|
| TP-Link Archer C2 v1 | `dd` des U-Boot-Teils aus der TP-Link-Firmware, `cat` mit dem sysupgrade, TFTP-Recovery | `ArcherC2V1_tp_recovery.bin` mit RAMpe |
| TP-Link Archer C20 v1 | wie C2 v1 (Datei mit `up_boot`) | `ArcherC20V1_tp_recovery.bin` mit RAMpe |
| TP-Link Archer C20 v5 | erste 131584 Byte der TP-Link-Firmware + sysupgrade (Web-UI); für TFTP 196608 Nullbytes davor | `boot.bin` (Web-UI) und `tp_recovery.bin` (TFTP) mit RAMpe |
| TP-Link Archer C50 v4 | wie C20 v5 | wie C20 v5 |
| TP-Link Archer C50 v6 | wie C20 v5 | wie C20 v5 |
| ZTE MF286R | TFTP-Notweg: 8 MB Nullen vor dem initramfs | gepolstertes RAMpe-initramfs (keine Herstellerdatei) |
| D-Link M30 (zweite Partition aktiv) | OEM-Image von D-Link entschlüsseln (m32-firmware-util) | Umschalt-Image wie beim M60 [offen: Format prüfen] |

Hinweise:

- Bei den TP-Link-Geräten schreibt die Recovery in den Flash, der Router
  startet danach von dort. Die RAMpe muss deshalb als squashfs-sysupgrade
  gebaut werden, nicht als initramfs [abgeleitet].
- C20 v5 und C50 v6: Der U-Boot-Teil muss zur Region passen. Vorschlag:
  zuerst nur EU. Für den C50 v4 nennt das OpenWrt-Wiki die Hardware für alle
  Regionen gleich.
- 8 MB Flash und 64 MB RAM: Größe gegen die Flash-Partition prüfen und am
  Gerät testen, ob die RAMpe neben dem hochgeladenen sysupgrade in den RAM
  passt.
- Alternative für eine einzelne Community: derselbe Hook im eigenen
  Firmware-Bau, mit dem Community-sysupgrade statt der RAMpe. Dann entfällt
  der RAMpe-Schritt ganz.
- Rechtlich offen: Weitergabe von Bootloader-Binärdateien der Hersteller.
  TP-Links U-Boot steht unter GPL, die Quellen stellt TP-Link bereit.

## Gruppe B: rein serieller Weg, RAMpe statt OpenWrt-initramfs

Hier ist nichts vom Hersteller nötig. Die serielle Vorarbeit bleibt, die
RAMpe ersetzt das OpenWrt-initramfs im TFTP-Schritt und das `sysupgrade`
per `scp`.

| Gerät | Target | Besonderheit |
|---|---|---|
| Acer Predator Connect W6, W6d, Connect Vero W6m | mediatek-filogic | Datei `predator.bin` |
| Adtran SDG-8612, -8614, -8622, -8632 | mediatek-filogic | Datei `openwrt.4xx` |
| TP-Link Archer AX80 v1 | mediatek-filogic | `fw_setenv` vor dem sysupgrade per Vorbereitungsskript |
| TP-Link EAP683 LR, UR | mediatek-filogic | heute "nein", neu bewerten |
| TP-Link RE6000XD | mediatek-filogic | Gehäuse öffnen, UART unbestückt |
| Zyxel EX5601-T0, EX5700 (Telenor) | mediatek-filogic | heute "nein", neu bewerten; Datei `C0A80101.img` beim EX5700 |

Zusammen 13 Geräte. Kosten: Bauzeit der initramfs-Images für filogic.

## Gruppe C: Vorbereitungsskript mit Bootloader-Tausch

Muster wie heute bei der FRITZ!Box 7530 (die RAMpe schreibt den
OpenWrt-U-Boot vor dem sysupgrade). Die Bootloader-Dateien (`preloader.bin`,
`bl31-uboot.fip`) kommen von OpenWrt, nicht vom Hersteller. Die RAMpe
braucht dafür beschreibbare Bootloader-Partitionen (`kmod-mtd-rw` oder eine
DTS-Änderung im RAMpe-Bau).

| Gerät | Weg bis zur RAMpe |
|---|---|
| Linksys E8450 (UBI) | Stock-Web-UI nimmt ein `initramfs-recovery.itb` |
| TP-Link TL-XDR4288, -6086, -6088, TL-XTR8488 | Shell-Zugang zur Stock-Firmware [offen: ob die TFTP-Recovery ohne vorherigen Tausch bootet] |
| Netcore N60 | ssh/telnet in die Stock-Firmware |
| JDCloud RE-CP-03 | Migrations-Firmware eines Dritten |
| Xiaomi AX3000T, Redmi AX6000 (je OpenWrt-U-Boot-Layout) | Exploit, dann RAMpe als `initramfs-factory.ubi` |
| Xiaomi Redmi AX6000 (Stock-Layout) | Exploit, RAMpe als `initramfs-factory.ubi` |
| Zyxel EX5601-T0, WX5600-T0 (OpenWrt-U-Boot-Layout) | Zyxel-U-Boot startet ein initramfs per TFTP |
| Bananapi BPI-R3 mini | Stock-Shell |
| Mercusys MR90X v1 (UBI) | wie MR90X v1; EEPROM und MAC liest das Skript aus `tp_data` des Geräts selbst |

Zusammen etwa 14 Geräte. Vorbild bei OpenWrt: der UBI-Installer für die
E8450 (dangowrt) macht genau das. Risiko: Bootloader-Schreiben; jedes Gerät
braucht einen eigenen Hardware-Test, bevor eine Anleitung es anbietet.

## Gruppe D: Vorbereitung ohne Datei an vorhandenen RAMpen

| Gerät | fehlt der RAMpe heute |
|---|---|
| ZTE MF289F | `ubirmvol` vor dem sysupgrade |
| Ocedo Panda | `ubirmvol` und `fw_setenv` |
| Sophos RED 15w Rev.1 | `ubiformat` |
| ZTE MF281 | factory statt sysupgrade per `mtd write` |

## Schon mit RAMpe, kein neues Image

- Aruba Instant On AP11 (AP11D, AP17): Die Anleitung spielt seriell den
  älteren APBoot 2.5.0.2 auf (Datei stellen wir bereit) und startet danach
  die RAMpe des AP-303. Der Bootloader-Schritt muss im APBoot passieren,
  weil der neuere APBoot kein `bootm` mehr hat; ein Hook bringt hier nichts
  zusätzlich.
- Aruba AP-32x: RAMpe (`.ari`) gibt es; der gepatchte APBoot bleibt ein
  serieller Schritt.

## Bleibt ohne RAMpe

- Ubiquiti EdgeRouter X / X-SFP: Kernel 6.6 passt nicht in den
  3-MB-Kernel-Slot von EdgeOS.
- Arcadyan VGV7510KW22: `board_config` ist je Gerät verschieden und der
  Bootloader-Tausch passiert vor jedem Linux [offen: ob ein Skript sie aus
  dem Gerät lesen kann].
- Cudy mit Signaturprüfung: Cudys eigene Zwischenfirmware ist schon ein
  OpenWrt mit Upload.

## Umsetzung

1. `devices/<gerät>.sh` bekommt eine optionale Funktion, die `build.sh`
   nach dem Bau aufruft (Gruppe A).
2. Herstellerdateien: URL und SHA256 im Rezept, Cache auf dem Buildhost;
   fehlt die Datei oder stimmt die Prüfsumme nicht, bricht nur dieses Gerät
   ab.
3. Prüfungen im Hook: Größe gegen die Flash-Partition; Ergebnis Byte für
   Byte gleich mit dem, was die heutige Anleitung von Hand erzeugt (mit der
   RAMpe statt des sysupgrade als Eingabe).
4. LISTE.txt bekommt eigene Arten, z. B. "TP-Link-Recovery (dauerhaft)".
5. Vorbereitungsskripte (Gruppen C und D) nach dem Muster der vorhandenen
   (`overlay/lib/gluon-rampe/prepare`), mit Prüfung des Geräts vor jedem
   Schreibzugriff.
6. Reihenfolge: A (TP-Link, EU) und B zuerst, dann D, dann C Gerät für
   Gerät mit Hardware-Test.

## Zahlen

| Gruppe | Geräte |
|---|---|
| A Herstellerteile per Hook | 7 (5 TP-Link, MF286R, M30-Umschaltung) |
| B serieller Weg | 13 |
| C Bootloader-Tausch per Skript | etwa 14 |
| D Vorbereitung an vorhandenen RAMpen | 4 (keine neuen Images) |

## Quellen

- OpenWrt-Wiki Linksys E8450: https://openwrt.org/toh/linksys/e8450
- UBI-Installer E8450: https://github.com/dangowrt/owrt-ubi-installer
- APBoot AP11 (bootm entfernt): https://lists.openwrt.org/pipermail/openwrt-devel/2023-November/041835.html
- OpenWrt-Forum AP11: https://forum.openwrt.org/t/aruba-iap-11-apboot-downgrade-invalid-instant-small-business-image/120921
- OpenWrt-Wiki Archer C50: https://openwrt.org/toh/tp-link/archer-c50
- OpenWrt-Forum Archer C50 v4: https://forum.openwrt.org/t/support-for-archer-c50-v4/20174/17
