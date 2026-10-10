# Erstinstallation Gluon 2025.1: Inventar aller Geräte

Stand 10.10.2026. Alle Geräte, die wir mit Gluon 2025.1 anbieten (Gluon
v2025.1.3 `0ad3ad5` mit gluon-patches-hardware, 22 Targets), je eine Zeile:
wie kommt Gluon ab Werk auf das Gerät, was braucht man dafür, und hilft die
Gluon-RAMpe (dieses Repo).
Zweck: Grundlage für bessere Installationsanleitungen im
gluon-firmware-selector und für die Geräteauswahl der Gluon-RAMpe. Erstellt
bei Freifunk im Neanderland (Neanderfunk); die Geräteliste ist die der
Neanderfunk-Firmware 2025.1, also Gluon v2025.1.3 plus
[gluon-patches-hardware](https://github.com/Neanderfunk/gluon-patches-hardware).

Erstellt aus Quellen, **nichts davon ist auf Hardware getestet**:
- je Gerät der OpenWrt-Commit, der es eingeführt hat (Abschnitt
  "Installation"), voller Text gelesen; dazu die Image-Rezepte
  `target/linux/*/image/*.mk` am OpenWrt-Pin `a1ea57bd050c172fdc2b851824ebd9782aafb055`
  (24.10 nach v24.10.8);
- wo der Commit schweigt: OpenWrt-Wiki/ToH, als [abgeleitet] markiert;
- Links: OpenWrt-Release 24.10.8 (Backports aus 25.12: 25.12.5, sonst
  Snapshot), gegen die `sha256sums` bzw. `profiles.json` der
  Download-Verzeichnisse abgeglichen und zum großen Teil per HTTP geprüft;
- Detail-Anleitung: vorhandene Links aus `devices_info` des
  gluon-firmware-selector (master `35130c88cf6c9f54c6b76dd582a5352ad0958217`);
  leere Zellen sind die Lücken, die wir füllen wollen.

Jede Wegbeschreibung trägt **[geprüft]** (im Commit, Makefile oder in den
Release-Daten gelesen) oder **[abgeleitet]** (Wiki, Analogie, eigener Schluss).
Erarbeitet in drei Teilen (ath79; ramips/lantiq/mpc85xx; mediatek/ipq/Rest),
deren Einzelbefunde im Anhang stehen.

## Kategorien

| Kat. | Bedeutung | Gluon-RAMpe | Stufe für Lesende (Vorschlag) |
|---|---|---|---|
| K0 | Gluon-factory direkt aus der Stock-Firmware (Web-UI-Upload) | unnötig | einfach |
| K0+ | Gluon-factory vorhanden, der Weg ist aber mehr als ein Web-UI-Upload (TFTP-Recovery, versteckte Seite, SSH-Vorbereitung, nmrpflash, ap51-flash) | unnötig | mit Werkzeug |
| K1 | ohne Öffnen: Hersteller-Recovery, Netboot oder Werkzeug bootet ein initramfs, danach sysupgrade | **passt** | mit Werkzeug |
| K1d | ohne Öffnen: Hersteller- oder Bootloader-Weg schreibt das Gluon-sysupgrade bzw. ein Gluon-Sonderimage direkt (GL.iNet-U-Boot, EVA, ap51-flash, SSH/dd, Exploit) | unnötig | mit Werkzeug |
| K2 | Hersteller-Zwischenfirmware, Exploit oder Spezialweg mit fremdem Zwischenimage (Cudy-Zwischenfirmware, Xiaomi, ASUS TUF, AVM 75x0) | teilweise | fortgeschritten |
| K3 | Teile der Stock-Firmware nötig (per dd voran-/angehängt), modifiziertes OpenWrt oder Layout-Umbau (UBI, ERX) | meist nein | Werkstatt |
| K4 | serielle Konsole + TFTP-initramfs | ersetzt nur das Zwischenimage | Werkstatt |
| K5 | Bootloader entsperren oder ersetzen, Signaturen umgehen (Aruba AP-11, Meraki MR33) | nein | nur Werkstatt |
| offen | Weg ab Werk nicht belegt | | ? |

Stufen: K0..K5 bleiben intern; in Anleitungen steht die Stufe in Worten
(Wunsch Content). "mit Werkzeug" = Taste, Recovery-Seite oder Programm auf dem
Rechner, Gehäuse bleibt zu; "fortgeschritten" = Zwischenfirmware oder Exploit;
"Werkstatt" = serielle Konsole oder Teile der Herstellerfirmware. Die Worte
legt Content fest.

Abgleich: Die drei Teile haben K2 verschieden weit gefasst. Vereinheitlicht
nach diesen Regeln: K2 mit "Gluon-RAMpe passt: ja" wird K1; K2, bei dem der Weg
das Gluon-Image direkt nimmt, wird K1d (bzw. K0+, wenn es ein Gluon-factory
ist); "K0 (besonders)" heißt jetzt K0+.

## Spalten

Gepflegt werden die Daten in [`data/geraete-2025.1.json`](../data/geraete-2025.1.json),
ein Objekt je Gerät. Zahlen, Übersicht und Einzelheiten in diesem Dokument
erzeugt `scripts/erstinstallation.py` daraus (`--check` prüft, ob das Markdown
aktuell ist). Belegmarken stehen im jeweiligen Feld. Leere Felder sind noch
nicht recherchiert und erscheinen in den Einzelheiten nicht.

- **Anleitungsfamilie:** Geräte mit demselben Installationsweg, also einer
  gemeinsamen Anleitung (Schnitt nach Vorschlag Content, 10.10.2026). Eine
  Anleitung je Familie, darin eine Tabelle der Gerätewerte mit Anker je
  Gluon-Name; "Detail-Anleitung" zeigt dann auf `Familienseite#gluon-name`.
  `k0-webui` braucht keine eigene Anleitung, dort reicht ein allgemeiner Text.
  `sonderweg-<gluon-name>` ist ein Einzelfall mit eigener Seite. Erstzuordnung
  per Regel aus Hersteller, Kategorie, Übertragung und Werkzeug, danach von
  Hand durchgesehen.
- **Übertragung:** wie das Image auf das Gerät kommt. `webui-upload` (Stock-Weboberfläche),
  `recovery-web` (Recovery-Seite des Bootloaders), `tftp-server-am-geraet` (Gerät nimmt per
  `tftp put` an), `tftp-client-am-geraet` (Gerät holt per TFTP; man braucht einen TFTP-Server
  mit fester IP und festem Dateinamen), `ftp` (AVM EVA), `http-server-noetig`, `ssh/scp`,
  `usb`, `herstellertool`. IPs und Dateinamen stehen in der Zelle, wo bekannt.
- **Dateinamen bei TFTP:** Was eine Quelle als Dateinamen nennt
  (`firmware.bin`, `tp_recovery.bin`, `1401A8C0.img` …), steht hier wörtlich.
  Oft ist unklar, ob der Bootloader genau diesen Namen verlangt, nur keine
  langen Namen mag oder nur auf die Endung achtet, und ob das für alle
  Bootloader-Stände der Serie gilt. Regel für Anleitungen (Neanderfunk, 10.10.2026):
  **better safe than sorry**. Im Zweifel und bei widersprüchlichen Angaben im
  Netz die strengste Angabe nehmen, also genau den genannten Namen, kurz, mit
  derselben Endung, und so in die Anleitung schreiben. Ob ein Name wirklich
  zwingend ist, als [abgeleitet] kennzeichnen, solange es nicht am Gerät oder
  im Bootloader-Quelltext belegt ist. Das gilt auch beim Hochladen auf ein
  Gerät, das selbst TFTP-Server ist (`tftp put`, z. B. Ubiquiti).
- **Gehäuse öffnen:** `nein`; `ja` (UART auf der Platine); `nein, Konsole außen` (RJ45-Konsole,
  Pins am RJ45). Bei USB-Buchsen: **USB-Konsole echt** (USB-Seriell-Chip dahinter, normales
  Kabel) oder **USB-Buchse als UART-Stecker** (nur 3,3-V-TTL, eigener Adapter, **nie** an einen
  USB-Port des Rechners).
- **seriell nötig / Gehäuse öffnen:** Das erste Wort gilt für den Normalweg
  (so auch in der Übersicht), Klammer danach für Alternativen und den seriellen
  Notweg, einheitlich im Muster `nein (nur für den seriellen Notweg: ja, …)`.
- **initramfs-Link:** das OpenWrt-initramfs, auch wo der Weg es nicht braucht; für die
  Gluon-RAMpe ist es die Vorlage (Dateiname, Format).
- **RAM:** ein Gluon-initramfs braucht Platz; bei 64 MB knapp.
- **Gluon-RAMpe passt:** ja / teilweise / nein, mit Grund.
- **Gluon-RAMpe-Rezept:** ob es `devices/<gluon-name>.sh` gibt und was es tut.

Noch leer, für die Anleitungen (Vorschlag Content, 10.10.2026), zu füllen,
wo es eine Quelle gibt:

- **Taste und Zeitpunkt:** welche Taste, wann (beim Einschalten), wie lange.
- **Sichtbare Zeichen:** LED/Verhalten, woran man "Recovery erreicht" und
  "fertig, Strom lassen" erkennt.
- **Rechner braucht:** feste IP (welche), Programm (nmrpflash, `eva_ramboot.py`,
  TFTP-Server, ap51-flash), Betriebssystem, falls nur eines geht.
- **Typenschild/Verwechslung:** Revision, Region, "v2 sieht aus wie v1".
- **Bedingung an die Herstellerfirmware:** geht nur bis/ab Version X, Downgrade nötig.
- **Dauer:** ungefähr, und "währenddessen nicht Strom ziehen".
- **Rückweg zur Herstellerfirmware:** nice to have, nur eintragen, wenn es
  ohne Aufwand in der Quelle steht.
- **Hardware-Test:** Datum, und ob bei Neanderfunk ein Testgerät liegt.

## Zahlen

<!-- BEGIN erzeugt:zahlen -->
<!-- erzeugt von scripts/erstinstallation.py aus data/geraete-2025.1.json, nicht von Hand ändern -->

| Kat. | Geräte |
|---|---:|
| K0 | 119 |
| K0+ | 24 |
| K1 | 25 |
| K1d | 99 |
| K2 | 40 |
| K3 | 9 |
| K4 | 27 |
| K5 | 7 |
| offen | 1 |
| **gesamt** | **351** |

Gluon-RAMpe passt: **ja 24**, teilweise 38, nein/unnötig 289.

Gluon-RAMpe passt "ja": `ocedo-koala`, `ocedo-raccoon`, `mikrotik-routerboard-951ui-2nd-hap`, `mikrotik-routerboard-mapl-2nd`, `mikrotik-routerboard-wap-g-5hact2hnd`, `mikrotik-routerboard-wapr-2nd`, `zte-mf286r`, `asus-lyra-map-ac2200`, `mikrotik-discg-5acd`, `mikrotik-hap-ac2`, `mikrotik-sxtsq-5-ac-rbsxtsqg-5acd`, `mikrotik-wap-ac`, `avm-fritz-box-3390`, `avm-fritz-box-7362-sl`, `avm-fritz-box-7412`, `avm-fritz-box-7430`, `asus-rt-ax52`, `d-link-aquila-pro-ai-m30-a1`, `d-link-aquila-pro-ai-m60-a1`, `netgear-wax218`, `asus-rt-ax53u`, `genexis-pulse-ex400`, `mikrotik-routerboard-750gr3`, `zyxel-wsm20`.

<!-- END erzeugt:zahlen -->

## Wichtigste Befunde

- **Die Gluon-RAMpe hilft gezielt, nicht breit.** Bei den meisten Geräten ohne
  factory nimmt der Hersteller-Weg das Gluon-Image ohnehin direkt (K1d), oder
  es bleibt ein serieller bzw. Exploit-Schritt. Gute Kandidaten: D-Link M30/M60,
  ASUS RT-AX52/RT-AX53U, Genexis Pulse EX400 (OpenWrt-factory ist ein initramfs
  mit Inteno-Header), Zyxel WSM20, die MikroTik-Geräte (Netboot), AVM
  3390/7362 SL/7412/7430 (`eva_ramboot.py`), ZTE MF286R (Exploit), ASUS Lyra.
- **Fehlender Schritt vor dem sysupgrade:** Bei Aruba (`ubiformat`), AVM
  7520/7530/Repeater (U-Boot schreiben, `ubirmvol`), ZTE MF289F, OCEDO
  (`ubirmvol`, `fw_setenv`) reicht der Upload allein nicht. Eine Gluon-RAMpe
  bräuchte je Gerät ein Vorbereitungsskript.
- **Hersteller-Formate:** Die Hersteller-Wege wollen oft ein verpacktes
  initramfs (ASUS-TRX, D-Link-Header, Netgear `web-ui-factory.fit`, Xiaomi
  `initramfs-factory.ubi`, Aruba `.ari`). Gluon schaltet `TARGET_ROOTFS_INITRAMFS`
  nur für filogic und ipq40xx-mikrotik ein; jedes RAMpe-Rezept braucht den
  Schalter und das passende Hersteller-Format.
- **K3 (Stock-Teile per dd):** TP-Link Archer C2 v1, C20 v1, C20 v5, C50 v4,
  C50 v6 brauchen den U-Boot-Teil aus der TP-Link-Firmware (dd-Befehle und
  Downloads in der Tabelle). Die Gluon-RAMpe bringt hier nichts. In ath79 gibt es
  keinen K3-Fall.
- **ERX/ERX-SFP passt für die Gluon-RAMpe nicht:** Der 6.6-Kernel ist größer als
  der 3-MB-Slot, OpenWrt 24.10.8 baut kein factory.tar mehr (Neanderfunk-Notiz zur ERX-Migration).
- **Mögliche Gluon-Korrekturen statt Gluon-RAMpe:** Linksys MR8300,
  WNDR3700 v5, Archer C60 v1 und MikroTik mAP lite/wAP ac haben `factory = false`
  ohne erkennbaren Grund, obwohl OpenWrt (teils) ein brauchbares factory baut.
- **Widersprüche zu älteren Neanderfunk-Notizen, offen:** Mercusys MR90X (ältere Neanderfunk-Notiz
  nennt `tp_boot_idx` + Web-Recovery, Commit und Wiki nennen SSH/Telnet und
  `ubiupdatevol`); DIR-878/882 (Commit: Web-Recovery 192.168.0.1,
  ältere Neanderfunk-Notiz: TFTP); DAP-X1860 (Commit: factory.bin in die Recovery,
  ältere Neanderfunk-Notiz: OpenWrt-initramfs).

## Übersicht

<!-- BEGIN erzeugt:uebersicht -->
<!-- erzeugt von scripts/erstinstallation.py aus data/geraete-2025.1.json, nicht von Hand ändern -->

Sortiert nach Target, dann Gluon-Name. Der Gluon-Name führt zu den Einzelheiten des Geräts.

| Gluon-Name | Modell | Target | Kat. | Anleitungsfamilie | Übertragung | seriell nötig | Gehäuse öffnen | Gluon-RAMpe | Detail-Anleitung |
|---|---|---|---|---|---|---|---|---|---|
| [alfa-network-ap121f](#alfa-network-ap121f) | ALFA Network AP121F | ath79-generic | K1d | [`recovery-web`](#familie-recovery-web) | recovery-web | nein | nein | nein |  |
| [avm-fritz-box-4020](#avm-fritz-box-4020) | AVM FRITZ!Box 4020 | ath79-generic | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein | https://fritz-tools.readthedocs.io/ |
| [avm-fritz-wlan-repeater-1750e](#avm-fritz-wlan-repeater-1750e) | AVM FRITZ!WLAN Repeater 1750E (broken) | ath79-generic | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein |  |
| [avm-fritz-wlan-repeater-300e](#avm-fritz-wlan-repeater-300e) | AVM FRITZ!WLAN Repeater 300E | ath79-generic | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein | https://fritz-tools.readthedocs.io/ |
| [avm-fritz-wlan-repeater-450e](#avm-fritz-wlan-repeater-450e) | AVM FRITZ!WLAN Repeater 450E | ath79-generic | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein | https://fritz-tools.readthedocs.io/ |
| [buffalo-wzr-600dhp](#buffalo-wzr-600dhp) | Buffalo WZR-600DHP | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [buffalo-wzr-hp-ag300h](#buffalo-wzr-hp-ag300h) | Buffalo WZR-HP-AG300H | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [buffalo-wzr-hp-g300nh-rtl8366s](#buffalo-wzr-hp-g300nh-rtl8366s) | Buffalo WZR-HP-G300NH (RTL8366S switch) | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [buffalo-wzr-hp-g450h-wzr-450hp](#buffalo-wzr-hp-g450h-wzr-450hp) | Buffalo WZR-HP-G450H/WZR-450HP | ath79-generic | K0+ | [`sonderweg-buffalo-wzr-hp-g450h-wzr-450hp`](#familie-sonderweg-buffalo-wzr-hp-g450h-wzr-450hp) | webui-upload | nein | nein | nein |  |
| [comfast-cf-ew71-v2](#comfast-cf-ew71-v2) | COMFAST CF-EW71 v2 | ath79-generic | K1d | [`sonderweg-comfast-cf-ew71-v2`](#familie-sonderweg-comfast-cf-ew71-v2) | webui-upload | nein | nein | nein |  |
| [d-link-dap-1330-a1](#d-link-dap-1330-a1) | D-Link DAP-1330 A1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [d-link-dap-1365-a1](#d-link-dap-1365-a1) | D-Link DAP-1365 A1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [d-link-dap-2660-a1](#d-link-dap-2660-a1) | D-Link DAP-2660 A1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [d-link-dap-2680-a1](#d-link-dap-2680-a1) | D-Link DAP-2680 A1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=5b58710fad2137eedad874f0fe8fe22082d1edc6 |
| [d-link-dap-2695-a1](#d-link-dap-2695-a1) | D-Link DAP-2695 A1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [d-link-dir-505](#d-link-dir-505) | D-Link DIR-505 | ath79-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ? | teilweise |  |
| [d-link-dir825b1](#d-link-dir825b1) | D-Link DIR-825 B1 | ath79-generic | offen | [`sonderweg-d-link-dir825b1`](#familie-sonderweg-d-link-dir825b1) | ? | ? | ? | offen |  |
| [devolo-dlan-pro-1200+-wifi-ac](#devolo-dlan-pro-1200+-wifi-ac) | devolo dLAN pro 1200+ WiFi ac (broken) | ath79-generic | K1d | [`sonderweg-devolo-dlan-pro-1200+-wifi-ac`](#familie-sonderweg-devolo-dlan-pro-1200+-wifi-ac) | tftp-client-am-geraet | nein | nein | nein |  |
| [devolo-wifi-pro-1200e](#devolo-wifi-pro-1200e) | devolo WiFi pro 1200e | ath79-generic | K1d | [`devolo-ssh`](#familie-devolo-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1724d4e9ed7716a5444eca42adf045c2f3afc554 |
| [devolo-wifi-pro-1200i](#devolo-wifi-pro-1200i) | devolo WiFi pro 1200i | ath79-generic | K1d | [`devolo-ssh`](#familie-devolo-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=c8115167f946be85f812f3c94d6294b67ac8944c |
| [devolo-wifi-pro-1750c](#devolo-wifi-pro-1750c) | devolo WiFi pro 1750c | ath79-generic | K1d | [`devolo-ssh`](#familie-devolo-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=e67da3443168fa6b6727cd81a35d559be77d6b4c |
| [devolo-wifi-pro-1750e](#devolo-wifi-pro-1750e) | devolo WiFi pro 1750e | ath79-generic | K1d | [`devolo-ssh`](#familie-devolo-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1c2f7b511514d43d8a826b26e09817b2750a2bf4 |
| [devolo-wifi-pro-1750i](#devolo-wifi-pro-1750i) | devolo WiFi pro 1750i | ath79-generic | K1d | [`devolo-ssh`](#familie-devolo-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=8d68be8057d6c689025cc236d20b96b77a6ccf30 |
| [devolo-wifi-pro-1750x](#devolo-wifi-pro-1750x) | devolo WiFi pro 1750x | ath79-generic | K1d | [`devolo-ssh`](#familie-devolo-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=cb3cd526948af3f69da1af18e035177a0a8f58e3 |
| [enterasys-ws-ap3705i](#enterasys-ws-ap3705i) | Enterasys WS-AP3705i | ath79-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | nein | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=ebddc5f984a240980303aed68524eb615484eef8 |
| [extreme-networks-ws-ap3805i](#extreme-networks-ws-ap3805i) | Extreme Networks WS-AP3805i | ath79-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ja | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=f8c87aa2d27ab405f284dd4357377ab5c893a345 |
| [gl.inet-6416](#gl.inet-6416) | GL.iNet 6416 | ath79-generic | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [gl.inet-gl-ar150](#gl.inet-gl-ar150) | GL.iNet GL-AR150 | ath79-generic | K1d | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein |  |
| [gl.inet-gl-ar300m-lite](#gl.inet-gl-ar300m-lite) | GL.iNet GL-AR300M Lite | ath79-generic | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [gl.inet-gl-ar300m16](#gl.inet-gl-ar300m16) | GL.iNet GL-AR300M16 | ath79-generic | K1d | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein |  |
| [gl.inet-gl-ar750](#gl.inet-gl-ar750) | GL.iNet GL-AR750 | ath79-generic | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [gl.inet-gl-usb150](#gl.inet-gl-usb150) | GL.iNET GL-USB150 | ath79-generic | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [joy-it-jt-or750i](#joy-it-jt-or750i) | Joy-IT JT-OR750i | ath79-generic | K1d | [`recovery-web`](#familie-recovery-web) | recovery-web | nein | nein | nein | https://wiki.freifunk-stuttgart.net/technik:hardware:joy-it_jt-or750i |
| [librerouter-v1](#librerouter-v1) | Librerouter LibreRouter v1 | ath79-generic | K1d | [`sonderweg-librerouter-v1`](#familie-sonderweg-librerouter-v1) | webui-upload | nein | nein | nein |  |
| [netgear-wndr3700](#netgear-wndr3700) | NETGEAR WNDR3700 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [netgear-wndr3700-v2](#netgear-wndr3700-v2) | NETGEAR WNDR3700 v2 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [netgear-wndr3800](#netgear-wndr3800) | NETGEAR WNDR3800 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [netgear-wndr3800ch](#netgear-wndr3800ch) | NETGEAR WNDR3800CH | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [netgear-wndrmac-v2](#netgear-wndrmac-v2) | NETGEAR WNDRMAC v2 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [netgear-wnr2200-16m](#netgear-wnr2200-16m) | NETGEAR WNR2200 16M | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [netgear-wnr2200-8m](#netgear-wnr2200-8m) | NETGEAR WNR2200 8M | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [ocedo-koala](#ocedo-koala) | Ocedo Koala | ath79-generic | K1 | [`ocedo-tftp`](#familie-ocedo-tftp) | tftp-client-am-geraet | nein | nein | ja |  |
| [ocedo-raccoon](#ocedo-raccoon) | Ocedo Raccoon | ath79-generic | K1 | [`ocedo-tftp`](#familie-ocedo-tftp) | tftp-client-am-geraet | nein | nein | ja |  |
| [onion-omega](#onion-omega) | Onion Omega | ath79-generic | K0 | [`recovery-web`](#familie-recovery-web) | recovery-web | nein | nein | nein |  |
| [openmesh-a40](#openmesh-a40) | OpenMesh A40 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-a60](#openmesh-a60) | OpenMesh A60 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-mr1750-v1](#openmesh-mr1750-v1) | OpenMesh MR1750 v1 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-mr1750-v2](#openmesh-mr1750-v2) | OpenMesh MR1750 v2 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-mr600-v1](#openmesh-mr600-v1) | OpenMesh MR600 v1 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-mr600-v2](#openmesh-mr600-v2) | OpenMesh MR600 v2 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-mr900-v1](#openmesh-mr900-v1) | OpenMesh MR900 v1 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-mr900-v2](#openmesh-mr900-v2) | OpenMesh MR900 v2 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om2p-hs-v1](#openmesh-om2p-hs-v1) | OpenMesh OM2P-HS v1 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om2p-hs-v2](#openmesh-om2p-hs-v2) | OpenMesh OM2P-HS v2 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om2p-hs-v3](#openmesh-om2p-hs-v3) | OpenMesh OM2P-HS v3 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om2p-hs-v4](#openmesh-om2p-hs-v4) | OpenMesh OM2P-HS v4 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om2p-lc](#openmesh-om2p-lc) | OpenMesh OM2P-LC | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om2p-v1](#openmesh-om2p-v1) | OpenMesh OM2P v1 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om2p-v2](#openmesh-om2p-v2) | OpenMesh OM2P v2 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om2p-v4](#openmesh-om2p-v4) | OpenMesh OM2P v4 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om5p](#openmesh-om5p) | OpenMesh OM5P | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om5p-ac-v1](#openmesh-om5p-ac-v1) | OpenMesh OM5P-AC v1 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om5p-ac-v2](#openmesh-om5p-ac-v2) | OpenMesh OM5P-AC v2 | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [openmesh-om5p-an](#openmesh-om5p-an) | OpenMesh OM5P-AN | ath79-generic | K1d | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [plasma-cloud-pa300](#plasma-cloud-pa300) | Plasma Cloud PA300 | ath79-generic | K0+ | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [plasma-cloud-pa300e](#plasma-cloud-pa300e) | Plasma Cloud PA300E | ath79-generic | K0+ | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein |  |
| [siemens-ws-ap3610](#siemens-ws-ap3610) | Siemens WS-AP3610 | ath79-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | nein | teilweise | https://github.com/freifunk-darmstadt/projects/wiki/90-%E2%80%90-Hardware-%E2%80%90-Siemens-AP3610 |
| [sophos-ap100](#sophos-ap100) | Sophos AP100 | ath79-generic | K1d | [`sophos-xg-awetool`](#familie-sophos-xg-awetool) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7 |
| [sophos-ap100c](#sophos-ap100c) | Sophos AP100C | ath79-generic | K1d | [`sophos-xg-awetool`](#familie-sophos-xg-awetool) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7 |
| [sophos-ap15](#sophos-ap15) | Sophos AP15 (broken) | ath79-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ja | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=0dc58214896aacf67a3759495d70e2b4e9c160d8 |
| [sophos-ap15c](#sophos-ap15c) | Sophos AP15C | ath79-generic | K1d | [`sophos-xg-awetool`](#familie-sophos-xg-awetool) | ssh | nein | nein | nein |  |
| [sophos-ap55](#sophos-ap55) | Sophos AP55 | ath79-generic | K1d | [`sophos-xg-awetool`](#familie-sophos-xg-awetool) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7 |
| [sophos-ap55c](#sophos-ap55c) | Sophos AP55C | ath79-generic | K1d | [`sophos-xg-awetool`](#familie-sophos-xg-awetool) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7 |
| [teltonika-rut230-v1](#teltonika-rut230-v1) | Teltonika RUT230 v1 | ath79-generic | K0+ | [`recovery-web`](#familie-recovery-web) | recovery-web | nein | nein | nein |  |
| [tp-link-archer-a7-v5](#tp-link-archer-a7-v5) | TP-Link Archer A7 v5 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c2-v3](#tp-link-archer-c2-v3) | TP-Link Archer C2 v3 (broken) | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c25-v1](#tp-link-archer-c25-v1) | TP-Link Archer C25 v1 (broken) | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c5-v1](#tp-link-archer-c5-v1) | TP-Link Archer C5 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c58-v1](#tp-link-archer-c58-v1) | TP-Link Archer C58 v1 (broken) | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c59-v1](#tp-link-archer-c59-v1) | TP-Link Archer C59 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c6-v2-eu-ru-jp](#tp-link-archer-c6-v2-eu-ru-jp) | TP-Link Archer C6 v2 (EU/RU/JP) | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c60-v1](#tp-link-archer-c60-v1) | TP-Link Archer C60 v1 | ath79-generic | K2 | [`sonderweg-tp-link-archer-c60-v1`](#familie-sonderweg-tp-link-archer-c60-v1) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c7-v2](#tp-link-archer-c7-v2) | TP-Link Archer C7 v2 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c7-v4](#tp-link-archer-c7-v4) | TP-Link Archer C7 v4 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c7-v5](#tp-link-archer-c7-v5) | TP-Link Archer C7 v5 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-d50-v1](#tp-link-archer-d50-v1) | TP-Link Archer D50 v1 (broken) | ath79-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ja | teilweise |  |
| [tp-link-cpe210-v1](#tp-link-cpe210-v1) | TP-Link CPE210 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-cpe210-v2](#tp-link-cpe210-v2) | TP-Link CPE210 v2 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-cpe210-v3](#tp-link-cpe210-v3) | TP-Link CPE210 v3 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-cpe220-v3](#tp-link-cpe220-v3) | TP-Link CPE220 v3 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-cpe510-v1](#tp-link-cpe510-v1) | TP-Link CPE510 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-cpe510-v2](#tp-link-cpe510-v2) | TP-Link CPE510 v2 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-cpe510-v3](#tp-link-cpe510-v3) | TP-Link CPE510 v3 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-cpe710-v1](#tp-link-cpe710-v1) | TP-Link CPE710 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-cpe710-v2](#tp-link-cpe710-v2) | TP-Link CPE710 v2 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-eap225-outdoor-v1](#tp-link-eap225-outdoor-v1) | TP-Link EAP225-Outdoor v1 | ath79-generic | K0+ | [`tplink-eap-ssh`](#familie-tplink-eap-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=4f86edf477edbc0f20b5a49a69f658fa82158284 |
| [tp-link-eap225-outdoor-v3](#tp-link-eap225-outdoor-v3) | TP-Link EAP225-Outdoor v3 | ath79-generic | K0+ | [`tplink-eap-ssh`](#familie-tplink-eap-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=7e4de89e631aaf56be5375662b7d5ed0f27e26f6 |
| [tp-link-eap225-wall-v2](#tp-link-eap225-wall-v2) | TP-Link EAP225-Wall v2 | ath79-generic | K0+ | [`tplink-eap-ssh`](#familie-tplink-eap-ssh) | ssh | nein | nein | nein |  |
| [tp-link-tl-wdr3500-v1](#tp-link-tl-wdr3500-v1) | TP-Link TL-WDR3500 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wdr3600-v1](#tp-link-tl-wdr3600-v1) | TP-Link TL-WDR3600 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wdr4300-v1](#tp-link-tl-wdr4300-v1) | TP-Link TL-WDR4300 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wr1043n-v5](#tp-link-tl-wr1043n-v5) | TP-Link TL-WR1043N v5 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wr1043nd-v2](#tp-link-tl-wr1043nd-v2) | TP-Link TL-WR1043N/ND v2 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wr1043nd-v3](#tp-link-tl-wr1043nd-v3) | TP-Link TL-WR1043N/ND v3 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wr1043nd-v4](#tp-link-tl-wr1043nd-v4) | TP-Link TL-WR1043N/ND v4 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wr2543n-nd](#tp-link-tl-wr2543n-nd) | TP-Link TL-WR2543N/ND v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wr810n-v1](#tp-link-tl-wr810n-v1) | TP-Link TL-WR810N v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wr842n-v3](#tp-link-tl-wr842n-v3) | TP-Link TL-WR842N v3 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-wr902ac-v1](#tp-link-tl-wr902ac-v1) | TP-Link TL-WR902AC v1 (broken) | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-wbs210-v1](#tp-link-wbs210-v1) | TP-Link WBS210 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-wbs210-v2](#tp-link-wbs210-v2) | TP-Link WBS210 v2 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-wbs510-v1](#tp-link-wbs510-v1) | TP-Link WBS510 v1 | ath79-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [ubiquiti-nanobeam-ac-gen1-xc](#ubiquiti-nanobeam-ac-gen1-xc) | Ubiquiti NanoBeam AC Gen1 (XC) | ath79-generic | K0+ | [`sonderweg-ubiquiti-nanobeam-ac-gen1-xc`](#familie-sonderweg-ubiquiti-nanobeam-ac-gen1-xc) | laut | nein | nein | nein |  |
| [ubiquiti-nanostation-loco-m-xw](#ubiquiti-nanostation-loco-m-xw) | Ubiquiti Nanostation Loco M XW | ath79-generic | K0+ | [`ubiquiti-tftp`](#familie-ubiquiti-tftp) | tftp-server-am-geraet | nein | nein | nein |  |
| [ubiquiti-nanostation-m-xw](#ubiquiti-nanostation-m-xw) | Ubiquiti Nanostation M XW | ath79-generic | K0+ | [`ubiquiti-tftp`](#familie-ubiquiti-tftp) | tftp-server-am-geraet | nein | nein | nein |  |
| [ubiquiti-rocket-m-xm](#ubiquiti-rocket-m-xm) | Ubiquiti Rocket M XM | ath79-generic | K0+ | [`ubiquiti-tftp`](#familie-ubiquiti-tftp) | tftp-server-am-geraet | nein | nein | nein |  |
| [ubiquiti-unifi-ac-lite](#ubiquiti-unifi-ac-lite) | Ubiquiti UniFi AC Lite | ath79-generic | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790 |
| [ubiquiti-unifi-ac-lr](#ubiquiti-unifi-ac-lr) | Ubiquiti UniFi AC LR | ath79-generic | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790 |
| [ubiquiti-unifi-ac-mesh](#ubiquiti-unifi-ac-mesh) | Ubiquiti UniFi AC Mesh | ath79-generic | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790 |
| [ubiquiti-unifi-ac-mesh-pro](#ubiquiti-unifi-ac-mesh-pro) | Ubiquiti UniFi AC Mesh Pro | ath79-generic | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790 |
| [ubiquiti-unifi-ac-pro](#ubiquiti-unifi-ac-pro) | Ubiquiti UniFi AC Pro | ath79-generic | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790 |
| [ubiquiti-unifi-ap](#ubiquiti-unifi-ap) | Ubiquiti UniFi AP | ath79-generic | K0+ | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein |  |
| [ubiquiti-unifi-ap-outdoor+](#ubiquiti-unifi-ap-outdoor+) | Ubiquiti UniFi AP Outdoor+ | ath79-generic | K0+ | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein |  |
| [ubiquiti-unifi-ap-pro](#ubiquiti-unifi-ap-pro) | Ubiquiti UniFi AP Pro | ath79-generic | K0+ | [`ubiquiti-tftp`](#familie-ubiquiti-tftp) | tftp-server-am-geraet | nein | nein | nein |  |
| [ubiquiti-unifi-swiss-army-knife-ultra](#ubiquiti-unifi-swiss-army-knife-ultra) | Ubiquiti UniFi Swiss Army Knife Ultra | ath79-generic | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=5ad05681f2de00c8c6d6449df2b958b0838dbc1a |
| [zyxel-nbg6616](#zyxel-nbg6616) | Zyxel NBG6616 | ath79-generic | K5 | [`sonderweg-zyxel-nbg6616`](#familie-sonderweg-zyxel-nbg6616) | tftp-client-am-geraet | ja | ? | nein |  |
| [mikrotik-routerboard-951ui-2nd-hap](#mikrotik-routerboard-951ui-2nd-hap) | MikroTik RouterBOARD 951Ui-2nD (hAP) | ath79-mikrotik | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client-am-geraet | nein | nein | ja |  |
| [mikrotik-routerboard-mapl-2nd](#mikrotik-routerboard-mapl-2nd) | MikroTik RouterBOARD mAPL-2nD (mAP lite) | ath79-mikrotik | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client-am-geraet | nein | nein | ja |  |
| [mikrotik-routerboard-wap-g-5hact2hnd](#mikrotik-routerboard-wap-g-5hact2hnd) | MikroTik RouterBOARD wAP G-5HacT2HnD (wAP AC) | ath79-mikrotik | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client-am-geraet | nein | nein | ja |  |
| [mikrotik-routerboard-wapr-2nd](#mikrotik-routerboard-wapr-2nd) | MikroTik RouterBOARD wAPR-2nD (wAP R) | ath79-mikrotik | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client-am-geraet | nein | nein | ja |  |
| [aerohive-hiveap-121](#aerohive-hiveap-121) | Aerohive HiveAP 121 | ath79-nand | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ? | teilweise |  |
| [gl.inet-gl-ar300m-nor](#gl.inet-gl-ar300m-nor) | GL.iNet GL-AR300M NOR | ath79-nand | K1d | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein |  |
| [gl.inet-gl-ar750s-nor](#gl.inet-gl-ar750s-nor) | GL.iNet GL-AR750S NOR | ath79-nand | K1d | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein |  |
| [gl.inet-gl-e750](#gl.inet-gl-e750) | GL.iNet GL-E750 (broken) | ath79-nand | K2 | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein |  |
| [gl.inet-gl-xe300](#gl.inet-gl-xe300) | GL.iNet GL-XE300 | ath79-nand | K2 | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein |  |
| [netgear-wndr3700-v4](#netgear-wndr3700-v4) | NETGEAR WNDR3700 v4 | ath79-nand | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [netgear-wndr4300](#netgear-wndr4300) | NETGEAR WNDR4300 | ath79-nand | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [zte-mf281](#zte-mf281) | ZTE MF281 (broken) | ath79-nand | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ja | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1e1695f959e678868bb7911d059b847f38fc9cf4 |
| [zte-mf286r](#zte-mf286r) | ZTE MF286R (broken) | ath79-nand | K1 | [`sonderweg-zte-mf286r`](#familie-sonderweg-zte-mf286r) | Exploit | nein | nein | ja |  |
| [zyxel-nbg6716](#zyxel-nbg6716) | Zyxel NBG6716 | ath79-nand | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [raspberrypi-model-b](#raspberrypi-model-b) | Raspberry Pi 1 Model B/B+ | bcm27xx-bcm2708 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | sd-karte | nein | nein | nein | - |
| [raspberrypi-2-model-b](#raspberrypi-2-model-b) | Raspberry Pi 2 Model B | bcm27xx-bcm2709 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | sd-karte | nein | nein | nein | - |
| [raspberrypi-3-model-b](#raspberrypi-3-model-b) | Raspberry Pi 3 Model B/B+ | bcm27xx-bcm2710 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | sd-karte | nein | nein | nein | - |
| [raspberrypi-4-model-b](#raspberrypi-4-model-b) | Raspberry Pi 4 Model B | bcm27xx-bcm2711 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | sd-karte | nein | nein | nein | - |
| [google-wifi-gale](#google-wifi-gale) | Google WiFi (Gale) | ipq40xx-chromium | K5 | [`sonderweg-google-wifi-gale`](#familie-sonderweg-google-wifi-gale) | usb | nein | ja | nein | https://openwrt.org/inbox/toh/google/google_wifi |
| [8devices-jalapeno](#8devices-jalapeno) | 8devices Jalapeno | ipq40xx-generic | K0 | [`ssh-stock`](#familie-ssh-stock) | ssh | nein | nein | nein | - |
| [aruba-ap-303](#aruba-ap-303) | Aruba AP-303 | ipq40xx-generic | K4 | [`aruba-apboot`](#familie-aruba-apboot) | tftp-client | ja | nein | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=102c8c55f217606cdbdc9a449667e034676b3e75 |
| [aruba-ap-303h](#aruba-ap-303h) | Aruba AP-303H | ipq40xx-generic | K4 | [`aruba-apboot`](#familie-aruba-apboot) | tftp-client | ja | nein | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=c6e972c8772a628a1a2f2e5590d7c6f4acef9ab0 |
| [aruba-ap-365](#aruba-ap-365) | Aruba AP-365 | ipq40xx-generic | K4 | [`aruba-apboot`](#familie-aruba-apboot) | tftp-client | ja | nein | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=300b7fe85a743ab0e039457a5a551819b49450da |
| [aruba-instant-on-ap11](#aruba-instant-on-ap11) | Aruba Instant On AP11 (Alias von aruba-ap-303) | ipq40xx-generic | K5 | [`sonderweg-aruba-instant-on-ap11`](#familie-sonderweg-aruba-instant-on-ap11) | tftp-client | ja | nein | teilweise | - |
| [aruba-instant-on-ap11d](#aruba-instant-on-ap11d) | Aruba Instant On AP11D (Alias von aruba-ap-303h) | ipq40xx-generic | K4 | [`aruba-apboot`](#familie-aruba-apboot) | tftp-client | ja | nein | teilweise | - |
| [aruba-instant-on-ap17](#aruba-instant-on-ap17) | Aruba Instant On AP17 (Alias von aruba-ap-365) | ipq40xx-generic | K4 | [`aruba-apboot`](#familie-aruba-apboot) | tftp-client | ja | USB | teilweise | - |
| [asus-lyra-map-ac2200](#asus-lyra-map-ac2200) | ASUS Lyra MAP-AC2200 | ipq40xx-generic | K1 | [`sonderweg-asus-lyra-map-ac2200`](#familie-sonderweg-asus-lyra-map-ac2200) | ssh | nein | nein | ja | https://openwrt.org/toh/asus/lyra_map-ac2200#oem_easy_installation |
| [avm-fritz-box-4040](#avm-fritz-box-4040) | AVM FRITZ!Box 4040 | ipq40xx-generic | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein | https://fritz-tools.readthedocs.io/ |
| [avm-fritz-box-7520](#avm-fritz-box-7520) | AVM FRITZ!Box 7520 (Alias von avm-fritz-box-7530) | ipq40xx-generic | K2 | [`avm-eva-uboot`](#familie-avm-eva-uboot) | ftp | nein | nein | teilweise | https://openwrt.org/toh/avm/avm_fritz_box_7530#installation |
| [avm-fritz-box-7530](#avm-fritz-box-7530) | AVM FRITZ!Box 7530 | ipq40xx-generic | K2 | [`avm-eva-uboot`](#familie-avm-eva-uboot) | ftp | nein | nein | teilweise | https://openwrt.org/toh/avm/avm_fritz_box_7530#installation |
| [avm-fritz-repeater-1200](#avm-fritz-repeater-1200) | AVM FRITZ!Repeater 1200 | ipq40xx-generic | K2 | [`avm-eva-uboot`](#familie-avm-eva-uboot) | ftp | nein | nein | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=7f187229a8e9b7966248b1e024217e07a9fc3e50 |
| [avm-fritz-repeater-3000](#avm-fritz-repeater-3000) | AVM FRITZ!Repeater 3000 (Gluon: broken, drittes Radio ungetestet) | ipq40xx-generic | K2 | [`avm-eva-uboot`](#familie-avm-eva-uboot) | ftp | nein | nein | teilweise | - |
| [extreme-networks-ws-ap3915i](#extreme-networks-ws-ap3915i) | Extreme Networks WS-AP3915i | ipq40xx-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | nein | teilweise | - |
| [gl.inet-gl-ap1300](#gl.inet-gl-ap1300) | GL.iNet GL-AP1300 | ipq40xx-generic | K0 | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein | - |
| [gl.inet-gl-b1300](#gl.inet-gl-b1300) | GL.iNet GL-B1300 | ipq40xx-generic | K1d | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein | - |
| [linksys-ea6350v3](#linksys-ea6350v3) | Linksys EA6350 v3 | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [linksys-ea8300-dallas](#linksys-ea8300-dallas) | Linksys EA8300 | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [linksys-mr8300-dallas](#linksys-mr8300-dallas) | Linksys MR8300 | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | teilweise | - |
| [linksys-vlp01](#linksys-vlp01) | Linksys VLP01 (Alias von linksys-whw01) | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://openwrt.org/toh/linksys/whw01_v1#installation |
| [linksys-whw01](#linksys-whw01) | Linksys WHW01 v1 (Velop) | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://openwrt.org/toh/linksys/whw01_v1#installation |
| [linksys-whw03-v2-velop](#linksys-whw03-v2-velop) | Linksys WHW03 v2 (Velop) | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://openwrt.org/toh/linksys/whw03_v2#oem_easy_installation |
| [linksys-whw03-velop](#linksys-whw03-velop) | Linksys WHW03 v1 (Velop) | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://openwrt.org/toh/linksys/whw03_v1#oem_easy_installation |
| [meraki-mr33-access-point](#meraki-mr33-access-point) | Cisco Meraki MR33 | ipq40xx-generic | K5 | [`sonderweg-meraki-mr33-access-point`](#familie-sonderweg-meraki-mr33-access-point) | tftp-server-am-geraet | ja | ja | nein | https://openwrt.org/toh/meraki/mr33 |
| [netgear-ex6100v2](#netgear-ex6100v2) | NETGEAR EX6100 v2 | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [netgear-ex6150v2](#netgear-ex6150v2) | NETGEAR EX6150 v2 | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://freifunk-ingolstadt.de/eigener-freifunk-hotspot/anleitung/installationsanleitung-fuer-netgear-wi-fi-range-extender-ex6150-v2/ |
| [netgear-rbr50](#netgear-rbr50) | NETGEAR Orbi RBR50 v1 | ipq40xx-generic | K0+ | [`netgear-nmrp`](#familie-netgear-nmrp) | herstellertool | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2cb24b3f3cd89692f3c0bd137f3f560ada359bfa |
| [netgear-rbs50](#netgear-rbs50) | NETGEAR Orbi RBS50 v1 | ipq40xx-generic | K0+ | [`netgear-nmrp`](#familie-netgear-nmrp) | herstellertool | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2cb24b3f3cd89692f3c0bd137f3f560ada359bfa |
| [netgear-srr60](#netgear-srr60) | NETGEAR Orbi Pro SRR60 | ipq40xx-generic | K0+ | [`netgear-nmrp`](#familie-netgear-nmrp) | herstellertool | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2cb24b3f3cd89692f3c0bd137f3f560ada359bfa |
| [netgear-srs60](#netgear-srs60) | NETGEAR Orbi Pro SRS60 | ipq40xx-generic | K0+ | [`netgear-nmrp`](#familie-netgear-nmrp) | herstellertool | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2cb24b3f3cd89692f3c0bd137f3f560ada359bfa |
| [openmesh-a42](#openmesh-a42) | OpenMesh A42 | ipq40xx-generic | K0+ | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein | - |
| [openmesh-a62](#openmesh-a62) | OpenMesh A62 | ipq40xx-generic | K0+ | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein | - |
| [plasma-cloud-pa1200](#plasma-cloud-pa1200) | Plasma Cloud PA1200 | ipq40xx-generic | K0+ | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein | - |
| [plasma-cloud-pa2200](#plasma-cloud-pa2200) | Plasma Cloud PA2200 | ipq40xx-generic | K0+ | [`ap51-flash`](#familie-ap51-flash) | herstellertool | nein | nein | nein | - |
| [zte-mf289f](#zte-mf289f) | ZTE MF289F | ipq40xx-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ja | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=0de6a3339f1aadc1de2c9371435e3de239a00645 |
| [zyxel-nbg6617](#zyxel-nbg6617) | Zyxel NBG6617 | ipq40xx-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [mikrotik-discg-5acd](#mikrotik-discg-5acd) | MikroTik DISC Lite5 ac (Alias von mikrotik-sxtsq-5-ac-rbsxtsqg-5acd) | ipq40xx-mikrotik | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client | nein | nein | ja | - |
| [mikrotik-hap-ac2](#mikrotik-hap-ac2) | MikroTik hAP ac2 (RBD52G-5HacD2HnD) | ipq40xx-mikrotik | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client | nein | nein | ja | - |
| [mikrotik-sxtsq-5-ac-rbsxtsqg-5acd](#mikrotik-sxtsq-5-ac-rbsxtsqg-5acd) | MikroTik SXTsq 5 ac (RBSXTsqG-5acD) | ipq40xx-mikrotik | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client | nein | nein | ja | - |
| [mikrotik-wap-ac](#mikrotik-wap-ac) | MikroTik wAP ac (RBwAPG-5HacD2HnD, ipq40xx) | ipq40xx-mikrotik | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client | nein | nein | ja | - |
| [aruba-ap-32x](#aruba-ap-32x) | Aruba AP-324/AP-325, Siemens Scalance W1750D | ipq806x-generic | K5 | [`sonderweg-aruba-ap-32x`](#familie-sonderweg-aruba-ap-32x) | tftp-client | ja | nein | teilweise | https://github.com/lukasstockner/ap325-apboot-openwrt |
| [extreme-networks-ap3935](#extreme-networks-ap3935) | Extreme Networks AP3935i/e | ipq806x-generic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | nein | teilweise | - |
| [netgear-nighthawk-x4s-r7800](#netgear-nighthawk-x4s-r7800) | NETGEAR Nighthawk X4S R7800 | ipq806x-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [tp-link-archer-c2600](#tp-link-archer-c2600) | TP-Link Archer C2600 v1 | ipq806x-generic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [ubiquiti-unifi-ac-hd](#ubiquiti-unifi-ac-hd) | Ubiquiti UniFi AC HD | ipq806x-generic | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | - |
| [arcadyan-vgv7510kw22](#arcadyan-vgv7510kw22) | Arcadyan VGV7510KW22 / o2 Box 6431 (NOR-Image) | lantiq-xrx200 | K5 | [`sonderweg-arcadyan-vgv7510kw22`](#familie-sonderweg-arcadyan-vgv7510kw22) | recovery-web | teilweise | nein | nein | https://forum.openwrt.org/t/installing-lede-u-boot-via-brnboot-web-interface-without-rs232/9857/6 |
| [avm-fritz-box-3370-rev-2-hynix-nand](#avm-fritz-box-3370-rev-2-hynix-nand) | AVM FRITZ!Box 3370 Rev. 2, Hynix-NAND (Gluon: broken) | lantiq-xrx200 | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein | https://openwrt.org/toh/avm/fritz.box.wlan.3370#installation |
| [avm-fritz-box-3370-rev-2-micron-nand](#avm-fritz-box-3370-rev-2-micron-nand) | AVM FRITZ!Box 3370 Rev. 2, Micron-NAND (Gluon: broken) | lantiq-xrx200 | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein | https://openwrt.org/toh/avm/fritz.box.wlan.3370#installation |
| [avm-fritz-box-3390](#avm-fritz-box-3390) | AVM FRITZ!Box 3390 | lantiq-xrx200 | K1 | [`avm-eva-ramboot`](#familie-avm-eva-ramboot) | ftp | nein | nein | ja |  |
| [avm-fritz-box-7360-sl](#avm-fritz-box-7360-sl) | AVM FRITZ!Box 7360 SL (Alias 7360 v1) | lantiq-xrx200 | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein | https://fritz-tools.readthedocs.io/ |
| [avm-fritz-box-7360-v2](#avm-fritz-box-7360-v2) | AVM FRITZ!Box 7360 v2 | lantiq-xrx200 | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein |  |
| [avm-fritz-box-7362-sl](#avm-fritz-box-7362-sl) | AVM FRITZ!Box 7362 SL | lantiq-xrx200 | K1 | [`avm-eva-ramboot`](#familie-avm-eva-ramboot) | ftp | nein | nein | ja | https://openwrt.org/toh/avm/avm_7362_sl#installation |
| [avm-fritz-box-7412](#avm-fritz-box-7412) | AVM FRITZ!Box 7412 | lantiq-xrx200 | K1 | [`avm-eva-ramboot`](#familie-avm-eva-ramboot) | ftp | nein | nein | ja | https://openwrt.org/toh/avm/avm_fritz_box_7412#installation |
| [avm-fritz-box-7430](#avm-fritz-box-7430) | AVM FRITZ!Box 7430 | lantiq-xrx200 | K1 | [`avm-eva-ramboot`](#familie-avm-eva-ramboot) | ftp | nein | nein | ja | https://openwrt.org/toh/avm/avm_fritz_box_7430#installation |
| [tp-link-td-w8970](#tp-link-td-w8970) | TP-Link TD-W8970 v1 | lantiq-xrx200_legacy | K2 | [`sonderweg-tp-link-td-w8970`](#familie-sonderweg-tp-link-td-w8970) | ssh | nein | nein | nein |  |
| [tp-link-td-w8980](#tp-link-td-w8980) | TP-Link TD-W8980 (Alias TD-W9980; Gluon: broken, 5 GHz) | lantiq-xrx200_legacy | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | ja | nein |  |
| [avm-fritz-box-7312](#avm-fritz-box-7312) | AVM FRITZ!Box 7312 | lantiq-xway | K1d | [`avm-eva-ftp`](#familie-avm-eva-ftp) | ftp | nein | nein | nein | https://fritz-tools.readthedocs.io/ |
| [netgear-dgn3500b](#netgear-dgn3500b) | NETGEAR DGN3500B | lantiq-xway | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [asus-rt-ax52](#asus-rt-ax52) | ASUS RT-AX52 | mediatek-filogic | K1 | [`sonderweg-asus-rt-ax52`](#familie-sonderweg-asus-rt-ax52) | webui-upload | nein | nein | ja | https://openwrt.org/toh/asus/rt-ax52#installation |
| [asus-rt-ax59u](#asus-rt-ax59u) | ASUS RT-AX59U | mediatek-filogic | K2 | [`sonderweg-asus-rt-ax59u`](#familie-sonderweg-asus-rt-ax59u) | webui-upload | nein | nein | teilweise | - |
| [asus-tuf-ax4200](#asus-tuf-ax4200) | ASUS TUF-AX4200 | mediatek-filogic | K2 | [`asus-tuf-herbetom`](#familie-asus-tuf-herbetom) | ssh | nein | nein | teilweise | https://github.com/freifunk-darmstadt/projects/wiki/90-%E2%80%90-Hardware-%E2%80%90-ASUS-TUF-AX4200 |
| [asus-tuf-ax6000](#asus-tuf-ax6000) | ASUS TUF-AX6000 | mediatek-filogic | K2 | [`asus-tuf-herbetom`](#familie-asus-tuf-herbetom) | ssh | nein | nein | teilweise | https://github.com/herbetom/openwrt-asus-filogic-factory/releases/latest |
| [cudy-ap3000-outdoor-v1](#cudy-ap3000-outdoor-v1) | Cudy AP3000 Outdoor v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-ap3000-v1](#cudy-ap3000-v1) | Cudy AP3000 v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | - |
| [cudy-ap3000-wall-v1](#cudy-ap3000-wall-v1) | Cudy AP3000 Wall v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | - |
| [cudy-m3000-v1](#cudy-m3000-v1) | Cudy M3000 v1 (RTL8221B) | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-m3000-v2-with-motorcomm-yt8821](#cudy-m3000-v2-with-motorcomm-yt8821) | Cudy M3000 v2 mit Motorcomm YT8821 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | - |
| [cudy-re3000-v1](#cudy-re3000-v1) | Cudy RE3000 v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-tr3000-256mb-v1](#cudy-tr3000-256mb-v1) | Cudy TR3000 256 MB v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-tr3000-v1](#cudy-tr3000-v1) | Cudy TR3000 v1 (128 MB Flash) | mediatek-filogic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ja | teilweise | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-wr3000-v1](#cudy-wr3000-v1) | Cudy WR3000 v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-wr3000e-v1](#cudy-wr3000e-v1) | Cudy WR3000E v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-wr3000h-v1](#cudy-wr3000h-v1) | Cudy WR3000H v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-wr3000p-v1](#cudy-wr3000p-v1) | Cudy WR3000P v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | - |
| [cudy-wr3000s-v1](#cudy-wr3000s-v1) | Cudy WR3000S v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-wr3000u-v1](#cudy-wr3000u-v1) | Cudy WR3000U v1 | mediatek-filogic | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | - |
| [d-link-aquila-pro-ai-m30-a1](#d-link-aquila-pro-ai-m30-a1) | D-Link AQUILA PRO AI M30 A1 | mediatek-filogic | K1 | [`dlink-recovery-web`](#familie-dlink-recovery-web) | recovery-web | nein | nein | ja | https://freifunk-aachen.de/2026/08/17/installationsanleitung-d-link-m30/ |
| [d-link-aquila-pro-ai-m60-a1](#d-link-aquila-pro-ai-m60-a1) | D-Link AQUILA PRO AI M60 A1 | mediatek-filogic | K1 | [`dlink-recovery-web`](#familie-dlink-recovery-web) | recovery-web | nein | nein | ja | - |
| [gl.inet-gl-mt2500](#gl.inet-gl-mt2500) | GL.iNet GL-MT2500 (MaxLinear-PHY) | mediatek-filogic | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein | - |
| [gl.inet-gl-mt3000](#gl.inet-gl-mt3000) | GL.iNet GL-MT3000 | mediatek-filogic | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein | - |
| [gl.inet-gl-mt6000](#gl.inet-gl-mt6000) | GL.iNet GL-MT6000 | mediatek-filogic | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein | - |
| [mercusys-mr80x-v3](#mercusys-mr80x-v3) | Mercusys MR80X v3 | mediatek-filogic | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | ja | teilweise |  |
| [mercusys-mr90x-v1](#mercusys-mr90x-v1) | Mercusys MR90X v1 | mediatek-filogic | K2 | [`sonderweg-mercusys-mr90x-v1`](#familie-sonderweg-mercusys-mr90x-v1) | ssh | nein | nein | teilweise | https://openwrt.org/toh/mercusys/mr90x_v1#installation_stock_bootloader |
| [netgear-wax220](#netgear-wax220) | NETGEAR WAX220 | mediatek-filogic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://openwrt.org/toh/netgear/wax220#oem_easy_installation |
| [openwrt-one](#openwrt-one) | OpenWrt One | mediatek-filogic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [ubiquiti-unifi-6-plus](#ubiquiti-unifi-6-plus) | Ubiquiti UniFi 6+ (U6+) | mediatek-filogic | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=75ee5546e9b7cfa5bbfd6f844ab8c5fffd5bb594 |
| [wavlink-wl-wn573hx3](#wavlink-wl-wn573hx3) | WAVLINK WL-WN573HX3 / 7Links WLR-1300 | mediatek-filogic | K1d | [`sonderweg-wavlink-wl-wn573hx3`](#familie-sonderweg-wavlink-wl-wn573hx3) | webui-upload | nein | nein | nein | - |
| [xiaomi-mi-router-ax3000t](#xiaomi-mi-router-ax3000t) | Xiaomi Mi Router AX3000T | mediatek-filogic | K2 | [`sonderweg-xiaomi-mi-router-ax3000t`](#familie-sonderweg-xiaomi-mi-router-ax3000t) | ssh | nein | nein | teilweise | - |
| [xiaomi-mi-router-ax3000t-openwrt-u-boot-layout](#xiaomi-mi-router-ax3000t-openwrt-u-boot-layout) | Xiaomi Mi Router AX3000T (OpenWrt-U-Boot-Layout) | mediatek-filogic | K3 | [`sonderweg-xiaomi-mi-router-ax3000t-openwrt-u-boot-layout`](#familie-sonderweg-xiaomi-mi-router-ax3000t-openwrt-u-boot-layout) | ssh | nein | nein | nein | - |
| [zyxel-nwa50ax-pro](#zyxel-nwa50ax-pro) | Zyxel NWA50AX Pro | mediatek-filogic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=f0445746f6fd96fc7c5394b238153bd2ff22bc5b |
| [zyxel-nwa90ax-pro](#zyxel-nwa90ax-pro) | Zyxel NWA90AX Pro (Alias von zyxel-nwa50ax-pro) | mediatek-filogic | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [linksys-e8450-ubi](#linksys-e8450-ubi) | Linksys E8450 / Belkin RT3200 (UBI-Layout) | mediatek-mt7622 | K3 | [`sonderweg-linksys-e8450-ubi`](#familie-sonderweg-linksys-e8450-ubi) | webui-upload | nein | nein | nein | https://openwrt.org/toh/linksys/e8450#installation |
| [netgear-wax206](#netgear-wax206) | NETGEAR WAX206 | mediatek-mt7622 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | webui-upload | nein | nein | nein | https://openwrt.org/toh/netgear/wax206#oem_easy_installation |
| [ubiquiti-unifi-6-lr-v1](#ubiquiti-unifi-6-lr-v1) | Ubiquiti UniFi 6 LR v1 | mediatek-mt7622 | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://openwrt.org/toh/ubiquiti/unifi_6_lr#installation_steps |
| [ubiquiti-unifi-6-lr-v2](#ubiquiti-unifi-6-lr-v2) | Ubiquiti UniFi 6 LR v2 | mediatek-mt7622 | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://openwrt.org/toh/ubiquiti/unifi_6_lr#installation_steps |
| [ubiquiti-unifi-6-lr-v3](#ubiquiti-unifi-6-lr-v3) | Ubiquiti UniFi 6 LR v3 | mediatek-mt7622 | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://openwrt.org/toh/ubiquiti/unifi_6_lr#installation_steps |
| [xiaomi-redmi-router-ax6s](#xiaomi-redmi-router-ax6s) | Xiaomi Redmi Router AX6S / AX3200 | mediatek-mt7622 | K0+ | [`sonderweg-xiaomi-redmi-router-ax6s`](#familie-sonderweg-xiaomi-redmi-router-ax6s) | webui-upload | nein | nein | nein | - |
| [enterasys-ws-ap3715i](#enterasys-ws-ap3715i) | Enterasys WS-AP3715i | mpc85xx-p1010 | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | nein | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=765f66810a3324cc35fa6471ee8eeee335ba8c2b |
| [sophos-red-15w-rev.1](#sophos-red-15w-rev.1) | Sophos RED 15w Rev. 1 | mpc85xx-p1010 | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | nein | teilweise |  |
| [tp-link-tl-wdr4900-v1](#tp-link-tl-wdr4900-v1) | TP-Link TL-WDR4900 v1 | mpc85xx-p1010 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [aerohive-hiveap-330](#aerohive-hiveap-330) | Aerohive HiveAP 330 | mpc85xx-p1020 | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | nein | teilweise |  |
| [enterasys-ws-ap3710i](#enterasys-ws-ap3710i) | Enterasys WS-AP3710i | mpc85xx-p1020 | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | nein | teilweise | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=16b01fb1b9c99513c318109bef96a1a3545c57a0 |
| [extreme-networks-ws-ap3825i](#extreme-networks-ws-ap3825i) | Extreme Networks WS-AP3825i | mpc85xx-p1020 | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | nein | teilweise | https://forum.darmstadt.freifunk.net/t/flashing-of-the-extreme-networks-ws-ap3825i/923 |
| [hewlett-packard-msm460](#hewlett-packard-msm460) | HPE MSM460 | mpc85xx-p1020 | K5 | [`sonderweg-hewlett-packard-msm460`](#familie-sonderweg-hewlett-packard-msm460) | tftp-server-am-geraet | nein | nein | nein | https://github.com/blocktrron/msm460-flashing?tab=readme-ov-file |
| [ocedo-panda](#ocedo-panda) | OCEDO Panda | mpc85xx-p1020 | K1 | [`ocedo-tftp`](#familie-ocedo-tftp) | tftp-client-am-geraet | nein | nein | teilweise |  |
| [linksys-mx5300](#linksys-mx5300) | Linksys MX5300 | qualcommax-ipq807x | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | - |
| [netgear-wax218](#netgear-wax218) | NETGEAR WAX218 | qualcommax-ipq807x | K1 | [`sonderweg-netgear-wax218`](#familie-sonderweg-netgear-wax218) | webui-upload | nein | nein | ja | - |
| [tp-link-eap620-hd-v1](#tp-link-eap620-hd-v1) | TP-Link EAP620 HD v1 | qualcommax-ipq807x | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client | ja | ja | teilweise | - |
| [xiaomi-ax3600](#xiaomi-ax3600) | Xiaomi AX3600 | qualcommax-ipq807x | K2 | [`sonderweg-xiaomi-ax3600`](#familie-sonderweg-xiaomi-ax3600) | ssh | nein | nein | teilweise | - |
| [asus-rt-ac51u](#asus-rt-ac51u) | ASUS RT-AC51U | ramips-mt7620 | K1d | [`asus-firmware-restoration`](#familie-asus-firmware-restoration) | tftp-server-am-geraet | nein | nein | nein | https://openwrt.org/toh/asus/rt-ac51u#installation |
| [gl-mt300a](#gl-mt300a) | GL.iNet GL-MT300A | ramips-mt7620 | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [gl-mt300n](#gl-mt300n) | GL.iNet GL-MT300N (v1) | ramips-mt7620 | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [gl-mt750](#gl-mt750) | GL.iNet GL-MT750 | ramips-mt7620 | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [netgear-ex3700](#netgear-ex3700) | NETGEAR EX3700/EX3800 (Alias netgear-ex3800) | ramips-mt7620 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | webui-upload | nein | nein | nein | https://freifunk-ingolstadt.de/installationsanleitung-für-netgear-wi-fi-range-extender-ex3700/ |
| [netgear-ex6130](#netgear-ex6130) | NETGEAR EX6130 | ramips-mt7620 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | webui-upload | nein | nein | nein |  |
| [nexx-wt3020-8m](#nexx-wt3020-8m) | Nexx WT3020 8M (Aliase WT3020AD/F/H) | ramips-mt7620 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c2-v1](#tp-link-archer-c2-v1) | TP-Link Archer C2 v1 | ramips-mt7620 | K3 | [`tplink-ubootteil-dd`](#familie-tplink-ubootteil-dd) | tftp-client-am-geraet | nein | nein | nein |  |
| [tp-link-archer-c20-v1](#tp-link-archer-c20-v1) | TP-Link Archer C20 v1 | ramips-mt7620 | K3 | [`tplink-ubootteil-dd`](#familie-tplink-ubootteil-dd) | tftp-client-am-geraet | nein | nein | nein |  |
| [tp-link-archer-c20i](#tp-link-archer-c20i) | TP-Link Archer C20i | ramips-mt7620 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c50-v1](#tp-link-archer-c50-v1) | TP-Link Archer C50 v1 | ramips-mt7620 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [xiaomi-miwifi-mini](#xiaomi-miwifi-mini) | Xiaomi MiWiFi Mini | ramips-mt7620 | K1d | [`ssh-stock`](#familie-ssh-stock) | ssh | nein | nein | nein |  |
| [asus-rt-ac57u-v1](#asus-rt-ac57u-v1) | ASUS RT-AC57U v1 | ramips-mt7621 | K1d | [`asus-firmware-restoration`](#familie-asus-firmware-restoration) | tftp-server-am-geraet | nein | nein | nein |  |
| [asus-rt-ax53u](#asus-rt-ax53u) | ASUS RT-AX53U (RT-AX1800U) | ramips-mt7621 | K1 | [`asus-firmware-restoration`](#familie-asus-firmware-restoration) | tftp-server-am-geraet | nein | nein | ja | https://openwrt.org/toh/asus/rt-ax53u#installation_with_mtd-write |
| [cudy-ap1300-outdoor-v1](#cudy-ap1300-outdoor-v1) | Cudy AP1300 Outdoor v1 | ramips-mt7621 | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-m1800](#cudy-m1800) | Cudy M1800 | ramips-mt7621 | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein |  |
| [cudy-wr1300-v1](#cudy-wr1300-v1) | Cudy WR1300 v1 | ramips-mt7621 | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-wr2100](#cudy-wr2100) | Cudy WR2100 | ramips-mt7621 | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-x6-v1](#cudy-x6-v1) | Cudy X6 v1 | ramips-mt7621 | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-x6-v2](#cudy-x6-v2) | Cudy X6 v2 | ramips-mt7621 | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [d-link-covr-x1860-a1](#d-link-covr-x1860-a1) | D-Link COVR-X1860 A1 | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://freifunk-aachen.de/2023/08/03/installationsanleitung-d-link-covr-x1860/ |
| [d-link-dap-1620-b1](#d-link-dap-1620-b1) | D-Link DAP-1620 B1 (Gluon: broken) | ramips-mt7621 | K0 | [`dlink-recovery-web`](#familie-dlink-recovery-web) | recovery-web | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=e4c7703d2a62b8914e4723adae3f67c68a57532c |
| [d-link-dap-x1860-a1](#d-link-dap-x1860-a1) | D-Link DAP-X1860 A1 | ramips-mt7621 | K0 | [`dlink-recovery-web`](#familie-dlink-recovery-web) | recovery-web | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-d-link-dap-x1860/987 |
| [d-link-dir-860l-b1](#d-link-dir-860l-b1) | D-Link DIR-860L B1 | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [d-link-dir-878-a1](#d-link-dir-878-a1) | D-Link DIR-878 A1 | ramips-mt7621 | K0 | [`dlink-recovery-web`](#familie-dlink-recovery-web) | recovery-web | nein | nein | nein | https://openwrt.org/toh/d-link/dir-878_a1#installation |
| [d-link-dir-882-a1](#d-link-dir-882-a1) | D-Link DIR-882 A1 | ramips-mt7621 | K0 | [`dlink-recovery-web`](#familie-dlink-recovery-web) | recovery-web | nein | nein | nein | https://openwrt.org/toh/d-link/dir-882_a1#installation |
| [genexis-pulse-ex400](#genexis-pulse-ex400) | Genexis/Inteno Pulse EX400 | ramips-mt7621 | K1 | [`sonderweg-genexis-pulse-ex400`](#familie-sonderweg-genexis-pulse-ex400) | webui-upload | nein | nein | ja | https://github.com/freifunk-darmstadt/projects/wiki/90-%E2%80%90-Hardware-%E2%80%90-Genexis-EX400 |
| [gl.inet-gl-mt1300](#gl.inet-gl-mt1300) | GL.iNet GL-MT1300 (Beryl) | ramips-mt7621 | K1d | [`glinet`](#familie-glinet) | recovery-web | nein | nein | nein |  |
| [mercusys-mr70x-v1](#mercusys-mr70x-v1) | Mercusys MR70X v1 | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [mikrotik-routerboard-750gr3](#mikrotik-routerboard-750gr3) | MikroTik hEX RB750Gr3 (Alias mikrotik-routerboard-hex-v3) | ramips-mt7621 | K1 | [`mikrotik-netboot`](#familie-mikrotik-netboot) | tftp-client-am-geraet | nein | nein | ja | https://openwrt.org/toh/mikrotik/common |
| [netgear-eax12](#netgear-eax12) | NETGEAR EAX12 (Aliase EAX11 v2, EAX15 v2) | ramips-mt7621 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | webui-upload | nein | nein | nein |  |
| [netgear-ex6150](#netgear-ex6150) | NETGEAR EX6150 (v1) | ramips-mt7621 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | webui-upload | nein | nein | nein | https://freifunk-ingolstadt.de/eigener-freifunk-hotspot/anleitung/installationsanleitung-für-netgear-wi-fi-range-extender-ex6150-v2/ |
| [netgear-r6220](#netgear-r6220) | NETGEAR R6220 | ramips-mt7621 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | webui-upload | nein | nein | nein | https://freifunk-ingolstadt.de/installationsanleitung-für-netgear-r6220/ |
| [netgear-r6260](#netgear-r6260) | NETGEAR R6260 | ramips-mt7621 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | webui-upload | nein | nein | nein |  |
| [netgear-wac104](#netgear-wac104) | NETGEAR WAC104 | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [netgear-wax202](#netgear-wax202) | NETGEAR WAX202 | ramips-mt7621 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | webui-upload | nein | nein | nein | https://openwrt.org/toh/netgear/wax202#oem_easy_installation |
| [netgear-wndr3700-v5](#netgear-wndr3700-v5) | NETGEAR WNDR3700 v5 (Gluon: broken, "untested") | ramips-mt7621 | K0+ | [`netgear-nmrp`](#familie-netgear-nmrp) | herstellertool | nein | nein | nein |  |
| [totolink-x5000r](#totolink-x5000r) | TOTOLINK X5000R | ramips-mt7621 | K1d | [`sonderweg-totolink-x5000r`](#familie-sonderweg-totolink-x5000r) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-ax23-v1](#tp-link-archer-ax23-v1) | TP-Link Archer AX23 v1 (Gluon: broken) | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c6-v3](#tp-link-archer-c6-v3) | TP-Link Archer C6 v3 (Gluon: broken) | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-eap613-v1](#tp-link-eap613-v1) | TP-Link EAP613 v1 | ramips-mt7621 | K0 | [`tplink-eap-ssh`](#familie-tplink-eap-ssh) | ssh | nein | nein | nein |  |
| [tp-link-eap615-wall-v1](#tp-link-eap615-wall-v1) | TP-Link EAP615-Wall v1 | ramips-mt7621 | K0 | [`tplink-eap-ssh`](#familie-tplink-eap-ssh) | ssh | nein | nein | nein |  |
| [tp-link-re500-v1](#tp-link-re500-v1) | TP-Link RE500 v1 | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-re650-v1](#tp-link-re650-v1) | TP-Link RE650 v1 | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [ubiquiti-edgerouter-x](#ubiquiti-edgerouter-x) | Ubiquiti EdgeRouter X | ramips-mt7621 | K3 | [`ubiquiti-edgerouter`](#familie-ubiquiti-edgerouter) | webui-upload | nein | nein | nein | https://github.com/oszilloskop/UBNT_ERX_Gluon_Factory-Image/blob/master/README.md#gluon-auf-ubnt-edgerouter-x-und-x-sfp |
| [ubiquiti-edgerouter-x-sfp](#ubiquiti-edgerouter-x-sfp) | Ubiquiti EdgeRouter X-SFP | ramips-mt7621 | K3 | [`ubiquiti-edgerouter`](#familie-ubiquiti-edgerouter) | webui-upload | nein | nein | nein | https://github.com/oszilloskop/UBNT_ERX_Gluon_Factory-Image/blob/master/README.md#gluon-auf-ubnt-edgerouter-x-und-x-sfp |
| [ubiquiti-unifi-6-lite](#ubiquiti-unifi-6-lite) | Ubiquiti UniFi 6 Lite | ramips-mt7621 | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein | https://openwrt.org/toh/ubiquiti/unifi6lite#installation |
| [ubiquiti-unifi-nanohd](#ubiquiti-unifi-nanohd) | Ubiquiti UniFi nanoHD | ramips-mt7621 | K1d | [`ubiquiti-unifi-ssh`](#familie-ubiquiti-unifi-ssh) | ssh | nein | nein | nein |  |
| [wavlink-ws-wn572hp3-4g](#wavlink-ws-wn572hp3-4g) | Wavlink WS-WN572HP3 4G | ramips-mt7621 | K1d | [`recovery-web`](#familie-recovery-web) | recovery-web | nein | nein | nein | https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6cd1035d8dc001561331ca9e613d7dfc7d0fd7a6 |
| [xiaomi-mi-router-3g](#xiaomi-mi-router-3g) | Xiaomi Mi Router 3G | ramips-mt7621 | K2 | [`sonderweg-xiaomi-mi-router-3g`](#familie-sonderweg-xiaomi-mi-router-3g) | ssh | nein | nein | nein |  |
| [xiaomi-mi-router-3g-v2](#xiaomi-mi-router-3g-v2) | Xiaomi Mi Router 3G v2 | ramips-mt7621 | K2 | [`xiaomi-openwrtinvasion`](#familie-xiaomi-openwrtinvasion) | ssh | nein | nein | nein |  |
| [xiaomi-mi-router-4a-gigabit-edition](#xiaomi-mi-router-4a-gigabit-edition) | Xiaomi Mi Router 4A Gigabit | ramips-mt7621 | K1d | [`xiaomi-openwrtinvasion`](#familie-xiaomi-openwrtinvasion) | ssh | nein | nein | nein | https://github.com/acecilia/OpenWRTInvasion/blob/master/README.md |
| [xiaomi-mi-router-4a-gigabit-edition-v2](#xiaomi-mi-router-4a-gigabit-edition-v2) | Xiaomi Mi Router 4A Gigabit v2 | ramips-mt7621 | K1d | [`xiaomi-openwrtinvasion`](#familie-xiaomi-openwrtinvasion) | ssh | nein | nein | nein |  |
| [xiaomi-mi-router-ac2100](#xiaomi-mi-router-ac2100) | Xiaomi Mi Router AC2100 (R2100) | ramips-mt7621 | K2 | [`xiaomi-ac2100-pppoe`](#familie-xiaomi-ac2100-pppoe) | ssh | nein | nein | nein |  |
| [xiaomi-redmi-router-ac2100](#xiaomi-redmi-router-ac2100) | Xiaomi Redmi Router AC2100 (RM2100) | ramips-mt7621 | K2 | [`xiaomi-ac2100-pppoe`](#familie-xiaomi-ac2100-pppoe) | ssh | nein | nein | nein | https://openwrt.org/toh/xiaomi/xiaomi_redmi_router_ac2100 |
| [zbtlink-zbt-wg3526-16m](#zbtlink-zbt-wg3526-16m) | ZBT WG3526 16M | ramips-mt7621 | K1d | [`recovery-web`](#familie-recovery-web) | recovery-web | nein | nein | nein |  |
| [zbtlink-zbt-wg3526-32m](#zbtlink-zbt-wg3526-32m) | ZBT WG3526 32M | ramips-mt7621 | K1d | [`recovery-web`](#familie-recovery-web) | recovery-web | nein | nein | nein |  |
| [zyxel-nwa50ax](#zyxel-nwa50ax) | ZyXEL NWA50AX (Alias NWA90AX) | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-nwa50ax-nwa55axe/964 |
| [zyxel-nwa55axe](#zyxel-nwa55axe) | ZyXEL NWA55AXE (Gluon: broken) | ramips-mt7621 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-nwa50ax-nwa55axe/964 |
| [zyxel-wsm20](#zyxel-wsm20) | ZyXEL WSM20 (Multy M1) | ramips-mt7621 | K1 | [`sonderweg-zyxel-wsm20`](#familie-sonderweg-zyxel-wsm20) | webui-upload | nein | nein | ja | https://freifunk-aachen.de/2024/01/04/installationsanleitung-zyxel-wsm20/ |
| [cudy-tr1200-v1](#cudy-tr1200-v1) | Cudy TR1200 v1 | ramips-mt76x8 | K2 | [`cudy-zwischenfirmware`](#familie-cudy-zwischenfirmware) | webui-upload | nein | nein | nein | https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010 |
| [cudy-wr1000](#cudy-wr1000) | Cudy WR1000 | ramips-mt76x8 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [gl-mt300n-v2](#gl-mt300n-v2) | GL.iNet GL-MT300N v2 | ramips-mt76x8 | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [gl.inet-microuter-n300](#gl.inet-microuter-n300) | GL.iNet microuter-N300 | ramips-mt76x8 | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [gl.inet-vixmini](#gl.inet-vixmini) | GL.iNet VIXMINI | ramips-mt76x8 | K1d | [`glinet`](#familie-glinet) | webui-upload | nein | nein | nein |  |
| [netgear-r6020](#netgear-r6020) | NETGEAR R6020 | ramips-mt76x8 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | herstellertool | nein | nein | nein |  |
| [netgear-r6120](#netgear-r6120) | NETGEAR R6120 | ramips-mt76x8 | K0 | [`netgear-nmrp`](#familie-netgear-nmrp) | herstellertool | nein | nein | nein | https://freifunk-ingolstadt.de/eigener-freifunk-hotspot/anleitung/installationsanleitung-für-netgear-r6120/ |
| [ravpower-rp-wd009](#ravpower-rp-wd009) | RAVPower RP-WD009 | ramips-mt76x8 | K0 | [`recovery-web`](#familie-recovery-web) | recovery-web | nein | nein | nein | https://openwrt.org/toh/ravpower/rp-wd009#oem_installation_using_the_tftp_method |
| [tp-link-archer-c20-v4](#tp-link-archer-c20-v4) | TP-Link Archer C20 v4 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein |  |
| [tp-link-archer-c20-v5](#tp-link-archer-c20-v5) | TP-Link Archer C20 v5 | ramips-mt76x8 | K3 | [`tplink-ubootteil-dd`](#familie-tplink-ubootteil-dd) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c50-v3](#tp-link-archer-c50-v3) | TP-Link Archer C50 v3 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein |  |
| [tp-link-archer-c50-v4](#tp-link-archer-c50-v4) | TP-Link Archer C50 v4 | ramips-mt76x8 | K3 | [`tplink-ubootteil-dd`](#familie-tplink-ubootteil-dd) | webui-upload | nein | nein | nein |  |
| [tp-link-archer-c50-v6-ca-eu-ru](#tp-link-archer-c50-v6-ca-eu-ru) | TP-Link Archer C50 v6 (CA/EU/RU; nicht ES = C54) | ramips-mt76x8 | K3 | [`tplink-ubootteil-dd`](#familie-tplink-ubootteil-dd) | webui-upload | nein | nein | nein |  |
| [tp-link-re200-v2](#tp-link-re200-v2) | TP-Link RE200 v2 | ramips-mt76x8 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-re200-v3](#tp-link-re200-v3) | TP-Link RE200 v3 | ramips-mt76x8 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-re200-v4](#tp-link-re200-v4) | TP-Link RE200 v4 | ramips-mt76x8 | K0 | [`k0-webui`](#familie-k0-webui) | webui-upload | nein | nein | nein |  |
| [tp-link-tl-mr3020-v3](#tp-link-tl-mr3020-v3) | TP-Link TL-MR3020 v3 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein |  |
| [tp-link-tl-mr3420-v5](#tp-link-tl-mr3420-v5) | TP-Link TL-MR3420 v5 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein |  |
| [tp-link-tl-mr6400-v5](#tp-link-tl-mr6400-v5) | TP-Link TL-MR6400 v5 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein |  |
| [tp-link-tl-wa801nd-v5](#tp-link-tl-wa801nd-v5) | TP-Link TL-WA801ND v5 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein |  |
| [tp-link-tl-wr841n-v13](#tp-link-tl-wr841n-v13) | TP-Link TL-WR841N v13 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein | https://openwrt.org/toh/tp-link/tl-wr841nd#tftp_recovery_via_bootloader_for_v8_v9_v10_v11_v12_v13 |
| [tp-link-tl-wr902ac-v3](#tp-link-tl-wr902ac-v3) | TP-Link TL-WR902AC v3 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein | https://openwrt.org/toh/tp-link/tl-wr902ac_v3#installation |
| [tp-link-tl-wr902ac-v4](#tp-link-tl-wr902ac-v4) | TP-Link TL-WR902AC v4 | ramips-mt76x8 | K1d | [`tplink-tftp-recovery`](#familie-tplink-tftp-recovery) | tftp-client-am-geraet | nein | nein | nein |  |
| [vocore2](#vocore2) | VoCore2 | ramips-mt76x8 | K1d | [`ssh-stock`](#familie-ssh-stock) | ssh | nein | nein | nein |  |
| [xiaomi-mi-ra75](#xiaomi-mi-ra75) | Xiaomi Mi WiFi Range Extender AC1200 RA75 (Gluon: broken, "Only serial flash possible") | ramips-mt76x8 | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | ja | nein |  |
| [xiaomi-mi-router-4a-100m-edition](#xiaomi-mi-router-4a-100m-edition) | Xiaomi Mi Router 4A 100M | ramips-mt76x8 | K4 | [`seriell-tftp`](#familie-seriell-tftp) | tftp-client-am-geraet | ja | ja | nein | https://openwrt.org/toh/xiaomi/mi_router_4a_mir4a_100m#installation |
| [xiaomi-mi-router-4a-100m-international-edition](#xiaomi-mi-router-4a-100m-international-edition) | Xiaomi Mi Router 4A 100M International (R4AC) | ramips-mt76x8 | K1d | [`xiaomi-openwrtinvasion`](#familie-xiaomi-openwrtinvasion) | ssh | nein | nein | nein | https://forum.ffrn.de/t/howto-installation-xiaomi-mi-router-4a-r4ac-100m-international-edition/3536 |
| [xiaomi-mi-router-4a-100m-international-edition-v2](#xiaomi-mi-router-4a-100m-international-edition-v2) | Xiaomi Mi Router 4A 100M International v2 | ramips-mt76x8 | K2 | [`xiaomi-openwrtinvasion`](#familie-xiaomi-openwrtinvasion) | ssh | nein | nein | nein |  |
| [xiaomi-mi-router-4c](#xiaomi-mi-router-4c) | Xiaomi Mi Router 4C | ramips-mt76x8 | K2 | [`xiaomi-openwrtinvasion`](#familie-xiaomi-openwrtinvasion) | ssh | nein | nein | nein | https://github.com/acecilia/OpenWRTInvasion/blob/master/README.md |
| [friendlyelec-nanopi-r2c](#friendlyelec-nanopi-r2c) | FriendlyElec NanoPi R2C | rockchip-armv8 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | sd-karte | nein | nein | nein | - |
| [friendlyelec-nanopi-r2s](#friendlyelec-nanopi-r2s) | FriendlyElec NanoPi R2S | rockchip-armv8 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | sd-karte | nein | nein | nein | - |
| [friendlyelec-nanopi-r3s](#friendlyelec-nanopi-r3s) | FriendlyElec NanoPi R3S | rockchip-armv8 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | sd-karte | nein | nein | nein | - |
| [friendlyelec-nanopi-r4s](#friendlyelec-nanopi-r4s) | FriendlyElec NanoPi R4S (4 GB) | rockchip-armv8 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | sd-karte | nein | nein | nein | - |
| [x86-64](#x86-64) | x86 (x86-64) | x86-64 | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | Datenträger | nein | nein | nein | - |
| [x86-generic](#x86-generic) | x86 (x86-generic) | x86-generic | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | Datenträger | nein | nein | nein | - |
| [x86-geode](#x86-geode) | x86 (x86-geode) | x86-geode | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | Datenträger | nein | nein | nein | - |
| [x86-legacy](#x86-legacy) | x86 (x86-legacy) | x86-legacy | K0 | [`image-auf-datentraeger`](#familie-image-auf-datentraeger) | Datenträger | nein | nein | nein | - |

<!-- END erzeugt:uebersicht -->

## Einzelheiten nach Anleitungsfamilie

<!-- BEGIN erzeugt:einzelheiten -->
<!-- erzeugt von scripts/erstinstallation.py aus data/geraete-2025.1.json, nicht von Hand ändern -->

### Familie `ap51-flash`

26 Gerät(e).

#### openmesh-a40

OpenMesh A40 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_a40-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 9a172797e593c061f6759a37eaeba2956ad8d72f [geprüft]

#### openmesh-a60

OpenMesh A60 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_a60-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** eaf2e32c12655d7fb58e158086a784393dc6f69a [geprüft]

#### openmesh-mr1750-v1

OpenMesh MR1750 v1 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_mr1750-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** ae7680dc4bf914d640dba32c8f1c36631768a56a [geprüft]

#### openmesh-mr1750-v2

OpenMesh MR1750 v2 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_mr1750-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 0988e03f0e676286f3377d1530ebfb0d819ee629 [geprüft]

#### openmesh-mr600-v1

OpenMesh MR600 v1 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_mr600-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 4b35999588ee6dbe1fd818760b358b1191ddd0be [geprüft]

#### openmesh-mr600-v2

OpenMesh MR600 v2 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_mr600-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** d9a3af46d8a1001223c2a327f449b7048d0fd5f6 [geprüft]

#### openmesh-mr900-v1

OpenMesh MR900 v1 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_mr900-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** e06c9eec5dc8a3721df768ab952712cf015d4e6f [geprüft]

#### openmesh-mr900-v2

OpenMesh MR900 v2 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_mr900-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 31172e53f9d0971204e6fa7e3541c0695d99618a [geprüft]

#### openmesh-om2p-hs-v1

OpenMesh OM2P-HS v1 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om2p-hs-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** a462412977cc25b79a7a3479527e754d85c23fd7 [geprüft]

#### openmesh-om2p-hs-v2

OpenMesh OM2P-HS v2 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om2p-hs-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** f096accce26bc46831e859ccd40b3f88e404cc7e [geprüft]

#### openmesh-om2p-hs-v3

OpenMesh OM2P-HS v3 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om2p-hs-v3-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 75900a25ed2acd4201bcd9a5516bdf7cdb9a8e73 [geprüft]

#### openmesh-om2p-hs-v4

OpenMesh OM2P-HS v4 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om2p-hs-v4-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 5b37b52e69884c6c843738cc45ed8a1deba0eba3 [geprüft]

#### openmesh-om2p-lc

OpenMesh OM2P-LC · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om2p-lc-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** eb3a5ddba0d4d0c4ab1f21ccbfbcf9aa0254bce9 [geprüft]

#### openmesh-om2p-v1

OpenMesh OM2P v1 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om2p-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 32 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 8143709c90c3aa0a84e14cf4a9dfbcb365b0d966 [geprüft]

#### openmesh-om2p-v2

OpenMesh OM2P v2 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om2p-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** ff9e48e75c191e0d7e08a14791853559d509ca2e [geprüft]

#### openmesh-om2p-v4

OpenMesh OM2P v4 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om2p-v4-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** dd1d95cb0357278900d09fae3ad20e9e0b2d569a [geprüft]

#### openmesh-om5p

OpenMesh OM5P · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om5p-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 80713657b20d58c2fb7fa503e24cbf7db379550f [geprüft]

#### openmesh-om5p-ac-v1

OpenMesh OM5P-AC v1 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om5p-ac-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 97f561725962ddb8823b2e01563a0f37f7930477 [geprüft]

#### openmesh-om5p-ac-v2

OpenMesh OM5P-AC v2 · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om5p-ac-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 1699c1dc7f26b332f868d338457abfbe716d6ba0 (Einführung, Anleitung) [geprüft]

#### openmesh-om5p-an

OpenMesh OM5P-AN · ath79-generic · K1d

- **Weg ab Werk:** Bootloader nimmt Images per ap51-flash beim Einschalten an; alternativ seriell U-Boot + TFTP-initramfs, dann sysupgrade [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner am LAN, Gerät einschalten); alternativ tftp-client: U-Boot-Shell, serverip frei (Beispiel 192.168.1.21), Gerät 192.168.1.1
- **seriell nötig:** nein (nur für den seriellen Notweg über TFTP: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, TTL-Pins auf der Platine)
- **Werkzeug/Spezial:** ap51-flash (github.com/ap51-flash/ap51-flash)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-openmesh_om5p-an-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-sysupgrade direkt; im UART-Weg könnte die Gluon-RAMpe das OpenWrt-initramfs ersetzen, spart aber nichts
- **Quelle (OpenWrt-Commit):** 72ef5945508193228544bcd7fcfe81b32e8dc042 [geprüft]

#### plasma-cloud-pa300

Plasma Cloud PA300 · ath79-generic · K0+

- **Weg ab Werk:** factory per ap51-flash an den U-Boot beim Einschalten übertragen [geprüft]
- **Übertragung:** herstellertool: ap51-flash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ap51-flash
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-plasmacloud_pa300-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-plasmacloud_pa300-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-factory direkt
- **Quelle (OpenWrt-Commit):** 5fc28ef47959c1256f2553d507224bb481b08494 [geprüft]

#### plasma-cloud-pa300e

Plasma Cloud PA300E · ath79-generic · K0+

- **Weg ab Werk:** factory per ap51-flash an den U-Boot beim Einschalten übertragen [geprüft]
- **Übertragung:** herstellertool: ap51-flash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ap51-flash
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-plasmacloud_pa300e-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-plasmacloud_pa300e-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: ap51-flash schreibt das Gluon-factory direkt
- **Quelle (OpenWrt-Commit):** 17e592049005f3f7e65429966b21b2d834f9c2f0 [geprüft]

#### openmesh-a42

OpenMesh A42 · ipq40xx-generic · K0+

- **Weg ab Werk:** ap51-flash schiebt das Gluon-factory beim Einschalten in den U-Boot [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner direkt am Gerät)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ap51-flash
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-openmesh_a42-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-openmesh_a42-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory über ap51-flash)
- **Quelle (OpenWrt-Commit):** OpenWrt 86e18f6706e1f2c881fb6a2b9facf108573416e6
- **Detail-Anleitung:** -

#### openmesh-a62

OpenMesh A62 · ipq40xx-generic · K0+

- **Weg ab Werk:** ap51-flash schiebt das Gluon-factory beim Einschalten in den U-Boot [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner direkt am Gerät)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ap51-flash
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-openmesh_a62-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-openmesh_a62-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory über ap51-flash)
- **Quelle (OpenWrt-Commit):** OpenWrt 0b204902075157dbb002ea04f41a5b1a4fbe848c
- **Detail-Anleitung:** -

#### plasma-cloud-pa1200

Plasma Cloud PA1200 · ipq40xx-generic · K0+

- **Weg ab Werk:** ap51-flash schiebt das Gluon-factory beim Einschalten in den U-Boot [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner direkt am Gerät)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ap51-flash
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-plasmacloud_pa1200-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-plasmacloud_pa1200-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory über ap51-flash)
- **Quelle (OpenWrt-Commit):** OpenWrt ea5bb6bbfee06f44f714aff40c8929505face221
- **Detail-Anleitung:** -

#### plasma-cloud-pa2200

Plasma Cloud PA2200 · ipq40xx-generic · K0+

- **Weg ab Werk:** ap51-flash schiebt das Gluon-factory beim Einschalten in den U-Boot [geprüft]
- **Übertragung:** herstellertool: ap51-flash (Rechner direkt am Gerät)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ap51-flash
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-plasmacloud_pa2200-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-plasmacloud_pa2200-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory über ap51-flash)
- **Quelle (OpenWrt-Commit):** OpenWrt 4871fd2616acb03fefe69b068955dba36eb00770
- **Detail-Anleitung:** -

### Familie `aruba-apboot`

5 Gerät(e).

#### aruba-ap-303

Aruba AP-303 · ipq40xx-generic · K4

- **Weg ab Werk:** serielle apboot-Konsole: bootargs/nandboot/ramboot setzen, initramfs als `ipq40xx.ari` per netget booten, `ubidetach/ubiformat /dev/mtd1`, `sysupgrade -n` [geprüft]; bei gesperrtem apboot siehe Instant On AP11
- **Übertragung:** tftp-client (apboot `netget`): Server 192.168.1.75, Gerät 192.168.1.105, Datei ipq40xx.ari
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: Micro-USB-Buchse "Console" als UART-Stecker (kein USB!): D+ = TX, D- = RX, GND = GND, VCC nicht belegt (so im Commit, aus wessen Sicht TX gemeint ist, steht dort nicht); 3,3 V, 9600 8N1, eigener USB-TTL-Adapter [geprüft]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-303-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: RAMpe-initramfs als ipq40xx.ari geht, aber vor dem sysupgrade muss `ubiformat` laufen (fehlt der Gluon-RAMpe) und Gluon baut für ipq40xx-generic kein initramfs; seriell bleibt [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 102c8c55f217606cdbdc9a449667e034676b3e75
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=102c8c55f217606cdbdc9a449667e034676b3e75

#### aruba-ap-303h

Aruba AP-303H · ipq40xx-generic · K4

- **Weg ab Werk:** wie AP-303, TFTP nur über Port E0 (WAN), danach `ubiformat /dev/mtd16`, `sysupgrade -n` [geprüft]
- **Übertragung:** tftp-client (apboot `netget`): Server 192.168.1.75, Gerät 192.168.1.105, Datei ipq40xx.ari (Rechner an E0)
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: Micro-USB als UART-Stecker wie AP-303 (D+ = TX, D- = RX laut Commit), 9600 8N1 [geprüft]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-303h-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: wie AP-303
- **Quelle (OpenWrt-Commit):** OpenWrt c6e972c8772a628a1a2f2e5590d7c6f4acef9ab0
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=c6e972c8772a628a1a2f2e5590d7c6f4acef9ab0

#### aruba-ap-365

Aruba AP-365 · ipq40xx-generic · K4

- **Weg ab Werk:** wie AP-303 (apboot, ipq40xx.ari per netget, `ubiformat` der Partition "ubi", `sysupgrade -n`) [geprüft]
- **Übertragung:** tftp-client (apboot `netget`): Server 192.168.1.75, Gerät 192.168.1.105, Datei ipq40xx.ari
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: USB-Konsole echt (CP2101 auf der Platine), 9600 8N1 [geprüft]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-365-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: wie AP-303
- **Quelle (OpenWrt-Commit):** OpenWrt 300b7fe85a743ab0e039457a5a551819b49450da
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=300b7fe85a743ab0e039457a5a551819b49450da

#### aruba-instant-on-ap11d

Aruba Instant On AP11D (Alias von aruba-ap-303h) · ipq40xx-generic · K4

- **Weg ab Werk:** wie AP-303H; ob das apboot gesperrt ist wie beim AP11: ? [abgeleitet]
- **Übertragung:** tftp-client (apboot `netget`): Server 192.168.1.75, Gerät 192.168.1.105, Datei ipq40xx.ari
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: Micro-USB als UART-Stecker [abgeleitet]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-303h-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: wie AP-303
- **Quelle (OpenWrt-Commit):** OpenWrt c6e972c8772a628a1a2f2e5590d7c6f4acef9ab0
- **Detail-Anleitung:** -

#### aruba-instant-on-ap17

Aruba Instant On AP17 (Alias von aruba-ap-365) · ipq40xx-generic · K4

- **Weg ab Werk:** wie AP-365; apboot-Sperre wie beim AP11: ? [abgeleitet]
- **Übertragung:** tftp-client (apboot `netget`): Server 192.168.1.75, Gerät 192.168.1.105, Datei ipq40xx.ari
- **seriell nötig:** ja
- **Gehäuse öffnen:** USB, Art ? (AP-365: echt, CP2101) [abgeleitet]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-365-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: wie AP-303
- **Quelle (OpenWrt-Commit):** OpenWrt 300b7fe85a743ab0e039457a5a551819b49450da
- **Detail-Anleitung:** -

### Familie `asus-firmware-restoration`

3 Gerät(e).

#### asus-rt-ac51u

ASUS RT-AC51U · ramips-mt7620 · K1d

- **Weg ab Werk:** Reset beim Einschalten halten bis die Power-LED langsam blinkt; der Bootloader nimmt das sysupgrade per TFTP oder per ASUS Firmware Restoration [geprüft]
- **Übertragung:** tftp-server-am-geraet: Gerät 192.168.1.1, Rechner 192.168.1.75, LAN1; Dateiname beliebig (`tftp put`); alternativ herstellertool
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ASUS Firmware Restoration (Windows) oder tftp-Client
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-asus_rt-ac51u-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Recovery nimmt das sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 5f932988c3b65af14bd6e48a05cc2204b7aeb419
- **Detail-Anleitung:** https://openwrt.org/toh/asus/rt-ac51u#installation

#### asus-rt-ac57u-v1

ASUS RT-AC57U v1 · ramips-mt7621 · K1d

- **Weg ab Werk:** Reset beim Einschalten 5 s, Bootloader nimmt das sysupgrade per TFTP; alternativ SSH auf Stock + `mtd-write -i owrt.bin -d linux` [geprüft]
- **Übertragung:** tftp-server-am-geraet: Gerät 192.168.1.1, Rechner 192.168.1.75; oder ssh/scp admin@192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** tftp-Client
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-asus_rt-ac57u-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 14e0e4f138e35c3e2a15cc3a836c939547ee053b

#### asus-rt-ax53u

ASUS RT-AX53U (RT-AX1800U) · ramips-mt7621 · K1

- **Weg ab Werk:** Stock-Web-UI nimmt OpenWrt nicht. Reset beim Einschalten halten bis die Power-LED sehr langsam blinkt, initramfs-kernel per TFTP oder ASUS Firmware Restoration, dann sysupgrade; Alternative: SSH auf Stock + mtd-write mit factory [abgeleitet: Wiki; der Commit nennt nur das serielle U-Boot-Menü mit factory]
- **Übertragung:** tftp-server-am-geraet: Gerät 192.168.1.1, Rechner 192.168.1.10, Port LAN1, Dateiname beliebig; oder herstellertool ASUS Firmware Restoration
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** tftp-Client oder ASUS Firmware Restoration
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-asus_rt-ax53u-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community) (für mtd-write bzw. U-Boot-Menü)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** ja: genau der Fall "erst initramfs, dann sysupgrade"
- **Quelle (OpenWrt-Commit):** 8c00fd9b4519bf0ef8fb3470a6df421b9f38c03c
- **Detail-Anleitung:** https://openwrt.org/toh/asus/rt-ax53u#installation_with_mtd-write

### Familie `asus-tuf-herbetom`

2 Gerät(e).

#### asus-tuf-ax4200

ASUS TUF-AX4200 · mediatek-filogic · K2

- **Weg ab Werk:** OpenWrt-Commit nennt nur UART + TFTP-initramfs [geprüft]; ohne UART: SSH in die Stock-Firmware, Sonderbau "factory-initramfs" (herbetom) per wget holen und mit `mtd-write -d linux` schreiben, dann sysupgrade [geprüft: Release-Text herbetom filogic-v2]
- **Übertragung:** ssh + http-server-noetig: SSH admin@192.168.50.1, Rechner-HTTP-Server Port 8080 (Name openwrtimage.lan per /etc/hosts), Datei openwrt.bin; seriell: tftp-client Server 192.168.1.66, Gerät 192.168.1.1, Datei tufax4200.bin
- **seriell nötig:** nein (nur für den seriellen Notweg: ja)
- **Gehäuse öffnen:** nein (Lage der Konsole für den seriellen Notweg nicht belegt: ?)
- **Werkzeug/Spezial:** Sonderbau herbetom (Dez. 2023)
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-asus_tuf-ax4200-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [herbetom filogic-v2](https://github.com/herbetom/openwrt-asus-filogic-factory/releases/download/filogic-v2/openwrt-mediatek-filogic-asus_tuf-ax4200-initramfs-kernel.bin)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: der SSH-Weg schreibt ein initramfs ins Flash; ob ein Gluon-/RAMpe-initramfs statt des herbetom-Sonderbaus bootet, ist nicht geprüft
- **Quelle (OpenWrt-Commit):** OpenWrt e7c399bee677e9bac66e1bea697aefb8d828edfe
- **Detail-Anleitung:** https://github.com/freifunk-darmstadt/projects/wiki/90-%E2%80%90-Hardware-%E2%80%90-ASUS-TUF-AX4200

#### asus-tuf-ax6000

ASUS TUF-AX6000 · mediatek-filogic · K2

- **Weg ab Werk:** wie TUF-AX4200: SSH + mtd-write des herbetom-Sonderbaus [geprüft: Release-Text], oder UART + TFTP-initramfs [geprüft]
- **Übertragung:** ssh + http-server-noetig wie TUF-AX4200; seriell: tftp-client Server 192.168.1.70, Gerät 192.168.1.1, Datei TUF-AX6000.bin (U-Boot-Menü 1 oder 4)
- **seriell nötig:** nein (nur für den seriellen Notweg: ja)
- **Gehäuse öffnen:** nein, Konsole außen: drei Löcher im Gehäuse (von unten RX, TX, GND), Stiftleisten-Drähte, 115200 8N1 [geprüft]
- **Werkzeug/Spezial:** Sonderbau herbetom (Dez. 2023)
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-asus_tuf-ax6000-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [herbetom filogic-v2](https://github.com/herbetom/openwrt-asus-filogic-factory/releases/download/filogic-v2/openwrt-mediatek-filogic-asus_tuf-ax6000-initramfs-kernel.bin)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: wie TUF-AX4200; über die Gehäuselöcher ist auch der TFTP-Weg ohne Öffnen möglich, dort passt die Gluon-RAMpe als initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt d522ccecb28f941aadcaf7a50cd6daa861f468a7
- **Detail-Anleitung:** https://github.com/herbetom/openwrt-asus-filogic-factory/releases/latest

### Familie `avm-eva-ftp`

10 Gerät(e).

#### avm-fritz-box-4020

AVM FRITZ!Box 4020 · ath79-generic · K1d

- **Weg ab Werk:** AVM-EVA-Bootloader: in den ersten Sekunden nach Strom-an per FTP anmelden und das sysupgrade nach mtd1 schreiben, danach Strom aus/an [geprüft]
- **Übertragung:** ftp: Gerät 169.254.157.1 (laut Commit evtl. 192.168.178.1), USER/PASS adam2, binary, passive, `quote MEDIA FLSH`, `put <sysupgrade> mtd1`
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** AVM EVA (FTP); fritz-tools laut Firmware-Selector
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-avm_fritz4020-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [abgeleitet: Chip Winbond W971GG6KB laut Commit = 1 Gbit]
- **Gluon-RAMpe passt:** nein: EVA nimmt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 3f8c5d547677e7f4e450e88379c03448b8f53b1d [geprüft]
- **Detail-Anleitung:** https://fritz-tools.readthedocs.io/

#### avm-fritz-wlan-repeater-1750e

AVM FRITZ!WLAN Repeater 1750E (broken) · ath79-generic · K1d

- **Weg ab Werk:** AVM-EVA-Bootloader: in den ersten Sekunden nach Strom-an per FTP anmelden und das sysupgrade nach mtd1 schreiben, danach Strom aus/an [geprüft]
- **Übertragung:** ftp: Gerät 192.168.178.1, USER/PASS adam2, binary, passive, `quote MEDIA FLSH`, `put <sysupgrade> mtd1`
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** AVM EVA (FTP); fritz-tools laut Firmware-Selector
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-avm_fritz1750e-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: EVA nimmt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 8918c038f330a1bb5a898d80c170caf9f42cac89 [geprüft]

#### avm-fritz-wlan-repeater-300e

AVM FRITZ!WLAN Repeater 300E · ath79-generic · K1d

- **Weg ab Werk:** AVM-EVA-Bootloader: in den ersten Sekunden nach Strom-an per FTP anmelden und das sysupgrade nach mtd1 schreiben, danach Strom aus/an [geprüft]
- **Übertragung:** ftp: Gerät 192.168.178.1, USER/PASS adam2, binary, passive, `quote MEDIA FLSH`, `put <sysupgrade> mtd1`
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** AVM EVA (FTP); fritz-tools laut Firmware-Selector
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-avm_fritz300e-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [ar71xx-Commit e7cd6f5d]
- **Gluon-RAMpe passt:** nein: EVA nimmt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 75ed56a08a4ce978323259a59a8f45ceed511584 (ath79, ohne Anleitung); e7cd6f5d66b827e31cfa7e7bc019ac1b86aac770 (ar71xx, EVA-Anleitung) [geprüft]
- **Detail-Anleitung:** https://fritz-tools.readthedocs.io/

#### avm-fritz-wlan-repeater-450e

AVM FRITZ!WLAN Repeater 450E · ath79-generic · K1d

- **Weg ab Werk:** AVM-EVA-Bootloader: in den ersten Sekunden nach Strom-an per FTP anmelden und das sysupgrade nach mtd1 schreiben, danach Strom aus/an [geprüft]
- **Übertragung:** ftp: Gerät 192.168.178.1, USER/PASS adam2, binary, passive, `quote MEDIA FLSH`, `put <sysupgrade> mtd1`
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** AVM EVA (FTP); fritz-tools laut Firmware-Selector
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-avm_fritz450e-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: EVA nimmt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 8d9c1087e4d07d625a9fef61d5dce71d850732ae [geprüft]
- **Detail-Anleitung:** https://fritz-tools.readthedocs.io/

#### avm-fritz-box-4040

AVM FRITZ!Box 4040 · ipq40xx-generic · K1d

- **Weg ab Werk:** AVM-EVA (FTP im Bootloader) nimmt das Gluon-`-bootloader.bin` (OpenWrt-U-Boot + Gluon, OpenWrt eva.bin) [geprüft: 70e6ea31]
- **Übertragung:** ftp (EVA): Gerät 192.168.178.1, Rechner 192.168.178.x/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** fritz-tools / EVA-Upload
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-avm_fritzbox-4040-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-eva.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-avm_fritzbox-4040-squashfs-eva.bin)<br>[24.10.8: uboot-fritz4040.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/u-boot-fritz4040/uboot-fritz4040.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: Gluon baut das EVA-Image selbst (extra_images -bootloader)
- **Quelle (OpenWrt-Commit):** OpenWrt 1cb406d019dc84497a8405c470f0b0394d5ff64a + 70e6ea319d3bfdfdb34be540dc7d89aa175b5587
- **Detail-Anleitung:** https://fritz-tools.readthedocs.io/

#### avm-fritz-box-3370-rev-2-hynix-nand

AVM FRITZ!Box 3370 Rev. 2, Hynix-NAND (Gluon: broken) · lantiq-xrx200 · K1d

- **Weg ab Werk:** EVA-FTP in den ersten Sekunden nach dem Einschalten: adam2/adam2, `SETENV linux_fs_start 0`, `MEDIA FLSH`, eva-kernel.bin nach mtd1, eva-filesystem.bin nach mtd0; Gluon baut beide (other/). Bei EVA 2186 Reboot nach 30 s [geprüft]
- **Übertragung:** ftp: Gerät 192.168.178.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein; NAND-Hersteller laut Commit nur nach Öffnen erkennbar
- **Werkzeug/Spezial:** ftp-Client
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-avm_fritz3370-rev2-hynix-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-eva-kernel/-eva-filesystem (other/)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-EVA-Images direkt
- **Quelle (OpenWrt-Commit):** 0b62fe5ed87ecac52301096b15abb69f96117c8c
- **Detail-Anleitung:** https://openwrt.org/toh/avm/fritz.box.wlan.3370#installation

#### avm-fritz-box-3370-rev-2-micron-nand

AVM FRITZ!Box 3370 Rev. 2, Micron-NAND (Gluon: broken) · lantiq-xrx200 · K1d

- **Weg ab Werk:** EVA-FTP in den ersten Sekunden nach dem Einschalten: adam2/adam2, `SETENV linux_fs_start 0`, `MEDIA FLSH`, eva-kernel.bin nach mtd1, eva-filesystem.bin nach mtd0; Gluon baut beide (other/). Bei EVA 2186 Reboot nach 30 s [geprüft]
- **Übertragung:** ftp: Gerät 192.168.178.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein; NAND-Hersteller laut Commit nur nach Öffnen erkennbar
- **Werkzeug/Spezial:** ftp-Client
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-avm_fritz3370-rev2-micron-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-eva-kernel/-eva-filesystem (other/)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-EVA-Images direkt
- **Quelle (OpenWrt-Commit):** 0b62fe5ed87ecac52301096b15abb69f96117c8c
- **Detail-Anleitung:** https://openwrt.org/toh/avm/fritz.box.wlan.3370#installation

#### avm-fritz-box-7360-sl

AVM FRITZ!Box 7360 SL (Alias 7360 v1) · lantiq-xrx200 · K1d

- **Weg ab Werk:** ADAM2/EVA-FTP: `quote GETENV HWRevision` (181 = SL, 183 = v1), `bin`, `quote MEDIA FLSH`, sysupgrade nach mtd1 [abgeleitet: Wiki; Commit ohne Text]
- **Übertragung:** ftp: Gerät 192.168.178.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ftp-Client
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-avm_fritz7360sl-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt per FTP
- **Quelle (OpenWrt-Commit):** bf007a480a46a9fa843765a54fc2f8aa32b2683f (ohne Installationstext) + Wiki toh:avm:fritz.box.wlan.7360
- **Detail-Anleitung:** https://fritz-tools.readthedocs.io/

#### avm-fritz-box-7360-v2

AVM FRITZ!Box 7360 v2 · lantiq-xrx200 · K1d

- **Weg ab Werk:** ADAM2-FTP in den ersten 5 s: adam2/adam2, passive, binary, `quote MEDIA FLSH`, sysupgrade nach mtd1, warten bis die rote LED aus ist [geprüft]
- **Übertragung:** ftp: Gerät 192.168.178.1, Rechner 192.168.178.2
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ftp-Client
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-avm_fritz7360-v2-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig
- **Quelle (OpenWrt-Commit):** 78bebe680f67e8967c2baad8a5c07035d431f9d5

#### avm-fritz-box-7312

AVM FRITZ!Box 7312 · lantiq-xway · K1d

- **Weg ab Werk:** EVA-FTP in den ersten Sekunden: adam2/adam2, binary, passive, `quote MEDIA FLSH`, sysupgrade nach mtd1, `quote REBOOT` [geprüft]
- **Übertragung:** ftp: Gerät 192.168.178.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ftp-Client (fritz-tools)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xway/openwrt-24.10.8-lantiq-xway-avm_fritz7312-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig
- **Quelle (OpenWrt-Commit):** 02d53e6a2113f80ae429664e7990d167fbf44604
- **Detail-Anleitung:** https://fritz-tools.readthedocs.io/

### Familie `avm-eva-ramboot`

4 Gerät(e).

#### avm-fritz-box-3390

AVM FRITZ!Box 3390 · lantiq-xrx200 · K1

- **Weg ab Werk:** EVA-Ramboot: `scripts/flashing/eva_ramboot.py` lädt das initramfs in den RAM, dann sysupgrade per scp [geprüft]
- **Übertragung:** ftp (eva_ramboot.py): Gerät 192.168.178.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** eva_ramboot.py (OpenWrt scripts/flashing)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-avm_fritz3390-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** ja: eva_ramboot.py bootet ein beliebiges initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** 73ec21cde2cde1fc27f66b08e8762cdc3c78b61a

#### avm-fritz-box-7362-sl

AVM FRITZ!Box 7362 SL · lantiq-xrx200 · K1

- **Weg ab Werk:** EVA-Ramboot: `eva_ramboot.py 192.168.178.1 <initramfs>` kurz nach dem Einschalten; das initramfs muss lzma-komprimiert sein (Bootloader hängt sonst); dann sysupgrade per scp [geprüft]
- **Übertragung:** ftp (eva_ramboot.py): Gerät 192.168.178.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** eva_ramboot.py
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-avm_fritz7362sl-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** ja: eva_ramboot.py bootet das RAMpe-initramfs statt des OpenWrt-initramfs; Bedingung: lzma-komprimiert [abgeleitet]
- **Quelle (OpenWrt-Commit):** eae6cac6a30b95bef04d033ed8a303b7e35a078b
- **Detail-Anleitung:** https://openwrt.org/toh/avm/avm_7362_sl#installation

#### avm-fritz-box-7412

AVM FRITZ!Box 7412 · lantiq-xrx200 · K1

- **Weg ab Werk:** EVA-Ramboot: `eva_ramboot.py 192.168.178.1 <initramfs>` kurz nach dem Einschalten; das initramfs muss lzma-komprimiert sein (Bootloader hängt sonst); dann sysupgrade per scp [geprüft]; vor sysupgrade `linux_fs_start` prüfen; Ersatzadresse 169.254.120.1
- **Übertragung:** ftp (eva_ramboot.py): Gerät 192.168.178.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** eva_ramboot.py
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-avm_fritz7412-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** ja: eva_ramboot.py bootet das RAMpe-initramfs statt des OpenWrt-initramfs; Bedingung: lzma-komprimiert [abgeleitet]
- **Quelle (OpenWrt-Commit):** 20f48c8ae334f8502e756282995cc84d89fa81c1
- **Detail-Anleitung:** https://openwrt.org/toh/avm/avm_fritz_box_7412#installation

#### avm-fritz-box-7430

AVM FRITZ!Box 7430 · lantiq-xrx200 · K1

- **Weg ab Werk:** EVA-Ramboot: `eva_ramboot.py 192.168.178.1 <initramfs>` kurz nach dem Einschalten; das initramfs muss lzma-komprimiert sein (Bootloader hängt sonst); dann sysupgrade per scp [geprüft]; vor sysupgrade `linux_fs_start` prüfen; Ersatzadresse 169.254.120.1
- **Übertragung:** ftp (eva_ramboot.py): Gerät 192.168.178.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** eva_ramboot.py
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-avm_fritz7430-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** ja: eva_ramboot.py bootet das RAMpe-initramfs statt des OpenWrt-initramfs; Bedingung: lzma-komprimiert [abgeleitet]
- **Quelle (OpenWrt-Commit):** 6c85a449a988876fdfd4ce84d6aa5ffe4a2820c1
- **Detail-Anleitung:** https://openwrt.org/toh/avm/avm_fritz_box_7430#installation

### Familie `avm-eva-uboot`

4 Gerät(e).

#### avm-fritz-box-7520

AVM FRITZ!Box 7520 (Alias von avm-fritz-box-7530) · ipq40xx-generic · K2

- **Weg ab Werk:** wie 7530, mit eigenem U-Boot uboot-fritz7520.bin [geprüft: Download-Liste 24.10.8]; TFTP-Dateiname: ? [abgeleitet]
- **Übertragung:** ftp (EVA) 192.168.178.1, dann tftp-client 192.168.1.70
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** eva_ramboot.py, OpenWrt-U-Boot
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-avm_fritzbox-7530-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: uboot-fritz7520.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/u-boot-fritz7520/uboot-fritz7520.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: wie 7530
- **Quelle (OpenWrt-Commit):** OpenWrt 95b0c07a618fe5fd93a26931152ced483bba143b
- **Detail-Anleitung:** https://openwrt.org/toh/avm/avm_fritz_box_7530#installation

#### avm-fritz-box-7530

AVM FRITZ!Box 7530 · ipq40xx-generic · K2

- **Weg ab Werk:** `eva_ramboot.py` (OpenWrt scripts/flashing) lädt den OpenWrt-U-Boot per EVA-FTP in den RAM; der holt das initramfs per TFTP; im initramfs U-Boot nach uboot0/uboot1 schreiben, `ubirmvol` avm_filesys_0/1, `sysupgrade -n` [geprüft]
- **Übertragung:** ftp (EVA): Box 192.168.178.1, Rechner 192.168.178.10/24; dann tftp-client: Server 192.168.1.70/24, Datei FRITZ7530.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** eva_ramboot.py, OpenWrt-U-Boot
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-avm_fritzbox-7530-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: uboot-fritz7530.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/u-boot-fritz7530/uboot-fritz7530.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: das RAMpe-initramfs passt als FRITZ7530.bin, aber U-Boot-Schreiben und `ubirmvol` vor dem sysupgrade fehlen ihm; Gluon baut für ipq40xx-generic kein initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 95b0c07a618fe5fd93a26931152ced483bba143b
- **Detail-Anleitung:** https://openwrt.org/toh/avm/avm_fritz_box_7530#installation

#### avm-fritz-repeater-1200

AVM FRITZ!Repeater 1200 · ipq40xx-generic · K2

- **Weg ab Werk:** `eva_ramboot.py` (OpenWrt scripts/flashing) lädt den OpenWrt-U-Boot per EVA-FTP in den RAM; der holt das initramfs per TFTP; im initramfs U-Boot nach uboot0/uboot1 schreiben, `ubirmvol` avm_filesys_0/1, `sysupgrade -n` [geprüft]
- **Übertragung:** ftp (EVA): Box 192.168.178.1, Rechner 192.168.178.10/24; dann tftp-client: Server 192.168.1.70/24, Datei FRITZ1200.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** eva_ramboot.py, OpenWrt-U-Boot
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-avm_fritzrepeater-1200-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: uboot-fritz1200.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/u-boot-fritz1200/uboot-fritz1200.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: das RAMpe-initramfs passt als FRITZ1200.bin, aber U-Boot-Schreiben und `ubirmvol` vor dem sysupgrade fehlen ihm; Gluon baut für ipq40xx-generic kein initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 7f187229a8e9b7966248b1e024217e07a9fc3e50
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=7f187229a8e9b7966248b1e024217e07a9fc3e50

#### avm-fritz-repeater-3000

AVM FRITZ!Repeater 3000 (Gluon: broken, drittes Radio ungetestet) · ipq40xx-generic · K2

- **Weg ab Werk:** `eva_ramboot.py` (OpenWrt scripts/flashing) lädt den OpenWrt-U-Boot per EVA-FTP in den RAM; der holt das initramfs per TFTP; im initramfs U-Boot nach uboot0/uboot1 schreiben, `ubirmvol` avm_filesys_0/1, `sysupgrade -n` [geprüft]
- **Übertragung:** ftp (EVA): Box 192.168.178.1, Rechner 192.168.178.10/24; dann tftp-client: Server 192.168.1.70/24, Datei FRITZ3000.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** eva_ramboot.py, OpenWrt-U-Boot
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-avm_fritzrepeater-3000-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: uboot-fritz3000.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/u-boot-fritz3000/uboot-fritz3000.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: das RAMpe-initramfs passt als FRITZ3000.bin, aber U-Boot-Schreiben und `ubirmvol` vor dem sysupgrade fehlen ihm; Gluon baut für ipq40xx-generic kein initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 148d29d47b1d555d0058dcc5dda450b74c4628ec
- **Detail-Anleitung:** -

### Familie `cudy-zwischenfirmware`

20 Gerät(e).

#### cudy-ap3000-outdoor-v1

Cudy AP3000 Outdoor v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_ap3000outdoor-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel AP3000_Outdoor_1.0](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/AP3000_Outdoor_1.0/)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt 19d770d7b91aaca1de18281dea0da8616df34c6c
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-ap3000-v1

Cudy AP3000 v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; Zwischenfirmware laut Commit nur per Mail an support@cudy.com, im Spiegel die vom Support erhaltene Datei; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_ap3000-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel AP3000_V1.0](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/AP3000_V1.0/)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt 6dacba30a75b0ac8a65115f78808a97abbb34939
- **Detail-Anleitung:** -

#### cudy-ap3000-wall-v1

Cudy AP3000 Wall v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [25.12.5: initramfs-kernel.bin](https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/filogic/openwrt-25.12.5-mediatek-filogic-cudy_ap3000wall-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel AP3000_Wall_1.0](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/AP3000_Wall_1.0/)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt afad4c71f8d558ca86b997781ca0236f321cf1e9 (25.12: 45788a48c7); gluon-patches-hardware 9263f242b86a943e62671ec445f08dd9eb2dfbd2 [Backport]
- **Detail-Anleitung:** -

#### cudy-m3000-v1

Cudy M3000 v1 (RTL8221B) · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; Commit (2024) nennt nur UART, die Zwischenfirmware kam später; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_m3000-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel M3000_1.0_2.0](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/M3000_1.0_2.0/)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt 20e4a18feb3f766b0f6ebec1afc154b345398a7a
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-m3000-v2-with-motorcomm-yt8821

Cudy M3000 v2 mit Motorcomm YT8821 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; vorher im Cudy-Systemlog nach "yt8821" bzw. "rtl8221b" suchen, um v1/v2 zu unterscheiden [geprüft]
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1 (am "1Gbps LAN"-Port)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, Platine ausbauen)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [25.12.5: initramfs-kernel.bin](https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/filogic/openwrt-25.12.5-mediatek-filogic-cudy_m3000-v2-yt8821-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel M3000_1.0_2.0 (ob für YT8821 passend: abgeleitet)](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/M3000_1.0_2.0/)<br>[Cudy-Drive](https://drive.google.com/drive/folders/1BKVarlwlNxf7uJUtRhuMGUqeCa5KpMnj)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt 45b51ebaff51d2a49d149e9011717abb1b032683 (25.12: ca825537fb); gluon-patches-hardware 9263f242b86a943e62671ec445f08dd9eb2dfbd2 [Backport]
- **Detail-Anleitung:** -

#### cudy-re3000-v1

Cudy RE3000 v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; Commit nennt nur UART (Stecker unter dem Kühlkörper); alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_re3000-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel RE3000_V1](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/RE3000_V1/)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt e8f75973172749874afa13e4f746acd8cb515de2
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-tr3000-256mb-v1

Cudy TR3000 256 MB v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; Zwischenfirmware laut Commit von Cudy CN; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_tr3000-256mb-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel TR3000_256MB_Flash_V1_not_for_TR3000_V1_](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/TR3000_256MB_Flash_V1_not_for_TR3000_V1_/)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt 0ec28e59a815bb43c359328c8fd644f399d344da
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-wr3000-v1

Cudy WR3000 v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; Commit (2023) nennt nur UART, TFTP-Server 192.168.1.2, Datei cudy3000.bin; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_wr3000-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel WR3000%2BV1_without_recovery_TFTP](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/WR3000%2BV1_without_recovery_TFTP/)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt c9cb6411c1a70516d5922e88c45b338de041baba
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-wr3000e-v1

Cudy WR3000E v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_wr3000e-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel WR3000E_1.0](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/WR3000E_1.0/)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt f50551dd18318f2255da3ecd5de5cc1078201651
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-wr3000h-v1

Cudy WR3000H v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_wr3000h-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel WR3000H_1.0](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/WR3000H_1.0/)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt fdbbb8415fd19ae0748a2bbe41b15257054e4077
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-wr3000p-v1

Cudy WR3000P v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_wr3000p-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel WR3000P_1.0](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/WR3000P_1.0/)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt 51108508f10eb25f99395ec9334f996813bc5a22; gluon-patches-hardware 8dbae18666543aa9b8b5e7faa1d267024d62071e (Gluon-Zeile)
- **Detail-Anleitung:** -

#### cudy-wr3000s-v1

Cudy WR3000S v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; alternativ seriell: U-Boot, initramfs per TFTP von 192.168.1.88
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_wr3000s-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Spiegel WR3000S_1.0](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/WR3000S_1.0/)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt 4779e954fa847c4b376623bc3bdf9651007e8a89
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-wr3000u-v1

Cudy WR3000U v1 · mediatek-filogic · K2

- **Weg ab Werk:** Cudy-Zwischenfirmware (von Cudy signiertes OpenWrt) über die Stock-Web-UI, danach Gluon-sysupgrade ohne Einstellungen über LuCI [geprüft: Commit/Neanderfunk-Notiz cudy-installation.md]; alternativ UART + TFTP (192.168.1.88) [geprüft]
- **Übertragung:** webui-upload: Stock-UI 192.168.10.1 (Passwort admin), danach LuCI 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ?, laut Commit "Serial console: no need to solder")
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware (nicht im Spiegel, nur Cudy-Drive)
- **initramfs-Link:** [snapshot: initramfs-kernel.bin](https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/openwrt-mediatek-filogic-cudy_wr3000u-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [Cudy-Drive](https://drive.google.com/drive/folders/1BKVarlwlNxf7uJUtRhuMGUqeCa5KpMnj)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: die Zwischenfirmware ist schon ein OpenWrt mit Upload; die Stock-UI nimmt nur Cudy-signierte Images [geprüft: Commit-Texte]. Ob die Cudy-TFTP-Recovery (recovery.bin von 192.168.1.88) fremde Images nimmt: offen; OpenWrt-Images nur als Snapshot (nicht in 25.12.5) [geprüft]
- **Quelle (OpenWrt-Commit):** OpenWrt b9d7b448c256bb3860c7965ccf599c29c4847cb4 (25.12: 95dec97d08); gluon-patches-hardware 9263f242b86a943e62671ec445f08dd9eb2dfbd2 [Backport]
- **Detail-Anleitung:** -

#### cudy-ap1300-outdoor-v1

Cudy AP1300 Outdoor v1 · ramips-mt7621 · K2

- **Weg ab Werk:** Cudys signierte OpenWrt-Zwischenfirmware im Stock-Web-UI einspielen, danach Gluon-sysupgrade in LuCI ohne "Einstellungen behalten" [geprüft]; Stock 192.168.10.254, Passwort admin [geprüft]
- **Übertragung:** webui-upload (Zwischenfirmware), danach LuCI-Upload; TFTP-Recovery (Server 192.168.1.88, recovery.bin) nimmt nur Cudy-signierte Images
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-cudy_ap1300-outdoor-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [Spiegel](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/AP1300_Outdoor_V1.0) / [Cudy](https://www.cudy.com/blogs/faq/openwrt-software-download)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: Stock und Recovery prüfen Cudys RSA-Signatur
- **Quelle (OpenWrt-Commit):** c6e59d06afca02ccb2541631cacc769ae4d6569f
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-m1800

Cudy M1800 · ramips-mt7621 · K2

- **Weg ab Werk:** Cudys signierte OpenWrt-Zwischenfirmware im Stock-Web-UI einspielen, danach Gluon-sysupgrade in LuCI ohne "Einstellungen behalten" [geprüft]; Spiegel hat nur "M1800+V2"; ob das zu cudy_m1800 passt, ist ungeprüft
- **Übertragung:** webui-upload (Zwischenfirmware), danach LuCI-Upload; TFTP-Recovery (Server 192.168.1.88, recovery.bin) nimmt nur Cudy-signierte Images
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-cudy_m1800-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [Spiegel](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/M1800%2BV2) / [Cudy](https://www.cudy.com/blogs/faq/openwrt-software-download)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein: Stock und Recovery prüfen Cudys RSA-Signatur
- **Quelle (OpenWrt-Commit):** f6d394e9f2fd41547236c092ac914322220eb77c

#### cudy-wr1300-v1

Cudy WR1300 v1 · ramips-mt7621 · K2

- **Weg ab Werk:** Cudys signierte OpenWrt-Zwischenfirmware im Stock-Web-UI einspielen, danach Gluon-sysupgrade in LuCI ohne "Einstellungen behalten" [geprüft]
- **Übertragung:** webui-upload (Zwischenfirmware), danach LuCI-Upload; TFTP-Recovery (Server 192.168.1.88, recovery.bin) nimmt nur Cudy-signierte Images
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-cudy_wr1300-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [Spiegel](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/WR1300%2BV1) / [Cudy](https://www.cudy.com/blogs/faq/openwrt-software-download)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: Stock und Recovery prüfen Cudys RSA-Signatur
- **Quelle (OpenWrt-Commit):** cd2b661453a8a2b8260dfb9b9c0dc5297b981331
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-wr2100

Cudy WR2100 · ramips-mt7621 · K2

- **Weg ab Werk:** Cudys signierte OpenWrt-Zwischenfirmware im Stock-Web-UI einspielen, danach Gluon-sysupgrade in LuCI ohne "Einstellungen behalten" [geprüft]
- **Übertragung:** webui-upload (Zwischenfirmware), danach LuCI-Upload; TFTP-Recovery (Server 192.168.1.88, recovery.bin) nimmt nur Cudy-signierte Images
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-cudy_wr2100-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [Spiegel](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/WR2100%2BV1) / [Cudy](https://www.cudy.com/blogs/faq/openwrt-software-download)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: Stock und Recovery prüfen Cudys RSA-Signatur
- **Quelle (OpenWrt-Commit):** 3501db9b9b4a71ae52c539b46af817783c327866
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-x6-v1

Cudy X6 v1 · ramips-mt7621 · K2

- **Weg ab Werk:** Cudys signierte OpenWrt-Zwischenfirmware im Stock-Web-UI einspielen, danach Gluon-sysupgrade in LuCI ohne "Einstellungen behalten" [geprüft]
- **Übertragung:** webui-upload (Zwischenfirmware), danach LuCI-Upload; TFTP-Recovery (Server 192.168.1.88, recovery.bin) nimmt nur Cudy-signierte Images
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-cudy_x6-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [Spiegel](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/X6%2BV1) / [Cudy](https://www.cudy.com/blogs/faq/openwrt-software-download)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein: Stock und Recovery prüfen Cudys RSA-Signatur
- **Quelle (OpenWrt-Commit):** 4a8eaa5c7c9235212c4af022c18b2dfbadfe557f
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-x6-v2

Cudy X6 v2 · ramips-mt7621 · K2

- **Weg ab Werk:** Cudys signierte OpenWrt-Zwischenfirmware im Stock-Web-UI einspielen, danach Gluon-sysupgrade in LuCI ohne "Einstellungen behalten" [geprüft]
- **Übertragung:** webui-upload (Zwischenfirmware), danach LuCI-Upload; TFTP-Recovery (Server 192.168.1.88, recovery.bin) nimmt nur Cudy-signierte Images
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-cudy_x6-v2-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [Spiegel](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/X6%2BV2) / [Cudy](https://www.cudy.com/blogs/faq/openwrt-software-download)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein: Stock und Recovery prüfen Cudys RSA-Signatur
- **Quelle (OpenWrt-Commit):** e38de40f8dd350344407fe5a91e81191f6960804
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### cudy-tr1200-v1

Cudy TR1200 v1 · ramips-mt76x8 · K2

- **Weg ab Werk:** Commit (05/2024): nur seriell (Cudy-Beta-Firmware, UART, TFTP recovery.bin von 192.168.1.88). Inzwischen liegt eine Cudy-Zwischenfirmware TR1200_V1 im Spiegel, damit wie die anderen Cudy [abgeleitet]
- **Übertragung:** webui-upload (Zwischenfirmware)
- **seriell nötig:** nein (mit Zwischenfirmware; nur für den seriellen Weg laut Commit: ja)
- **Gehäuse öffnen:** nein (mit Zwischenfirmware; nur für den seriellen Weg laut Commit: ja, UART unbestückt)
- **Werkzeug/Spezial:** Cudy-Zwischenfirmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-cudy_tr1200-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [Spiegel](https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/TR1200_V1) / [Cudy](https://www.cudy.com/blogs/faq/openwrt-software-download)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: Signaturprüfung wie bei allen Cudy
- **Quelle (OpenWrt-Commit):** f1091ef7ac3596f1e401b918a36273672acbe389
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

### Familie `devolo-ssh`

6 Gerät(e).

#### devolo-wifi-pro-1200e

devolo WiFi pro 1200e · ath79-generic · K1d

- **Weg ab Werk:** Stock ist OpenWrt-basiert: im Web-UI root-Passwort setzen, sysupgrade per scp nach /tmp, `sysupgrade -n -F` [geprüft]
- **Übertragung:** ssh/scp: root mit dem im Web-UI gesetzten Passwort, Ziel /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-devolo_dvl1200e-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht per `sysupgrade -F` direkt
- **Quelle (OpenWrt-Commit):** 1724d4e9ed7716a5444eca42adf045c2f3afc554 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1724d4e9ed7716a5444eca42adf045c2f3afc554

#### devolo-wifi-pro-1200i

devolo WiFi pro 1200i · ath79-generic · K1d

- **Weg ab Werk:** Stock ist OpenWrt-basiert: im Web-UI root-Passwort setzen, sysupgrade per scp nach /tmp, `sysupgrade -n -F` [geprüft]
- **Übertragung:** ssh/scp: root mit dem im Web-UI gesetzten Passwort, Ziel /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-devolo_dvl1200i-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht per `sysupgrade -F` direkt
- **Quelle (OpenWrt-Commit):** c8115167f946be85f812f3c94d6294b67ac8944c [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=c8115167f946be85f812f3c94d6294b67ac8944c

#### devolo-wifi-pro-1750c

devolo WiFi pro 1750c · ath79-generic · K1d

- **Weg ab Werk:** Stock ist OpenWrt-basiert: im Web-UI root-Passwort setzen, sysupgrade per scp nach /tmp, `sysupgrade -n -F` [geprüft]
- **Übertragung:** ssh/scp: root mit dem im Web-UI gesetzten Passwort, Ziel /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-devolo_dvl1750c-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht per `sysupgrade -F` direkt
- **Quelle (OpenWrt-Commit):** e67da3443168fa6b6727cd81a35d559be77d6b4c [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=e67da3443168fa6b6727cd81a35d559be77d6b4c

#### devolo-wifi-pro-1750e

devolo WiFi pro 1750e · ath79-generic · K1d

- **Weg ab Werk:** Stock ist OpenWrt-basiert: im Web-UI root-Passwort setzen, sysupgrade per scp nach /tmp, `sysupgrade -n -F` [geprüft]
- **Übertragung:** ssh/scp: root mit dem im Web-UI gesetzten Passwort, Ziel /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-devolo_dvl1750e-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht per `sysupgrade -F` direkt
- **Quelle (OpenWrt-Commit):** 1c2f7b511514d43d8a826b26e09817b2750a2bf4 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1c2f7b511514d43d8a826b26e09817b2750a2bf4

#### devolo-wifi-pro-1750i

devolo WiFi pro 1750i · ath79-generic · K1d

- **Weg ab Werk:** Stock ist OpenWrt-basiert: im Web-UI root-Passwort setzen, sysupgrade per scp nach /tmp, `sysupgrade -n -F` [geprüft]
- **Übertragung:** ssh/scp: root mit dem im Web-UI gesetzten Passwort, Ziel /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-devolo_dvl1750i-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht per `sysupgrade -F` direkt
- **Quelle (OpenWrt-Commit):** 8d68be8057d6c689025cc236d20b96b77a6ccf30 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=8d68be8057d6c689025cc236d20b96b77a6ccf30

#### devolo-wifi-pro-1750x

devolo WiFi pro 1750x · ath79-generic · K1d

- **Weg ab Werk:** Stock ist OpenWrt-basiert: im Web-UI root-Passwort setzen, sysupgrade per scp nach /tmp, `sysupgrade -n -F` [geprüft]
- **Übertragung:** ssh/scp: root mit dem im Web-UI gesetzten Passwort, Ziel /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-devolo_dvl1750x-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht per `sysupgrade -F` direkt
- **Quelle (OpenWrt-Commit):** cb3cd526948af3f69da1af18e035177a0a8f58e3 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=cb3cd526948af3f69da1af18e035177a0a8f58e3

### Familie `dlink-recovery-web`

6 Gerät(e).

#### d-link-aquila-pro-ai-m30-a1

D-Link AQUILA PRO AI M30 A1 · mediatek-filogic · K1

- **Weg ab Werk:** D-Link-Web-Recovery (Reset beim Einschalten halten, bis die LED rot blinkt) nimmt `squashfs-recovery.bin` (initramfs mit D-Link-Header DLK6E6110001); schreibt in die aktive Partition, OpenWrt bootet nur aus der ersten [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.200.1, Rechner 192.168.200.10/24, POST /upload.cgi (curl oder Chromium), kein Ping
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: squashfs-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-dlink_aquila-pro-ai-m30-a1-squashfs-recovery.bin)<br>[24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-dlink_aquila-pro-ai-m30-a1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** nur wenn die zweite Partition aktiv ist: OEM-Image von D-Link verschlüsselt und entschlüsselt (m32-firmware-util von RolandoMagico) [geprüft]
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** ja: RAMpe-Image gebaut, Header wie OpenWrt, Hardware-Test offen [geprüft: gluon-rampe-installer docs/NOTIZEN.md]
- **Quelle (OpenWrt-Commit):** OpenWrt 29cca6cfee4bc732f9bf7eca0cae9e56cd3c0f2f
- **Detail-Anleitung:** https://freifunk-aachen.de/2026/08/17/installationsanleitung-d-link-m30/

#### d-link-aquila-pro-ai-m60-a1

D-Link AQUILA PRO AI M60 A1 · mediatek-filogic · K1

- **Weg ab Werk:** D-Link-Web-Recovery nimmt `squashfs-recovery.bin` (initramfs mit Header DLK6E8202001) [geprüft, am Testplatz 29./30.09.2026 erprobt]; bei aktiver zweiter Partition vorher das UBI-Switch-Image
- **Übertragung:** recovery-web: Gerät 192.168.200.1, Rechner z. B. 192.168.200.66/24, POST /upload.cgi, 10-11 min
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** bei falscher Partition: UBI-Switch-Image (github RolandoMagico, M60-Recovery-UBI-Switch)
- **initramfs-Link:** [24.10.8: squashfs-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-dlink_aquila-pro-ai-m60-a1-squashfs-recovery.bin)<br>[24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-dlink_aquila-pro-ai-m60-a1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** ja: Gluon baut selbst ein `-recovery.bin`; laut RAMpe-NOTIZEN startet ein Gluon-initramfs aber nicht im Config-Mode, vermutlich derselbe Fehler wie beim M30 [abgeleitet]; das RAMpe-Image wäre der Ersatz
- **Quelle (OpenWrt-Commit):** OpenWrt 7271ee587cd104d30d6d46dd3c623c9d4602bd0c
- **Detail-Anleitung:** -

#### d-link-dap-1620-b1

D-Link DAP-1620 B1 (Gluon: broken) · ramips-mt7621 · K0

- **Weg ab Werk:** Reset beim Einstecken halten, Web-Recovery 192.168.0.50, factory.bin hochladen (Chromium) [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.0.50
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-dlink_dap-1620-b1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** e4c7703d2a62b8914e4723adae3f67c68a57532c
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=e4c7703d2a62b8914e4723adae3f67c68a57532c

#### d-link-dap-x1860-a1

D-Link DAP-X1860 A1 · ramips-mt7621 · K0

- **Weg ab Werk:** Reset beim Einstecken, Web-Recovery 192.168.0.50; laut Commit factory.bin hochladen [geprüft]. Neanderfunk-Notiz dlink-flashen.md (01.10.2026) nennt dagegen OpenWrt-initramfs + sysupgrade: Widerspruch, offen
- **Übertragung:** recovery-web: Gerät 192.168.0.50, Rechner 192.168.0.65/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-dlink_dap-x1860-a1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nicht nötig, falls factory klappt; sonst ja (Recovery nimmt laut Neanderfunk-Notiz ein initramfs)
- **Quelle (OpenWrt-Commit):** 3c31f6b521bb5fc49e222a8f2bcd454b73452a0e
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-d-link-dap-x1860/987

#### d-link-dir-878-a1

D-Link DIR-878 A1 · ramips-mt7621 · K0

- **Weg ab Werk:** Reset beim Einstecken halten bis die Power-LED orange blinkt, Web-Recovery 192.168.0.1, factory hochladen (oder `curl -F firmware=@...`) [geprüft]. Neanderfunk-Notiz recovery-wege.md Abschnitt 6 sagt dagegen "DIR-Reihe über TFTP": Widerspruch, offen
- **Übertragung:** recovery-web: Gerät 192.168.0.1, Rechner 192.168.0.2/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** curl (optional)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-dlink_dir-878-a1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community); OpenWrt baut zusätzlich [squashfs-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-dlink_dir-878-a1-squashfs-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** d7233b0a6a9b8cb9207a74a8cb3d0525170cf504
- **Detail-Anleitung:** https://openwrt.org/toh/d-link/dir-878_a1#installation

#### d-link-dir-882-a1

D-Link DIR-882 A1 · ramips-mt7621 · K0

- **Weg ab Werk:** Reset beim Einstecken halten bis die Power-LED orange blinkt, Web-Recovery 192.168.0.1, factory hochladen (oder `curl -F firmware=@...`) [geprüft]. Neanderfunk-Notiz recovery-wege.md Abschnitt 6 sagt dagegen "DIR-Reihe über TFTP": Widerspruch, offen
- **Übertragung:** recovery-web: Gerät 192.168.0.1, Rechner 192.168.0.2/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** curl (optional)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-dlink_dir-882-a1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community); OpenWrt baut zusätzlich [squashfs-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-dlink_dir-882-a1-squashfs-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 73e8f23579bcb87764dae9ed0aefe28be3183d3e
- **Detail-Anleitung:** https://openwrt.org/toh/d-link/dir-882_a1#installation

### Familie `glinet`

22 Gerät(e).

#### gl.inet-6416

GL.iNet 6416 · ath79-generic · K1d

- **Weg ab Werk:** sysupgrade über die Stock-GUI oder die U-Boot-Weboberfläche [geprüft]
- **Übertragung:** webui-upload (Stock) oder recovery-web: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** GL.iNet-U-Boot-Web nimmt sysupgrade
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-glinet_6416-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** b4d3110ac1f1f1962f812ac139c437837a448cff [geprüft]

#### gl.inet-gl-ar150

GL.iNet GL-AR150 · ath79-generic · K1d

- **Weg ab Werk:** GL.iNet-U-Boot-Weboberfläche bzw. Stock-GUI mit sysupgrade [abgeleitet: Commit 53c474a ohne Anleitung, Verfahren wie bei den anderen GL.iNet]
- **Übertragung:** recovery-web: Gerät 192.168.1.1 [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** GL.iNet-U-Boot-Web
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-glinet_gl-ar150-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt [abgeleitet]
- **Quelle (OpenWrt-Commit):** 53c474abbdfef8eb3499e2d10c9ad491788b8a72 (erstes ath79-Target, ohne Anleitung) [abgeleitet]

#### gl.inet-gl-ar300m-lite

GL.iNet GL-AR300M Lite · ath79-generic · K1d

- **Weg ab Werk:** sysupgrade über die OEM-GUI (LuCI, "Advanced"), Einstellungen nicht behalten [geprüft]
- **Übertragung:** webui-upload (Stock-LuCI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Stock ist OpenWrt-basiert
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-glinet_gl-ar300m-lite-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** fefa34def84561688e6af2feeec2dbb390ba4486 [geprüft]

#### gl.inet-gl-ar300m16

GL.iNet GL-AR300M16 · ath79-generic · K1d

- **Weg ab Werk:** OEM-U-Boot (HTTP) oder `sysupgrade --force` aus der NOR-Stock-Firmware [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.1.1 [abgeleitet]; oder ssh
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** GL.iNet-U-Boot-Web
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-glinet_gl-ar300m16-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** b591cabd3989b44cfaf15248af9e55a0300a9c0a [geprüft]

#### gl.inet-gl-ar750

GL.iNet GL-AR750 · ath79-generic · K1d

- **Weg ab Werk:** Stock nimmt sysupgrade per Kommandozeile oder LuCI [geprüft]
- **Übertragung:** webui-upload (Stock-LuCI) oder ssh
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Stock ist OpenWrt-basiert
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-glinet_gl-ar750-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** 921675a2d148330a7ec44f10ea4d583b8d7b5a44 [geprüft]

#### gl.inet-gl-usb150

GL.iNET GL-USB150 · ath79-generic · K1d

- **Weg ab Werk:** Stock (OpenWrt-basiert) nimmt das sysupgrade in der GUI oder per sysupgrade, Einstellungen nicht behalten [geprüft]
- **Übertragung:** webui-upload (Stock-GUI) oder ssh
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Stock ist OpenWrt-basiert
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-glinet_gl-usb150-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** a1b5a43fc4b0edda5bbbb4eb0130ba9160dc515b [geprüft]

#### gl.inet-gl-ar300m-nor

GL.iNet GL-AR300M NOR · ath79-nand · K1d

- **Weg ab Werk:** OEM-U-Boot-Weboberfläche nimmt NOR-Firmware (sysupgrade) oder NAND-factory.img; ohne serielle Konsole [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.1.1 [abgeleitet, Adresse im Commit nicht genannt]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** GL.iNet-U-Boot-Web
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-glinet_gl-ar300m-nor-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade (NOR) geht direkt
- **Quelle (OpenWrt-Commit):** 55e6c903ae20bd8e694f4626166766e59602f87c (NOR/NAND-Aufteilung, Anleitung); 6e78d546d1197d7a3ec4cbc7aab22286ad49fb0f (Umbenennung) [geprüft]

#### gl.inet-gl-ar750s-nor

GL.iNet GL-AR750S NOR · ath79-nand · K1d

- **Weg ab Werk:** U-Boot-Recovery: Reset beim Einstecken halten bis 5x Blinken, http://192.168.1.1, sysupgrade im NOR-Bereich hochladen [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.1.1, PC 192.168.1.2
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** GL.iNet-U-Boot-Web
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-glinet_gl-ar750s-nor-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit af28d8a]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade (NOR) geht direkt
- **Quelle (OpenWrt-Commit):** af28d8a539fe64bfc893f798fdbbc49b4e78352a (Einführung, Anleitung); b496a2294c6e663a2dcbf08d714443e758d1269d (NOR/NAND) [geprüft]

#### gl.inet-gl-e750

GL.iNet GL-E750 (broken) · ath79-nand · K2

- **Weg ab Werk:** Mit GL-Firmware 3.100 nur über den U-Boot (GL.iNet-Debrick-Anleitung), weil deren sysupgrade den größeren Kernel zerstört [geprüft]; Gluon baut kein factory.img, OpenWrt schon
- **Übertragung:** recovery-web (GL.iNet-U-Boot) [Adresse im Commit nicht genannt]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** GL.iNet-U-Boot-Web, OpenWrt-factory.img als Zwischenschritt [abgeleitet]
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-glinet_gl-e750-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-glinet_gl-e750-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: U-Boot-Web nimmt NAND-factory.img (Kernel+UBI), kein initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** 68ac3f2cddab8422d7de0ce1a78d23edf29012e7 [geprüft]

#### gl.inet-gl-xe300

GL.iNet GL-XE300 · ath79-nand · K2

- **Weg ab Werk:** U-Boot-Rescue: Reset und Power gleichzeitig halten bis LAN-LED 5x blinkt, http://192.168.1.1, factory-Image hochladen [geprüft]; Gluon baut kein factory.img -> OpenWrt-factory.img als Zwischenschritt [abgeleitet]
- **Übertragung:** recovery-web: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** GL.iNet-U-Boot-Web, OpenWrt-factory.img als Zwischenschritt [abgeleitet]
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-glinet_gl-xe300-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-glinet_gl-xe300-squashfs-factory.img) (HEAD 200)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: U-Boot-Rescue nimmt NAND-factory.img (Kernel+UBI), kein initramfs; eine Gluon-RAMpe in diesem Format wäre ein eigenes Projekt [abgeleitet]
- **Quelle (OpenWrt-Commit):** af8a059bb41dd7afee49ce9a5d52e9a8e010bbd8 [geprüft]

#### gl.inet-gl-ap1300

GL.iNet GL-AP1300 · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory (`.ubi`) über die U-Boot-Web-Failsafe (Reset 10 s, bis die Power-LED schneller blinkt) oder U-Boot-TFTP `run lf` [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-glinet_gl-ap1300-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.ubi](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-glinet_gl-ap1300-squashfs-factory.ubi)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt b9389186b012e5bd99ea6523b8220aaee6ca0085
- **Detail-Anleitung:** -

#### gl.inet-gl-b1300

GL.iNet GL-B1300 · ipq40xx-generic · K1d

- **Weg ab Werk:** GL.iNet-U-Boot-Web (Reset beim Einschalten, bis drei LEDs leuchten) nimmt das sysupgrade, umbenannt in lede-gl-b1300.bin; liegt die Datei auf einem TFTP-Server 192.168.1.2, holt der U-Boot sie selbst [geprüft: Commit von 2017, ob neuere U-Boots denselben Namen erwarten: offen]
- **Übertragung:** recovery-web: Gerät 192.168.1.1; oder tftp-client: Server 192.168.1.2, Datei lede-gl-b1300.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-glinet_gl-b1300-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: der Bootloader nimmt das Gluon-sysupgrade
- **Quelle (OpenWrt-Commit):** OpenWrt 04d3308b6248ef21a6f0bc3378b342906c2d2865
- **Detail-Anleitung:** -

#### gl.inet-gl-mt2500

GL.iNet GL-MT2500 (MaxLinear-PHY) · mediatek-filogic · K1d

- **Weg ab Werk:** GL.iNet-Stock-UI nimmt das OpenWrt-/Gluon-sysupgrade direkt (ohne Einstellungen) [geprüft]; die U-Boot-Recovery nimmt laut Commit keine Images. Neue HW-Revision mit Airoha-PHY hat in OpenWrt ein eigenes Profil `glinet_gl-mt2500-airoha`, das Gluon nicht führt [geprüft: 24.10.8-Liste]
- **Übertragung:** webui-upload (GL.iNet-UI); bzw. recovery-web (GL.iNet-U-Boot, Reset beim Einschalten) [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-glinet_gl-mt2500-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 1 GB
- **Gluon-RAMpe passt:** nein, nicht nötig: Hersteller-UI nimmt das Gluon-sysupgrade
- **Quelle (OpenWrt-Commit):** OpenWrt 12396686484a488dff1c4a1ee8b5197c552572fe
- **Detail-Anleitung:** -

#### gl.inet-gl-mt3000

GL.iNet GL-MT3000 · mediatek-filogic · K1d

- **Weg ab Werk:** GL.iNet-Stock-UI bzw. U-Boot-Web-Failsafe nimmt das sysupgrade direkt [abgeleitet: Commit ohne Installationsabschnitt, gluon-rampe-installer docs/GERAETE.md]
- **Übertragung:** webui-upload (GL.iNet-UI); bzw. recovery-web (GL.iNet-U-Boot, Reset beim Einschalten) [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-glinet_gl-mt3000-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: Hersteller-UI nimmt das Gluon-sysupgrade
- **Quelle (OpenWrt-Commit):** OpenWrt 7cbe34170e3d8471c1ebacde33a2372c92433be4
- **Detail-Anleitung:** -

#### gl.inet-gl-mt6000

GL.iNet GL-MT6000 · mediatek-filogic · K1d

- **Weg ab Werk:** GL.iNet-Stock-UI nimmt das sysupgrade direkt [abgeleitet: Commit-Text Patch-Repo 8dbae18]; OpenWrts `squashfs-factory.bin` ist nur für den OpenWrt-U-Boot [geprüft]
- **Übertragung:** webui-upload (GL.iNet-UI); bzw. recovery-web (GL.iNet-U-Boot, Reset beim Einschalten) [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-glinet_gl-mt6000-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 1 GB
- **Gluon-RAMpe passt:** nein, nicht nötig: Hersteller-UI nimmt das Gluon-sysupgrade
- **Quelle (OpenWrt-Commit):** OpenWrt fe10f9743935d6986e80e7cb082469e6bc5a03f0; gluon-patches-hardware 8dbae18666543aa9b8b5e7faa1d267024d62071e (Gluon-Zeile)
- **Detail-Anleitung:** -

#### gl-mt300a

GL.iNet GL-MT300A · ramips-mt7620 · K1d

- **Weg ab Werk:** Stock ist ein GL.iNet-OpenWrt und nimmt das sysupgrade im Web-UI; Notweg U-Boot-Web: Reset beim Einstecken mind. 3 s halten [abgeleitet: Wiki, Commit ohne Installationstext]
- **Übertragung:** webui-upload; recovery-web: Gerät 192.168.1.1, Rechner 192.168.1.2/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-glinet_gl-mt300a-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 96ee39b184a3863bba1cc42efc5bbd34495d20ff (ohne Installationstext) + Wiki toh:gl.inet

#### gl-mt300n

GL.iNet GL-MT300N (v1) · ramips-mt7620 · K1d

- **Weg ab Werk:** Stock ist ein GL.iNet-OpenWrt und nimmt das sysupgrade im Web-UI; Notweg U-Boot-Web: Reset beim Einstecken mind. 3 s halten [abgeleitet: Wiki, Commit ohne Installationstext]
- **Übertragung:** webui-upload; recovery-web: Gerät 192.168.1.1, Rechner 192.168.1.2/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-glinet_gl-mt300n-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt
- **Quelle (OpenWrt-Commit):** be53e5a154931109dd76a8015583123201c4b602 (ohne Installationstext) + Wiki toh:gl.inet

#### gl-mt750

GL.iNet GL-MT750 · ramips-mt7620 · K1d

- **Weg ab Werk:** Stock ist ein GL.iNet-OpenWrt und nimmt das sysupgrade im Web-UI; Notweg U-Boot-Web: Reset beim Einstecken mind. 3 s halten [abgeleitet: Wiki, Commit ohne Installationstext]
- **Übertragung:** webui-upload; recovery-web: Gerät 192.168.1.1, Rechner 192.168.1.2/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-glinet_gl-mt750-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB (ToH)
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt
- **Quelle (OpenWrt-Commit):** be7962925927ab5cdc7a13fdb24d1b08792f8f23 (ohne Installationstext) + Wiki toh:gl.inet

#### gl.inet-gl-mt1300

GL.iNet GL-MT1300 (Beryl) · ramips-mt7621 · K1d

- **Weg ab Werk:** U-Boot-Web: Reset beim Einschalten, nach 5x blauem Blinken loslassen, http://192.168.1.1, sysupgrade hochladen [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.1.1, Rechner 192.168.1.2
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-glinet_gl-mt1300-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt
- **Quelle (OpenWrt-Commit):** d89a7f0120db42d4fae1656e1860ef49523acabb

#### gl-mt300n-v2

GL.iNet GL-MT300N v2 · ramips-mt76x8 · K1d

- **Weg ab Werk:** Stock (GL.iNet-LEDE) nimmt das sysupgrade in LuCI; U-Boot-Web: Reset beim Einstecken bis die rote LED blinkt, 192.168.1.1 [geprüft]
- **Übertragung:** webui-upload; recovery-web: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-glinet_gl-mt300n-v2-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig
- **Quelle (OpenWrt-Commit):** abbfcc85259a4f6658c61e99dd3d2d3567e3eb3a

#### gl.inet-microuter-n300

GL.iNet microuter-N300 · ramips-mt76x8 · K1d

- **Weg ab Werk:** Stock-Web-UI 192.168.8.1 (per WLAN, der Ethernet-Port ist WAN), "Local Update" mit sysupgrade ohne Einstellungen; oder U-Boot-Web: Reset beim Einschalten, 5x Blinken, 192.168.1.1 [geprüft]
- **Übertragung:** webui-upload (192.168.8.1); recovery-web: Gerät 192.168.1.1, Rechner statisch 192.168.1.x
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-glinet_microuter-n300-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig
- **Quelle (OpenWrt-Commit):** b30f2281cce6649567e0194d203f06517d173115

#### gl.inet-vixmini

GL.iNet VIXMINI · ramips-mt76x8 · K1d

- **Weg ab Werk:** Stock-Web-UI 192.168.8.1 (per WLAN, der Ethernet-Port ist WAN), "Local Update" mit sysupgrade ohne Einstellungen; oder U-Boot-Web: Reset beim Einschalten, 5x Blinken, 192.168.1.1 [geprüft]
- **Übertragung:** webui-upload (192.168.8.1); recovery-web: Gerät 192.168.1.1, Rechner statisch 192.168.1.x
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-glinet_vixmini-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig
- **Quelle (OpenWrt-Commit):** 43e8c37cb4da64a12a3cb88a84b19db7f2fc640c

### Familie `image-auf-datentraeger`

12 Gerät(e).

#### raspberrypi-model-b

Raspberry Pi 1 Model B/B+ · bcm27xx-bcm2708 · K0

- **Weg ab Werk:** Gluon-factory (`.img.gz`) auf die SD-Karte schreiben [geprüft: targets/bcm27xx.inc]
- **Übertragung:** sd-karte (Kartenleser)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-factory .img.gz
- **Stock-Teile:** -
- **RAM:** je Modell
- **Gluon-RAMpe passt:** nein, keine Hersteller-Firmware im Spiel
- **Quelle (OpenWrt-Commit):** Gluon targets/bcm27xx-bcm2708
- **Detail-Anleitung:** -

#### raspberrypi-2-model-b

Raspberry Pi 2 Model B · bcm27xx-bcm2709 · K0

- **Weg ab Werk:** Gluon-factory (`.img.gz`) auf die SD-Karte schreiben [geprüft: targets/bcm27xx.inc]
- **Übertragung:** sd-karte (Kartenleser)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-factory .img.gz
- **Stock-Teile:** -
- **RAM:** je Modell
- **Gluon-RAMpe passt:** nein, keine Hersteller-Firmware im Spiel
- **Quelle (OpenWrt-Commit):** Gluon targets/bcm27xx-bcm2709
- **Detail-Anleitung:** -

#### raspberrypi-3-model-b

Raspberry Pi 3 Model B/B+ · bcm27xx-bcm2710 · K0

- **Weg ab Werk:** Gluon-factory (`.img.gz`) auf die SD-Karte schreiben [geprüft: targets/bcm27xx.inc]
- **Übertragung:** sd-karte (Kartenleser)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-factory .img.gz
- **Stock-Teile:** -
- **RAM:** je Modell
- **Gluon-RAMpe passt:** nein, keine Hersteller-Firmware im Spiel
- **Quelle (OpenWrt-Commit):** Gluon targets/bcm27xx-bcm2710
- **Detail-Anleitung:** -

#### raspberrypi-4-model-b

Raspberry Pi 4 Model B · bcm27xx-bcm2711 · K0

- **Weg ab Werk:** Gluon-factory (`.img.gz`) auf die SD-Karte schreiben [geprüft: targets/bcm27xx.inc]
- **Übertragung:** sd-karte (Kartenleser)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-factory .img.gz
- **Stock-Teile:** -
- **RAM:** je Modell
- **Gluon-RAMpe passt:** nein, keine Hersteller-Firmware im Spiel
- **Quelle (OpenWrt-Commit):** Gluon targets/bcm27xx-bcm2711
- **Detail-Anleitung:** -

#### friendlyelec-nanopi-r2c

FriendlyElec NanoPi R2C · rockchip-armv8 · K0

- **Weg ab Werk:** Gluon-sysupgrade (`.img.gz`, Gluon hat `factory = false`) auf die SD-Karte schreiben [abgeleitet: targets/rockchip-armv8]
- **Übertragung:** sd-karte (Kartenleser)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade .img.gz
- **Stock-Teile:** -
- **RAM:** je Modell
- **Gluon-RAMpe passt:** nein, keine Hersteller-Firmware im Spiel
- **Quelle (OpenWrt-Commit):** Gluon targets/rockchip-armv8; R2C: gluon-patches-hardware devices/add-nanopi-r2c
- **Detail-Anleitung:** -

#### friendlyelec-nanopi-r2s

FriendlyElec NanoPi R2S · rockchip-armv8 · K0

- **Weg ab Werk:** Gluon-sysupgrade (`.img.gz`, Gluon hat `factory = false`) auf die SD-Karte schreiben [abgeleitet: targets/rockchip-armv8]
- **Übertragung:** sd-karte (Kartenleser)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade .img.gz
- **Stock-Teile:** -
- **RAM:** je Modell
- **Gluon-RAMpe passt:** nein, keine Hersteller-Firmware im Spiel
- **Quelle (OpenWrt-Commit):** Gluon targets/rockchip-armv8
- **Detail-Anleitung:** -

#### friendlyelec-nanopi-r3s

FriendlyElec NanoPi R3S · rockchip-armv8 · K0

- **Weg ab Werk:** Gluon-sysupgrade (`.img.gz`, Gluon hat `factory = false`) auf die SD-Karte schreiben [abgeleitet: targets/rockchip-armv8]
- **Übertragung:** sd-karte (Kartenleser)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade .img.gz
- **Stock-Teile:** -
- **RAM:** je Modell
- **Gluon-RAMpe passt:** nein, keine Hersteller-Firmware im Spiel
- **Quelle (OpenWrt-Commit):** Gluon targets/rockchip-armv8
- **Detail-Anleitung:** -

#### friendlyelec-nanopi-r4s

FriendlyElec NanoPi R4S (4 GB) · rockchip-armv8 · K0

- **Weg ab Werk:** Gluon-sysupgrade (`.img.gz`, Gluon hat `factory = false`) auf die SD-Karte schreiben [abgeleitet: targets/rockchip-armv8]
- **Übertragung:** sd-karte (Kartenleser)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade .img.gz
- **Stock-Teile:** -
- **RAM:** je Modell
- **Gluon-RAMpe passt:** nein, keine Hersteller-Firmware im Spiel
- **Quelle (OpenWrt-Commit):** Gluon targets/rockchip-armv8
- **Detail-Anleitung:** -

#### x86-64

x86 (x86-64) · x86-64 · K0

- **Weg ab Werk:** Gluon-factory (`squashfs-combined-efi`, .img.gz/.vmdk/.vdi) auf Platte/USB schreiben [geprüft: targets/x86*]
- **Übertragung:** Datenträger direkt beschreiben
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-factory
- **Stock-Teile:** -
- **RAM:** -
- **Gluon-RAMpe passt:** nein; die Gluon-RAMpe-Prototyp wird hier nur in QEMU getestet (x86-64)
- **Quelle (OpenWrt-Commit):** Gluon targets/x86-64
- **Detail-Anleitung:** -

#### x86-generic

x86 (x86-generic) · x86-generic · K0

- **Weg ab Werk:** wie x86-64 [geprüft: targets/x86*]
- **Übertragung:** Datenträger direkt beschreiben
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-factory
- **Stock-Teile:** -
- **RAM:** -
- **Gluon-RAMpe passt:** nein; die Gluon-RAMpe-Prototyp wird hier nur in QEMU getestet (x86-64)
- **Quelle (OpenWrt-Commit):** Gluon targets/x86-generic
- **Detail-Anleitung:** -

#### x86-geode

x86 (x86-geode) · x86-geode · K0

- **Weg ab Werk:** Gluon `squashfs-combined` (.img.gz) [geprüft: targets/x86*]
- **Übertragung:** Datenträger direkt beschreiben
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-factory
- **Stock-Teile:** -
- **RAM:** -
- **Gluon-RAMpe passt:** nein; die Gluon-RAMpe-Prototyp wird hier nur in QEMU getestet (x86-64)
- **Quelle (OpenWrt-Commit):** Gluon targets/x86-geode
- **Detail-Anleitung:** -

#### x86-legacy

x86 (x86-legacy) · x86-legacy · K0

- **Weg ab Werk:** wie x86-64 [geprüft: targets/x86*]
- **Übertragung:** Datenträger direkt beschreiben
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** Gluon-factory
- **Stock-Teile:** -
- **RAM:** -
- **Gluon-RAMpe passt:** nein; die Gluon-RAMpe-Prototyp wird hier nur in QEMU getestet (x86-64)
- **Quelle (OpenWrt-Commit):** Gluon targets/x86-legacy
- **Detail-Anleitung:** -

### Familie `k0-webui`

87 Gerät(e).

#### buffalo-wzr-600dhp

Buffalo WZR-600DHP · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI (Administration, Firmware Upgrade) [geprüft]
- **Übertragung:** webui-upload: http://192.168.11.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-buffalo_wzr-600dhp-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-buffalo_wzr-600dhp-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 25f2f66eeaf720e3db154019fe0b32a146c6082f [geprüft]

#### buffalo-wzr-hp-ag300h

Buffalo WZR-HP-AG300H · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI (Administration, Firmware Upgrade) [geprüft]
- **Übertragung:** webui-upload: http://192.168.11.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-buffalo_wzr-hp-ag300h-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-buffalo_wzr-hp-ag300h-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 480bf28273926d7b30be21b7605dd4fefd07fc3a [geprüft]

#### buffalo-wzr-hp-g300nh-rtl8366s

Buffalo WZR-HP-G300NH (RTL8366S switch) · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI; alternativ U-Boot-TFTP mit tftp-Image [geprüft]
- **Übertragung:** webui-upload; alternativ tftp-server-am-geraet: 192.168.11.1 (arp -s auf 02:AA:BB:CC:DD:1A), PC 192.168.11.2
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-buffalo_wzr-hp-g300nh-s-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-buffalo_wzr-hp-g300nh-s-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** bc356de2850f14629cb1301be719772fa1212e72 [geprüft]

#### d-link-dap-1330-a1

D-Link DAP-1330 A1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI (ohne Passwort); Recovery-Web bei Reset beim Einschalten, notfalls per curl [geprüft]
- **Übertragung:** webui-upload bzw. recovery-web: Gerät 192.168.0.50 (oder per DHCP), `curl -F files=@<factory> http://192.168.0.50/cgi/index`
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-1330-a1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-1330-a1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 361c670a468cac8def368ed95487c72cfdb4a3fa [geprüft]

#### d-link-dap-1365-a1

D-Link DAP-1365 A1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI (ohne Passwort); Recovery-Web bei Reset beim Einschalten, notfalls per curl [geprüft]
- **Übertragung:** webui-upload bzw. recovery-web: Gerät 192.168.0.50 (oder per DHCP), `curl -F files=@<factory> http://192.168.0.50/cgi/index`
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-1365-a1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-1365-a1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 361c670a468cac8def368ed95487c72cfdb4a3fa [geprüft]

#### d-link-dap-2660-a1

D-Link DAP-2660 A1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI (admin, leeres Passwort); Recovery-Web bei Reset beim Einschalten [geprüft]
- **Übertragung:** webui-upload bzw. recovery-web: Gerät 192.168.0.50
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-2660-a1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-2660-a1-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 8ec997d0063bbc1ac41d1025f4c94ae6337899fa [geprüft]

#### d-link-dap-2680-a1

D-Link DAP-2680 A1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI (admin, leeres Passwort); Recovery-Web bei Reset beim Einschalten [geprüft]
- **Übertragung:** webui-upload bzw. recovery-web: Gerät 192.168.0.50
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-2680-a1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-2680-a1-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 256 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 5b58710fad2137eedad874f0fe8fe22082d1edc6 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=5b58710fad2137eedad874f0fe8fe22082d1edc6

#### d-link-dap-2695-a1

D-Link DAP-2695 A1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI; alternativ Emergency-Web-Server des Bootloaders über die Konsole (q drücken) [geprüft]
- **Übertragung:** webui-upload; alternativ recovery-web: Gerät 192.168.0.50, PC 192.168.0.90 (nur nach Abbruch an der RJ45-Konsole)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (auch für den seriellen Notweg: RJ45-RS-232-Konsole außen, 115200 8N1)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-2695-a1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dap-2695-a1-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 256 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** cd09f26660b684db541a0f49fc23988df142892c [geprüft]

#### netgear-wndr3700

NETGEAR WNDR3700 v1 · ath79-generic · K0

- **Weg ab Werk:** factory (.img) im Stock-Web-UI [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3700-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory-NA.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3700-squashfs-factory-NA.img), [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3700-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 4dc7cb792a8e34b6ad97c7b8058c70311a06bd38 [abgeleitet]

#### netgear-wndr3700-v2

NETGEAR WNDR3700 v2 · ath79-generic · K0

- **Weg ab Werk:** factory (.img) im Stock-Web-UI [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3700-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3700-v2-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 4dc7cb792a8e34b6ad97c7b8058c70311a06bd38 (ohne Anleitung) [abgeleitet]

#### netgear-wndr3800

NETGEAR WNDR3800 · ath79-generic · K0

- **Weg ab Werk:** factory (.img) im Stock-Web-UI [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3800-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3800-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 53c474abbdfef8eb3499e2d10c9ad491788b8a72 (erstes ath79-Target, ohne Anleitung) [abgeleitet]

#### netgear-wndr3800ch

NETGEAR WNDR3800CH · ath79-generic · K0

- **Weg ab Werk:** factory (.img) im Stock-Web-UI [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3800ch-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndr3800ch-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 00ed75f47f4726dff17c6d63d6847bc4f7a74970 [abgeleitet]

#### netgear-wndrmac-v2

NETGEAR WNDRMAC v2 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Upgrade-Web [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndrmac-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wndrmac-v2-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 7f297e740bc288d29fab1f7490ed0e2e49e9e6f9 [geprüft]

#### netgear-wnr2200-16m

NETGEAR WNR2200 16M · ath79-generic · K0

- **Weg ab Werk:** factory (.img) im Stock-Web-UI; auch TFTP-Recovery [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wnr2200-16m-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wnr2200-16m-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** f85d56bb034d8017bdb6b4bb493eb076a21d11b3 [geprüft]

#### netgear-wnr2200-8m

NETGEAR WNR2200 8M · ath79-generic · K0

- **Weg ab Werk:** factory (.img) im Stock-Web-UI; auch TFTP-Recovery [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wnr2200-8m-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory-NA.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wnr2200-8m-squashfs-factory-NA.img), [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-netgear_wnr2200-8m-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** f85d56bb034d8017bdb6b4bb493eb076a21d11b3 [geprüft]

#### tp-link-archer-a7-v5

TP-Link Archer A7 v5 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei ArcherC7v5_tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-a7-v5-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-a7-v5-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 1e4ee63cc8d1889a78b539a5ed7be8d56e9b976f [geprüft]

#### tp-link-archer-c2-v3

TP-Link Archer C2 v3 (broken) · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c2-v3-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c2-v3-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 9c01273e5e7b3929ad46d974685ec29de207a8de [geprüft]

#### tp-link-archer-c25-v1

TP-Link Archer C25 v1 (broken) · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c25-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c25-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** fde0abf267033bfaaf08dc2f5cbba2bf2a3ff897 (ohne Anleitung) [abgeleitet]

#### tp-link-archer-c5-v1

TP-Link Archer C5 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c5-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c5-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 438605454980ee815a506a9a2a4a3532ab378922 (ohne Anleitung, Wiki-Verweis) [abgeleitet]

#### tp-link-archer-c58-v1

TP-Link Archer C58 v1 (broken) · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c58-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c58-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 946ffe470d923fdde53db68592437194e0c276fc [geprüft]

#### tp-link-archer-c59-v1

TP-Link Archer C59 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c59-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c59-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 946ffe470d923fdde53db68592437194e0c276fc [geprüft]

#### tp-link-archer-c6-v2-eu-ru-jp

TP-Link Archer C6 v2 (EU/RU/JP) · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei ArcherC6v2_tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c6-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c6-v2-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** d03aae1a09fce5a5d5747855bc07ee1f54388e03 [geprüft]

#### tp-link-archer-c7-v2

TP-Link Archer C7 v2 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]; Gluon baut das factory mit Regionssuffix (GLUON_REGION, OpenWrt: factory-eu/-us) [Makefile geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c7-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory-eu.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c7-v2-squashfs-factory-eu.bin), [squashfs-factory-us.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c7-v2-squashfs-factory-us.bin), [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c7-v2-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** ba74b45476ab1fe36f8449b18501ba5d2c01cf8c (ohne Anleitung) [abgeleitet]

#### tp-link-archer-c7-v4

TP-Link Archer C7 v4 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei ArcherC7v4_tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c7-v4-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c7-v4-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 12310f05b7b080b016ec515796be437f4cd30b62 [geprüft]

#### tp-link-archer-c7-v5

TP-Link Archer C7 v5 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei ArcherC7v5_tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c7-v5-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c7-v5-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 8471944325db80ca37f7c756130070d0add58ff6 [geprüft]

#### tp-link-cpe210-v1

TP-Link CPE210 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe210-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe210-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 08857e69becc214336ba073bca6f626bfaa67781 [geprüft]

#### tp-link-cpe210-v2

TP-Link CPE210 v2 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe210-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe210-v2-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 141698ce8fbc52d253c9207ef46b3630a0870567 [geprüft]

#### tp-link-cpe210-v3

TP-Link CPE210 v3 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe210-v3-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe210-v3-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 5ec205d7ac00de89510a6e71055d45aa57b705e1 [geprüft]

#### tp-link-cpe220-v3

TP-Link CPE220 v3 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe220-v3-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe220-v3-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** bae0d47f2e36376d2876bc4d5557e3e11f80f2fb [geprüft]

#### tp-link-cpe510-v1

TP-Link CPE510 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe510-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe510-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 0104eed1e5ca93a1c912e2d9b70e800b8d3099ad [geprüft]

#### tp-link-cpe510-v2

TP-Link CPE510 v2 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe510-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe510-v2-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [abgeleitet: laut Commit Hardware wie CPE510]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** cad4132e003cecc386d791d552ddba42c182c216 [geprüft]

#### tp-link-cpe510-v3

TP-Link CPE510 v3 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe510-v3-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe510-v3-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [abgeleitet: laut Commit Hardware wie CPE510]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** cad4132e003cecc386d791d552ddba42c182c216 [geprüft]

#### tp-link-cpe710-v1

TP-Link CPE710 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt (Reset 30-40 s) alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe710-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe710-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** ac03e246351fbfa98e98f0319cce3a8663f836d3 [geprüft]

#### tp-link-cpe710-v2

TP-Link CPE710 v2 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt (Reset 30-40 s) alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe710-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_cpe710-v2-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 0b4d831886689b55e149e276dbca5b780fb6a00e [geprüft]

#### tp-link-tl-wdr3500-v1

TP-Link TL-WDR3500 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei wdr3500v1_tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wdr3500-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wdr3500-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** fbbb4eb8b41d59b38f41fe382c6e4108a36aa909 [geprüft]

#### tp-link-tl-wdr3600-v1

TP-Link TL-WDR3600 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wdr3600-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wdr3600-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** a7e1e919afa9659f66dada5e69d1b162f447ced7 (ohne Anleitung) [abgeleitet]

#### tp-link-tl-wdr4300-v1

TP-Link TL-WDR4300 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wdr4300-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wdr4300-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** a7e1e919afa9659f66dada5e69d1b162f447ced7 (ohne Anleitung) [abgeleitet]

#### tp-link-tl-wr1043n-v5

TP-Link TL-WR1043N v5 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei WR1043v5_tp_recovery.bin (Gerät 192.168.0.86)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr1043n-v5-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr1043n-v5-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** d4b89b7170ab82530cfaf21e5f00bee7088432e2 [geprüft]

#### tp-link-tl-wr1043nd-v2

TP-Link TL-WR1043N/ND v2 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr1043nd-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr1043nd-v2-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** b1a173d7c396c0a9e6bb0078a1a061eb9fdd0316 (ohne Anleitung) [abgeleitet]

#### tp-link-tl-wr1043nd-v3

TP-Link TL-WR1043N/ND v3 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr1043nd-v3-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr1043nd-v3-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** b1a173d7c396c0a9e6bb0078a1a061eb9fdd0316 (ohne Anleitung) [abgeleitet]

#### tp-link-tl-wr1043nd-v4

TP-Link TL-WR1043N/ND v4 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr1043nd-v4-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr1043nd-v4-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 71ae0792bad1b0eeb476513e15b326409f15ccb0 (ohne Anleitung) [abgeleitet]

#### tp-link-tl-wr2543n-nd

TP-Link TL-WR2543N/ND v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [abgeleitet: Commit ohne Anleitung]
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr2543-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr2543-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 2a7e03af37d1112c2c2f6b6c80283d4d49407889 (ohne Anleitung) [abgeleitet]

#### tp-link-tl-wr810n-v1

TP-Link TL-WR810N v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI (192.168.0.254, admin/admin) [geprüft über Verweis auf ar71xx-Commit b23b0fb2]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei wr810nv1_tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr810n-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr810n-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** cdbf2de77768dfde560b4ea663b4eac0d3a5a581 (Verweis); b23b0fb28b760ce66a8f93d4681c8bd300d75d30 (ar71xx, Anleitung) [geprüft]

#### tp-link-tl-wr842n-v3

TP-Link TL-WR842N v3 · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]; Dateiname darf eine gewisse Länge nicht überschreiten
- **Übertragung:** webui-upload (Stock-Web-UI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr842n-v3-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr842n-v3-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** e0d98e120a94b75f63066d7abc6a392996ccb284 [geprüft]

#### tp-link-tl-wr902ac-v1

TP-Link TL-WR902AC v1 (broken) · ath79-generic · K0

- **Weg ab Werk:** factory im Stock-Web-UI hochladen [geprüft]
- **Übertragung:** webui-upload (Stock-Web-UI); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei wr902acv1_un_tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr902ac-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_tl-wr902ac-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 60de1fdbb4492b5270edf49d634979c0cfd1e743 [geprüft]

#### tp-link-wbs210-v1

TP-Link WBS210 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_wbs210-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_wbs210-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 866ad466626e6a83831f79e9dd072c31a2b71d66 [geprüft]

#### tp-link-wbs210-v2

TP-Link WBS210 v2 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_wbs210-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_wbs210-v2-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 3930aab2cb067d04f5c9ebbf1af57744e19355eb [geprüft]

#### tp-link-wbs510-v1

TP-Link WBS510 v1 · ath79-generic · K0

- **Weg ab Werk:** factory im Pharos-Web-UI (https://192.168.0.254) hochladen [geprüft]; TFTP-Rescue nimmt laut Neanderfunk-Labortest vom 01.10.2026 nur TP-Link-Firmware (Neanderfunk-Notiz tplink-pharos-flashen.md), entgegen dem Commit
- **Übertragung:** webui-upload: https://192.168.0.254 (TLS 1.0); Commit nennt alternativ tftp-client: Server 192.168.0.100, Datei recovery.bin, Gerät 192.168.0.254
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_wbs510-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_wbs510-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 20fdfe37d21f19901eec86ace8da0c083faa7ebc [geprüft]

#### netgear-wndr3700-v4

NETGEAR WNDR3700 v4 · ath79-nand · K0

- **Weg ab Werk:** factory (.img) im Stock-Web-UI; auch TFTP-Recovery und U-Boot-TFTP [geprüft]
- **Übertragung:** webui-upload; alternativ TFTP-Recovery (Details im Commit nicht genannt)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-netgear_wndr3700-v4-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-netgear_wndr3700-v4-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 7e623c312832386d5eb5aa970738288cf96d96c3 [geprüft]

#### netgear-wndr4300

NETGEAR WNDR4300 · ath79-nand · K0

- **Weg ab Werk:** factory (.img) im Stock-Web-UI; auch TFTP-Recovery und U-Boot-TFTP [geprüft]
- **Übertragung:** webui-upload; alternativ TFTP-Recovery (Details im Commit nicht genannt)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-netgear_wndr4300-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-netgear_wndr4300-squashfs-factory.img)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 9b6f89c37fc9c2e23cc123bd7b5cf9a1f8dc301a [geprüft]

#### zyxel-nbg6716

Zyxel NBG6716 · ath79-nand · K0

- **Weg ab Werk:** Commit beschreibt nur den Wechsel von ar71xx und den zloader-Zugang; Weg aus der Stock-Firmware nicht beschrieben [abgeleitet: Web-UI]
- **Übertragung:** webui-upload [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-zyxel_nbg6716-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-zyxel_nbg6716-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 99835e09992bb411519fda1f8d16a6d07df7f598 [abgeleitet]

#### linksys-ea6350v3

Linksys EA6350 v3 · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory über die Linksys-Smart-WiFi-UI (Connectivity > Manual update) [geprüft]
- **Übertragung:** webui-upload: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_ea6350v3-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_ea6350v3-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt a873b292840848b67addb5be0c762d292bde33a1
- **Detail-Anleitung:** -

#### linksys-ea8300-dallas

Linksys EA8300 · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory über die Linksys-UI [geprüft]
- **Übertragung:** webui-upload: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_ea8300-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_ea8300-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 819e7946b0964725dab50c92797f49cf4053d955
- **Detail-Anleitung:** -

#### linksys-mr8300-dallas

Linksys MR8300 · ipq40xx-generic · K0

- **Weg ab Werk:** Linksys-UI (https://192.168.1.1/fwupdate.html) nimmt ein factory-Image [geprüft]; Gluon setzt aber `factory = false` (ohne Begründung im Gluon-Commit d04ea647), also heute OpenWrt-factory als Zwischenschritt, dann Gluon-sysupgrade
- **Übertragung:** webui-upload: https://192.168.1.1/fwupdate.html
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** OpenWrt-24.10-factory als Zwischenschritt
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_mr8300-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_mr8300-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: eine Gluon-RAMpe bräuchte das Linksys-factory-Format (Kernel + UBI, linksys-image), kein initramfs; einfacher wäre `factory` in Gluon einzuschalten [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt a9071d02b5ab11fbd73ea42076a09f2fd8136517
- **Detail-Anleitung:** -

#### linksys-vlp01

Linksys VLP01 (Alias von linksys-whw01) · ipq40xx-generic · K0

- **Weg ab Werk:** wie WHW01 [abgeleitet: Alias]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt b4184c666c13fdf08ecd3abf340538d593e9084c
- **Detail-Anleitung:** https://openwrt.org/toh/linksys/whw01_v1#installation

#### linksys-whw01

Linksys WHW01 v1 (Velop) · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory über die Linksys-UI im Support-Modus ("CA"-Link) [geprüft: OpenWrt-Wiki, Abruf 10.10.2026]; der OpenWrt-Commit kennt nur UART + TFTP (Server 192.168.1.236, Datei nodes-jr.img, `run flashimg`/`flashimg2`) [geprüft]
- **Übertragung:** webui-upload; seriell: tftp-client Server 192.168.1.236, Datei nodes-jr.img
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_whw01-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_whw01-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory); beide Partitionen beachten
- **Quelle (OpenWrt-Commit):** OpenWrt b4184c666c13fdf08ecd3abf340538d593e9084c
- **Detail-Anleitung:** https://openwrt.org/toh/linksys/whw01_v1#installation

#### linksys-whw03-v2-velop

Linksys WHW03 v2 (Velop) · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory über http://192.168.1.1/ca (Support-Modus), Connectivity [geprüft]
- **Übertragung:** webui-upload: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_whw03v2-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_whw03v2-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 9e4ede8344d60d4837e047e9275c21fd2a8f130b
- **Detail-Anleitung:** https://openwrt.org/toh/linksys/whw03_v2#oem_easy_installation

#### linksys-whw03-velop

Linksys WHW03 v1 (Velop) · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory über die Linksys-UI im Support-Modus (Link "CA" unten), Connectivity > Choose file [geprüft]
- **Übertragung:** webui-upload: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_whw03-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-linksys_whw03-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt c90487556229ae264dec33305e5c71c4ef7dd1c5
- **Detail-Anleitung:** https://openwrt.org/toh/linksys/whw03_v1#oem_easy_installation

#### netgear-ex6100v2

NETGEAR EX6100 v2 · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory (`.img`) über die Netgear-Web-UI (ggf. zweite Bestätigung wegen "älterer" Version) [geprüft]
- **Übertragung:** webui-upload; alternativ seriell `fw_recovery` (Gerät ist TFTP-Server 192.168.1.1)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_ex6100v2-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_ex6100v2-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 970f1914be3f299fb302ca74a214589397000858
- **Detail-Anleitung:** -

#### netgear-ex6150v2

NETGEAR EX6150 v2 · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory (`.img`) über die Netgear-Web-UI (ggf. zweite Bestätigung wegen "älterer" Version) [geprüft]
- **Übertragung:** webui-upload; alternativ seriell `fw_recovery` (Gerät ist TFTP-Server 192.168.1.1)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_ex6150v2-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_ex6150v2-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 970f1914be3f299fb302ca74a214589397000858
- **Detail-Anleitung:** https://freifunk-ingolstadt.de/eigener-freifunk-hotspot/anleitung/installationsanleitung-fuer-netgear-wi-fi-range-extender-ex6150-v2/

#### zyxel-nbg6617

Zyxel NBG6617 · ipq40xx-generic · K0

- **Weg ab Werk:** Gluon-factory über die Zyxel-Web-UI (Expert Mode > Maintenance > Firmware-Upgrade, Passwort 1234) [geprüft]
- **Übertragung:** webui-upload: Gerät 192.168.1.1 (DHCP); Notweg tftp-client: Server 192.168.1.99, Datei ras.bin, WPS-Taste beim Einschalten
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-zyxel_nbg6617-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-zyxel_nbg6617-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 82618062cf7ed6b40d2c52c6f6b96364888ffda6
- **Detail-Anleitung:** -

#### netgear-nighthawk-x4s-r7800

NETGEAR Nighthawk X4S R7800 · ipq806x-generic · K0

- **Weg ab Werk:** Gluon-factory (`.img`) über die Netgear-Web-UI [abgeleitet: Image-Rezept DniImage, Commit ohne Text]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage](https://downloads.openwrt.org/releases/24.10.8/targets/ipq806x/generic/openwrt-24.10.8-ipq806x-generic-netgear_r7800-initramfs-uImage)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ipq806x/generic/openwrt-24.10.8-ipq806x-generic-netgear_r7800-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** ?
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 823242185b56ea518568296f1a5834f736f12076
- **Detail-Anleitung:** -

#### tp-link-archer-c2600

TP-Link Archer C2600 v1 · ipq806x-generic · K0

- **Weg ab Werk:** Gluon-factory (safeloader) über die TP-Link-Web-UI [abgeleitet: Image-Rezept TpSafeImage, Commit ohne Text]; Gluon: broken
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage](https://downloads.openwrt.org/releases/24.10.8/targets/ipq806x/generic/openwrt-24.10.8-ipq806x-generic-tplink_c2600-initramfs-uImage)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq806x/generic/openwrt-24.10.8-ipq806x-generic-tplink_c2600-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** ?
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt ef02e8967cac02ebec78fadd063b367e67f8fbc6
- **Detail-Anleitung:** -

#### netgear-dgn3500b

NETGEAR DGN3500B · lantiq-xway · K0

- **Weg ab Werk:** factory.img im Stock-Web-UI oder im Sercomm-Bootmodus mit Windows-Werkzeug (Upgrade_207_XP) [geprüft]
- **Übertragung:** webui-upload; herstellertool
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xway/openwrt-24.10.8-lantiq-xway-netgear_dgn3500b-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 575127fe1c82e814da155a15be0a02b4153e1d00

#### netgear-wax220

NETGEAR WAX220 · mediatek-filogic · K0

- **Weg ab Werk:** Gluon-factory (`.img`, verschlüsselt) über die Stock-Web-UI [abgeleitet: Image-Rezept "Padding … required by OEM web interface"; Commit nennt nur UART]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-netgear_wax220-initramfs-recovery.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-netgear_wax220-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** 1 GB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 984786a2f7ec622c99e8c9cdada65d0ea0cf4e0b
- **Detail-Anleitung:** https://openwrt.org/toh/netgear/wax220#oem_easy_installation

#### openwrt-one

OpenWrt One · mediatek-filogic · K0

- **Weg ab Werk:** ab Werk OpenWrt: Gluon-sysupgrade (`.itb`) über LuCI/sysupgrade; Gluon-factory `.ubi` für die Neuinstallation über den NOR-U-Boot (Bootschalter) [abgeleitet: Image-Rezept, Commit ohne Installationsabschnitt]
- **Übertragung:** webui-upload (LuCI)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-openwrt_one-initramfs.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: factory.ubi](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-openwrt_one-factory.ubi)
- **Stock-Teile:** -
- **RAM:** 1 GB
- **Gluon-RAMpe passt:** nein, nicht nötig
- **Quelle (OpenWrt-Commit):** OpenWrt 797904b3cb4a5c575641c19e7f3989926e4c7902
- **Detail-Anleitung:** -

#### zyxel-nwa50ax-pro

Zyxel NWA50AX Pro · mediatek-filogic · K0

- **Weg ab Werk:** Gluon-factory über die Zyxel-Web-UI; vorher muss Slot B aktiv sein, sonst bootet OpenWrt nur einmal (dann erst ein Zyxel-Update einspielen) [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-zyxel_nwa50ax-pro-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-zyxel_nwa50ax-pro-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt f0445746f6fd96fc7c5394b238153bd2ff22bc5b
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=f0445746f6fd96fc7c5394b238153bd2ff22bc5b

#### zyxel-nwa90ax-pro

Zyxel NWA90AX Pro (Alias von zyxel-nwa50ax-pro) · mediatek-filogic · K0

- **Weg ab Werk:** wie NWA50AX Pro; Factory braucht compat-model 81e1, im Backport enthalten [geprüft: Patch 0003]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt e34e874a11f0506ff17365819bc101a455dc503e + 2cc8d3e382c0b8b919cef2e9f1cfec9ec7954150; gluon-patches-hardware 9263f242b86a943e62671ec445f08dd9eb2dfbd2 [Backport]
- **Detail-Anleitung:** -

#### tp-link-tl-wdr4900-v1

TP-Link TL-WDR4900 v1 · mpc85xx-p1010 · K0

- **Weg ab Werk:** factory im Stock-Web-UI [abgeleitet: ToH "GUI OEM"; Commit ohne Text]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** kein initramfs in 24.10.8
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 4305c6cda18051efad9952425a8ce2478adc64b9 (ohne Installationstext)

#### linksys-mx5300

Linksys MX5300 · qualcommax-ipq807x · K0

- **Weg ab Werk:** Gluon-factory über die Linksys-UI (manuelles Update); danach laut Commit dasselbe factory per `mtd write` auch in die zweite Partition [geprüft]
- **Übertragung:** webui-upload; alternativ usb (initramfs von FAT32-Stick, seriell)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/qualcommax/ipq807x/openwrt-24.10.8-qualcommax-ipq807x-linksys_mx5300-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/qualcommax/ipq807x/openwrt-24.10.8-qualcommax-ipq807x-linksys_mx5300-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 1 GB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 70fd815e57dc98cef88828faa5ce71717540e99e
- **Detail-Anleitung:** -

#### nexx-wt3020-8m

Nexx WT3020 8M (Aliase WT3020AD/F/H) · ramips-mt7620 · K0

- **Weg ab Werk:** factory (Poray-Header) im Stock-Web-UI [abgeleitet: mk + ToH "GUI OEM"; Wiki beschreibt zusätzlich Breed-U-Boot]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-nexx_wt3020-8m-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 7bac455a4ccd4a55e5db64c7eac224c98be045b6 (ohne Installationstext)

#### tp-link-archer-c20i

TP-Link Archer C20i · ramips-mt7620 · K0

- **Weg ab Werk:** factory im Stock-Web-UI [abgeleitet: Gluon baut factory; Wiki nennt nur TFTP-Recovery mit ArcherC20iV1_tp_recovery.bin von 192.168.0.66]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-tplink_archer-c20i-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 48d8bc4f971ad7795e3162134759caa37900138f (ohne Installationstext)

#### tp-link-archer-c50-v1

TP-Link Archer C50 v1 · ramips-mt7620 · K0

- **Weg ab Werk:** factory-eu/-us (Gluon: Regionssuffix) im Stock-Web-UI [abgeleitet: Gluon baut factory; Wiki nennt TFTP-Recovery wie TL-WDR4300]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-tplink_archer-c50-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 1c00c09eb6af88a0a96451f8da6108171c46a42d (ohne Installationstext)

#### d-link-covr-x1860-a1

D-Link COVR-X1860 A1 · ramips-mt7621 · K0

- **Weg ab Werk:** factory im Stock-Web-UI (`/UpdateFirmware_Simple.html`) oder Gluon-recovery.bin (squashfs) in der Web-Recovery [geprüft; Neanderfunk-Notiz dlink-flashen.md]
- **Übertragung:** webui-upload (192.168.0.1); recovery-web: Gerät 192.168.0.1, Rechner 192.168.0.10/24, rechter LAN-Port, kein Ping
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-dlink_covr-x1860-a1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community); Gluon-recovery.bin
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nicht nötig (Gluon hat factory und recovery); steht in GERAETE.md noch als Kandidat
- **Quelle (OpenWrt-Commit):** 0a18259e4aa361cd9e5848c038be4b9f4e3bfcc6
- **Detail-Anleitung:** https://freifunk-aachen.de/2023/08/03/installationsanleitung-d-link-covr-x1860/

#### d-link-dir-860l-b1

D-Link DIR-860L B1 · ramips-mt7621 · K0

- **Weg ab Werk:** factory (SEAMA) über das Stock-Web-UI oder die D-Link-Recovery [abgeleitet: ToH "D-Link Recovery GUI"; Commit ohne Text]
- **Übertragung:** webui-upload; recovery-web
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-dlink_dir-860l-b1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 40b740b23234574115225bf8bde7bc679f8034e1 (ohne Installationstext)

#### mercusys-mr70x-v1

Mercusys MR70X v1 · ramips-mt7621 · K0

- **Weg ab Werk:** factory im Stock-Web-UI [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-mercusys_mr70x-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 47de2c686291e69afc9f443e27e1dfd11ed5fbe7

#### netgear-wac104

NETGEAR WAC104 · ramips-mt7621 · K0

- **Weg ab Werk:** factory.img im Stock-Web-UI [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_wac104-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 221d8a1c6086ffd8bc53f81d5074a177d8dd8480

#### tp-link-archer-ax23-v1

TP-Link Archer AX23 v1 (Gluon: broken) · ramips-mt7621 · K0

- **Weg ab Werk:** factory im Stock-Web-UI; Web-Recovery 192.168.0.1 (Reset beim Einschalten) nimmt factory [geprüft]
- **Übertragung:** webui-upload; recovery-web 192.168.0.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-tplink_archer-ax23-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 7dceef5ee554ec4ab5d2dd2ff999f4a60bf2e0f4

#### tp-link-archer-c6-v3

TP-Link Archer C6 v3 (Gluon: broken) · ramips-mt7621 · K0

- **Weg ab Werk:** factory im Stock-Web-UI [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-tplink_archer-c6-v3-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** d22fb7f4fd833c420bc2ab34384862da0a6688b5

#### tp-link-re500-v1

TP-Link RE500 v1 · ramips-mt7621 · K0

- **Weg ab Werk:** factory im Stock-Web-UI [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-tplink_re500-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** ba0f4f0cfddc6f1152273565ec35f2a0bda1e95d

#### tp-link-re650-v1

TP-Link RE650 v1 · ramips-mt7621 · K0

- **Weg ab Werk:** factory im Stock-Web-UI [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-tplink_re650-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 8c51ddeff0876b439ac35a3f492ab719085bfb9c

#### zyxel-nwa50ax

ZyXEL NWA50AX (Alias NWA90AX) · ramips-mt7621 · K0

- **Weg ab Werk:** factory im Stock-Web-UI; nur wenn das aktive Image auf Slot B liegt, sonst erst ein ZyXEL-Update einspielen [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-zyxel_nwa50ax-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** a0b7fef0ffe4cd9cca39a652a37e4f3ce8f0a681
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-nwa50ax-nwa55axe/964

#### zyxel-nwa55axe

ZyXEL NWA55AXE (Gluon: broken) · ramips-mt7621 · K0

- **Weg ab Werk:** wie NWA50AX; ohne Reset-Taste, bei unbekanntem Passwort nur seriell (atns-Trick, TFTP owrt.bin, ramboot-factory) [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-zyxel_nwa55axe-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** a0b7fef0ffe4cd9cca39a652a37e4f3ce8f0a681
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-nwa50ax-nwa55axe/964

#### cudy-wr1000

Cudy WR1000 · ramips-mt76x8 · K0

- **Weg ab Werk:** factory im Stock-Web-UI [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-cudy_wr1000-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 7c91144ae6a45dc8d7ca6b68b3403e166185a498

#### tp-link-re200-v2

TP-Link RE200 v2 · ramips-mt76x8 · K0

- **Weg ab Werk:** factory im Stock-Web-UI; keine Recovery, im Fehlerfall nur seriell [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_re200-v2-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 6d6f36ae787c3b339b16c1d345a90faa1d9f4011

#### tp-link-re200-v3

TP-Link RE200 v3 · ramips-mt76x8 · K0

- **Weg ab Werk:** factory im Stock-Web-UI; keine Recovery, im Fehlerfall nur seriell [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_re200-v3-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 009e62c92c35142c5be3b375d6c393e63d2d27eb

#### tp-link-re200-v4

TP-Link RE200 v4 · ramips-mt76x8 · K0

- **Weg ab Werk:** factory im Stock-Web-UI; keine Recovery, im Fehlerfall nur seriell [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_re200-v4-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 33b76d66d1afa9d888f32587b18d78a930593ca5

### Familie `mikrotik-netboot`

9 Gerät(e).

#### mikrotik-routerboard-951ui-2nd-hap

MikroTik RouterBOARD 951Ui-2nD (hAP) · ath79-mikrotik · K1

- **Weg ab Werk:** RouterBOOT-Netboot: initramfs per BOOTP/DHCP+TFTP booten, dann sysupgrade [geprüft: Commit verweist auf openwrt.org/toh/mikrotik/common; Einzelschritte abgeleitet aus dem Wiki]
- **Übertragung:** tftp-client-am-geraet: eigener DHCP/BOOTP- und TFTP-Server, Dateiname per DHCP [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server (z. B. dnsmasq); kein netinstall nötig [abgeleitet]
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/mikrotik/openwrt-24.10.8-ath79-mikrotik-mikrotik_routerboard-951ui-2nd-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory = initramfs (mikrotik.inc)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** ja: Gluon liefert hier selbst das initramfs als factory (mikrotik.inc); Gluon-RAMpe wäre die Variante mit Upload-Seite. Prüfen: startet Gluons initramfs-factory überhaupt im Config-Mode (Befund 70_initramfs_test aus NOTIZEN.md)? [abgeleitet]
- **Quelle (OpenWrt-Commit):** 5ce64e0646fcd5c4f374b4de898b591560c32e18 [geprüft]

#### mikrotik-routerboard-mapl-2nd

MikroTik RouterBOARD mAPL-2nD (mAP lite) · ath79-mikrotik · K1

- **Weg ab Werk:** RouterBOOT-Netboot: initramfs per BOOTP/DHCP+TFTP booten, dann sysupgrade [geprüft: Commit verweist auf openwrt.org/toh/mikrotik/common; Einzelschritte abgeleitet aus dem Wiki]
- **Übertragung:** tftp-client-am-geraet: eigener DHCP/BOOTP- und TFTP-Server, Dateiname per DHCP [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server (z. B. dnsmasq); kein netinstall nötig [abgeleitet]
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/mikrotik/openwrt-24.10.8-ath79-mikrotik-mikrotik_routerboard-mapl-2nd-initramfs-kernel.bin) (HEAD 200)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** ja: Netboot nimmt ein initramfs. Neanderfunk-Patch setzt factory = false (ohne dokumentierten Grund), obwohl mikrotik.inc sonst das initramfs als factory ausliefert
- **Quelle (OpenWrt-Commit):** eb38af788180d624e5b37aa5db1fe3766b138dc8 [geprüft]

#### mikrotik-routerboard-wap-g-5hact2hnd

MikroTik RouterBOARD wAP G-5HacT2HnD (wAP AC) · ath79-mikrotik · K1

- **Weg ab Werk:** RouterBOOT-Netboot: initramfs per BOOTP/DHCP+TFTP booten, dann sysupgrade [geprüft: Commit verweist auf openwrt.org/toh/mikrotik/common; Einzelschritte abgeleitet aus dem Wiki]
- **Übertragung:** tftp-client-am-geraet: eigener DHCP/BOOTP- und TFTP-Server, Dateiname per DHCP [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server (z. B. dnsmasq); kein netinstall nötig [abgeleitet]
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/mikrotik/openwrt-24.10.8-ath79-mikrotik-mikrotik_routerboard-wap-g-5hact2hnd-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** ja: Netboot nimmt ein initramfs. Neanderfunk-Patch setzt factory = false (ohne dokumentierten Grund), obwohl mikrotik.inc sonst das initramfs als factory ausliefert
- **Quelle (OpenWrt-Commit):** 6aaa5ce2c5138877e0f0504c3bd536b40e9af928 [geprüft]

#### mikrotik-routerboard-wapr-2nd

MikroTik RouterBOARD wAPR-2nD (wAP R) · ath79-mikrotik · K1

- **Weg ab Werk:** RouterBOOT-Netboot: initramfs per BOOTP/DHCP+TFTP booten, dann sysupgrade [geprüft: Commit verweist auf openwrt.org/toh/mikrotik/common; Einzelschritte abgeleitet aus dem Wiki]
- **Übertragung:** tftp-client-am-geraet: eigener DHCP/BOOTP- und TFTP-Server, Dateiname per DHCP [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server (z. B. dnsmasq); kein netinstall nötig [abgeleitet]
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/mikrotik/openwrt-24.10.8-ath79-mikrotik-mikrotik_routerboard-wapr-2nd-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory = initramfs (mikrotik.inc)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** ja: Gluon liefert hier selbst das initramfs als factory (mikrotik.inc); Gluon-RAMpe wäre die Variante mit Upload-Seite. Prüfen: startet Gluons initramfs-factory überhaupt im Config-Mode (Befund 70_initramfs_test aus NOTIZEN.md)? [abgeleitet]
- **Quelle (OpenWrt-Commit):** 817bf0204569ca28121576c13f48186ed7b7c2ae [geprüft]

#### mikrotik-discg-5acd

MikroTik DISC Lite5 ac (Alias von mikrotik-sxtsq-5-ac-rbsxtsqg-5acd) · ipq40xx-mikrotik · K1

- **Weg ab Werk:** wie SXTsq 5 ac [abgeleitet: Alias]
- **Übertragung:** tftp-client: RouterBOOT holt per BOOTP/DHCP + TFTP vom Rechner (DHCP-/BOOTP- und TFTP-Server nötig, Dateiname per DHCP-Option) [abgeleitet: Commit verweist auf openwrt.org/toh/mikrotik/common, nicht gelesen]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server
- **initramfs-Link:** -
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** ?
- **Gluon-RAMpe passt:** ja: wie SXTsq
- **Quelle (OpenWrt-Commit):** OpenWrt d1f1e5269ed992e6fc30d575b43b0913c9e58ca2 (Gluon-Alias)
- **Detail-Anleitung:** -

#### mikrotik-hap-ac2

MikroTik hAP ac2 (RBD52G-5HacD2HnD) · ipq40xx-mikrotik · K1

- **Weg ab Werk:** RouterBOOT-Netboot (BOOTP/DHCP + TFTP) bootet das initramfs, danach sysupgrade; das sysupgrade löscht bei tmpfs-root die Partition `firmware` selbst [geprüft: Commit, platform.sh]; Gluons "factory" ist hier selbst ein initramfs (mikrotik.inc)
- **Übertragung:** tftp-client: RouterBOOT holt per BOOTP/DHCP + TFTP vom Rechner (DHCP-/BOOTP- und TFTP-Server nötig, Dateiname per DHCP-Option) [abgeleitet: Commit verweist auf openwrt.org/toh/mikrotik/common, nicht gelesen]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server (z. B. dnsmasq); netinstall nicht nötig [abgeleitet]
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/mikrotik/openwrt-24.10.8-ipq40xx-mikrotik-mikrotik_hap-ac2-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** Gluon `-factory` = initramfs-kernel
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** ja: Netboot nimmt ein initramfs; laut RAMpe-NOTIZEN startet ein Gluon-initramfs nicht im Config-Mode, die Gluon-RAMpe wäre der passende Ersatz für Gluons eigenes initramfs-"factory" [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt faea7becafc634dc882f0ad8f9388862ccd5bd0d
- **Detail-Anleitung:** -

#### mikrotik-sxtsq-5-ac-rbsxtsqg-5acd

MikroTik SXTsq 5 ac (RBSXTsqG-5acD) · ipq40xx-mikrotik · K1

- **Weg ab Werk:** RouterBOOT-Netboot (BOOTP/DHCP + TFTP) bootet das initramfs, danach sysupgrade; das sysupgrade löscht bei tmpfs-root die Partition `firmware` selbst [geprüft: Commit, platform.sh]; Gluon liefert hier kein initramfs (`factory = false`)
- **Übertragung:** tftp-client: RouterBOOT holt per BOOTP/DHCP + TFTP vom Rechner (DHCP-/BOOTP- und TFTP-Server nötig, Dateiname per DHCP-Option) [abgeleitet: Commit verweist auf openwrt.org/toh/mikrotik/common, nicht gelesen]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/mikrotik/openwrt-24.10.8-ipq40xx-mikrotik-mikrotik_sxtsq-5-ac-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** ja: wie hAP ac2; heute nur mit OpenWrt-initramfs als Zwischenschritt
- **Quelle (OpenWrt-Commit):** OpenWrt d1f1e5269ed992e6fc30d575b43b0913c9e58ca2
- **Detail-Anleitung:** -

#### mikrotik-wap-ac

MikroTik wAP ac (RBwAPG-5HacD2HnD, ipq40xx) · ipq40xx-mikrotik · K1

- **Weg ab Werk:** RouterBOOT-Netboot (BOOTP/DHCP + TFTP) bootet das initramfs, danach sysupgrade; das sysupgrade löscht bei tmpfs-root die Partition `firmware` selbst [geprüft: Commit, platform.sh]; Gluon liefert hier kein initramfs (`factory = false`)
- **Übertragung:** tftp-client: RouterBOOT holt per BOOTP/DHCP + TFTP vom Rechner (DHCP-/BOOTP- und TFTP-Server nötig, Dateiname per DHCP-Option) [abgeleitet: Commit verweist auf openwrt.org/toh/mikrotik/common, nicht gelesen]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/mikrotik/openwrt-24.10.8-ipq40xx-mikrotik-mikrotik_wap-ac-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** ja: wie hAP ac2
- **Quelle (OpenWrt-Commit):** OpenWrt 7f54bf6fe2ac331d018cd273bb1abe04493b5457
- **Detail-Anleitung:** -

#### mikrotik-routerboard-750gr3

MikroTik hEX RB750Gr3 (Alias mikrotik-routerboard-hex-v3) · ramips-mt7621 · K1

- **Weg ab Werk:** RouterBOOT-Netboot: RouterOS ggf. auf v6 zurück, Reset beim Einschalten halten, das Gerät holt das initramfs per BOOTP/DHCP + TFTP und bootet es im RAM, dann sysupgrade [geprüft: Commit verweist auf die MikroTik-Methode; Wiki toh:mikrotik:common]
- **Übertragung:** tftp-client-am-geraet + eigener BOOTP/DHCP-Server (Dateiname per DHCP-Option), WAN-Port
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** DHCP/BOOTP+TFTP-Server (z. B. dnsmasq); Netinstall nur für RouterOS
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-mikrotik_routerboard-750gr3-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** ja: Netboot lädt ein beliebiges initramfs (ELF); Gluon-RAMpe statt OpenWrt-initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** 52f2d7d2a9dc3e142bb957462a30806eb5cebaf4 (+ faf94d926e2810f895f2a98d4a49ee2fe8f673e8: Erstunterstützung mit Bootloader-Tausch, überholt)
- **Detail-Anleitung:** https://openwrt.org/toh/mikrotik/common

### Familie `netgear-nmrp`

15 Gerät(e).

#### netgear-rbr50

NETGEAR Orbi RBR50 v1 · ipq40xx-generic · K0+

- **Weg ab Werk:** Gluon-factory (`.img`) läuft nur auf Boot-Partition 1, die Netgear-UI schreibt immer in die andere: entweder nmrpflash beim Einschalten, oder Telnet über debug.htm einschalten, `artmtd -w boot_part 02`, Neustart, dann Web-UI [geprüft]
- **Übertragung:** herstellertool (NMRP mit nmrpflash, Rechner notfalls 10.164.183.253); oder telnet 192.168.1.250 + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** nmrpflash
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_rbr50-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_rbr50-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 2cb24b3f3cd89692f3c0bd137f3f560ada359bfa
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2cb24b3f3cd89692f3c0bd137f3f560ada359bfa

#### netgear-rbs50

NETGEAR Orbi RBS50 v1 · ipq40xx-generic · K0+

- **Weg ab Werk:** Gluon-factory (`.img`) läuft nur auf Boot-Partition 1, die Netgear-UI schreibt immer in die andere: entweder nmrpflash beim Einschalten, oder Telnet über debug.htm einschalten, `artmtd -w boot_part 02`, Neustart, dann Web-UI [geprüft]
- **Übertragung:** herstellertool (NMRP mit nmrpflash, Rechner notfalls 10.164.183.253); oder telnet 192.168.1.250 + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** nmrpflash
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_rbs50-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_rbs50-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 2cb24b3f3cd89692f3c0bd137f3f560ada359bfa
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2cb24b3f3cd89692f3c0bd137f3f560ada359bfa

#### netgear-srr60

NETGEAR Orbi Pro SRR60 · ipq40xx-generic · K0+

- **Weg ab Werk:** Gluon-factory (`.img`) läuft nur auf Boot-Partition 1, die Netgear-UI schreibt immer in die andere: entweder nmrpflash beim Einschalten, oder Telnet über debug.htm einschalten, `artmtd -w boot_part 02`, Neustart, dann Web-UI [geprüft]
- **Übertragung:** herstellertool (NMRP mit nmrpflash, Rechner notfalls 10.164.183.253); oder telnet 192.168.1.250 + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** nmrpflash
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_srr60-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_srr60-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 2cb24b3f3cd89692f3c0bd137f3f560ada359bfa
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2cb24b3f3cd89692f3c0bd137f3f560ada359bfa

#### netgear-srs60

NETGEAR Orbi Pro SRS60 · ipq40xx-generic · K0+

- **Weg ab Werk:** Gluon-factory (`.img`) läuft nur auf Boot-Partition 1, die Netgear-UI schreibt immer in die andere: entweder nmrpflash beim Einschalten, oder Telnet über debug.htm einschalten, `artmtd -w boot_part 02`, Neustart, dann Web-UI [geprüft]
- **Übertragung:** herstellertool (NMRP mit nmrpflash, Rechner notfalls 10.164.183.253); oder telnet 192.168.1.250 + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** nmrpflash
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_srs60-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-netgear_srs60-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt 2cb24b3f3cd89692f3c0bd137f3f560ada359bfa
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2cb24b3f3cd89692f3c0bd137f3f560ada359bfa

#### netgear-wax206

NETGEAR WAX206 · mediatek-mt7622 · K0

- **Weg ab Werk:** Gluon-factory (`.img`) über die Stock-Web-UI, oder per NMRP/TFTP an den Bootloader ohne Öffnen [geprüft]
- **Übertragung:** webui-upload; alternativ herstellertool (NMRP, z. B. nmrpflash)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-netgear_wax206-initramfs-recovery.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-netgear_wax206-squashfs-factory.img)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig (factory)
- **Quelle (OpenWrt-Commit):** OpenWrt f6d2a23cbca61611663efb531c97efeded26e0cd
- **Detail-Anleitung:** https://openwrt.org/toh/netgear/wax206#oem_easy_installation

#### netgear-ex3700

NETGEAR EX3700/EX3800 (Alias netgear-ex3800) · ramips-mt7620 · K0

- **Weg ab Werk:** factory.chk im Stock-Web-UI oder per nmrpflash [geprüft]
- **Übertragung:** webui-upload; alternativ herstellertool nmrpflash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-netgear_ex3700-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** de33a4cef0411f13df397ada2dc3634c5748a457
- **Detail-Anleitung:** https://freifunk-ingolstadt.de/installationsanleitung-für-netgear-wi-fi-range-extender-ex3700/

#### netgear-ex6130

NETGEAR EX6130 · ramips-mt7620 · K0

- **Weg ab Werk:** factory.chk im Stock-Web-UI oder per nmrpflash [geprüft]
- **Übertragung:** webui-upload; alternativ herstellertool nmrpflash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-netgear_ex6130-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 0cbd2c74d0c9f41d07757907226e5cfeaf16e06a

#### netgear-eax12

NETGEAR EAX12 (Aliase EAX11 v2, EAX15 v2) · ramips-mt7621 · K0

- **Weg ab Werk:** factory.img im Stock-Web-UI oder per TFTP/NMRP an den Bootloader [geprüft]
- **Übertragung:** webui-upload; herstellertool nmrpflash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_eax12-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 32ea8a9a7e4b1319607ae398e9bf7d8e3c4cd756

#### netgear-ex6150

NETGEAR EX6150 (v1) · ramips-mt7621 · K0

- **Weg ab Werk:** factory.chk im Stock-Web-UI (192.168.1.250) oder per nmrpflash [geprüft]
- **Übertragung:** webui-upload; herstellertool nmrpflash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_ex6150-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 3f019bf96cdf52668750f67cb139fa1b5c538f0b
- **Detail-Anleitung:** https://freifunk-ingolstadt.de/eigener-freifunk-hotspot/anleitung/installationsanleitung-für-netgear-wi-fi-range-extender-ex6150-v2/

#### netgear-r6220

NETGEAR R6220 · ramips-mt7621 · K0

- **Weg ab Werk:** factory.img im Stock-Web-UI [abgeleitet: ToH "GUI OEM"; Commit beschreibt Telnet-Debug + USB + mtd_write, damals ohne factory]
- **Übertragung:** webui-upload; herstellertool nmrpflash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_r6220-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 38bee61dab029a7608088f64da71c19cfc8cf267
- **Detail-Anleitung:** https://freifunk-ingolstadt.de/installationsanleitung-für-netgear-r6220/

#### netgear-r6260

NETGEAR R6260 · ramips-mt7621 · K0

- **Weg ab Werk:** factory.img im Stock-Web-UI [abgeleitet: ToH "GUI OEM"; Commit ohne Text]
- **Übertragung:** webui-upload; herstellertool nmrpflash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_r6260-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 6cea9688af4a05f407266ed1de5a739e5c984b8c (ohne Installationstext)

#### netgear-wax202

NETGEAR WAX202 · ramips-mt7621 · K0

- **Weg ab Werk:** factory.img (verschlüsselt) im Stock-Web-UI oder per TFTP/NMRP [geprüft]
- **Übertragung:** webui-upload; herstellertool nmrpflash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_wax202-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 0f068e7c4a83bcbf20c4e52a5f8a3f1fe2af2246
- **Detail-Anleitung:** https://openwrt.org/toh/netgear/wax202#oem_easy_installation

#### netgear-wndr3700-v5

NETGEAR WNDR3700 v5 (Gluon: broken, "untested") · ramips-mt7621 · K0+

- **Weg ab Werk:** OpenWrt-factory.img per nmrpflash, danach Gluon-sysupgrade [geprüft]
- **Übertragung:** herstellertool: nmrpflash (NETGEAR-NMRP, TFTP)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** nmrpflash
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_wndr3700-v5-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_wndr3700-v5-squashfs-factory.img) (200)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig: OpenWrt baut ein factory.img (Sercomm), Gluon setzt trotzdem `factory = false`; mit factory wäre es K0
- **Quelle (OpenWrt-Commit):** cb049e71cdc08e17f664403a0ef970c480ae5c4a + 2fdd02cc7c3516c2cce2ace2c7b539e0821ecbe8 (factory-Image)

#### netgear-r6020

NETGEAR R6020 · ramips-mt76x8 · K0

- **Weg ab Werk:** factory.img nur per nmrpflash (LAN1, Gerät aus, nmrpflash starten, einschalten); Web-UI nicht [geprüft]
- **Übertragung:** herstellertool: nmrpflash (NETGEAR-NMRP, TFTP)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** nmrpflash
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-netgear_r6020-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** edbc8e5512dccc2e0b6925258e34b3f21d66679c

#### netgear-r6120

NETGEAR R6120 · ramips-mt76x8 · K0

- **Weg ab Werk:** factory.img per nmrpflash; Web-UI laut Commit nicht [geprüft]
- **Übertragung:** herstellertool: nmrpflash
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** nmrpflash
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-netgear_r6120-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 5543d63fc84e64be83afaa4241369a07797f041b
- **Detail-Anleitung:** https://freifunk-ingolstadt.de/eigener-freifunk-hotspot/anleitung/installationsanleitung-für-netgear-r6120/

### Familie `ocedo-tftp`

3 Gerät(e).

#### ocedo-koala

Ocedo Koala · ath79-generic · K1

- **Weg ab Werk:** Reset beim Einschalten halten: der Bootloader lädt per TFTP ein initramfs und startet es; danach sysupgrade und `fw_setenv bootcmd run bootcmd_1` (Flip-Flop-Bootloader) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.100.8, Datei koala-uImage-initramfs-lzma.bin (je nach Stock auch koala-uimage-factory)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** keins (Hersteller-TFTP-Boot)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ocedo_koala-initramfs-kernel.bin) (HEAD 200)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** ja: RAMpe-initramfs unter diesem Namen bereitstellen; die Gluon-RAMpe muss zusätzlich `fw_setenv bootcmd run bootcmd_1` setzen (OpenWrt-platform.sh tut es nicht) [geprüft im Baum]
- **Quelle (OpenWrt-Commit):** c4931713df8ffb3c4e5c1be7d0b6d4aa96a7dd4c [geprüft]

#### ocedo-raccoon

Ocedo Raccoon · ath79-generic · K1

- **Weg ab Werk:** Reset beim Einschalten halten: der Bootloader lädt per TFTP ein initramfs und startet es; danach sysupgrade und `fw_setenv bootcmd run bootcmd_1` (Flip-Flop-Bootloader) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.100.8, Datei raccoon-uImage-initramfs-lzma.bin (je nach Stock auch raccoon-uimage-factory)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** keins (Hersteller-TFTP-Boot)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ocedo_raccoon-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** ja: RAMpe-initramfs unter diesem Namen bereitstellen; die Gluon-RAMpe muss zusätzlich `fw_setenv bootcmd run bootcmd_1` setzen (OpenWrt-platform.sh tut es nicht) [geprüft im Baum]
- **Quelle (OpenWrt-Commit):** 647614803473757e3b2d93d46938afccd61a5a5d [geprüft]

#### ocedo-panda

OCEDO Panda · mpc85xx-p1020 · K1

- **Weg ab Werk:** Reset beim Einschalten: der Bootloader holt initramfs und DTB per TFTP und bootet im RAM; dann per SSH Werks-UBI-Volumes löschen (ubirmvol), bootcmd per fw_setenv setzen, sysupgrade -n [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.100.8, Dateien panda-uimage-factory (initramfs) + panda.fdt
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1020/openwrt-24.10.8-mpc85xx-p1020-ocedo_panda-initramfs-kernel.bin) (200) + [squashfs-fdt.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1020/openwrt-24.10.8-mpc85xx-p1020-ocedo_panda-squashfs-fdt.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 1 GB
- **Gluon-RAMpe passt:** teilweise: Ramboot passt; ubirmvol und fw_setenv vor dem sysupgrade macht die Gluon-RAMpe nicht
- **Quelle (OpenWrt-Commit):** b368373fab45f31963cd2bc1c6ab90e0a577e611

### Familie `recovery-web`

8 Gerät(e).

#### alfa-network-ap121f

ALFA Network AP121F · ath79-generic · K1d

- **Weg ab Werk:** U-Boot-Web-Recovery: Reset beim Einschalten halten, nach dem ersten Blinken weitere drei Blinks, dann sysupgrade unter http://192.168.1.1 hochladen [geprüft, ar71xx-Commit]
- **Übertragung:** recovery-web: Gerät 192.168.1.1, PC 192.168.1.2/24, Datei = sysupgrade
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** U-Boot-Web nimmt sysupgrade direkt
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-alfa-network_ap121f-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [ar71xx-Commit 0c6165d2]
- **Gluon-RAMpe passt:** nein: Bootloader nimmt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 334bbc51987c6694e130af25876f178babf37140 (ath79, ohne Anleitung); 0c6165d21ad274261bf8176828e122964e25c215 (ar71xx, Anleitung) [geprüft]

#### joy-it-jt-or750i

Joy-IT JT-OR750i · ath79-generic · K1d

- **Weg ab Werk:** Ab Werk nur Bootloader: dessen Weboberfläche (DHCP) nimmt das sysupgrade; alternativ TFTP-Recovery [geprüft]
- **Übertragung:** recovery-web: Gerät 10.123.123.1 (DHCP); alternativ tftp-client-am-geraet: Server 192.168.0.66, Datei jt-or750i_firmware.bin, Reset 4 s
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Bootloader-Web nimmt sysupgrade
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-joyit_jt-or750i-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** 55b4b3655263984b92e4b9fc515a5e6b8003c655 [geprüft]
- **Detail-Anleitung:** https://wiki.freifunk-stuttgart.net/technik:hardware:joy-it_jt-or750i

#### onion-omega

Onion Omega · ath79-generic · K0

- **Weg ab Werk:** Stock (OpenWrt) per sysupgrade oder factory über die U-Boot-Weboberfläche [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.1.1, PC 192.168.1.2/24; oder ssh (root/onioneer)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (Gluon-Kommentar: Einrichtung auch über "integrated (USB-)tty"; USB, Art ?)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-onion_omega-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-onion_omega-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** d98738b5c118fc45068b45f07b8b6938e91f35d2 (Einführung, Anleitung) [geprüft]

#### teltonika-rut230-v1

Teltonika RUT230 v1 · ath79-generic · K0+

- **Weg ab Werk:** Bootloader-Recovery-Web: Reset beim Einstecken halten bis die Signal-LEDs 3x blinken, factory unter http://192.168.1.1 hochladen [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.1.1, PC 192.168.1.10/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-teltonika_rut230-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-teltonika_rut230-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 6cf1dfd7e1d6b5c6a94b87eb065408bb489574c0 [geprüft]

#### wavlink-ws-wn572hp3-4g

Wavlink WS-WN572HP3 4G · ramips-mt7621 · K1d

- **Weg ab Werk:** Reset beim Einschalten 10 s halten, Recovery-Webseite nimmt das sysupgrade (Chromium; Firefox 106 nicht) [geprüft]
- **Übertragung:** recovery-web: Gerät 192.168.10.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-wavlink_ws-wn572hp3-4g-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt
- **Quelle (OpenWrt-Commit):** dce66899bf243d78689afcc693340b891bbf4c2d
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6cd1035d8dc001561331ca9e613d7dfc7d0fd7a6

#### zbtlink-zbt-wg3526-16m

ZBT WG3526 16M · ramips-mt7621 · K1d

- **Weg ab Werk:** Stock ist ein angepasstes OpenWrt; Recovery-Modus des Bootloaders mit (chinesischer) Upload-Seite nimmt das Image, wie beim WG2626 [abgeleitet: Wiki toh:zbtlink:zbt_wg3526]
- **Übertragung:** recovery-web (Adresse ?)
- **seriell nötig:** nein [abgeleitet]
- **Gehäuse öffnen:** nein [abgeleitet]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-zbtlink_zbt-wg3526-16m-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt [abgeleitet]
- **Stock-Teile:** -
- **RAM:** 512 MB (ToH)
- **Gluon-RAMpe passt:** nein, unnötig [abgeleitet]
- **Quelle (OpenWrt-Commit):** 30fbc1a4d146ae0060d02946709fd6d8cc2a2b56 (ohne Installationstext)

#### zbtlink-zbt-wg3526-32m

ZBT WG3526 32M · ramips-mt7621 · K1d

- **Weg ab Werk:** Stock ist ein angepasstes OpenWrt; Recovery-Modus des Bootloaders mit (chinesischer) Upload-Seite nimmt das Image, wie beim WG2626 [abgeleitet: Wiki toh:zbtlink:zbt_wg3526]
- **Übertragung:** recovery-web (Adresse ?)
- **seriell nötig:** nein [abgeleitet]
- **Gehäuse öffnen:** nein [abgeleitet]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-zbtlink_zbt-wg3526-32m-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt [abgeleitet]
- **Stock-Teile:** -
- **RAM:** 512 MB (ToH)
- **Gluon-RAMpe passt:** nein, unnötig [abgeleitet]
- **Quelle (OpenWrt-Commit):** 619d68bfc90e548e3398b26a2a0ca3fccd7d3f38 (ohne Installationstext)

#### ravpower-rp-wd009

RAVPower RP-WD009 · ramips-mt76x8 · K0

- **Weg ab Werk:** Reset beim Einschalten 10 s bis die Globus-LED leuchtet, Recovery-Seite 10.10.10.128, factory hochladen [geprüft]
- **Übertragung:** recovery-web: Gerät 10.10.10.128, Rechner 10.10.10.1/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-ravpower_rp-wd009-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** e959048c128e4350b78df653be7cd7277787518e
- **Detail-Anleitung:** https://openwrt.org/toh/ravpower/rp-wd009#oem_installation_using_the_tftp_method

### Familie `seriell-tftp`

22 Gerät(e).

#### d-link-dir-505

D-Link DIR-505 · ath79-generic · K4

- **Weg ab Werk:** laut Commit nur per U-Boot-TFTP, modifiziertem U-Boot oder sysupgrade aus älterem OpenWrt; ath79 baut kein factory (ar71xx hatte eins mit HORNET-Kennung) [geprüft]
- **Übertragung:** tftp-client am U-Boot (seriell); IPs/Dateiname im Commit nicht genannt
- **seriell nötig:** ja
- **Gehäuse öffnen:** ? (UART-Lage im Commit nicht genannt)
- **Werkzeug/Spezial:** serielle Konsole
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dir-505-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** teilweise: RAMpe-initramfs per tftpboot statt OpenWrt-initramfs; seriell bleibt [abgeleitet]
- **Quelle (OpenWrt-Commit):** c9ac7b17296ff29d9df39db8a68c449ef1514bbd [geprüft]

#### enterasys-ws-ap3705i

Enterasys WS-AP3705i · ath79-generic · K4

- **Weg ab Werk:** Serielle Konsole, U-Boot (Passwort admin/new2day) umstellen und OpenWrt-initramfs per TFTP laden, dann sysupgrade [geprüft]
- **Übertragung:** tftp-client am U-Boot: Server 192.168.1.66/24, Datei 1401A8C0.img
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: Cisco-RJ45 auf der Rückseite, 115200 8N1
- **Werkzeug/Spezial:** serielle Konsole (Cisco-Konsolenkabel)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-enterasys_ws-ap3705i-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe als 1401A8C0.img statt OpenWrt-initramfs, Upload-Seite statt scp; seriell bleibt
- **Quelle (OpenWrt-Commit):** ebddc5f984a240980303aed68524eb615484eef8 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=ebddc5f984a240980303aed68524eb615484eef8

#### extreme-networks-ws-ap3805i

Extreme Networks WS-AP3805i · ath79-generic · K4

- **Weg ab Werk:** UART (J10), U-Boot (admin/new2day) umstellen, OpenWrt-initramfs per TFTP laden, dann sysupgrade [geprüft]
- **Übertragung:** tftp-client am U-Boot: Server 192.168.1.66/24, Datei 1D01A8C0.img
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (UART-Pins J10 auf der Platine, 3.3 V, 115200 8N1)
- **Werkzeug/Spezial:** serielle Konsole
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-extreme-networks_ws-ap3805i-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 256 MB [Commit]
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe als 1D01A8C0.img statt OpenWrt-initramfs; seriell bleibt
- **Quelle (OpenWrt-Commit):** f8c87aa2d27ab405f284dd4357377ab5c893a345 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=f8c87aa2d27ab405f284dd4357377ab5c893a345

#### siemens-ws-ap3610

Siemens WS-AP3610 · ath79-generic · K4

- **Weg ab Werk:** Serielle Konsole (RJ45), U-Boot-Umgebung setzen, OpenWrt-initramfs per TFTP laden, dann sysupgrade [geprüft]
- **Übertragung:** tftp-client am U-Boot: Server 192.168.1.66/24, Datei 1401A8C0.img
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: Cisco-RJ45, 115200 8N1
- **Werkzeug/Spezial:** serielle Konsole (Cisco-Konsolenkabel)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-siemens_ws-ap3610-initramfs-kernel.bin) (HEAD 200)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit: 2x 64M DDR1]
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe als 1401A8C0.img; Achtung, das initramfs ist hier unkomprimiert (KERNEL_INITRAMFS ... uImage none, OpenWrt 23.7 MB); seriell bleibt
- **Quelle (OpenWrt-Commit):** d2b8ccb1c04def81224da6f42f644c7d239b9986 [geprüft]
- **Detail-Anleitung:** https://github.com/freifunk-darmstadt/projects/wiki/90-%E2%80%90-Hardware-%E2%80%90-Siemens-AP3610

#### sophos-ap15

Sophos AP15 (broken) · ath79-generic · K4

- **Weg ab Werk:** Gehäuse öffnen, UART, im U-Boot OpenWrt-initramfs per TFTP booten, dann sysupgrade im Web-UI [geprüft]; XG-Weg der AP55/AP100 "sollte auch gehen" [ungeprüft im Commit]
- **Übertragung:** tftp-client am U-Boot: Server 192.168.99.8/24, Datei frei (Beispiel boot.bin)
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (UART-Header auf der Platine, 115200 8N1)
- **Werkzeug/Spezial:** serielle Konsole
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-sophos_ap15-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe statt OpenWrt-initramfs; seriell bleibt
- **Quelle (OpenWrt-Commit):** 0dc58214896aacf67a3759495d70e2b4e9c160d8 (Einführung, Anleitung); fc31261c3307458e38c9a676211a25c99c044ece (DTS-Umbenennung) [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=0dc58214896aacf67a3759495d70e2b4e9c160d8

#### tp-link-archer-d50-v1

TP-Link Archer D50 v1 (broken) · ath79-generic · K4

- **Weg ab Werk:** UART (J2), im U-Boot das sysupgrade per TFTP laden und nach 0x9f020000 schreiben; oder initramfs booten [geprüft]
- **Übertragung:** tftp-client am U-Boot: IPs selbst setzen (im Commit nicht vorgegeben)
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (UART-Header J2 der Qualcomm-CPU)
- **Werkzeug/Spezial:** serielle Konsole
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-d50-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** für die Installation keine; Rückweg: OEM-Datei per `dd skip=257 bs=512 count=15616` zuschneiden (Hersteller-Download TP-Link)
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** teilweise: RAMpe-initramfs per tftpboot; seriell bleibt
- **Quelle (OpenWrt-Commit):** f5d2c91415a68f554815860d574145644fc31c16 [geprüft]

#### aerohive-hiveap-121

Aerohive HiveAP 121 · ath79-nand · K4

- **Weg ab Werk:** UART (9600 Baud), U-Boot ggf. mit Passwort (administrator oder AhNf?d@ta06), factory per TFTP laden und mit `nand write` schreiben [geprüft]
- **Übertragung:** tftp-client am U-Boot: Adresse per `dhcp`, serverip selbst setzen
- **seriell nötig:** ja
- **Gehäuse öffnen:** ? (Anschluss im Commit nicht genannt)
- **Werkzeug/Spezial:** serielle Konsole, 9600 Baud
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-aerohive_hiveap-121-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-aerohive_hiveap-121-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** teilweise: statt factory per nand write könnte man die Gluon-RAMpe per tftpboot starten; seriell bleibt [abgeleitet]
- **Quelle (OpenWrt-Commit):** 62db255543c8fb5d1787caf36c6c7c9c51db71cd [geprüft]

#### zte-mf281

ZTE MF281 (broken) · ath79-nand · K4

- **Weg ab Werk:** UART, U-Boot unterbrechen, OpenWrt-initramfs per TFTP booten, dann factory per `mtd write ... firmware` [geprüft]
- **Übertragung:** tftp-client am U-Boot: Server 192.168.1.66, Gerät 192.168.1.154, Datei speedbox-2.bin
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (unbestückter Stecker neben dem SIM-Slot; 3V3 nicht anschließen)
- **Werkzeug/Spezial:** serielle Konsole
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-zte_mf281-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-zte_mf281-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe statt OpenWrt-initramfs; die Gluon-RAMpe müsste aber das factory (nicht sysupgrade) per mtd schreiben [abgeleitet]
- **Quelle (OpenWrt-Commit):** 1e1695f959e678868bb7911d059b847f38fc9cf4 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=1e1695f959e678868bb7911d059b847f38fc9cf4

#### extreme-networks-ws-ap3915i

Extreme Networks WS-AP3915i · ipq40xx-generic · K4

- **Weg ab Werk:** Konsole, Autoboot mit "s" abbrechen, Login admin/new2day, ramboot/boot_openwrt/bootcmd setzen, initramfs per TFTP, `sysupgrade -n` [geprüft]
- **Übertragung:** tftp-client: Server 192.168.1.66, Gerät 192.168.1.1, Datei openwrt-3915.bin
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: RJ45 (Cisco-Konsolenkabel), 115200 8N1 [geprüft]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-extreme-networks_ws-ap3915i-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe als openwrt-3915.bin, seriell bleibt; Gluon baut für ipq40xx-generic kein initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt e16a0e7e8876df0a92ec4779fe766de1a943307a
- **Detail-Anleitung:** -

#### zte-mf289f

ZTE MF289F · ipq40xx-generic · K4

- **Weg ab Werk:** Gehäuse öffnen, UART, U-Boot (ESC), initramfs per TFTP, Backup mtd16/mtd17, `ubirmvol` ubi_rootfs(_data), `sysupgrade -n` [geprüft]
- **Übertragung:** tftp-client: Server 192.168.0.2, Gerät 192.168.0.1, Datei openwrt-ipq40xx-generic-zte_mf289f-initramfs-fit-zImage.itb (24.10: …-initramfs-zImage.itb)
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (Pins neben "MF289F MIMO-V1.0", 115200 8N1)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-zImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-zte_mf289f-initramfs-zImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** - (Backup mtd16 web, mtd17 rootfs für den Rückweg)
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe als TFTP-initramfs möglich, aber der `ubirmvol`-Schritt fehlt ihm; seriell bleibt [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 0de6a3339f1aadc1de2c9371435e3de239a00645 (Gluon: broken)
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=0de6a3339f1aadc1de2c9371435e3de239a00645

#### extreme-networks-ap3935

Extreme Networks AP3935i/e · ipq806x-generic · K4

- **Weg ab Werk:** Konsole, Autoboot abbrechen, Login admin/new2day, serverip/ipaddr setzen, bootcmd "ping …; run boot_flash", initramfs per TFTP nach 0x42000000, bootm, sysupgrade nand-sysupgrade [geprüft]
- **Übertragung:** tftp-client: Server 192.168.1.2, Gerät 192.168.1.101, Datei openwrt-ipq806x-generic-extreme_ap3935-initramfs-uImage (Port LAN1)
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: RJ45 (Cisco-Kabel) oder interne 4-Pin-Leiste, 115200 8N1 [geprüft]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage](https://downloads.openwrt.org/releases/24.10.8/targets/ipq806x/generic/openwrt-24.10.8-ipq806x-generic-extreme_ap3935-initramfs-uImage)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-nand-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq806x/generic/openwrt-24.10.8-ipq806x-generic-extreme_ap3935-squashfs-nand-factory.bin)
- **Stock-Teile:** -
- **RAM:** ?
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe als TFTP-initramfs, seriell bleibt; Gluon baut für ipq806x kein initramfs; QCA9990 ohne 802.11s [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 3aef61060e3f51aa43fe494d5ff173e81dd43003
- **Detail-Anleitung:** -

#### tp-link-td-w8980

TP-Link TD-W8980 (Alias TD-W9980; Gluon: broken, 5 GHz) · lantiq-xrx200_legacy · K4

- **Weg ab Werk:** Seriell: `t` beim Booten, TFTP, `sf erase 0x20000 0x7a0000`, sysupgrade schreiben; Web-UI nur bei Stock vor 12.10.2013; Shell-Injection wie TD-W9980 [abgeleitet: Wiki]
- **Übertragung:** tftp-client-am-geraet (IPs per setenv frei)
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (UART auf der Platine)
- **Werkzeug/Spezial:** USB-TTL-Adapter, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200_legacy/openwrt-24.10.8-lantiq-xrx200_legacy-tplink_tdw8980-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein
- **Quelle (OpenWrt-Commit):** 161179f40bd7899516518f3844fea28c6dd86efc (ohne Installationstext)

#### cudy-tr3000-v1

Cudy TR3000 v1 (128 MB Flash) · mediatek-filogic · K4

- **Weg ab Werk:** UART + TFTP-initramfs (Reset beim Einschalten 5 s halten, U-Boot-Shell), dann sysupgrade [geprüft]; eine Cudy-Zwischenfirmware fehlt im Spiegel und bei Cudy (Stand cudy-installation.md 08.10.2026), sonst wäre es K2
- **Übertragung:** tftp-client: Server 192.168.1.88/24, Gerät 192.168.1.1, Datei per `setenv bootfile`
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (interne Testpunkte)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-cudy_tr3000-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe ersetzt das OpenWrt-initramfs im TFTP-Schritt, der serielle Teil bleibt
- **Quelle (OpenWrt-Commit):** OpenWrt 63b8d98dd0d2f7797ea5b5f25978590982bbbb5d
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/installation-cudy-tr3000/1010

#### mercusys-mr80x-v3

Mercusys MR80X v3 · mediatek-filogic · K4

- **Weg ab Werk:** UART: Boot mit Ctrl-C abbrechen, `setenv tp_boot_idx 0; setenv bootcmd bootm 0x46000000; saveenv` (bootarg ggf. von ubi1 auf ubi0), initramfs per TFTP laden und booten, dann `sysupgrade -n` [geprüft: Commit]; ob der SSH-/Telnet-Weg des MR90X auch hier geht, ist nicht belegt
- **Übertragung:** tftp-client-am-geraet: Server 192.168.1.2, Gerät 192.168.1.1, Datei initramfs-kernel.bin (Name im Commit)
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (UART auf der Platine) [abgeleitet]
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-mercusys_mr80x-v3-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** - (U-Boot-Recovery mit Reset, http://192.168.1.1, nimmt laut Commit nur OEM-Firmware)
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe statt OpenWrt-initramfs im TFTP-Schritt, seriell bleibt; Rezept `devices/mercusys-mr80x-v3.sh`. In Neanderfunk-2025.1 seit gluon-patches-hardware ab19bf1b46d34315a92f61974dd37f8a9ede9604 (10.10.2026), in Gluon v2025.1.3 nicht
- **Quelle (OpenWrt-Commit):** OpenWrt 0ecf136f4d3126d92edc13087ce03db83b7e8223

#### enterasys-ws-ap3715i

Enterasys WS-AP3715i · mpc85xx-p1010 · K4

- **Weg ab Werk:** Seriell, U-Boot anhalten (admin/new2day), ramboot_openwrt/boot_openwrt/bootcmd setzen + saveenv, initramfs per TFTP booten, dann sysupgrade -n per scp [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.1.66, Gerät 192.168.1.1, Datei ap3715.bin
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: RJ45, Cisco-Konsolenkabel, 115200 8N1
- **Werkzeug/Spezial:** Konsolenkabel, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1010/openwrt-24.10.8-mpc85xx-p1010-enterasys_ws-ap3715i-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: nach dem seriellen TFTP-Boot macht die Gluon-RAMpe den sysupgrade-Schritt statt scp; bootcmd/saveenv bleibt seriell
- **Quelle (OpenWrt-Commit):** 765f66810a3324cc35fa6471ee8eeee335ba8c2b
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=765f66810a3324cc35fa6471ee8eeee335ba8c2b

#### sophos-red-15w-rev.1

Sophos RED 15w Rev. 1 · mpc85xx-p1010 · K4

- **Weg ab Werk:** Am "Console port" U-Boot anhalten, bootargs_owrt/bootcmd setzen + saveenv, initramfs per TFTP booten, `ubiformat /dev/mtd4 -y`, sysupgrade -n per scp [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.1.2, Datei kernel.bin
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen ("Console port", Bauform im Commit nicht genannt: ?)
- **Werkzeug/Spezial:** Konsolenkabel, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1010/openwrt-24.10.8-mpc85xx-p1010-sophos_red-15w-rev1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** teilweise: ubiformat vor dem sysupgrade macht die Gluon-RAMpe nicht
- **Quelle (OpenWrt-Commit):** 97e4311fca73d064d17065e7844699aa777cb157

#### aerohive-hiveap-330

Aerohive HiveAP 330 · mpc85xx-p1020 · K4

- **Weg ab Werk:** Seriell (9600 8N1), U-Boot-Passwort `AhNf?d@ta06` oder `administrator`, `dhcp`, initramfs (Commit 2017: dazu .fdt) per TFTP laden und booten, dann sysupgrade per scp [geprüft: Commit; Konsole: Wiki]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.1.101 (Commit), Dateiname frei
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: RJ45 "console", Cisco-Konsolenkabel, RS232-Pegel (kein TTL-Adapter!), 9600 8N1
- **Werkzeug/Spezial:** RS232-Konsolenkabel, TFTP/DHCP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1020/openwrt-24.10.8-mpc85xx-p1020-aerohive_hiveap-330-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe statt scp+sysupgrade; der serielle Teil bleibt
- **Quelle (OpenWrt-Commit):** f2b7d9dc1ca3d33f14961cf2885639f4f9e8965e

#### enterasys-ws-ap3710i

Enterasys WS-AP3710i · mpc85xx-p1020 · K4

- **Weg ab Werk:** Seriell, U-Boot anhalten (admin/new2day), boot_openwrt/bootcmd setzen + saveenv, initramfs per TFTP booten, dann sysupgrade -n per scp [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.200.200, Datei 01C8A8C0.img
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: RJ45, Cisco-Konsolenkabel, 115200 8N1
- **Werkzeug/Spezial:** Konsolenkabel, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1020/openwrt-24.10.8-mpc85xx-p1020-enterasys_ws-ap3710i-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: wie WS-AP3715i
- **Quelle (OpenWrt-Commit):** 16b01fb1b9c99513c318109bef96a1a3545c57a0
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=16b01fb1b9c99513c318109bef96a1a3545c57a0

#### extreme-networks-ws-ap3825i

Extreme Networks WS-AP3825i · mpc85xx-p1020 · K4

- **Weg ab Werk:** Seriell, Autoboot anhalten (admin/new2day), boot_openwrt/bootcmd setzen + saveenv, ipaddr/serverip setzen, initramfs per tftpboot laden und `bootm` von Hand in Einzelschritten (fdt-Relocation umgehen), dann sysupgrade per scp. Nach dem Flashen bis 600 s ohne Ping (Neanderfunk-Notiz recovery-wege.md) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server frei (setenv serverip) oder DHCP+TFTP (dnsmasq)
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: RJ45 Cisco-kompatibel, RS232 (Wiki: "RJ45-RS232"), 115200 8N1
- **Werkzeug/Spezial:** Konsolenkabel, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1020/openwrt-24.10.8-mpc85xx-p1020-extreme-networks_ws-ap3825i-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: wie WS-AP3715i
- **Quelle (OpenWrt-Commit):** 7e614820a89208c4e91a3a5f9de07a5402accdaa
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/flashing-of-the-extreme-networks-ws-ap3825i/923

#### tp-link-eap620-hd-v1

TP-Link EAP620 HD v1 · qualcommax-ipq807x · K4

- **Weg ab Werk:** UART (JP1 bestücken, R58 und R62 brücken), U-Boot mit Ctrl+B anhalten, initramfs per TFTP nach 0x44000000, bootm, `sysupgrade -n` [geprüft]; ohne UART: SSH in Stock, `cliclientd stopcs`, OpenWrt-25.12-`web-ui-factory.bin` in der Stock-UI, danach Gluon-sysupgrade [abgeleitet: OpenWrt 8a15a75e9414bbb839ac457701b041454e89bbc4]
- **Übertragung:** tftp-client: serverip/ipaddr frei, Datei openwrt-qualcommax-ipq807x-tplink_eap620hd-v1-initramfs-uImage.itb; ohne UART: ssh + webui-upload (Dateiname unter 63 Zeichen)
- **seriell nötig:** ja (Weg mit OpenWrt 24.10; mit OpenWrt 25.12 als Zwischenschritt: nein)
- **Gehäuse öffnen:** ja (JP1 löten, R58/R62 brücken; mit OpenWrt 25.12 als Zwischenschritt: nein)
- **Werkzeug/Spezial:** OpenWrt 25.12 als Zwischenschritt
- **initramfs-Link:** [25.12.5: initramfs-uImage.itb](https://downloads.openwrt.org/releases/25.12.5/targets/qualcommax/ipq807x/openwrt-25.12.5-qualcommax-ipq807x-tplink_eap620hd-v1-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [25.12.5: squashfs-web-ui-factory.bin](https://downloads.openwrt.org/releases/25.12.5/targets/qualcommax/ipq807x/openwrt-25.12.5-qualcommax-ipq807x-tplink_eap620hd-v1-squashfs-web-ui-factory.bin)
- **Stock-Teile:** -
- **RAM:** 1 GB
- **Gluon-RAMpe passt:** teilweise: web-ui-factory ist ein squashfs-Flash-Image (tplink-image-2022, in 24.10 nicht vorhanden), kein initramfs; Gluon-RAMpe bräuchte dieses Format [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 4b6e7da0f7499acb69feaacca79e0ee826c0b8db; gluon-patches-hardware 9263f242b86a943e62671ec445f08dd9eb2dfbd2 [Backport]
- **Detail-Anleitung:** -

#### xiaomi-mi-ra75

Xiaomi Mi WiFi Range Extender AC1200 RA75 (Gluon: broken, "Only serial flash possible") · ramips-mt76x8 · K4

- **Weg ab Werk:** Kein Web-UI; seriell im U-Boot-Menü Option 2, sysupgrade per TFTP [geprüft]
- **Übertragung:** tftp-client-am-geraet (IPs im Menü)
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (UART-Header unbestückt, beschriftet)
- **Werkzeug/Spezial:** USB-TTL-Adapter, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-xiaomi_mi-ra75-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein
- **Quelle (OpenWrt-Commit):** f204c812e996d51f36972d5f4414ada3d4588c93

#### xiaomi-mi-router-4a-100m-edition

Xiaomi Mi Router 4A 100M · ramips-mt76x8 · K4

- **Weg ab Werk:** Seriell: im U-Boot-Menü Option 2 ("write to Flash via TFTP"), Gerät 192.168.1.1, Server 192.168.1.2, Datei test.bin = sysupgrade [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.1.2, Datei test.bin, LAN1
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (UART auf der Platine, beschriftet, 115200)
- **Werkzeug/Spezial:** USB-TTL-Adapter, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-xiaomi_mi-router-4a-100m-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein: Option 2 flasht das sysupgrade direkt; Option 1 (in SDRAM) könnte ein initramfs booten, 64 MB knapp, Nutzen gering [abgeleitet]
- **Quelle (OpenWrt-Commit):** 5ff5c9bce6b6e51060c272521528b5afd789e9ab
- **Detail-Anleitung:** https://openwrt.org/toh/xiaomi/mi_router_4a_mir4a_100m#installation

### Familie `sonderweg-arcadyan-vgv7510kw22`

1 Gerät(e).

#### arcadyan-vgv7510kw22

Arcadyan VGV7510KW22 / o2 Box 6431 (NOR-Image) · lantiq-xrx200 · K5

- **Weg ab Werk:** Bootloader ersetzen: brnboot-Recovery-Web (Reset beim Einschalten ~5 s, http://192.168.1.1) oder seriell U-Boot in den RAM, dann OpenWrt-U-Boot (u-boot-vgv7510kw22_nor/u-boot.bin) per TFTP in den NOR, dann sysupgrade per TFTP; das nor-Image setzt OpenWrt-U-Boot voraus [abgeleitet: Wiki; Commit ohne Text]
- **Übertragung:** recovery-web (brnboot, 192.168.1.1) + tftp-client-am-geraet
- **seriell nötig:** teilweise: kurzer Weg seriell, langer Weg ohne (brnboot-Web + 16-MB-Vollimage)
- **Gehäuse öffnen:** nein: Konsolen-Pins durch einen Lüftungsschlitz erreichbar (Wiki), 115200 8N1
- **Werkzeug/Spezial:** OpenWrt-U-Boot, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/openwrt-24.10.8-lantiq-xrx200-arcadyan_vgv7510kw22-nor-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [u-boot.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200/u-boot-vgv7510kw22_nor/u-boot.bin) (Verzeichnis 200)
- **Stock-Teile:** board_config des Geräts ins 16-MB-Vollimage (Wiki-Weg ohne seriell)
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein: Bootloader-Tausch nötig
- **Quelle (OpenWrt-Commit):** ca1db6b5ce5675d88b45b23f576e8c59f7f4fc48 (ohne Installationstext) + Wiki toh:arcadyan:vgv7510kw22
- **Detail-Anleitung:** https://forum.openwrt.org/t/installing-lede-u-boot-via-brnboot-web-interface-without-rs232/9857/6

### Familie `sonderweg-aruba-ap-32x`

1 Gerät(e).

#### aruba-ap-32x

Aruba AP-324/AP-325, Siemens Scalance W1750D · ipq806x-generic · K5

- **Weg ab Werk:** Stock-APBoot signiert-prüfend: gepatchtes APBoot (`apboot.mbn`) per `netget` laden, `sf erase/write 0x220000 0x100000`; NAND löschen, UBI `ubifs` (1 LEB) + `rootfs_data` anlegen; initramfs `.ari` per tftpboot; sysupgrade [geprüft]
- **Übertragung:** tftp-client (APBoot netget/tftpboot): Server per `setenv serverip` frei, Dateien openwrt-ipq806x-generic-aruba_ap-32x-apboot.mbn und …-initramfs.ari
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: RJ45 Cisco-Pinout, 9600 (Stock-APBoot) bzw. 115200 (gepatcht) [geprüft]
- **Werkzeug/Spezial:** gepatchtes APBoot (github lukasstockner/ap325-apboot-openwrt; OpenWrt-Paket apboot-aruba-ipq806x, bei uns nicht gebaut)
- **initramfs-Link:** [snapshot: initramfs.ari](https://downloads.openwrt.org/snapshots/targets/ipq806x/generic/openwrt-ipq806x-generic-aruba_ap-32x-initramfs.ari)
- **Factory-/Stock-Image-Link:** [snapshot: apboot.mbn](https://downloads.openwrt.org/snapshots/targets/ipq806x/generic/openwrt-ipq806x-generic-aruba_ap-32x-apboot.mbn)
- **Stock-Teile:** - (Bootloader aus OpenWrt-Paket; Backup aos0/aos1 für den Rückweg)
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe müsste das Aruba-`.ari`-Format (Vendor-Header) bekommen, Gluon baut für ipq806x kein initramfs; Bootloader-Tausch und UBI-Umbau bleiben seriell. OpenWrt-Artefakte nur als Snapshot (in keinem Release bis 25.12.5) [geprüft]
- **Quelle (OpenWrt-Commit):** OpenWrt d2a75029a5f8e54e1fd2f252f73b9a430a030116 (25.12: 65f01eb3576f69233e8b6c67d85ffd38fde47a1a); gluon-patches-hardware 9263f242b86a943e62671ec445f08dd9eb2dfbd2 [Backport]
- **Detail-Anleitung:** https://github.com/lukasstockner/ap325-apboot-openwrt

### Familie `sonderweg-aruba-instant-on-ap11`

1 Gerät(e).

#### aruba-instant-on-ap11

Aruba Instant On AP11 (Alias von aruba-ap-303) · ipq40xx-generic · K5

- **Weg ab Werk:** apboot-Environment gesperrt: entsperrtes apboot aus einem gepatchten SPI-Dump per dd schneiden (bs=983040 skip=1 count=1), per `netget` laden, `sf protect off; sf erase/write 0xf0000 0xf0000`, reset; danach wie AP-303 [geprüft: Neanderfunk-Notiz zum AP11, 2024]
- **Übertragung:** tftp-client (netget): Server 192.168.1.66, Gerät 192.168.1.6, Dateien apboot-unlocked.bin und ipq40xx.ari
- **seriell nötig:** ja
- **Gehäuse öffnen:** nein, Konsole außen: Micro-USB als UART-Stecker wie AP-303 [abgeleitet: Alias, gleiche Platine]
- **Werkzeug/Spezial:** gepatchter SPI-Dump eines Dritten (AP11-2023-spi-f061c0c4c850.patched-alex.bin, sha256 4ca6d503…)
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-303-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** apboot-Teil aus einem fremden, gepatchten Aruba-SPI-Dump (kein Hersteller-Download)
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: wie AP-303; der Bootloader-Schritt bleibt seriell
- **Quelle (OpenWrt-Commit):** Notiz ap11.md (2024); OpenWrt 102c8c55f217606cdbdc9a449667e034676b3e75
- **Detail-Anleitung:** -

### Familie `sonderweg-asus-lyra-map-ac2200`

1 Gerät(e).

#### asus-lyra-map-ac2200

ASUS Lyra MAP-AC2200 · ipq40xx-generic · K1

- **Weg ab Werk:** SSH in die Stock-Firmware (Zugang wie Web-UI), OpenWrt-initramfs nach /tmp, `mtd-write -d linux -i …`, Neustart, dann sysupgrade [geprüft]
- **Übertragung:** ssh/scp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-asus_map-ac2200-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** ja: statt des OpenWrt-initramfs das RAMpe-initramfs per mtd-write schreiben; SSH-Schritt bleibt; Gluon baut für ipq40xx-generic kein initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 9ad3967f140bd6d08796f1ec151b753186b3eb44
- **Detail-Anleitung:** https://openwrt.org/toh/asus/lyra_map-ac2200#oem_easy_installation

### Familie `sonderweg-asus-rt-ax52`

1 Gerät(e).

#### asus-rt-ax52

ASUS RT-AX52 · mediatek-filogic · K1

- **Weg ab Werk:** Stock-Web-UI (Administration > Firmware Upgrade) nimmt das OpenWrt-`initramfs.trx`, danach `sysupgrade -n` [geprüft]
- **Übertragung:** webui-upload: Gerät 192.168.50.1 (DHCP), Datei `…-initramfs.trx`; Rückweg/Notfall tftp-client: Server 192.168.1.70, Datei rtax52.bin (seriell)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs.trx](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-asus_rt-ax52-initramfs.trx)<br>[24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-asus_rt-ax52-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** ja: Hersteller-UI nimmt ein initramfs im ASUS-TRX; RAMpe-Rezept muss das ARTIFACT `initramfs.trx` einsammeln [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 99708cc16dbd7c93db80698fbe5c69f07995a3e6
- **Detail-Anleitung:** https://openwrt.org/toh/asus/rt-ax52#installation

### Familie `sonderweg-asus-rt-ax59u`

1 Gerät(e).

#### asus-rt-ax59u

ASUS RT-AX59U · mediatek-filogic · K2

- **Weg ab Werk:** Stock-Web-UI (192.168.50.1) mit einem Fremd-"transit TRX" von Google Drive oder UART + TFTP-initramfs [geprüft]
- **Übertragung:** webui-upload (Transit-TRX); sonst tftp-client: Server 192.168.1.70, Gerät 192.168.1.1, Datei rtax59u.bin
- **seriell nötig:** nein (nur für den seriellen TFTP-Weg: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen TFTP-Weg: ja, Pinout auf der Platine) [abgeleitet]
- **Werkzeug/Spezial:** Transit-TRX eines Dritten (Google-Drive-Ordner im Commit, Herkunft unklar)
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-asus_rt-ax59u-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: OpenWrt baut für die RT-AX59U kein `initramfs.trx` (24.10.8 und 25.12.5 nur initramfs-kernel.bin) [geprüft]; eine Gluon-RAMpe-TRX wie bei der RT-AX52 wäre zu bauen, ob die Stock-UI es nimmt: offen
- **Quelle (OpenWrt-Commit):** OpenWrt 782eb050082acac93c2f9b3eb22348234bc93e99; gluon-patches-hardware 8dbae18666543aa9b8b5e7faa1d267024d62071e (Gluon-Zeile)
- **Detail-Anleitung:** -

### Familie `sonderweg-buffalo-wzr-hp-g450h-wzr-450hp`

1 Gerät(e).

#### buffalo-wzr-hp-g450h-wzr-450hp

Buffalo WZR-HP-G450H/WZR-450HP · ath79-generic · K0+

- **Weg ab Werk:** factory über die versteckte Seite http://192.168.11.1/cgi-bin/cgi?req=frm&frm=py-db/firmup.html (bufpy/otdpopy) [geprüft]
- **Übertragung:** webui-upload (versteckte Firmware-Seite)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-buffalo_wzr-hp-g450h-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-buffalo_wzr-hp-g450h-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit 1df1ea4]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 1df1ea4d7e8b6ae3351780ed58800ccd9edd4c27 (Anleitung); 53c474abbdfef8eb3499e2d10c9ad491788b8a72 (erstes ath79-Target) [geprüft]

### Familie `sonderweg-comfast-cf-ew71-v2`

1 Gerät(e).

#### comfast-cf-ew71-v2

COMFAST CF-EW71 v2 · ath79-generic · K1d

- **Weg ab Werk:** Stock-Firmware ist OpenWrt-basiert und nimmt das sysupgrade; alternativ U-Boot-Recovery-Web (Reset ~5 s beim Einstecken) [geprüft]
- **Übertragung:** webui-upload (Stock) oder recovery-web: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Stock/U-Boot-Web nimmt sysupgrade direkt
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-comfast_cf-ew71-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** ee3a6adc6c22b2388eb3901bda335fd145c7355e [geprüft]

### Familie `sonderweg-d-link-dir825b1`

1 Gerät(e).

#### d-link-dir825b1

D-Link DIR-825 B1 · ath79-generic · offen

- **Weg ab Werk:** Weg ab Werk im ath79-Commit nicht beschrieben; factory-Rezept seit 4309be6bcb3d3cbf8fa5ae7eddb1520737542c6c abgeschaltet ("max image sizes too small", FACTORY_SIZE 6144k) [geprüft]; zu prüfen, ob die D-Link-Recovery ein initramfs annimmt (OpenWrt-initramfs 24.10.8: 6145 KB, also knapp über 6144k)
- **Übertragung:** ?
- **seriell nötig:** ?
- **Gehäuse öffnen:** ?
- **Werkzeug/Spezial:** ?
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-dlink_dir-825-b1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** offen: nur wenn die D-Link-Recovery ein initramfs nimmt; Größe ist der Engpass [abgeleitet]
- **Quelle (OpenWrt-Commit):** 97de133368762824ba3d7e9d95f97011a597ec1a (ohne Anleitung); 4309be6bcb3d3cbf8fa5ae7eddb1520737542c6c (factory entfernt) [geprüft]

### Familie `sonderweg-devolo-dlan-pro-1200+-wifi-ac`

1 Gerät(e).

#### devolo-dlan-pro-1200+-wifi-ac

devolo dLAN pro 1200+ WiFi ac (broken) · ath79-generic · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders: Reset beim Einschalten ~15 s halten, das Gerät holt sich das umbenannte sysupgrade [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.100, Datei `uploadfile` (= sysupgrade umbenannt)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Hersteller-TFTP-Recovery nimmt sysupgrade
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-devolo_dlan-pro-1200plus-ac-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Recovery nimmt das sysupgrade direkt (für das Gluon-sysupgrade [abgeleitet])
- **Quelle (OpenWrt-Commit):** 624b85e646328c5f4ff271e6cf0edc5923d40c67 [geprüft]

### Familie `sonderweg-genexis-pulse-ex400`

1 Gerät(e).

#### genexis-pulse-ex400

Genexis/Inteno Pulse EX400 · ramips-mt7621 · K1

- **Weg ab Werk:** Stock-Web-UI oder U-Boot-Recovery (Reset beim Einschalten, Update-LED grün, Webserver 192.168.1.1) nimmt das OpenWrt-factory.bin; das enthält ein initramfs; danach sysupgrade [geprüft]
- **Übertragung:** webui-upload; recovery-web: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-genexis_pulse-ex400-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-genexis_pulse-ex400-factory.bin) (200)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** ja: factory.bin = Kette `append-image-stage initramfs-kernel.bin`, `inteno-bootfs`, `inteno-y3-header EX400` (mt7621.mk); Gluon baut es nur nicht, weil das Rezept CONFIG_TARGET_ROOTFS_INITRAMFS braucht. Eine Gluon-RAMpe-Bau ergibt direkt eine Gluon-RAMpe-factory [abgeleitet aus mk]
- **Quelle (OpenWrt-Commit):** dd0c2839a81bb3c5067be99b02ec5c0adff93ac6
- **Detail-Anleitung:** https://github.com/freifunk-darmstadt/projects/wiki/90-%E2%80%90-Hardware-%E2%80%90-Genexis-EX400

### Familie `sonderweg-google-wifi-gale`

1 Gerät(e).

#### google-wifi-gale

Google WiFi (Gale) · ipq40xx-chromium · K5

- **Weg ab Werk:** Chrome-OS-Developer-Mode (laut Gluon nur mit geöffnetem Gehäuse), Boot von USB-Stick, Gluon-factory (GPT-Abbild) auf die eMMC [geprüft: Commit "requires booting from USB storage", Gluon-Kommentar]
- **Übertragung:** usb
- **seriell nötig:** nein (Konsole erst nach Dev-Mode über USB-C mit SuzyQable/CCD)
- **Gehäuse öffnen:** ja (Developer-Mode) [geprüft: Gluon-Kommentar]
- **Werkzeug/Spezial:** Developer-Mode, USB-Stick, ggf. SuzyQable
- **initramfs-Link:** [24.10.8: initramfs-fit-zImage.itb.vboot](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/chromium/openwrt-24.10.8-ipq40xx-chromium-google_wifi-initramfs-fit-zImage.itb.vboot)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/chromium/openwrt-24.10.8-ipq40xx-chromium-google_wifi-squashfs-factory.bin)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein
- **Quelle (OpenWrt-Commit):** OpenWrt f1c041e34f9742fcdd0c8c65f69888d3ec580541 (Gluon: broken, unser targets-ipq40xx-chromium.patch)
- **Detail-Anleitung:** https://openwrt.org/inbox/toh/google/google_wifi

### Familie `sonderweg-hewlett-packard-msm460`

1 Gerät(e).

#### hewlett-packard-msm460

HPE MSM460 · mpc85xx-p1020 · K5

- **Weg ab Werk:** Bootloader netzseitig ersetzen, ohne Öffnen: Reset beim Verbinden ~15 s halten, `tftp put commands.tftp nflashd.cccc9999` an 192.168.1.1; der Stock-Bootloader führt die Befehlsdatei aus, holt msm460-uboot.bin vom Rechner und schreibt sie in den NAND; danach factory [geprüft]
- **Übertragung:** tftp-server-am-geraet: put an 192.168.1.1 (Datei nflashd.cccc9999) + tftp-client-am-geraet: Server 192.168.1.66, Dateien msm460-uboot.bin, msm460-factory.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (RJ45-Konsole außen vorhanden, nicht nötig)
- **Werkzeug/Spezial:** blocktrron/msm460-flashing, blocktrron/u-boot-msm
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1020/openwrt-24.10.8-mpc85xx-p1020-hpe_msm460-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community); OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1020/openwrt-24.10.8-mpc85xx-p1020-hpe_msm460-squashfs-factory.bin) (200)
- **Stock-Teile:** Fremd-U-Boot (blocktrron/u-boot-msm), kein Stock-Teil
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein: der Weg schreibt ein factory, kein Ramboot-Schritt [abgeleitet]
- **Quelle (OpenWrt-Commit):** af329ec38980e2f706411a11b9f344a62eb0dd8f
- **Detail-Anleitung:** https://github.com/blocktrron/msm460-flashing?tab=readme-ov-file

### Familie `sonderweg-librerouter-v1`

1 Gerät(e).

#### librerouter-v1

Librerouter LibreRouter v1 · ath79-generic · K1d

- **Weg ab Werk:** OpenWrt/LibreRouterOS ab Werk: sysupgrade über die Weboberfläche oder `sysupgrade -n`; seriell nur als Notweg [geprüft]
- **Übertragung:** webui-upload (Stock) oder ssh; Notweg tftp am U-Boot, PC 192.168.1.10/24
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, UART-Header auf der Platine)
- **Werkzeug/Spezial:** Stock ist OpenWrt-basiert
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-librerouter_librerouter-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** 24463d0d9479bf701e3aaa122f539a43cc97402b [geprüft]

### Familie `sonderweg-linksys-e8450-ubi`

1 Gerät(e).

#### linksys-e8450-ubi

Linksys E8450 / Belkin RT3200 (UBI-Layout) · mediatek-mt7622 · K3

- **Weg ab Werk:** Stock-Web-UI (Configuration > Administration > Firmware Upgrade) nimmt `initramfs-recovery.itb`; daraus Flash-Backup und neuen Bootloader (preloader.bin, bl31-uboot.fip) per `mtd write`; der neue U-Boot baut UBI auf und holt das recovery-initramfs per TFTP [geprüft]
- **Übertragung:** webui-upload (Stock 192.168.1.1), dann tftp-client: Server 192.168.1.254, Gerät 192.168.1.1, Datei openwrt-mediatek-mt7622-linksys_e8450-ubi-initramfs-recovery.itb
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** alternativ der OpenWrt-UBI-Installer (Drittprojekt, laut DEVICE_COMPAT_MESSAGE "UBI installer version 1.1.0+")
- **initramfs-Link:** [24.10.8: initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-linksys_e8450-ubi-initramfs-recovery.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: preloader.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-linksys_e8450-ubi-preloader.bin)<br>[24.10.8: bl31-uboot.fip](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-linksys_e8450-ubi-bl31-uboot.fip)
- **Stock-Teile:** - (Backup aller mtdblock für den Rückweg)
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein: der Bootloader muss getauscht werden; die Web-UI nimmt zwar ein initramfs, aber ohne UBI-Umbau scheitert das Gluon-sysupgrade an DEVICE_COMPAT_VERSION 2.0 [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 02351861824a13ed158db1ef59aede2db6ba7568
- **Detail-Anleitung:** https://openwrt.org/toh/linksys/e8450#installation

### Familie `sonderweg-meraki-mr33-access-point`

1 Gerät(e).

#### meraki-mr33-access-point

Cisco Meraki MR33 · ipq40xx-generic · K5

- **Weg ab Werk:** Gehäuse öffnen, UART; `ubootwrite.py` (gepatcht) lädt einen modifizierten U-Boot (mr33-uboot.bin, 250-300 s), dann das sysupgrade per `tftp put` an den U-Boot [geprüft]; laut Gluon-Kommentar bricken neuere Bootloader-Versionen den SoC irreversibel
- **Übertragung:** tftp-server-am-geraet: Gerät 192.168.1.1, `tftp` binary, put sysupgrade.bin
- **seriell nötig:** ja
- **Gehäuse öffnen:** ja (1x4-Stiftleiste, niedrige Pins; 115200 8N1)
- **Werkzeug/Spezial:** ubootwrite.py mit Little-Endian-Patch, mr33-uboot.bin (beides über das OpenWrt-Wiki)
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-meraki_mr33-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** - (modifizierter Meraki-U-Boot aus Merakis GPL-Quellen, nicht aus der Stock-Firmware)
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein: der Weg schreibt das Gluon-sysupgrade direkt; das Risiko liegt im Bootloader
- **Quelle (OpenWrt-Commit):** OpenWrt 4943afd7818f56053231a5a7ae90e55da44f1f08 (Gluon: broken)
- **Detail-Anleitung:** https://openwrt.org/toh/meraki/mr33

### Familie `sonderweg-mercusys-mr90x-v1`

1 Gerät(e).

#### mercusys-mr90x-v1

Mercusys MR90X v1 · mediatek-filogic · K2

- **Weg ab Werk:** SSH in die Stock-Firmware (Port 20001, Web-Passwort), telnet-Hintertür über /etc/hotplug.d/iface/65-iptv + IPTV-Schalter, fremdes busybox-arm64 für `ubiupdatevol`, initramfs ins UBI-Volume `kernel`, `fw_setenv` (u. a. tp_boot_idx 0), Neustart, `sysupgrade -n` [geprüft: Commit und Wiki]
- **Übertragung:** ssh/scp: Router-IP Port 20001 (SSH), telnet Port 23; Datei initramfs-kernel.bin nach /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, R3/R6 bestücken)
- **Werkzeug/Spezial:** busybox-arm64 eines Dritten (github xerta555)
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-mercusys_mr90x-v1-initramfs-kernel.bin)<br>[24.10.8: ubi-initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-mercusys_mr90x-v1-ubi-initramfs-recovery.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** - (Wiki: Backup tp_data/boot für den Rückweg)
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: das RAMpe-initramfs könnte das OpenWrt-initramfs im kernel-Volume ersetzen; Exploit und fw_setenv bleiben Handarbeit [abgeleitet]. Hinweis: erstinstallation-ohne-factory.md beschreibt "tp_boot_idx 0, dann U-Boot-Web-Recovery nimmt initramfs" - weder im Commit noch im Wiki-Abschnitt "Stock bootloader" so belegt
- **Quelle (OpenWrt-Commit):** OpenWrt e4fe3097ef6a961874b66932a0ac4be18070630a
- **Detail-Anleitung:** https://openwrt.org/toh/mercusys/mr90x_v1#installation_stock_bootloader

### Familie `sonderweg-netgear-wax218`

1 Gerät(e).

#### netgear-wax218

NETGEAR WAX218 · qualcommax-ipq807x · K1

- **Weg ab Werk:** Stock-Web-UI (System Manager > Firmware > Local Firmware Upgrade) nimmt `web-ui-factory.fit` (ubinisiertes initramfs mit QSDK-Kopf), danach sysupgrade [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, Pogo-Pins oder Löten an J2)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: web-ui-factory.fit](https://downloads.openwrt.org/releases/24.10.8/targets/qualcommax/ipq807x/openwrt-24.10.8-qualcommax-ipq807x-netgear_wax218-web-ui-factory.fit)<br>[24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/qualcommax/ipq807x/openwrt-24.10.8-qualcommax-ipq807x-netgear_wax218-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 366 MB nutzbar (laut Commit)
- **Gluon-RAMpe passt:** ja: RAMpe-initramfs in dasselbe Format packen (ARTIFACT web-ui-factory.fit); Gluon baut für qualcommax kein initramfs, Rezept braucht TARGET_ROOTFS_INITRAMFS [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 7801161c4bb2413817b3dfd01695050e2da27bf3
- **Detail-Anleitung:** -

### Familie `sonderweg-totolink-x5000r`

1 Gerät(e).

#### totolink-x5000r

TOTOLINK X5000R · ramips-mt7621 · K1d

- **Weg ab Werk:** Stock-Web-UI nimmt das OpenWrt-sysupgrade [geprüft]
- **Übertragung:** webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-totolink_x5000r-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 23be410b3d1267c752bf9f6e5c8f5a514dc562c4

### Familie `sonderweg-tp-link-archer-c60-v1`

1 Gerät(e).

#### tp-link-archer-c60-v1

TP-Link Archer C60 v1 · ath79-generic · K2

- **Weg ab Werk:** OpenWrt-Commit: factory über Stock-Web-UI oder TFTP-Recovery; OpenWrt 24.10.8 liefert aber kein factory (nur initramfs/sysupgrade), Gluon setzt factory = false [geprüft]; bleibt UART + U-Boot (sysupgrade nach 0x9f020000 schreiben) [geprüft] oder ein älteres OpenWrt-factory als Zwischenschritt [abgeleitet]
- **Übertragung:** webui-upload bzw. tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin (nur mit factory); sonst tftp am U-Boot (seriell)
- **seriell nötig:** nein (nur für den seriellen Weg ohne factory-Image: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Weg: ja, Header auf der Platine)
- **Werkzeug/Spezial:** OpenWrt-factory älterer Version als Zwischenfirmware [abgeleitet]
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_archer-c60-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nein: TP-Link-Web/-TFTP nehmen nur safeloader-factory, kein initramfs; im UART-Weg teilweise
- **Quelle (OpenWrt-Commit):** 6d313da6dc5f655d92aa86e2ec42ecfcf763df3d [geprüft]; Gluon c2fc4e5a (factory = false ohne Begründung, PR #3034 hakt "flashable from vendor firmware" an)

### Familie `sonderweg-tp-link-td-w8970`

1 Gerät(e).

#### tp-link-td-w8970

TP-Link TD-W8970 v1 · lantiq-xrx200_legacy · K2

- **Weg ab Werk:** Ohne Öffnen: Shell per Injection (SSID `telnetd -p 1023 -l login` oder manipulierte Konfig "StatPost"), Image aus der Shell schreiben; Wiki: dafür OpenWrt 15.05 als Zwischenstufe. Mit Öffnen: seriell `t`, TFTP, `sf erase/write` sysupgrade [abgeleitet: Wiki]
- **Übertragung:** ssh/scp (telnet Port 1023) bzw. tftp-client-am-geraet: Server 192.168.1.2
- **seriell nötig:** nein (nur für den seriellen TFTP-Weg: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen TFTP-Weg: ja)
- **Werkzeug/Spezial:** tpconf_bin_xml.py oder StatPOSTer, telnet
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/lantiq/xrx200_legacy/openwrt-24.10.8-lantiq-xrx200_legacy-tplink_tdw8970-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein
- **Quelle (OpenWrt-Commit):** a99042c6a454d1167241ed35068f33ab97612e80 (ohne Installationstext) + Wiki toh:tp-link:td-w8970_v1

### Familie `sonderweg-ubiquiti-nanobeam-ac-gen1-xc`

1 Gerät(e).

#### ubiquiti-nanobeam-ac-gen1-xc

Ubiquiti NanoBeam AC Gen1 (XC) · ath79-generic · K0+

- **Weg ab Werk:** airOS-XC-Verfahren laut OpenWrt-Wiki (openwrt.org/toh/ubiquiti/common), im Commit nur verlinkt [geprüft: Verweis]
- **Übertragung:** laut Wiki [nicht geprüft]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_nanobeam-ac-xc-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_nanobeam-ac-xc-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 73ea763c0dcdb96c9163790f20edd964399035c0 [geprüft]

### Familie `sonderweg-wavlink-wl-wn573hx3`

1 Gerät(e).

#### wavlink-wl-wn573hx3

WAVLINK WL-WN573HX3 / 7Links WLR-1300 · mediatek-filogic · K1d

- **Weg ab Werk:** versteckte Seite der Stock-UI (meshUpgrade.html, Einrichtungsassistent überspringen) nimmt das `WN573HX3-sysupgrade.bin`, danach Werkseinstellungen [geprüft]
- **Übertragung:** webui-upload: Stock-UI 192.168.30.1 -> http://netlogin.link/html/meshUpgrade.html, Passwort admin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-wavlink_wl-wn573hx3-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: Gluon-sysupgrade geht direkt
- **Quelle (OpenWrt-Commit):** OpenWrt ca38f13ea2fd36850edee02fea6d81f0f8b16569
- **Detail-Anleitung:** -

### Familie `sonderweg-xiaomi-ax3600`

1 Gerät(e).

#### xiaomi-ax3600

Xiaomi AX3600 · qualcommax-ipq807x · K2

- **Weg ab Werk:** SSH-Zugang per Exploit (Wiki), `initramfs-factory.ubi` per `ubiformat` in die inaktive rootfs-mtd + nvram-Flags, Neustart, `sysupgrade -n` [geprüft]
- **Übertragung:** ssh/scp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH-Exploit (openwrt.org/inbox/toh/xiaomi/xiaomi_ax3600)
- **initramfs-Link:** [24.10.8: initramfs-factory.ubi](https://downloads.openwrt.org/releases/24.10.8/targets/qualcommax/ipq807x/openwrt-24.10.8-qualcommax-ipq807x-xiaomi_ax3600-initramfs-factory.ubi)<br>[24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/qualcommax/ipq807x/openwrt-24.10.8-qualcommax-ipq807x-xiaomi_ax3600-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe als `initramfs-factory.ubi` bauen, ersetzt den OpenWrt-Zwischenschritt; Exploit bleibt; Gluon baut für qualcommax kein initramfs [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 8364f0816417bfe404f7bded4eaa4f4a60c6d006
- **Detail-Anleitung:** -

### Familie `sonderweg-xiaomi-mi-router-3g`

1 Gerät(e).

#### xiaomi-mi-router-3g

Xiaomi Mi Router 3G · ramips-mt7621 · K2

- **Weg ab Werk:** Shell auf Stock per Telnet/SSH (wie man sie bekommt, sagt der Commit nicht), OpenWrt-kernel1.bin und rootfs0.bin per mtd schreiben, kernel0 löschen, danach Gluon-sysupgrade [geprüft; Shell-Zugang offen]
- **Übertragung:** ssh/scp (oder USB-Stick)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** mtd auf Stock
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-3g-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [squashfs-kernel1.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-3g-squashfs-kernel1.bin) (200), [squashfs-rootfs0.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-3g-squashfs-rootfs0.bin) (200)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein: Gluon baut kernel1/rootfs0 nicht, OpenWrt-Images nötig; Gluon-RAMpe ersetzte nur LuCI, wenn ein initramfs in kernel1 bootet (ungeprüft)
- **Quelle (OpenWrt-Commit):** 6e283cdc0da25928f8148805ebef7f8f2b769ee8

### Familie `sonderweg-xiaomi-mi-router-ax3000t`

1 Gerät(e).

#### xiaomi-mi-router-ax3000t

Xiaomi Mi Router AX3000T · mediatek-filogic · K2

- **Weg ab Werk:** Stock 1.0.47: SSH per Befehlseinschleusung in die API `misystem/arn_switch` (curl mit stok), Backup per nanddump, `initramfs-factory.ubi` per `ubiformat` in die inaktive ubi-Partition + nvram-Flags, Neustart, `sysupgrade -n` [geprüft]
- **Übertragung:** ssh/scp (Exploit über HTTP-API 192.168.31.1)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Exploit; Stock-Version 1.0.47
- **initramfs-Link:** [24.10.8: initramfs-factory.ubi](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-xiaomi_mi-router-ax3000t-initramfs-factory.ubi)<br>[24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-xiaomi_mi-router-ax3000t-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** - (Backup BL2, Nvram, Bdata, Factory, FIP, ubi, KF für den Rückweg)
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** teilweise: Gluon-RAMpe als `initramfs-factory.ubi` (ubinize-kernel) bauen, ersetzt den OpenWrt-Zwischenschritt; der Exploit bleibt [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 7dbcc1215a56cc1da68c81bf92d7efa174c5e051
- **Detail-Anleitung:** -

### Familie `sonderweg-xiaomi-mi-router-ax3000t-openwrt-u-boot-layout`

1 Gerät(e).

#### xiaomi-mi-router-ax3000t-openwrt-u-boot-layout

Xiaomi Mi Router AX3000T (OpenWrt-U-Boot-Layout) · mediatek-filogic · K3

- **Weg ab Werk:** wie AX3000T bis zum initramfs, dann kmod-mtd-rw, UBI neu anlegen (ubootenv, ubootenv2, optional recovery) und OpenWrt-Bootloader (preloader.bin, bl31-uboot.fip) per `mtd write` nach BL2/FIP [geprüft]
- **Übertragung:** ssh/scp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Exploit; kmod-mtd-rw
- **initramfs-Link:** [24.10.8: initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-xiaomi_mi-router-ax3000t-ubootmod-initramfs-recovery.itb)<br>[24.10.8: initramfs-factory.ubi](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-xiaomi_mi-router-ax3000t-ubootmod-initramfs-factory.ubi)
- **Factory-/Stock-Image-Link:** [24.10.8: preloader.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-xiaomi_mi-router-ax3000t-ubootmod-preloader.bin)<br>[24.10.8: bl31-uboot.fip](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-xiaomi_mi-router-ax3000t-ubootmod-bl31-uboot.fip)
- **Stock-Teile:** - (Bootloader aus OpenWrt; Backup für den Rückweg)
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein: Bootloader-Tausch braucht eine OpenWrt-Shell mit kmod-mtd-rw, die Gluon-RAMpe kann nur sysupgrade [abgeleitet]
- **Quelle (OpenWrt-Commit):** OpenWrt 7dbcc1215a56cc1da68c81bf92d7efa174c5e051
- **Detail-Anleitung:** -

### Familie `sonderweg-xiaomi-redmi-router-ax6s`

1 Gerät(e).

#### xiaomi-redmi-router-ax6s

Xiaomi Redmi Router AX6S / AX3200 · mediatek-mt7622 · K0+

- **Weg ab Werk:** Xiaomi-"closed beta"-Firmware 1.2.7 einspielen, telnet-Passwort aus der Seriennummer berechnen, nvram-Flags setzen, Gluon-`factory.bin` per wget holen und `mtd -r write … firmware` [geprüft]; Bootflags-Patch beachten (Neanderfunk-Notiz xiaomi-ax6s-bootflags.md)
- **Übertragung:** webui-upload (Beta-Firmware), telnet, http-server-noetig (wget vom Rechner, z. B. python -m http.server 8000)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Closed-Beta miwifi_rb03_firmware_stable_1.2.7_closedbeta.bin (MD5 5eedf1632ac97bb5a6bb072c08603ed7), telnet-Passwortrechner
- **initramfs-Link:** [24.10.8: initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-xiaomi_redmi-router-ax6s-initramfs-recovery.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-xiaomi_redmi-router-ax6s-factory.bin)
- **Stock-Teile:** Xiaomi-Beta-Firmware (Herstellerdatei, offizieller Download-Link nicht belegt)
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: Gluon baut factory.bin
- **Quelle (OpenWrt-Commit):** OpenWrt 9f9477b2751231d57cdd8c227149b88c93491d93
- **Detail-Anleitung:** -

### Familie `sonderweg-zte-mf286r`

1 Gerät(e).

#### zte-mf286r

ZTE MF286R (broken) · ath79-nand · K1

- **Weg ab Werk:** Root-Shell über Web-UI-Lücke (URL-Filter `&&telnetd&&`, telnet 4719 admin/admin), Backup, OpenWrt-initramfs mit nandwrite in "firmware" schreiben, reboot, sysupgrade; alternativ UART + TFTP [geprüft für MF286A/R, Dateinamen im Commit für MF286A]
- **Übertragung:** Exploit per Web-UI, dann telnet; Images per USB-Stick oder tftp (Busybox) auf das Gerät; UART-Weg: tftp-client am U-Boot, Server 192.168.0.22, Gerät 192.168.0.1
- **seriell nötig:** nein (nur für den seriellen Weg, Methode 3 im Commit: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen Weg: ja, Stecker X2 innen)
- **Werkzeug/Spezial:** Web-UI-Exploit; Busybox mit telnetd falls Stock ohne
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-zte_mf286r-initramfs-kernel.bin) (HEAD 200)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** für die Installation keine; Rückweg nur mit eigenem Backup (Stock-Firmware nicht öffentlich, providerspezifisch); TFTP-Notweg braucht 8 MB Nullen vor dem initramfs (`root_uImage`, Server 192.0.0.1/8)
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** ja (Exploit-Weg): genau der Fall "initramfs aus der Stock-Shell schreiben", Gluon-RAMpe statt OpenWrt-initramfs [abgeleitet]; Gluon markiert das Gerät broken mit "case must be opened" - laut Commit nicht zwingend
- **Quelle (OpenWrt-Commit):** 7ac8da00609f42b8aba74b7efc6b0d055b7cef3e [geprüft]

### Familie `sonderweg-zyxel-nbg6616`

1 Gerät(e).

#### zyxel-nbg6616

Zyxel NBG6616 · ath79-generic · K5

- **Weg ab Werk:** Serielle Konsole, ZyXEL-zloader per Passwort-Challenge (ATSE/ATEN) entsperren, U-Boot-bootcmd auf das kombinierte Image umstellen (saveenv), dann factory per TFTP-Recovery mit WPS-Taste [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.1.33, Datei ras.bin (WPS beim Booten halten)
- **seriell nötig:** ja
- **Gehäuse öffnen:** ? (Lage der Konsole im Commit nicht genannt)
- **Werkzeug/Spezial:** serielle Konsole + zloader-Passwortrechner (Skript im Commit)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-zyxel_nbg6616-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-zyxel_nbg6616-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: die Bootloader-Umstellung bleibt; danach nimmt die TFTP-Recovery das Gluon-factory direkt
- **Quelle (OpenWrt-Commit):** 459c8c9ef816156107e297964d088ddee2b4eef5 [geprüft]

### Familie `sonderweg-zyxel-wsm20`

1 Gerät(e).

#### zyxel-wsm20

ZyXEL WSM20 (Multy M1) · ramips-mt7621 · K1

- **Weg ab Werk:** Gerät in der Zyxel-Cloud registrieren, im Stock-Web-UI die versteckte Seite /gui/#/main/debug/firmwareupgrade öffnen, initramfs-kernel.bin hochladen, dann sysupgrade [geprüft]
- **Übertragung:** webui-upload: https://192.168.212.1/gui/#/main/debug/firmwareupgrade
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Zyxel-Cloud-Konto
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-zyxel_wsm20-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** ja: der Hersteller-Weg nimmt ein initramfs (KERNEL_INITRAMFS mit znet-Header, mt7621.mk); Cloud-Registrierung bleibt
- **Quelle (OpenWrt-Commit):** 28df7f7ff251d8684caa60f07ed0ba0c4a8e71f4
- **Detail-Anleitung:** https://freifunk-aachen.de/2024/01/04/installationsanleitung-zyxel-wsm20/

### Familie `sophos-xg-awetool`

5 Gerät(e).

#### sophos-ap100

Sophos AP100 · ath79-generic · K1d

- **Weg ab Werk:** Über eine Sophos-XG-Appliance (awetool) Root-Shell auf dem AP, sysupgrade per `mtd -r write ... astaro_image`; alternativ UART + U-Boot (`tftpboot`, `cp.b` nach 0x9f070000) [geprüft]
- **Übertragung:** ssh/scp über Sophos-XG (awetool); alternativ tftp-client am U-Boot: Server 192.168.99.8/24, Datei uImage_AP100 [Commit nennt uImage_AP100C als Beispiel]
- **seriell nötig:** nein (nur für den seriellen U-Boot-Weg ohne XG-Appliance: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen U-Boot-Weg: ja, UART nach Abnehmen des Deckels; die RJ45-Konsole außen ist laut Commit in der Herstellerfirmware abgeschaltet)
- **Werkzeug/Spezial:** Sophos-XG-Appliance (Home-Use-Lizenz, VM) mit `sudo awetool`
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-sophos_ap100-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: beide Wege schreiben das sysupgrade direkt (mtd write bzw. cp.b)
- **Quelle (OpenWrt-Commit):** 6f1efb28983758116a8ecaf9c93e1d875bb70af7 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7

#### sophos-ap100c

Sophos AP100C · ath79-generic · K1d

- **Weg ab Werk:** Über eine Sophos-XG-Appliance (awetool) Root-Shell auf dem AP, sysupgrade per `mtd -r write ... astaro_image`; alternativ UART + U-Boot (`tftpboot`, `cp.b` nach 0x9f070000) [geprüft]
- **Übertragung:** ssh/scp über Sophos-XG (awetool); alternativ tftp-client am U-Boot: Server 192.168.99.8/24, Datei uImage_AP100C [Commit nennt uImage_AP100C als Beispiel]
- **seriell nötig:** nein (nur für den seriellen U-Boot-Weg ohne XG-Appliance: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen U-Boot-Weg: ja, Platine ausbauen, drei Schrauben, 4-Pin-UART)
- **Werkzeug/Spezial:** Sophos-XG-Appliance (Home-Use-Lizenz, VM) mit `sudo awetool`
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-sophos_ap100c-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: beide Wege schreiben das sysupgrade direkt (mtd write bzw. cp.b)
- **Quelle (OpenWrt-Commit):** 6f1efb28983758116a8ecaf9c93e1d875bb70af7 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7

#### sophos-ap15c

Sophos AP15C · ath79-generic · K1d

- **Weg ab Werk:** Über eine Sophos-XG-Appliance (awetool) Root-Shell auf dem AP, sysupgrade per `mtd -r write ... astaro_image`; alternativ UART + U-Boot (`tftpboot`, `cp.b` nach 0x9f070000) [geprüft]
- **Übertragung:** ssh/scp über Sophos-XG (awetool); alternativ tftp-client am U-Boot: Server 192.168.99.8/24, Datei uImage_AP15C
- **seriell nötig:** nein (nur für den seriellen U-Boot-Weg ohne XG-Appliance: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen U-Boot-Weg: ja, laut Commit 4-Pin-UART innen; RJ45-Konsole außen vorhanden, ob im U-Boot nutzbar: ?)
- **Werkzeug/Spezial:** Sophos-XG-Appliance (Home-Use-Lizenz, VM) mit `sudo awetool`
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-sophos_ap15c-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nein: beide Wege schreiben das sysupgrade direkt (mtd write bzw. cp.b)
- **Quelle (OpenWrt-Commit):** 2d465fbf570e1f3286210305a26580cd417fec7c [geprüft]

#### sophos-ap55

Sophos AP55 · ath79-generic · K1d

- **Weg ab Werk:** Über eine Sophos-XG-Appliance (awetool) Root-Shell auf dem AP, sysupgrade per `mtd -r write ... astaro_image`; alternativ UART + U-Boot (`tftpboot`, `cp.b` nach 0x9f070000) [geprüft]
- **Übertragung:** ssh/scp über Sophos-XG (awetool); alternativ tftp-client am U-Boot: Server 192.168.99.8/24, Datei uImage_AP55 [Commit nennt uImage_AP100C als Beispiel]
- **seriell nötig:** nein (nur für den seriellen U-Boot-Weg ohne XG-Appliance: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen U-Boot-Weg: ja, UART nach Abnehmen des Deckels; die RJ45-Konsole außen ist laut Commit in der Herstellerfirmware abgeschaltet)
- **Werkzeug/Spezial:** Sophos-XG-Appliance (Home-Use-Lizenz, VM) mit `sudo awetool`
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-sophos_ap55-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: beide Wege schreiben das sysupgrade direkt (mtd write bzw. cp.b)
- **Quelle (OpenWrt-Commit):** 6f1efb28983758116a8ecaf9c93e1d875bb70af7 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7

#### sophos-ap55c

Sophos AP55C · ath79-generic · K1d

- **Weg ab Werk:** Über eine Sophos-XG-Appliance (awetool) Root-Shell auf dem AP, sysupgrade per `mtd -r write ... astaro_image`; alternativ UART + U-Boot (`tftpboot`, `cp.b` nach 0x9f070000) [geprüft]
- **Übertragung:** ssh/scp über Sophos-XG (awetool); alternativ tftp-client am U-Boot: Server 192.168.99.8/24, Datei uImage_AP55C [Commit nennt uImage_AP100C als Beispiel]
- **seriell nötig:** nein (nur für den seriellen U-Boot-Weg ohne XG-Appliance: ja)
- **Gehäuse öffnen:** nein (nur für den seriellen U-Boot-Weg: ja, Platine ausbauen, drei Schrauben, 4-Pin-UART)
- **Werkzeug/Spezial:** Sophos-XG-Appliance (Home-Use-Lizenz, VM) mit `sudo awetool`
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-sophos_ap55c-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: beide Wege schreiben das sysupgrade direkt (mtd write bzw. cp.b)
- **Quelle (OpenWrt-Commit):** 6f1efb28983758116a8ecaf9c93e1d875bb70af7 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7

### Familie `ssh-stock`

3 Gerät(e).

#### 8devices-jalapeno

8devices Jalapeno · ipq40xx-generic · K0

- **Weg ab Werk:** ab Werk ein altes LEDE: `sysupgrade -n -F` mit dem sysupgrade-Image; Gluon-factory `.ubi` für den U-Boot [geprüft]; alte U-Boots brauchen `bootm …#config@1`
- **Übertragung:** ssh/scp (LEDE ab Werk)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-8dev_jalapeno-initramfs-uImage.itb)
- **Factory-/Stock-Image-Link:** [24.10.8: squashfs-factory.ubi](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-8dev_jalapeno-squashfs-factory.ubi)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig
- **Quelle (OpenWrt-Commit):** OpenWrt 1e341bb5ef9ba342a56ad2765c2876091fdc66db
- **Detail-Anleitung:** -

#### xiaomi-miwifi-mini

Xiaomi MiWiFi Mini · ramips-mt7620 · K1d

- **Weg ab Werk:** Exploit: telnetd per Code-Injection in der Stock-Weboberfläche (`set_wifi_ap`), Root-Passwort setzen, dann `mtd -r write <sysupgrade> OS1`; alternativ Xiaomi-Entwickler-Firmware per USB-Stick + SSH-Patch (Xiaomi-Konto) [abgeleitet: Wiki]
- **Übertragung:** ssh/scp (hier telnet + wget/scp)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Browser/curl, telnet
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-xiaomi_miwifi-mini-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: Exploit schreibt das sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 70db4e46398c8c82774e6af7f7158f3df22d6afe (ohne Installationstext) + Wiki toh:xiaomi:miwifi_mini

#### vocore2

VoCore2 · ramips-mt76x8 · K1d

- **Weg ab Werk:** Stock ist ein OpenWrt-CC-Fork: per Ethernet oder WLAN "VoCore2" verbinden, `ssh root@192.168.1.1` (Passwort vocore), sysupgrade hochladen, `sysupgrade -n` [geprüft]
- **Übertragung:** ssh/scp: Gerät 192.168.1.1
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (Konsole am Dock über Micro-USB, UART2: USB, Art ?, Quelle Commit)
- **Werkzeug/Spezial:** ssh
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-vocore_vocore2-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein, unnötig: sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 3f31029b190417e12f4d19d9999cd52ec76d0f85

### Familie `tplink-eap-ssh`

5 Gerät(e).

#### tp-link-eap225-outdoor-v1

TP-Link EAP225-Outdoor v1 · ath79-generic · K0+

- **Weg ab Werk:** per SSH auf die Stock-Firmware `cliclientd stopcs` ausführen, dann factory im Web-UI hochladen [geprüft]
- **Übertragung:** ssh (Kommando) + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH-Zugang zur Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_eap225-outdoor-v1-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_eap225-outdoor-v1-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 4f86edf477edbc0f20b5a49a69f658fa82158284 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=4f86edf477edbc0f20b5a49a69f658fa82158284

#### tp-link-eap225-outdoor-v3

TP-Link EAP225-Outdoor v3 · ath79-generic · K0+

- **Weg ab Werk:** per SSH auf die Stock-Firmware `cliclientd stopcs` ausführen, dann factory im Web-UI hochladen [geprüft]
- **Übertragung:** ssh (Kommando) + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH-Zugang zur Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_eap225-outdoor-v3-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_eap225-outdoor-v3-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 7e4de89e631aaf56be5375662b7d5ed0f27e26f6 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=7e4de89e631aaf56be5375662b7d5ed0f27e26f6

#### tp-link-eap225-wall-v2

TP-Link EAP225-Wall v2 · ath79-generic · K0+

- **Weg ab Werk:** per SSH auf die Stock-Firmware `cliclientd stopcs` ausführen, dann factory im Web-UI hochladen [geprüft]
- **Übertragung:** ssh (Kommando) + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH-Zugang zur Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_eap225-wall-v2-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-tplink_eap225-wall-v2-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** c9f51a9ad6e8f99ed7adb78d208740b7d351985b [geprüft]

#### tp-link-eap613-v1

TP-Link EAP613 v1 · ramips-mt7621 · K0

- **Weg ab Werk:** SSH im Stock-Web-UI einschalten, per SSH `cliclientd stopcs`, dann factory im Web-UI hochladen (ggf. Dateinamen kürzen) [geprüft]
- **Übertragung:** ssh (ein Befehl) + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ssh-Client
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-tplink_eap613-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** 11588c52b47c2c3b2cdc7849ce9e4804bfdb8bb5

#### tp-link-eap615-wall-v1

TP-Link EAP615-Wall v1 · ramips-mt7621 · K0

- **Weg ab Werk:** SSH im Stock-Web-UI einschalten, per SSH `cliclientd stopcs`, dann factory im Web-UI hochladen (ggf. Dateinamen kürzen) [geprüft]
- **Übertragung:** ssh (ein Befehl) + webui-upload
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ssh-Client
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-tplink_eap615-wall-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-factory (Community)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nicht nötig
- **Quelle (OpenWrt-Commit):** a1b8a4d7b3ff3fa671623e2bccafd43a3c141e07

### Familie `tplink-tftp-recovery`

9 Gerät(e).

#### tp-link-archer-c20-v4

TP-Link Archer C20 v4 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (Reset 6-7 s beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_archer-c20-v4-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_archer-c20-v4-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** 5bdd238b634a34b038fbea9046893de29a77c000

#### tp-link-archer-c50-v3

TP-Link Archer C50 v3 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (Reset 6-7 s beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_archer-c50-v3-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_archer-c50-v3-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** 14951e8f8e09ba6e2cff140769189a66155a5345

#### tp-link-tl-mr3020-v3

TP-Link TL-MR3020 v3 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (Reset 6-7 s beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.225, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-mr3020-v3-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-mr3020-v3-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** 6bbb2202551be394fead2efd99eb946f846fc63d

#### tp-link-tl-mr3420-v5

TP-Link TL-MR3420 v5 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (Reset 6-7 s beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.225, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-mr3420-v5-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-mr3420-v5-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** 39e9bfb18199b046bd3b613002112e4e6dd53658

#### tp-link-tl-mr6400-v5

TP-Link TL-MR6400 v5 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (Reset mind. 8 s; Web-UI geht laut Commit nicht beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.225, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-mr6400-v5-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-mr6400-v5-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** b641eb6ecfbfc2c6a488483332d4b5a6ee4c736c

#### tp-link-tl-wa801nd-v5

TP-Link TL-WA801ND v5 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (WPS+Reset 10 s beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-wa801nd-v5-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-wa801nd-v5-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** ce31bdc20c3f2eb387a84c277dff76324a8e39c7

#### tp-link-tl-wr841n-v13

TP-Link TL-WR841N v13 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (Reset 6-7 s; das Web-UI zerschießt ein factory (Commit) beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-wr841n-v13-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-wr841n-v13-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** 24043a0d2e01b9843c0dc529205b3b0bc7ecbbf9
- **Detail-Anleitung:** https://openwrt.org/toh/tp-link/tl-wr841nd#tftp_recovery_via_bootloader_for_v8_v9_v10_v11_v12_v13

#### tp-link-tl-wr902ac-v3

TP-Link TL-WR902AC v3 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (Reset 6-7 s beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-wr902ac-v3-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-wr902ac-v3-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** d13b05741a4d05a271d26fc3be61e76530025098
- **Detail-Anleitung:** https://openwrt.org/toh/tp-link/tl-wr902ac_v3#installation

#### tp-link-tl-wr902ac-v4

TP-Link TL-WR902AC v4 · ramips-mt76x8 · K1d

- **Weg ab Werk:** TFTP-Recovery des Bootloaders (Reset bis LED blinkt beim Einschalten); Gluon liefert dafür `other/...-bootloader.bin` = OpenWrt-tftp-recovery (`pad-extra 128k` + factory, kein Stock-Teil) [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recover.bin (so im Commit; vermutlich tp_recovery.bin, ungeprüft)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-wr902ac-v4-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-`...-bootloader.bin` (other/); OpenWrt: [squashfs-tftp-recovery.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_tl-wr902ac-v4-squashfs-tftp-recovery.bin) (200)
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein, unnötig: Gluon-Image direkt; Recovery schreibt Flash, bootet nichts aus dem RAM
- **Quelle (OpenWrt-Commit):** ffa40fcc7fe1aee041775e097bccecb9be83cd21

### Familie `tplink-ubootteil-dd`

5 Gerät(e).

#### tp-link-archer-c2-v1

TP-Link Archer C2 v1 · ramips-mt7620 · K3

- **Weg ab Werk:** TFTP-Recovery (WPS/Reset beim Einschalten 10 s halten) mit selbst gebautem Image: U-Boot aus der TP-Link-Firmware + sysupgrade; überschreibt die Bootloader-Partition, Dauer laut Commit bis 20-25 min [geprüft]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.66, Datei ArcherC2V1_tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** dd, cat, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-tplink_archer-c2-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [TP-Link-Download](https://www.tp-link.com/en/support/download/archer-c2/v1/) (200)
- **Stock-Teile:** `dd if=<stock>.bin of=c2v1_uboot.bin bs=1 skip=512 count=131072`, dann `cat c2v1_uboot.bin <sysupgrade> > ArcherC2V1_tp_recovery.bin`
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein: Recovery schreibt Flash, bootet nichts aus dem RAM; das Gluon-sysupgrade lässt sich direkt anhängen
- **Quelle (OpenWrt-Commit):** 8375623a064037bbdd914bd9e7529eefa7172560

#### tp-link-archer-c20-v1

TP-Link Archer C20 v1 · ramips-mt7620 · K3

- **Weg ab Werk:** TFTP-Recovery (Reset beim Einschalten 6-7 s) mit U-Boot aus der TP-Link-Firmware vor dem OpenWrt-Image; alternativ seriell (Taste 4, tftp, erase/cp.b). Der Commit nennt das factory, das OpenWrt für dieses Gerät nicht mehr baut; heute analog Archer C2 v1 mit sysupgrade [geprüft für den Weg, abgeleitet für die Image-Wahl]
- **Übertragung:** tftp-client-am-geraet: Server 192.168.0.66, Datei ArcherC20V1_tp_recovery.bin
- **seriell nötig:** nein (nur für den seriellen Notweg: ja)
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** dd, cat, TFTP-Server
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7620/openwrt-24.10.8-ramips-mt7620-tplink_archer-c20-v1-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [TP-Link-Download](https://www.tp-link.com/en/support/download/archer-c20/v1/) (200)
- **Stock-Teile:** `dd if=<stock>.bin of=uboot.bin bs=512 count=256 skip=1`, dann `cat uboot.bin <image> > ArcherC20V1_tp_recovery.bin`
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein: wie Archer C2 v1
- **Quelle (OpenWrt-Commit):** 161a3be5adb21135eb75da81247fa5e04b6ea676

#### tp-link-archer-c20-v5

TP-Link Archer C20 v5 · ramips-mt76x8 · K3

- **Weg ab Werk:** Split-U-Boot: der Weg braucht den U-Boot-Teil aus der TP-Link-Firmware vor dem sysupgrade. boot.bin im Stock-Web-UI oder in der Web-Recovery (aktiviert durch Stromziehen ~3 s nach Start eines Stock-Updates), oder tp_recovery.bin per TFTP mit Reset beim Einschalten [geprüft]
- **Übertragung:** webui-upload; recovery-web: Gerät 192.168.0.1, Rechner statisch; tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** dd, cat
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_archer-c20-v5-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [TP-Link-Download](https://www.tp-link.com/de/support/download/archer-c20/v5/) (200)
- **Stock-Teile:** Web-UI: `dd if=tpl.bin of=boot.bin bs=131584 count=1; cat <sysupgrade> >> boot.bin`. TFTP: 196608 Nullbytes + (erste 131584 Byte ohne den ersten 512-Byte-Block) + sysupgrade
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade lässt sich direkt anhängen, kein Ramboot-Schritt
- **Quelle (OpenWrt-Commit):** 86e7353bff2a5de257de8ec62e782f016eed143c

#### tp-link-archer-c50-v4

TP-Link Archer C50 v4 · ramips-mt76x8 · K3

- **Weg ab Werk:** Split-U-Boot: der Weg braucht den U-Boot-Teil aus der TP-Link-Firmware vor dem sysupgrade. boot.bin im Stock-Web-UI oder in der Web-Recovery (aktiviert durch Stromziehen ~3 s nach Start eines Stock-Updates), oder tp_recovery.bin per TFTP mit Reset beim Einschalten [geprüft]
- **Übertragung:** webui-upload; recovery-web: Gerät 192.168.0.1, Rechner statisch; tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** dd, cat
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_archer-c50-v4-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [TP-Link-Download](https://www.tp-link.com/de/support/download/archer-c50/v4/) (200)
- **Stock-Teile:** Web-UI: `dd if=tpl.bin of=boot.bin bs=131584 count=1; cat <sysupgrade> >> boot.bin`. TFTP: 196608 Nullbytes + (erste 131584 Byte ohne den ersten 512-Byte-Block) + sysupgrade
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade lässt sich direkt anhängen, kein Ramboot-Schritt
- **Quelle (OpenWrt-Commit):** 01dcd574a24864c10a9c4df4304a3ce0da5c11a9

#### tp-link-archer-c50-v6-ca-eu-ru

TP-Link Archer C50 v6 (CA/EU/RU; nicht ES = C54) · ramips-mt76x8 · K3

- **Weg ab Werk:** Split-U-Boot: der Weg braucht den U-Boot-Teil aus der TP-Link-Firmware vor dem sysupgrade. boot.bin im Stock-Web-UI oder in der Web-Recovery (aktiviert durch Stromziehen ~3 s nach Start eines Stock-Updates), oder tp_recovery.bin per TFTP mit Reset beim Einschalten [geprüft] Stock-Image der passenden Variante (CA/EU oder RU) nehmen.
- **Übertragung:** webui-upload; recovery-web: Gerät 192.168.0.1, Rechner statisch; tftp-client-am-geraet: Server 192.168.0.66, Datei tp_recovery.bin
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** dd, cat
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-tplink_archer-c50-v6-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [TP-Link-Download](https://www.tp-link.com/de/support/download/archer-c50/v6/) (200)
- **Stock-Teile:** Web-UI: `dd if=tpl.bin of=boot.bin bs=131584 count=1; cat <sysupgrade> >> boot.bin`. TFTP: 196608 Nullbytes + (erste 131584 Byte ohne den ersten 512-Byte-Block) + sysupgrade
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein: Gluon-sysupgrade lässt sich direkt anhängen, kein Ramboot-Schritt
- **Quelle (OpenWrt-Commit):** e9ac1b19e0f3d383ab83373c261bfb5527a29521

### Familie `ubiquiti-edgerouter`

2 Gerät(e).

#### ubiquiti-edgerouter-x

Ubiquiti EdgeRouter X · ramips-mt7621 · K3

- **Weg ab Werk:** EdgeOS nimmt (Web-UI "System" oder `add system image`) ein initramfs-factory.tar, das OpenWrt heute nicht mehr baut (nur alte Releases/Fremdquellen); danach Umstieg auf das 24.10-Layout (Kernel 6 MB, compat_version 2.0). Seriell alternativ TFTP im Ralink-Menü [geprüft: Commit, mk, Wiki]
- **Übertragung:** webui-upload oder ssh/scp ubnt@192.168.1.1 (EdgeOS, eth0)
- **seriell nötig:** nein (nur für den seriellen TFTP-Weg: ja, 57600 Baud)
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Fremd-factory.tar (github stman/..., cyounkins/edgerouter-factory), darkxst/erx-migration, Neanderfunk-Notiz erx-migration-howto.md
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-ubnt_edgerouter-x-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** kein factory.tar in 24.10.8
- **Stock-Teile:** Umbau des Kernel-Layouts (Boot-Index in factory, Offset 160)
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein für 2025.1: EdgeOS schreibt in einen 3-MB-Kernel-Slot; Kernel 6.6 allein hat 3 173 556 Byte (Neanderfunk-Notiz erx-migration-howto.md), ein Gluon-initramfs mit Rootfs passt erst recht nicht [abgeleitet]
- **Quelle (OpenWrt-Commit):** 4e31b2e8697c21f9bd6493bb3d78a4a41c6a9a52
- **Detail-Anleitung:** https://github.com/oszilloskop/UBNT_ERX_Gluon_Factory-Image/blob/master/README.md#gluon-auf-ubnt-edgerouter-x-und-x-sfp

#### ubiquiti-edgerouter-x-sfp

Ubiquiti EdgeRouter X-SFP · ramips-mt7621 · K3

- **Weg ab Werk:** EdgeOS nimmt (Web-UI "System" oder `add system image`) ein initramfs-factory.tar, das OpenWrt heute nicht mehr baut (nur alte Releases/Fremdquellen); danach Umstieg auf das 24.10-Layout (Kernel 6 MB, compat_version 2.0). Seriell alternativ TFTP im Ralink-Menü [geprüft: Commit, mk, Wiki]
- **Übertragung:** webui-upload oder ssh/scp ubnt@192.168.1.1 (EdgeOS, eth0)
- **seriell nötig:** nein (nur für den seriellen TFTP-Weg: ja, 57600 Baud)
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** Fremd-factory.tar (github stman/..., cyounkins/edgerouter-factory), darkxst/erx-migration, Neanderfunk-Notiz erx-migration-howto.md
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-ubnt_edgerouter-x-sfp-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** kein factory.tar in 24.10.8
- **Stock-Teile:** Umbau des Kernel-Layouts (Boot-Index in factory, Offset 160)
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein für 2025.1: EdgeOS schreibt in einen 3-MB-Kernel-Slot; Kernel 6.6 allein hat 3 173 556 Byte (Neanderfunk-Notiz erx-migration-howto.md), ein Gluon-initramfs mit Rootfs passt erst recht nicht [abgeleitet]
- **Quelle (OpenWrt-Commit):** 9715beb04c74a918697945b3e2d23a139bd04b70
- **Detail-Anleitung:** https://github.com/oszilloskop/UBNT_ERX_Gluon_Factory-Image/blob/master/README.md#gluon-auf-ubnt-edgerouter-x-und-x-sfp

### Familie `ubiquiti-tftp`

4 Gerät(e).

#### ubiquiti-nanostation-loco-m-xw

Ubiquiti Nanostation Loco M XW · ath79-generic · K0+

- **Weg ab Werk:** Ubiquiti-TFTP-Recovery: Reset beim Einstecken halten bis die LEDs wechselweise blinken, factory per TFTP an das Gerät [geprüft]
- **Übertragung:** tftp-server-am-geraet: Gerät 192.168.1.20, PC z. B. 192.168.1.21/24, `tftp put` factory (binary)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_nanostation-loco-m-xw-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_nanostation-loco-m-xw-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 633c4304ad42d18d180ba65a264ba668de445d91 [geprüft]

#### ubiquiti-nanostation-m-xw

Ubiquiti Nanostation M XW · ath79-generic · K0+

- **Weg ab Werk:** Ubiquiti-TFTP-Recovery: Reset beim Einstecken halten bis die LEDs wechselweise blinken, factory per TFTP an das Gerät [geprüft]
- **Übertragung:** tftp-server-am-geraet: Gerät 192.168.1.20, PC 192.168.1.25/24, `tftp put` factory (binary)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_nanostation-m-xw-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_nanostation-m-xw-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 40530c8eb42aa4b98de10621b6c1c89030f00d0a [geprüft]

#### ubiquiti-rocket-m-xm

Ubiquiti Rocket M XM · ath79-generic · K0+

- **Weg ab Werk:** Commit ohne Anleitung; Ubiquiti-TFTP-Recovery wie bei den XW-Geräten [abgeleitet]
- **Übertragung:** tftp-server-am-geraet: 192.168.1.20 [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_rocket-m-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_rocket-m-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 53c474abbdfef8eb3499e2d10c9ad491788b8a72 (erstes ath79-Target, ohne Anleitung) [abgeleitet]

#### ubiquiti-unifi-ap-pro

Ubiquiti UniFi AP Pro · ath79-generic · K0+

- **Weg ab Werk:** Ubiquiti-TFTP-Recovery: Reset 10 s beim Einstecken, factory per TFTP an das Gerät [geprüft]
- **Übertragung:** tftp-server-am-geraet: Gerät 192.168.1.20, `tftp put` factory
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifi-ap-pro-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifi-ap-pro-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** b7da0d294465d5ab8d923f3b8265ece0a5847ac3 [geprüft]

### Familie `ubiquiti-unifi-ssh`

15 Gerät(e).

#### ubiquiti-unifi-ac-lite

Ubiquiti UniFi AC Lite · ath79-generic · K1d

- **Weg ab Werk:** SSH auf die Stock-Firmware (ubnt/ubnt, 192.168.1.20), Schreibschutz per /proc/ubnthal/.uf aus, sysupgrade nach kernel0/kernel1 schreiben, bootselect setzen [abgeleitet: Ablauf aus UK-Ultra-Commit bf94e0a, gleiche ubnt_unifiac-Basis; Commit des Geräts ohne Anleitung]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, ubnt/ubnt, Datei nach /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH + dd auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifiac-lite-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [abgeleitet: ar71xx-Commit 43a7a1a nennt AC Mesh = Hardwarekopie AC Lite, 128 MiB]
- **Gluon-RAMpe passt:** nein: per dd lässt sich das Gluon-sysupgrade direkt schreiben
- **Quelle (OpenWrt-Commit):** cad843e1f57790a08dd4804011b6cd3a4796786b (ohne Anleitung); 56fddc2577baf194d1e9a7b37d454d12ff9fb469 (Umbenennung) [abgeleitet]
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790

#### ubiquiti-unifi-ac-lr

Ubiquiti UniFi AC LR · ath79-generic · K1d

- **Weg ab Werk:** SSH auf die Stock-Firmware (ubnt/ubnt, 192.168.1.20), Schreibschutz per /proc/ubnthal/.uf aus, sysupgrade nach kernel0/kernel1 schreiben, bootselect setzen [abgeleitet: Ablauf aus UK-Ultra-Commit bf94e0a, gleiche ubnt_unifiac-Basis; Commit des Geräts ohne Anleitung]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, ubnt/ubnt, Datei nach /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH + dd auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifiac-lr-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [abgeleitet: laut Commit Hardware wie AC Lite]
- **Gluon-RAMpe passt:** nein: per dd lässt sich das Gluon-sysupgrade direkt schreiben
- **Quelle (OpenWrt-Commit):** 07c1ddf522dbe6085af664cf03a41f636a70b99c [abgeleitet]
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790

#### ubiquiti-unifi-ac-mesh

Ubiquiti UniFi AC Mesh · ath79-generic · K1d

- **Weg ab Werk:** SSH auf die Stock-Firmware (ubnt/ubnt, 192.168.1.20), Schreibschutz per /proc/ubnthal/.uf aus, sysupgrade nach kernel0/kernel1 schreiben, bootselect setzen [abgeleitet: Ablauf aus UK-Ultra-Commit bf94e0a, gleiche ubnt_unifiac-Basis; Commit des Geräts ohne Anleitung]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, ubnt/ubnt, Datei nach /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH + dd auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifiac-mesh-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [ar71xx-Commit 43a7a1a05e0906f8adacd9c09b5c0be79fc94de1]
- **Gluon-RAMpe passt:** nein: per dd lässt sich das Gluon-sysupgrade direkt schreiben
- **Quelle (OpenWrt-Commit):** 4456dd4660b4fa4e9c04d73029c72bf7b0f2ba84 [abgeleitet]
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790

#### ubiquiti-unifi-ac-mesh-pro

Ubiquiti UniFi AC Mesh Pro · ath79-generic · K1d

- **Weg ab Werk:** SSH auf die Stock-Firmware (ubnt/ubnt, 192.168.1.20), Schreibschutz per /proc/ubnthal/.uf aus, sysupgrade nach kernel0/kernel1 schreiben, bootselect setzen [abgeleitet: Ablauf aus UK-Ultra-Commit bf94e0a, gleiche ubnt_unifiac-Basis; Commit des Geräts ohne Anleitung]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, ubnt/ubnt, Datei nach /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH + dd auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifiac-mesh-pro-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [ar71xx-Commit 987b961537b7002eda21df97dd8bfebe8882bc6d]
- **Gluon-RAMpe passt:** nein: per dd lässt sich das Gluon-sysupgrade direkt schreiben
- **Quelle (OpenWrt-Commit):** e420b7b5c517d03e1282b5889065e22143f9c4ef [abgeleitet]
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790

#### ubiquiti-unifi-ac-pro

Ubiquiti UniFi AC Pro · ath79-generic · K1d

- **Weg ab Werk:** SSH auf die Stock-Firmware (ubnt/ubnt, 192.168.1.20), Schreibschutz per /proc/ubnthal/.uf aus, sysupgrade nach kernel0/kernel1 schreiben, bootselect setzen [abgeleitet: Ablauf aus UK-Ultra-Commit bf94e0a, gleiche ubnt_unifiac-Basis; Commit des Geräts ohne Anleitung]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, ubnt/ubnt, Datei nach /tmp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH + dd auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifiac-pro-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [abgeleitet: Mesh Pro ist laut ar71xx-Commit Hardwarekopie des AC Pro]
- **Gluon-RAMpe passt:** nein: per dd lässt sich das Gluon-sysupgrade direkt schreiben
- **Quelle (OpenWrt-Commit):** 7dd3d7e1d3845160c2ef51e6148b452e666bd6f5 [abgeleitet]
- **Detail-Anleitung:** https://forum.darmstadt.freifunk.net/t/unifi-ap-erstinstallation/790

#### ubiquiti-unifi-ap

Ubiquiti UniFi AP · ath79-generic · K0+

- **Weg ab Werk:** Commit ohne Anleitung; vermutlich wie UniFi AP Outdoor+ (gleiche ubnt-bz-Basis): SCP + fwupdate.real [abgeleitet]
- **Übertragung:** ssh/scp [abgeleitet]
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH auf der Stock-Firmware [abgeleitet]
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifi-ap-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifi-ap-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** ?
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 53c474abbdfef8eb3499e2d10c9ad491788b8a72 (erstes ath79-Target); 50e1f3d84db6fce48dd094f31cb55197db4c0d55 (Umbenennung) [abgeleitet]

#### ubiquiti-unifi-ap-outdoor+

Ubiquiti UniFi AP Outdoor+ · ath79-generic · K0+

- **Weg ab Werk:** factory per SCP auf die Stock-Firmware, dann `fwupdate.real -m <openwrt.bin> -d` [geprüft]
- **Übertragung:** ssh/scp
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifi-ap-outdoor-plus-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** Gluon-factory; OpenWrt: [squashfs-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_unifi-ap-outdoor-plus-squashfs-factory.bin)
- **Stock-Teile:** keine
- **RAM:** 64 MB [Commit]
- **Gluon-RAMpe passt:** nicht nötig (Gluon-factory)
- **Quelle (OpenWrt-Commit):** 51f578efa5012464a21565556eaf2027b3d88ab5 [geprüft]

#### ubiquiti-unifi-swiss-army-knife-ultra

Ubiquiti UniFi Swiss Army Knife Ultra · ath79-generic · K1d

- **Weg ab Werk:** SSH auf die Stock-Firmware (ubnt/ubnt, 192.168.1.20), `echo 5edfacbf > /proc/ubnthal/.uf`, sysupgrade per dd nach mtdblock2 und mtdblock3, bootselect auf kernel0, reboot [geprüft]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, ubnt/ubnt, `scp -O ... /tmp/firmware.bin`
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** SSH + dd auf der Stock-Firmware
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-ubnt_uk-ultra-initramfs-kernel.bin) (Liste)
- **Factory-/Stock-Image-Link:** kein factory (weder Gluon noch OpenWrt 24.10.8)
- **Stock-Teile:** keine
- **RAM:** 128 MB [Commit]
- **Gluon-RAMpe passt:** nein: dd schreibt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** bf94e0a38389b2ce5d33be9c97d104d36dd5ebd6 [geprüft]
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=5ad05681f2de00c8c6d6449df2b958b0838dbc1a

#### ubiquiti-unifi-ac-hd

Ubiquiti UniFi AC HD · ipq806x-generic · K1d

- **Weg ab Werk:** SSH (ubnt/ubnt), Byte 7 von `bootselect` (mtd11) nullen, sysupgrade per dd nach `kernel0` (mtdblock12), Neustart [geprüft]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, Login ubnt/ubnt
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-fit-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq806x/generic/openwrt-24.10.8-ipq806x-generic-ubnt_unifi-ac-hd-initramfs-fit-uImage.itb)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: der Weg schreibt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** OpenWrt 4e46beb31342a2b02e32185e91806093f68a77be
- **Detail-Anleitung:** -

#### ubiquiti-unifi-6-plus

Ubiquiti UniFi 6+ (U6+) · mediatek-filogic · K1d

- **Weg ab Werk:** SSH (ubnt/ubnt), Kernel-Partitionen per `/proc/ubnthal/.uf` entsperren, `fw_setenv` boot_openwrt/bootcmd_real, kernel und root aus dem sysupgrade-tar per dd nach mmcblk0p6/p7, Bootflag in mmcblk0p8 [geprüft]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, Rechner statisch 192.168.1.2, Login ubnt/ubnt
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/filogic/openwrt-24.10.8-mediatek-filogic-ubnt_unifi-6-plus-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** -
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: der Weg schreibt das Gluon-sysupgrade direkt, ohne initramfs-Schritt
- **Quelle (OpenWrt-Commit):** OpenWrt 75ee5546e9b7cfa5bbfd6f844ab8c5fffd5bb594
- **Detail-Anleitung:** https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=75ee5546e9b7cfa5bbfd6f844ab8c5fffd5bb594

#### ubiquiti-unifi-6-lr-v1

Ubiquiti UniFi 6 LR v1 · mediatek-mt7622 · K1d

- **Weg ab Werk:** SSH (ubnt/ubnt), bootselect in `bs` nullen, sysupgrade per dd nach kernel0 und kernel1, Neustart [geprüft: 634c13c1]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, Login ubnt/ubnt
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, Gehäuse verklebt)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-ubnt_unifi-6-lr-v1-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [24.10.8: ubootmod-initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-ubnt_unifi-6-lr-v1-ubootmod-initramfs-recovery.itb)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: der Weg schreibt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** OpenWrt 634c13c186646aff2badb51a43b248825d0fe5a0 (v1-Profil: 15a02471bb854245f8f94398c1e1d9ce29c2c341)
- **Detail-Anleitung:** https://openwrt.org/toh/ubiquiti/unifi_6_lr#installation_steps

#### ubiquiti-unifi-6-lr-v2

Ubiquiti UniFi 6 LR v2 · mediatek-mt7622 · K1d

- **Weg ab Werk:** SSH (ubnt/ubnt), bootselect in `bs` nullen, sysupgrade per dd nach kernel0 und kernel1, Neustart [geprüft: 634c13c1] [für v2 abgeleitet, eigener Commit ohne Installationsabschnitt]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, Login ubnt/ubnt
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, Gehäuse verklebt)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-ubnt_unifi-6-lr-v2-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [24.10.8: ubootmod-initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-ubnt_unifi-6-lr-v2-ubootmod-initramfs-recovery.itb)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: der Weg schreibt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** OpenWrt 634c13c186646aff2badb51a43b248825d0fe5a0 (v2: 31d86a1a119265393db02aa66e6bc6518ee7b905)
- **Detail-Anleitung:** https://openwrt.org/toh/ubiquiti/unifi_6_lr#installation_steps

#### ubiquiti-unifi-6-lr-v3

Ubiquiti UniFi 6 LR v3 · mediatek-mt7622 · K1d

- **Weg ab Werk:** SSH (ubnt/ubnt), bootselect in `bs` nullen, sysupgrade per dd nach kernel0 und kernel1, Neustart [geprüft: 634c13c1] [für v3 abgeleitet, eigener Commit ohne Installationsabschnitt]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20, Login ubnt/ubnt
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein (nur für den seriellen Notweg: ja, Gehäuse verklebt)
- **Werkzeug/Spezial:** -
- **initramfs-Link:** [24.10.8: initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-ubnt_unifi-6-lr-v3-initramfs-kernel.bin)
- **Factory-/Stock-Image-Link:** [24.10.8: ubootmod-initramfs-recovery.itb](https://downloads.openwrt.org/releases/24.10.8/targets/mediatek/mt7622/openwrt-24.10.8-mediatek-mt7622-ubnt_unifi-6-lr-v3-ubootmod-initramfs-recovery.itb)
- **Stock-Teile:** -
- **RAM:** 512 MB
- **Gluon-RAMpe passt:** nein, nicht nötig: der Weg schreibt das Gluon-sysupgrade direkt
- **Quelle (OpenWrt-Commit):** OpenWrt 634c13c186646aff2badb51a43b248825d0fe5a0 (v3: a0f4eadf6a25fb54c189bde91425673e11125d35)
- **Detail-Anleitung:** https://openwrt.org/toh/ubiquiti/unifi_6_lr#installation_steps

#### ubiquiti-unifi-6-lite

Ubiquiti UniFi 6 Lite · ramips-mt7621 · K1d

- **Weg ab Werk:** SSH auf Stock (ubnt/ubnt, 192.168.1.20): `fw_setenv devmode TRUE`, boot_openwrt/bootcmd setzen, sysupgrade per scp, bs-Flag nullen, sysupgrade per dd in kernel0 und kernel1 [geprüft]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ssh, dd, fw_setenv
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-ubnt_unifi-6-lite-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 256 MB
- **Gluon-RAMpe passt:** nein: der SSH-Weg schreibt das sysupgrade direkt; ein Ramboot ginge nur seriell (`fdt rm /signature`, TFTP C0A80114.img)
- **Quelle (OpenWrt-Commit):** fb4d7a9680117a00721936c98ce41eeb2dea95c9
- **Detail-Anleitung:** https://openwrt.org/toh/ubiquiti/unifi6lite#installation

#### ubiquiti-unifi-nanohd

Ubiquiti UniFi nanoHD · ramips-mt7621 · K1d

- **Weg ab Werk:** SSH auf Stock (ubnt/ubnt, 192.168.1.20; Stock v3.9.27, ggf. downgraden): bs-Flag nullen, sysupgrade per dd in kernel0 und kernel1 [geprüft]
- **Übertragung:** ssh/scp: Gerät 192.168.1.20
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** ssh, dd
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-ubnt_unifi-nanohd-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: SSH-Weg schreibt das sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 4c8446bf39de99990847eb4bc7744e25835a34f5

### Familie `xiaomi-ac2100-pppoe`

2 Gerät(e).

#### xiaomi-mi-router-ac2100

Xiaomi Mi Router AC2100 (R2100) · ramips-mt7621 · K2

- **Weg ab Werk:** Exploit CVE-2020-8597 über eine PPPoE-Sitzung am WAN-Port, Reverse-Shell, eigenes busybox per wget nachladen, OpenWrt-kernel1.bin + rootfs0.bin per mtd schreiben, nvram uart_en/bootdelay/flag_try_sys1_failed setzen [geprüft]
- **Übertragung:** ssh/scp (Reverse-Shell + wget, eigener http-Server nötig)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** PPPoE-Server + Python/scapy-Exploit, http-Server, netcat
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-ac2100-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [squashfs-kernel1.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-ac2100-squashfs-kernel1.bin) (200), [squashfs-rootfs0.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-ac2100-squashfs-rootfs0.bin) (200)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: OpenWrt-kernel1/rootfs0 nötig, Gluon baut sie nicht
- **Quelle (OpenWrt-Commit):** 53a1fede1f9856b61092ce4693e7610a515d562b

#### xiaomi-redmi-router-ac2100

Xiaomi Redmi Router AC2100 (RM2100) · ramips-mt7621 · K2

- **Weg ab Werk:** Exploit CVE-2020-8597 über eine PPPoE-Sitzung am WAN-Port, Reverse-Shell, eigenes busybox per wget nachladen, OpenWrt-kernel1.bin + rootfs0.bin per mtd schreiben, nvram uart_en/bootdelay/flag_try_sys1_failed setzen [geprüft]
- **Übertragung:** ssh/scp (Reverse-Shell + wget, eigener http-Server nötig)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** PPPoE-Server + Python/scapy-Exploit, http-Server, netcat
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_redmi-router-ac2100-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** [squashfs-kernel1.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_redmi-router-ac2100-squashfs-kernel1.bin) (200), [squashfs-rootfs0.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_redmi-router-ac2100-squashfs-rootfs0.bin) (200)
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: OpenWrt-kernel1/rootfs0 nötig, Gluon baut sie nicht
- **Quelle (OpenWrt-Commit):** f3792690c4f0567a8965d82898295b9d50c3bb7e
- **Detail-Anleitung:** https://openwrt.org/toh/xiaomi/xiaomi_redmi_router_ac2100

### Familie `xiaomi-openwrtinvasion`

6 Gerät(e).

#### xiaomi-mi-router-3g-v2

Xiaomi Mi Router 3G v2 · ramips-mt7621 · K2

- **Weg ab Werk:** Commit: Bootloader seriell erst mit `boot_wait=on`, Stock erst mit `uart_en=1`; beim Port per SPI-Programmer. Laut Commit baugleich mit 4A Gigabit, also OpenWRTInvasion + mtd write OS1 [abgeleitet]
- **Übertragung:** ssh/scp (Exploit)
- **seriell nötig:** nein [abgeleitet]
- **Gehäuse öffnen:** nein [abgeleitet]
- **Werkzeug/Spezial:** OpenWRTInvasion
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-3g-v2-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein
- **Quelle (OpenWrt-Commit):** 522d5ff42835f7ad01c090b9ea1863f5d56b91d3

#### xiaomi-mi-router-4a-gigabit-edition

Xiaomi Mi Router 4A Gigabit · ramips-mt7621 · K1d

- **Weg ab Werk:** OpenWRTInvasion-Exploit gibt eine Shell, dann `mtd -e OS1 -r write <sysupgrade> OS1` [geprüft]
- **Übertragung:** ssh/scp (Shell aus dem Exploit, telnet/ftp)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** OpenWRTInvasion (Python)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-4a-gigabit-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: Exploit schreibt das sysupgrade direkt
- **Quelle (OpenWrt-Commit):** a51e46e543ef2e923fb97fb092d04355dfca7d7d
- **Detail-Anleitung:** https://github.com/acecilia/OpenWRTInvasion/blob/master/README.md

#### xiaomi-mi-router-4a-gigabit-edition-v2

Xiaomi Mi Router 4A Gigabit v2 · ramips-mt7621 · K1d

- **Weg ab Werk:** OpenWRTInvasion-Exploit gibt eine Shell, dann `mtd -e OS1 -r write <sysupgrade> OS1` [geprüft]
- **Übertragung:** ssh/scp (Shell aus dem Exploit, telnet/ftp)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** OpenWRTInvasion (Python)
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-xiaomi_mi-router-4a-gigabit-v2-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 128 MB
- **Gluon-RAMpe passt:** nein: Exploit schreibt das sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 39e4f03fd335d5b5d1259d74fc3f00ad09e7796c

#### xiaomi-mi-router-4a-100m-international-edition

Xiaomi Mi Router 4A 100M International (R4AC) · ramips-mt76x8 · K1d

- **Weg ab Werk:** OpenWRTInvasion, `/proc/mtd` prüfen (overlay 2 MiB), sysupgrade nach /tmp, `mtd -r write <img> OS1` [abgeleitet: Wiki inbox:toh:xiaomi:r4ac; Commit ohne Installationstext]
- **Übertragung:** ssh/scp (Shell aus dem Exploit)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** OpenWRTInvasion
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-xiaomi_mi-router-4a-100m-intl-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein: Exploit schreibt das sysupgrade direkt
- **Quelle (OpenWrt-Commit):** 1a8c74da709190e5157af9f5c2502b600f6273bb (ohne Installationstext)
- **Detail-Anleitung:** https://forum.ffrn.de/t/howto-installation-xiaomi-mi-router-4a-r4ac-100m-international-edition/3536

#### xiaomi-mi-router-4a-100m-international-edition-v2

Xiaomi Mi Router 4A 100M International v2 · ramips-mt76x8 · K2

- **Weg ab Werk:** Stock einrichten, OpenWRTInvasion (zweimal), sysupgrade per nc nach /tmp/fw.bin, `mtd -r write /tmp/fw.bin OS1` [geprüft]
- **Übertragung:** ssh/scp (Shell aus dem Exploit, nc)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** OpenWRTInvasion, netcat
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-xiaomi_mi-router-4a-100m-intl-v2-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** ? (v1: 64 MB) [abgeleitet]
- **Gluon-RAMpe passt:** nein
- **Quelle (OpenWrt-Commit):** f51cb7447390949feff598b833b764ac1f3ff508

#### xiaomi-mi-router-4c

Xiaomi Mi Router 4C · ramips-mt76x8 · K2

- **Weg ab Werk:** OpenWRTInvasion gibt telnet/ftp, sysupgrade per ftp nach /tmp, `mtd -r write /tmp/firmware.bin OS1` [geprüft]
- **Übertragung:** ssh/scp (telnet + ftp, Gerät 192.168.31.1)
- **seriell nötig:** nein
- **Gehäuse öffnen:** nein
- **Werkzeug/Spezial:** OpenWRTInvasion
- **initramfs-Link:** [initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt76x8/openwrt-24.10.8-ramips-mt76x8-xiaomi_mi-router-4c-initramfs-kernel.bin) (200)
- **Factory-/Stock-Image-Link:** Gluon-sysupgrade direkt
- **Stock-Teile:** -
- **RAM:** 64 MB
- **Gluon-RAMpe passt:** nein
- **Quelle (OpenWrt-Commit):** 4287f739894ba2f95aca107e785b41a053c21315
- **Detail-Anleitung:** https://github.com/acecilia/OpenWRTInvasion/blob/master/README.md


<!-- END erzeugt:einzelheiten -->

## Anhang: Einzelbefunde der drei Teile

### Teil ath79


1. **K3 kommt in ath79 nicht vor.** Kein Gerät braucht für die Installation
   Sektoren oder Header aus der Stock-Firmware. Nur Rückwege brauchen Stock-Teile
   (Archer D50: OEM-Datei mit `dd` zuschneiden; ZTE MF286R: eigenes Backup, die
   Stock-Firmware ist nicht öffentlich).
2. **Die Gluon-RAMpe passt direkt nur bei 6 Geräten (K1)**: OCEDO Koala und
   Raccoon (Bootloader lädt per TFTP ein initramfs, ohne Gehäuse öffnen) und
   die vier MikroTik (Netboot). Bei OCEDO müsste die Gluon-RAMpe zusätzlich
   `fw_setenv bootcmd run bootcmd_1` setzen; OpenWrt tut das beim sysupgrade
   nicht (im Baum geprüft). Dazu ZTE MF286R über den Exploit-Weg (siehe 5).
3. **54 der 69 Geräte ohne factory brauchen die Gluon-RAMpe nicht**, weil der
   Herstellerweg das Gluon-sysupgrade direkt nimmt: 20 OpenMesh (ap51-flash),
   4 AVM (EVA), 8 GL.iNet, 7 devolo, 5 Sophos (XG-Appliance), 6 UniFi AC/UK-Ultra
   (SSH + dd), ALFA AP121F, COMFAST, Joy-IT, LibreRouter. Die übrigen K2:
   GL-E750 und GL-XE300 (U-Boot nimmt nur ein NAND-factory.img, das Gluon nicht
   baut, also OpenWrt-factory.img als Zwischenschritt [abgeleitet]), Archer C60
   v1 (siehe 6) und ZTE MF286R (siehe 5).
4. **K4 (6 ohne factory)**: Enterasys WS-AP3705i und Siemens WS-AP3610 haben
   die Konsole außen (Cisco-RJ45), Gehäuse bleibt zu; Extreme WS-AP3805i,
   Sophos AP15, Archer D50 und DIR-505 brauchen UART innen bzw. ohne Angabe. Die
   Gluon-RAMpe ersetzt dort nur das OpenWrt-initramfs, der serielle Teil bleibt.
   Siemens: das initramfs ist unkomprimiert (OpenWrt 23.7 MB).
5. **ZTE MF286R**: Gluon markiert das Gerät broken mit "case must be opened to
   install". Laut OpenWrt-Commit `7ac8da00` geht es ohne Öffnen: Root-Shell über
   eine Lücke im URL-Filter des Web-UI, dann OpenWrt-initramfs mit `nandwrite`
   in die "firmware"-Partition und neu starten. Genau dort passt die Gluon-RAMpe.
   Die Dateinamen im Commit gelten der MF286A; ob alles auch für die R gilt,
   ist nicht einzeln belegt.
6. **TP-Link Archer C60 v1**: Gluon setzt `factory = false` ohne Begründung
   (Commit c2fc4e5a, PR #3034 hakt "flashable from vendor firmware / Web
   interface" an). OpenWrt sieht factory im Makefile vor, das Release 24.10.8
   liefert aber keins (HEAD 404, nur initramfs/sysupgrade). Vermutlich ist das
   factory zu groß für 8 MB Flash [abgeleitet].
7. **D-Link DIR-825 B1**: kein factory mehr, seit OpenWrt `4309be6b` ("max
   image sizes are too small"). Der ath79-Commit beschreibt keinen Weg ab Werk.
   Offen, ob die D-Link-Recovery ein initramfs nimmt; das OpenWrt-initramfs
   liegt mit 6145 KB knapp über `FACTORY_SIZE` 6144k.
8. **Gluon-factory, aber trotzdem schwer**: Zyxel NBG6616 (Neanderfunk-Patch)
   braucht serielle Konsole, zloader-Passwort-Challenge und ein geändertes
   U-Boot-bootcmd (K5). Aerohive HiveAP 121 (UART 9600 Baud, `nand write`) und
   ZTE MF281 (UART, initramfs, `mtd write`) sind K4, Plasma Cloud PA300/PA300E
   nur per ap51-flash.
9. **MikroTik mAP lite und wAP AC**: der Neanderfunk-Patch setzt
   `factory = false` ohne dokumentierten Grund; Gluons `mikrotik.inc` würde
   sonst das initramfs als factory ausliefern. Zu prüfen bei allen vier
   MikroTik: ob Gluons initramfs-factory im Config-Mode startet. Laut
   `installer/docs/NOTIZEN.md` bricht `70_initramfs_test` den Preinit ab, bevor
   `90_setup_mode` läuft [abgeleitet, für ath79-mikrotik nicht getestet].
10. **OpenMesh OM2P v1 hat laut Commit 32 MB RAM.** Für ein Gluon-initramfs
    ist das zu wenig [abgeleitet]; für den ap51-flash-Weg spielt es keine Rolle.
11. **TP-Link CPE/WBS**: Die Commits nennen TFTP-Rescue mit `recovery.bin`
    als zweiten Weg; der Neanderfunk-Labortest hat am 01.10.2026 festgestellt, dass der
    Rescue nur TP-Link-Firmware nimmt. Der Web-UI-Weg bleibt.
12. **USB-Konsolen**: keine im ath79-Teil. Einzige Erwähnung ist Gluons
    Kommentar zum Onion Omega ("integrated (USB-)tty"), Art unbekannt.


### Teil ramips, lantiq, mpc85xx


1. **ERX/ERX-SFP: Gluon-RAMpe passt für 2025.1 nicht.** EdgeOS schreibt das
   factory.tar in einen 3-MB-Kernel-Slot. Laut `erx-migration-howto.md` hat
   der 6.6-Kernel allein 3 173 556 Byte; ein Gluon-initramfs mit Rootfs ist
   größer. OpenWrt 24.10.8 baut auch kein factory.tar mehr. Das betrifft
   NOTIZEN.md Punkt 4 (oszilloskops Original-Anwendungsfall) [abgeleitet].
2. **COVR-X1860 ist kein RAMpe-Kandidat** (steht in GERAETE.md noch so):
   Gluon baut factory und ein eigenes recovery.bin (squashfs, kein initramfs).
3. **Widersprüche zu älteren Neanderfunk-Notizen, offen:**
   - DIR-878/DIR-882: OpenWrt-Commits d7233b0a6a9b8cb9207a74a8cb3d0525170cf504 und 73e8f23579bcb87764dae9ed0aefe28be3183d3e beschreiben die
     D-Link-Web-Recovery auf 192.168.0.1; `recovery-wege.md` Abschnitt 6 sagt
     "DIR-Reihe über TFTP" (Quelle dort: ToH).
   - DAP-X1860: Commit 3c31f6b521bb5fc49e222a8f2bcd454b73452a0e lädt das factory.bin in die Recovery;
     `dlink-flashen.md` (01.10.2026) nennt OpenWrt-initramfs.
4. **WNDR3700 v5:** OpenWrt baut seit 2fdd02cc7c3516c2cce2ace2c7b539e0821ecbe8 ein factory.img für
   nmrpflash, Gluon setzt trotzdem `factory = false` (Gerät dort ohnehin
   broken, "untested").
5. **Cudy M1800:** Der Spiegel `Cudy_Intermediary_OpenWRT_Firmware-20251124`
   hat nur den Ordner "M1800+V2". Ob das zu `cudy_m1800` passt, ist
   ungeprüft. Für TR1200 v1 gibt es inzwischen eine Zwischenfirmware im
   Spiegel, der OpenWrt-Commit (05/2024) kennt nur den seriellen Weg.
6. **TP-Link mt76x8 mit `-bootloader.bin`:** Gluon legt das OpenWrt-tftp-recovery
   (`pad-extra 128k` + factory, kein Stock-Teil) als
   `other/…-bootloader.bin` ab. Damit installiert die TP-Link-TFTP-Recovery
   Gluon direkt. Der Dateiname führt in die Irre: Es ist kein Bootloader
   darin.
7. **TL-WR902AC v4:** Der Commit nennt die Datei `tp_recover.bin`, alle
   Geschwister `tp_recovery.bin`. Vermutlich ein Tippfehler, ungeprüft.
8. **HPE MSM460** hat ein Gluon-factory, der Weg dahin ersetzt aber
   netzseitig den Bootloader (Befehlsdatei per TFTP, Fremd-U-Boot von
   blocktrron). Deshalb K5, obwohl ohne Öffnen.
9. **Xiaomi Mi Router 3G, Mi Router AC2100, Redmi AC2100:** Der Exploit-Weg
   braucht die OpenWrt-Images kernel1.bin und rootfs0.bin; Gluon baut sie
   nicht.


### Teil mediatek, ipq40xx, ipq806x, qualcommax, bcm27xx, rockchip, x86


1. **initramfs fehlt im Gluon-Bau.** Gluon schaltet `TARGET_ROOTFS_INITRAMFS`
   nur in mediatek-filogic und ipq40xx-mikrotik ein [geprüft: targets/].
   Für ipq40xx-generic, ipq806x, qualcommax und mediatek-mt7622 braucht jedes
   RAMpe-Rezept `ensure_target_config … TARGET_ROOTFS_INITRAMFS`.
2. **Hersteller-Formate statt nacktem initramfs.** Der Hersteller-Weg nimmt
   oft eine verpackte Form: ASUS-TRX (`initramfs.trx`, RT-AX52), D-Link-Header
   (`squashfs-recovery.bin`), Netgear `web-ui-factory.fit` (WAX218), Xiaomi
   `initramfs-factory.ubi` (AX3000T, AX3600), Aruba `.ari` (AP-32x). OpenWrt
   erzeugt sie als IMAGES/ARTIFACTS, sobald initramfs an ist [geprüft:
   Image-Rezepte]; ob Gluons `extra_images` die ARTIFACTS einsammelt, ist nicht
   geprüft.
3. **Der Gluon-RAMpe fehlen Vorbereitungsschritte vor dem sysupgrade.** Aruba
   (`ubiformat`), AVM 7520/7530/Repeater (U-Boot nach uboot0/1, `ubirmvol`),
   ZTE MF289F (`ubirmvol`). Mit einem gerätespezifischen Hook in der Gluon-RAMpe
   würden aus diesen "teilweise" ein "ja"; der serielle bzw. EVA-Teil bleibt.
4. **MikroTik:** Gluons "factory" für den hAP ac2 ist selbst ein
   `-initramfs-kernel` (mikrotik.inc). Laut RAMpe-NOTIZEN startet ein
   Gluon-initramfs nie im Config-Mode; ob der hAP ac2 aus diesem "factory"
   heraus überhaupt bequem ins sysupgrade kommt, wäre zu prüfen
   [abgeleitet]. SXTsq und wAP ac haben in Gluon gar kein initramfs
   (`factory = false`). Alle drei sind gute RAMpe-Kandidaten.
5. **Linksys MR8300:** OpenWrt baut ein factory, das die Linksys-UI annimmt
   [geprüft: Commit], Gluon setzt trotzdem `factory = false` (Gluon d04ea647
   ohne Begründung). Kandidat für eine Gluon-Korrektur statt Gluon-RAMpe.
6. **GL-MT2500:** Die neue HW-Revision mit Airoha-PHY hat in OpenWrt 24.10 das
   eigene Profil `glinet_gl-mt2500-airoha` [geprüft: 24.10.8-Liste]; Gluon
   führt nur die MaxLinear-Fassung.
7. **Mercusys MR90X:** `erstinstallation-ohne-factory.md` beschreibt
   "tp_boot_idx 0, dann nimmt die U-Boot-Web-Recovery ein initramfs". Commit
   und Wiki-Abschnitt "Stock bootloader" beschreiben stattdessen
   busybox + `ubiupdatevol` ins kernel-Volume; die U-Boot-Web-Recovery steht
   dort nur für die OEM-Firmware. Die ältere Neanderfunk-Notiz ist so nicht belegt.
8. **Linksys WHW01:** Der OpenWrt-Commit kennt nur UART + TFTP, das Wiki
   (10.10.2026) beschreibt den Upload über die Linksys-UI im Support-Modus.
9. **Backports nicht in Vanilla-Gluon.** Die Gluon-RAMpe baut gegen Gluon
   v2025.1.3 ohne unsere Patches; für AP-32x, AP3000 Wall, WR3000U, M3000 v2
   und EAP620 HD müsste er gluon-patches-hardware einspielen. Für AP-32x und
   WR3000U gibt es OpenWrt-Images nur als Snapshot, nicht in 25.12.5
   [geprüft].
10. **Aruba-apboot:** Die OpenWrt-Commits (2019/2020) setzen ein offenes
    apboot-Environment voraus. Beim Instant On AP11 (Notiz 2024) war es
    gesperrt und brauchte ein entsperrtes apboot aus einem fremden, gepatchten
    SPI-Dump (K5). Ob AP-303/303H/365 aus heutiger Produktion ebenso gesperrt
    sind: offen.
11. **Cudy:** Alle Cudy-Geräte gehen über die Cudy-Zwischenfirmware; die
    Gluon-RAMpe bringt dort nichts. Ausnahme TR3000 v1 (128 MB): keine
    Zwischenfirmware im Spiegel, heute nur UART. Ob Cudys TFTP-Recovery
    (`recovery.bin` von 192.168.1.88, Reset beim Einschalten) ein fremdes
    initramfs annimmt, steht in keinem Commit (M3000-Commit: "not understood
    yet").
12. **EnGenius:** In diesen Targets führt Gluon kein EnGenius-Gerät mehr.




Lizenz dieser Datei: CC BY-SA 4.0. Quellen und Fundstellen siehe Tabelle.
