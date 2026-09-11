# Funktionsweise

## Was gebaut wird

Ein normales Gluon (Default v2025.1.3) mit einer Dummy-Site (`site/`): kein
Autoupdater, kein VPN, keine WLAN-Konfiguration (Radios bleiben aus),
`setup_mode.skip = false`. Pakete: `mesh-batman-adv-15` (verlangt Gluon als
Mesh-Protokoll) und `gluon-web-admin` (bringt Config-Mode und Upload-Seite).
Die Site-Werte sind Platzhalter – der Installer meshed nie.

Als **initramfs**: das Rootfs steckt im Kernel-Image und wird bei jedem Start
ins RAM entpackt. Das Image selbst liegt im Flash (Hersteller-Recovery,
-Web-UI) oder wird per TFTP/`-kernel` gestartet.

## Die vier Eingriffe (overlay/ -> openwrt/files)

1. **`lib/preinit/91_installer_initramfs`** – der wichtigste. OpenWrts
   `lib/preinit/70_initramfs_test` führt beim initramfs-Boot die Hooks
   `initramfs` aus und bricht `preinit_main` dann mit `break` ab. Gluons
   `90_setup_mode` (hängt an `preinit_main`) läuft deshalb nie: **ein Gluon als
   initramfs startet im Normalbetrieb, nicht im Config-Mode** – kein
   192.168.1.1. Die Datei hängt `setup_mode_enable` zusätzlich an den Hook
   `initramfs`. (oszilloskop löste es 2020 durch Umkopieren der rc.d-Verzeichnisse
   beim Einlesen der Datei.) Das erklärt auch, warum Gluons eigene
   recovery-Images für die D-Link M30/M60 „tot“ wirkten (Gluon #3816).
2. **`controller/gluon-config-mode/index.lua`** – ersetzt den Wizard: die
   Startseite zeigt über `admin` auf `admin/upgrade`. (oszilloskop)
3. **`controller/admin/index.lua`** – „Erweiterte Einstellungen“ nur mit
   Information und Firmware aktualisieren, ohne Fernzugang. (oszilloskop)
4. **`view/admin/upgrade.html`** – Hinweistext, Credit, und **ohne**
   „Einstellungen behalten“: fehlt `keepcfg`, ruft Gluons `upgrade.lua`
   `sysupgrade -n --ignore-minor-compat-version` auf.

Dazu `usr/share/doc/freifunk-installer/CREDITS` (Credit + MIT-Text).

## Ablauf auf dem Gerät

Installer startet → Config-Mode (192.168.1.1, DHCP) → Seite „Firmware
aktualisieren“ → Upload (Gluon prüft mit `sysupgrade -T`) → Bestätigung mit
Prüfsumme → `sysupgrade -n` → Neustart in die Community-Firmware, deren
Config-Mode wie nach einer Neuinstallation.

Die Kompatibilität prüft das sysupgrade des **Installers** (OpenWrt 24.10)
gegen das hochgeladene Image: gleiches Board, `compat_version` passend. Ein
Installer aus Gluon 2025.1 kann damit auch Community-Firmware auf Gluon 2023.2
aufspielen, solange die Kompatibilitätsversion des Geräts gleich ist.

## Geraete-Rezepte (devices/)

Pro Gerät ein kleines Skript, das in `gluon/targets/<target>` einschaltet, was
fehlt: `TARGET_ROOTFS_INITRAMFS` und das Hersteller-Image als `extra_images`.
`build.sh` setzt `targets/` vor jedem Lauf zurück.

## Test (test/qemu-x86-64.sh)

x86-64 in QEMU: Installer per `-kernel`, als Platte das factory-Image einer
beliebigen Gluon-Firmware (die Kernel-Kommandozeile bekommt deren
`root=PARTUUID`, damit `platform.sh` die Platte als Ziel findet), hochgeladen
wird das sysupgrade einer anderen Firmware. Danach von der Platte booten.
Kniffe: `/` leitet per meta-refresh weiter (Einstieg `/cgi-bin/config`), POST
braucht einen `Origin`-Header passend zum Host (gluon-web, CSRF-Schutz).
