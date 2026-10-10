# Anleitungsfamilien: Rechercheergebnisse

Grundlage für die Installationsanleitungen (eine je Anleitungsfamilie, siehe
[ERSTINSTALLATION-2025.1.md](ERSTINSTALLATION-2025.1.md), Abschnitt "Spalten").
Je Familie: gemeinsamer Ablauf, beste Quellen, Abweichungen. Die Werte je Gerät
stehen in [`data/geraete-2025.1.json`](../data/geraete-2025.1.json) (Felder
`taste`, `zeichen`, `rechner`, `verwechslung`, `stock_bedingung`, `dauer`,
`rueckweg`). Recherchiert in vier Teilen am 10.10.2026, nichts auf Hardware
geprüft. "Widersprüche zu vorhandenen Feldern" sind nicht eingearbeitet, sondern
zur Klärung gesammelt.

## Teil A: k0-webui und image-auf-datentraeger

Stand 10.10.2026. Gerätewerte stehen in `A.json` (99 Geräte, nur gefüllte Felder).
Hinweis zu den Belegmarken: Das OpenWrt-Wiki ließ sich nur per WebFetch lesen
(Botsperre gegen curl). WebFetch liefert eine Zusammenfassung durch ein Hilfsmodell,
keinen Rohtext. "[geprüft: Wiki ...]" heißt also "so in der Wiedergabe der Wiki-Seite
gelesen". Commits, Image-Rezepte, DTS und die tplink-safeloader-Supportlisten sind
dagegen lokal im Original gelesen (OpenWrt-Pin a1ea57bd, firmware-utils 2025.08.03).

### k0-webui (87 Geräte)

#### Gemeinsamer Ablauf

- Rechner per LAN-Kabel an einen LAN-Port des Geräts anschließen. Bei Outdoor- und
  PoE-Geräten an die LAN-Seite des PoE-Injektors. [abgeleitet]
- Hardware-Version vom Typenschild ablesen (TP-Link "Ver: x.y", D-Link "H/W Ver.",
  Region EU/US) und genau das Gluon-factory-Image dieser Version nehmen. Viele Familien
  haben je Version ein eigenes Image, und die Hersteller-Oberfläche lehnt fremde
  Versionen oder Regionen ab. [geprüft: tplink-safeloader-Supportlisten, OpenWrt-Image-Rezepte]
- Herstelleroberfläche im Browser öffnen, Menü "Firmware Upgrade/Update" aufrufen, factory
  hochladen, Rückfragen bestätigen. Adresse, Login und Menüpfad je Gerät stehen in
  `rechner`. [geprüft: Commits/Wiki je Gerät]
- Bei älteren TP-Link-Oberflächen den Dateinamen vorher kurz umbenennen (z. B. `factory.bin`).
  [geprüft: Wiki archer-c5-c7-wdr7500, archer_c7, tl-wr1043nd, tl-wr842nd, tl-wr902ac_v1, cpe510]
  - Pharos: höchstens 68 Zeichen. [geprüft: Wiki cpe510]
  - Archer A7 v5: Umbenennen nicht nötig. [geprüft: Wiki archer_a7_v5]
- Während des Schreibens nicht ausschalten und nicht neu laden. Bei TP-Link löscht der
  Bootloader vorher den ganzen Flash. [geprüft: Wiki archer-c5-c7-wdr7500]
  - Dauer meist 1 bis 5 Minuten. Bei Repeatern (RE200) bis 20 Minuten. [geprüft: Wiki je Gerät]
- Fertig ist es so: Das Gerät startet selbst neu, und Gluon startet beim ersten Mal im
  Konfigurationsmodus.
  - Die Status-LED blinkt dann langsam, etwa 1 s an und 0,3 s aus (`status_led_set_timer 1000 300`).
  - Erreichbar ist das Gerät unter http://192.168.1.1, der Rechner bekommt seine Adresse per DHCP.
  - Bei Outdoor-Geräten (CPE/WBS) liegt der Konfigurationsmodus am WAN-Port, sonst am LAN-Port.
  - [geprüft: Gluon package/gluon-setup-mode S96led, S20network, S60dnsmasq,
    320-setup-ifname, gluon-core platform.lua is_outdoor_device]
  - Welche Buchse bei den Zwei-Port-CPEs WAN (eth0) ist, ist [offen].
- Eine Taste braucht der Normalweg nicht. In `taste` steht nur, was die im Feld `weg`
  genannten Alternativen (Recovery-Web, TFTP, Sercomm-Bootmodus) oder der Rückweg brauchen.

#### Beste Quellen

- OpenWrt-Commit je Gerät (Feld `quelle`), Abschnitt Installation.
- tplink-safeloader-Supportlisten (welche Hardware-Version und Region ein Image annimmt):
  `firmware-utils/src/tplink-safeloader.c`, lokal unter
  `gluon/openwrt/build_dir/host/firmware-utils-2025.08.03~950f8340/`.
- OpenWrt-Wiki/ToH:
  - https://openwrt.org/toh/tp-link/archer_c7
  - https://openwrt.org/toh/tp-link/archer-c5-c7-wdr7500
  - https://openwrt.org/toh/tp-link/tl-wdr4300_v1
  - https://openwrt.org/toh/tp-link/archer_c6_v2
  - https://openwrt.org/toh/tp-link/cpe210
  - https://openwrt.org/toh/tp-link/cpe510
  - https://openwrt.org/toh/tp-link/cpe710_v1
  - https://openwrt.org/toh/netgear/wndr3700
  - https://openwrt.org/toh/netgear/wndr3800
  - https://openwrt.org/toh/linksys/ea8300
  - https://openwrt.org/toh/zyxel/nwa50ax_pro
- Gluon-Quelle, für den Konfigurationsmodus und für Regionsimages (`GLUON_REGION=eu` in
  `templates/common/site.mk`).

#### Abweichungen und Fallen

Sperren und Bedingungen in der Herstellerfirmware (Feld `stock_bedingung`):
- Archer C7 v2: ab 3.14.3 (2015) Fehler 18005. [geprüft]
- TL-WDR3600/4300: Build 151104 sperrt, vorher 3.13.33 einspielen. [geprüft]
- Archer C6 v2: 1.2.0/1.2.1 lehnen ab, 1.3.3/1.3.7 nehmen 24.10 an. [geprüft]
- RE200 v3: über 1.1.0 erst downgraden. [geprüft]
- CPE710: ab 1.1.2 RSA-Signatur, nicht aktualisieren. [geprüft für v1]
- Archer C50 v1 EU mit 160411: erst downgraden, sonst Brick. [geprüft]
- Archer C20i mit Build 151014: Brick, erst 140709. [geprüft]
- Archer C2600 v1.1: Login geht nicht, nur TFTP. [geprüft]

Region:
- Neanderfunk baut nur `factory-eu` für Archer C7 v2 und C50 v1. [geprüft: site.mk]
- Gluon baut kein `factory-NA` für WNDR3700 v1 und WNR2200-8M. [geprüft: generic.mk]
- Archer C6 v2 US/TW ist ein anderes Image (nicht in Gluon). [geprüft: safeloader]
- TL-WR1043ND v4: Supportliste nur EU. [geprüft: safeloader]

Dual-Partition (Linksys EA6350v3/EA8300/MR8300/WHW01/WHW03/MX5300, Zyxel NWA50AX/NWA55AXE/NWA50AX Pro/NWA90AX Pro):
- Linksys: Die Herstellerfirmware bleibt in der zweiten Partition.
  - Nach mehreren abgebrochenen Starts kehrt das Gerät zu ihr zurück. Das ist zugleich
    der einfachste Rückweg (Feld `rueckweg`).
- Zyxel: Vorher muss Slot B aktiv sein. Sonst startet OpenWrt nur einmal. [geprüft]
- MX5300: Die zweite Partition muss per `mtd write` nachgezogen werden. [geprüft]
- EA8300: factory ab OpenWrt 23.05 laut Wiki ein Soft-Brick. Siehe Widersprüche.

Oberflächen-Eigenheiten:
- Archer C2 v3: Oberfläche nur mit altem Browser (SeaMonkey). [geprüft]
- Zyxel NWA: Dateiname zu lang, dann kommt "ULCGI unable to parse CGI query". [geprüft]
- Netgear EX6100v2/EX6150v2: fragt wegen "älterer Version" ein zweites Mal nach. [geprüft]
- D-Link DAP-1330/1365: Bei Browserproblemen geht es per curl in die Recovery. [geprüft]
- D-Link-Recovery: antwortet nicht auf ping. [geprüft: Neanderfunk-Notiz]

Verwechslungen, die das Image unbrauchbar machen (Feld `verwechslung`):
- WNDR3700 v1/v2 (gleiche EAN)
- WNR2200 8M/16M
- Archer C6 v3 / v4 (v4 nie unterstützt)
- DIR-860L A1 (Broadcom) / B1
- Buffalo G300NH RTL8366S / RB (Modellcode-Tabelle)
- RE650 v2, RE200 v5, AX23 v2 nicht unterstützt
- Nexx WT3020A (4 MB)
- Pharos:
  - CPE220 1.1 braucht das CPE210-v1-Image.
  - CPE520 1.1 braucht das CPE510-v1-Image.
  - CPE210 3.20 und CPE510 3.20 brauchen das v3-Image.

#### Rückweg

Ohne Aufwand belegt sind:
- Pharos: TFTP mit Originalfirmware als recovery.bin.
- TL-WR902AC: TFTP nimmt Herstellerfirmware.
- Mercusys MR70X: Web-Recovery.
- WAC104: nmrpflash.
- Linksys: Partitionswechsel durch mehrmaliges Ein- und Ausschalten.
- NBG6617: TFTP ras.bin.
- DGN3500B: Sercomm-Werkzeug.

Bei den meisten TP-Link-Routern muss die Herstellerdatei vorher gekürzt werden, das ist
also nicht ohne Aufwand. Deshalb steht dort nichts im Feld.

### image-auf-datentraeger (12 Geräte)

#### Gemeinsamer Ablauf

- Image wählen:
  - Raspberry Pi: Gluon-factory `.img.gz`. [geprüft: Gluon targets/bcm27xx.inc]
  - NanoPi: Gluon-sysupgrade `.img.gz`, weil Gluon dort kein factory baut. [geprüft: targets/rockchip-armv8]
  - x86: `squashfs-combined-efi` `.img.gz`, Geode `combined`; für VMs `.vdi`/`.vmdk`. [geprüft: targets/x86*]
- Image auf die microSD-Karte schreiben (Rechner mit Kartenleser) bzw. auf Platte/USB-Stick.
  - Raspberry Pi Imager und balenaEtcher nehmen `.img.gz` direkt.
    [geprüft: rpi-imager CommonStrings.qml, etcher supported-formats.ts]
  - dd, Rufus und Win32DiskImager brauchen eine entpackte `.img`.
  - Mit dd immer auf das ganze Gerät schreiben (`/dev/sdX`), nicht auf eine Partition.
  - [geprüft: Wiki raspberry_pi, nanopi_r2s, openwrt_x86, FriendlyElec-Wiki]
- NanoPi- und x86-`.img.gz` haben angehängte Metadaten. `gzip -d` meldet dann vermutlich
  "trailing garbage ignored", die Datei ist trotzdem in Ordnung.
  [geprüft: append-metadata in rockchip/x86 image/Makefile; Meldung abgeleitet, nicht getestet]
- Schreiben dauert Sekunden bis etwa eine Minute, das Image ist 120-170 MB groß. Der Rest der
  Karte bleibt ungenutzt (squashfs, kein ext4). Jede Karte ab etwa 256 MB reicht technisch.
  [abgeleitet: Config-images.in, Gluon baut kein ext4]
- Karte einstecken und Strom anschließen, dann startet Gluon im Konfigurationsmodus.
  - Raspberry Pi: der einzige Port ("single").
  - NanoPi: LAN-Port eth1 (WAN ist eth0).
  - x86: eth0, falls nur eine Schnittstelle da ist.
  - [geprüft: Gluon 020-interfaces, OpenWrt rockchip board.d/02_network, x86 99-default_network;
    Port im Konfigurationsmodus abgeleitet aus 320-setup-ifname]
- NanoPi: Die MAC-Adresse wird aus der Seriennummer (CID) der SD-Karte bzw. des eMMC erzeugt.
  Wer die Karte tauscht, bekommt eine andere MAC und damit eine andere Knoten-ID. Das gehört
  in die Anleitung als Hinweis "Karte nicht tauschen".
  [geprüft: OpenWrt rockchip board.d/02_network macaddr_generate_from_mmc_cid; Folge abgeleitet]

#### Beste Quellen

- https://openwrt.org/toh/raspberry_pi_foundation/raspberry_pi
- https://openwrt.org/toh/friendlyarm/nanopi_r2s
- https://openwrt.org/docs/guide-user/installation/openwrt_x86
- FriendlyElec-Wiki: https://wiki.friendlyelec.com/wiki/index.php/NanoPi_R3S, NanoPi_R4S, NanoPi_R2C
- Gluon `docs/user/x86.rst`
- OpenWrt `target/linux/bcm27xx/image/Makefile`, welche Pi-Modelle welches Image starten

#### Abweichungen

Raspberry Pi:
- Gluon führt nur Model B/B+, 2B, 3B/3B+ und 4B.
- A+, Zero, Zero 2 W, 3A+, Pi 400 und CM starten zwar laut OpenWrt. Für sie ist der
  Gluon-image_name aber unbekannt, der Autoupdater findet vermutlich kein Image. [abgeleitet]
- Pi 5 wird nicht unterstützt.

NanoPi:
- R2C und R2S haben je eigenes Image (PHY).
- R4S nur 4 GB.
- R3S: optional eMMC. Ins eMMC kommt Gluon per dd aus einem SD-Start heraus.

x86:
- Target nach CPU wählen: 64 bit, generic = Pentium 4 32 bit, Geode, legacy = Pentium MMX.
- combined-efi startet laut Image-Rezept auch per BIOS. [abgeleitet]

Raspberry Pi: Es gibt kein eindeutiges "fertig"-Zeichen an den LEDs, ACT flackert bei
Kartenzugriff. [abgeleitet: kein led-boot/running-Alias im bcm27xx-DTS]

### Widersprüche zu vorhandenen Feldern

| Gerät | Feld | alt | neu | Quelle |
|---|---|---|---|---|
| linksys-ea8300-dallas | weg | "Gluon-factory über die Linksys-UI [geprüft]" | factory ab OpenWrt 23.05 führt über die Linksys-UI zum Soft-Brick; nur das factory.bin von 22.03.5/22.03.6, danach sysupgrade. Für Gluon auf 24.10 also vermutlich Zwischenschritt wie bei MR8300 | Wiki https://openwrt.org/toh/linksys/ea8300 |
| linksys-mr8300-dallas | familie | k0-webui | Gluon setzt `factory = false`, das Feld `werkzeug` nennt OpenWrt-factory als Zwischenschritt; das ist kein reiner Web-Upload des Gluon-Image | Feld weg/werkzeug, Gluon targets/ipq40xx-generic |
| tp-link-tl-wr810n-v1 | weg | "[geprüft über Verweis auf ar71xx-Commit b23b0fb2]" (192.168.0.254, admin/admin) | b23b0fb2 fügt die TL-WR810N **v2** hinzu (QCA9533, 32 MB RAM). Das ath79-Gerät v1 ist QCA9531 mit Hardware-ID 0x8100001, v2 hat 0x8100002 (DEFAULT := n, nicht in Gluon). Adresse und Login sind für v1 also nur [abgeleitet] | Commit b23b0fb2 (Titel/Spezifikation), OpenWrt generic-tp-link.mk |
| tp-link-tl-wr810n-v1 | weg | factory im Stock-Web-UI, ohne Einschränkung | Wiki: ath79-Image für v1.1 (EU) hat Geräte soft-gebrickt, Fixes ab 21.02-rc2 erwähnt. Stand 24.10 unbestätigt | Wiki toh/tp-link/tl-wr810n |
| zyxel-nbg6716 | weg/uebertragung | webui-upload [abgeleitet: Web-UI] | Wiki beschreibt keine Installation über die Zyxel-Weboberfläche, nur per SSH/Kommandozeile bzw. TFTP-Recovery (ras.bin, 192.168.1.33). Der Web-Weg ist damit weiter unbelegt | Wiki https://openwrt.org/toh/zyxel/nbg6716 |
| tp-link-archer-c50-v1 | weg | factory im Stock-Web-UI, ohne Einschränkung | mit Herstellerfirmware 160411 (EU V1) erst downgraden, sonst Brick | Wiki toh/tp-link/archer-c50 |
| tp-link-archer-c20i | weg | factory im Stock-Web-UI, ohne Einschränkung | aus Build 151014 per Web-UI flashen scheint zu bricken, vorher Build 140709 | Wiki toh/tp-link/archer_c20i |
| tp-link-archer-c2600 | uebertragung | webui-upload | Hardware v1.1: Werks-Login geht nicht, nur TFTP (ArcherC2600_1.0_tp_recovery.bin, 192.168.0.66) | Wiki toh/tp-link/archer_c2600_v1 |
| tp-link-archer-a7-v5 | uebertragung | TFTP-Datei ArcherC7v5_tp_recovery.bin | kein Widerspruch: Wiki bestätigt den "C7"-Namen für das A7 v5 (Hinweis, weil es wie ein Tippfehler aussieht) | Wiki toh/tp-link/archer_a7_v5 |
| netgear-wndr3700, -v2, wndr3800(ch), netgear-wndr4300, netgear-nighthawk-x4s-r7800, netgear-wax220 | weg | "[abgeleitet: Commit ohne Anleitung / Image-Rezept]" | Wiki beschreibt den Web-Upload des factory.img ausdrücklich, könnte also [geprüft: Wiki] werden | Wiki toh/netgear/wndr3700, wndr3800, wndr4300, r7800, wax220 |
| tp-link-tl-wdr3600-v1, tl-wdr4300-v1, archer-c25-v1, archer-c5-v1, tl-wr1043nd-v2..v4, tl-wr2543n-nd, tl-wdr4900-v1 | weg | "[abgeleitet: Commit ohne Anleitung]" | Wiki beschreibt den Web-Upload, könnte [geprüft: Wiki] werden | Wiki je Gerät |

### Offen

- Pharos-Regionsbindung: Die Neanderfunk-Notiz sagt, ein Image der falschen Region (EU/US/JP)
  werde abgelehnt. Die Supportlisten der OpenWrt-factory-Images enthalten aber bei allen
  CPE/WBS die Regionen EU, US und UN (CPE510 v1, WBS510 zusätzlich CA). Falls es eine
  Regionsbindung gibt, betrifft sie wohl nur Herstellerfirmware, z. B. beim Rückweg per
  recovery.bin. [geprüft: tplink-safeloader.c; Deutung abgeleitet]
- CPE710 v2: Ob die RSA-Sperre ab Herstellerfirmware 1.1.2 auch für v2 gilt, ist
  ungeprüft (Wiki nennt nur v1). Prüfen, ob CPE210/510 neuere Stände mit ähnlicher Sperre
  haben.
- Linksys EA8300/MR8300: Mit Gluon 2025.1 (24.10) am Gerät klären, ob ein Zwischenschritt
  über OpenWrt 22.03.5-factory nötig ist.
- Linksys WHW01/VLP01: Das Feld `weg` nennt das Wiki als Quelle für den Web-Weg im
  Support-Modus. Die Seite toh/linksys/whw01 fand die Recherche nicht. Laut OpenWrt-Commit
  braucht die Erstinstallation die serielle Konsole. Quelle des Web-Wegs nachweisen.
- Netgear factory-NA: Bei WNDR3700 v1 und WNR2200-8M baut Gluon kein NA-Image. Ob
  NA-Geräte das normale factory annehmen, ist ungeprüft. Laut Wiki warnt die Oberfläche
  außerhalb NA nur.
- WNDR3800CH vs. "WNDR3800-1CHNAS" (laut Wiki nimmt sie keine normalen WNDR3800-Images):
  Ist das dasselbe Gerät?
- Buffalo WZR-HP-G300NH: Bei der Modellcode-Zuordnung A0D0/B0C0 widersprechen sich Wiki
  (Variante S) und ein Forenbeitrag (Variante RB).
- NanoPi R2C: Das Gerät kommt aus einem lokalen Patch (gluon-patches-hardware). Es fehlt in
  Gluons `010-primary-mac`-Liste, R2S/R3S/R4S stehen darin
  (package/gluon-core/luasrc/lib/gluon/upgrade/010-primary-mac). Folge nicht untersucht,
  Hinweis an den Hauptstrang.
- NanoPi R3S: Ob mit gefülltem eMMC die SD-Karte zuerst startet, ist nicht belegt.
- Pi Imager/balenaEtcher: Ob sie den Metadaten-Anhang hinter dem gzip-Strom vertragen,
  ist ungetestet.
- TL-WDR3600/4300: Ob genau der Wiki-Dateiname `wdr4300v1_en_3_14_3_up_boot(150518).bin`
  zwingend ist oder nur eine passende Länge, ist offen. Nach der Regel "better safe than
  sorry" diesen Namen in die Anleitung schreiben, als [abgeleitet] markiert.
- Archer C59 v1: Hat keine Wiki-Seite. Ein Forenbeitrag nennt den Fehler "You have no
  authority to access this router" (fehlender HTTP-Referer, Lösung: anderer Browser). Nicht
  selbst gelesen, daher nicht in A.json:
  https://forum.openwrt.org/t/openwrt-installation-on-tp-link-archer-c59-v1/82181

## Teil C: Cudy, AVM EVA, MikroTik-Netboot, TP-Link-Recovery und -dd

Stand 10.10.2026. Gerätewerte in C.json; hier gemeinsamer Ablauf je Familie, Quellen, Abweichungen.

### cudy-zwischenfirmware (20 Geräte)

Gemeinsamer Ablauf:
- Stock-Firmware nimmt nur von Cudy signierte Images; daher erst Cudys signiertes OpenWrt ("Zwischenfirmware", "intermediate firmware"), dann Gluon-**sysupgrade** ohne "Einstellungen behalten" [geprüft: Commits, router-werkstatt docs/cudy-installation.md]
- Cudy-Oberfläche http://192.168.10.1, Passwort admin (AP1300 Outdoor: 192.168.10.254) [geprüft: cudy-installation.md, Commit c6e59d06]; Menü Erweiterte Einstellungen > System > Firmware; MD5 nach dem Hochladen mit der Tabelle vergleichen [geprüft: cudy-installation.md]
- danach LuCI http://192.168.1.1, Passwort leer, System > Backup / Firmware Update, Haken "Einstellungen beibehalten" weg [geprüft: cudy-installation.md, Commit M3000 v2]
- nur solange die Cudy-Originaloberfläche läuft [geprüft: Cudy-FAQ]
- Seriennummer ab 2543 (Woche 43/2025, neuer Flash F50L1G41LC): betroffen AP3000 Outdoor 1.0, AP3000 Wall 1.0, M3000 1.0/2.0, TR3000 1.0, WR3000E/H/S/P 1.0; nur Zwischenfirmware vom 19.11.2025 oder neuer, sonst startet das Gerät nicht mehr; OpenWrt braucht >= 24.10.5, am Gluon-2025.1-Pin ist der Treiber-Backport (422-...F50L1G41LC) drin [geprüft: Cudy-FAQ, OpenWrt-Pin a1ea57bd]
- Rückweg für alle: Cudy-Firmware als recovery.bin, Rechner 192.168.1.88, Reset halten beim Einschalten, LEDs schnell blinkend = Übertragung, langsam = fertig; TR1200 über WAN statt LAN [geprüft: Cudy-FAQ Recovery]; Cudy beschreibt das nur für Windows mit tftp32 und abgeschalteter Firewall [geprüft: dieselbe Seite]

Quellen:
- router-werkstatt/docs/cudy-installation.md (Neanderfunk-Laienfassung mit Spiegel-Tabelle und MD5)
- https://www.cudy.com/blogs/faq/openwrt-software-download (Flash-Hinweis, Bedingung Cudy-Oberfläche)
- https://www.cudy.com/en-us/blogs/faq/how-to-recovery-the-cudy-router-from-openwrt-firmware-to-cudy-official-firmware (Rückweg, LEDs)
- Spiegel https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/

Abweichungen:
- M3000: zwei Images nach WAN-PHY (rtl8221b / yt8821), Unterscheidung im Cudy-Systemprotokoll [geprüft: Commit 45b51eba]
- WR3000U: nicht im Spiegel, Zwischenfirmware nur im Cudy-Google-Drive [geprüft: Commit]
- AP1300 Outdoor, AP3000 Outdoor/Wall: nur PoE-Versorgung
- WR1300 v1, X6 v1: in LuCI ggf. "Force upgrade" nötig [geprüft: Commit]
- WR3000 v1: Spiegel-Ordner "without_recovery_TFTP"
- TR1200 v1, AP1300 Outdoor: nicht in cudy-installation.md; Zwischenfirmware liegt im Spiegel (TR1200_V1/TR1200-OpenWRT-Flash.bin, AP1300_Outdoor_V1.0/...flash.bin)

### avm-eva-ftp (10 Geräte)

Gemeinsamer Ablauf:
- keine Taste: Zeitfenster ist der Start des Bootloaders (EVA/ADAM2), nur wenige Sekunden nach Strom an (fritzflash: 10 s, Wiki 4020/7360 v2: 5 s) [geprüft: Commits, fritzflash.py]
- Rechner fest 192.168.178.2/24, Gateway 192.168.178.1; WLAN aus, nur ein Kabel, gelbe LAN-Buchse; ungemanagter Switch dazwischen hilft [geprüft: fritzflash.py, fritz-tools-Doku]
- fritzflash.py (Python 3, Windows/macOS/Linux) sucht die Box, wählt das Image nach HWRevision und schreibt das sysupgrade nach mtd1 [geprüft: fritzflash.py]; von Hand: adam2/adam2, binary, passive, `quote MEDIA FLSH`, `put <sysupgrade> mtd1` [geprüft: Commits]; Windows-ftp.exe kann kein passive [abgeleitet: Wiki 4020/3370]
- beim Schreiben leuchtet die rote Info-LED, "nicht ausschalten"; danach Neustart, Konfigurationsmodus nach 2-5 Minuten auf 192.168.1.1 [geprüft: fritzflash.py]
- Schreiben bis 2 Minuten (Repeater, 4020), 4040 "2 minutes+" [geprüft: Commits, upload-to-f4040.sh]
- Rückweg: AVM-Recovery-Tool (Windows) oder FRITZ!OS-kernel.image per EVA-FTP [abgeleitet: Wiki]

Quellen:
- https://fritz-tools.readthedocs.io/de/latest/ und https://github.com/freifunk-darmstadt/fritz-tools/blob/master/fritzflash.py (IP, LED-Text, Fenster, Dauer)
- OpenWrt-Commits je Gerät; OpenWrt-Wiki toh:avm:* (4020, 4040, 3370, 7360, 7360 v2, 1750E)

Abweichungen:
- 4040: Gluon -bootloader.bin (U-Boot + Gluon), nicht sysupgrade; FRITZ!OS muss vorher einmal eingerichtet sein [abgeleitet: Wiki 4040]
- 3370 Rev. 2: zwei Dateien (eva-kernel nach mtd1, eva-filesystem nach mtd0) und `SETENV linux_fs_start 0`, nicht mit fritzflash; NAND Hynix/Micron nur nach Öffnen erkennbar, falsches Image = Bootschleife, dann das andere; EVA 2186: 30-s-Neustart [geprüft: Commit 0b62fe5e; abgeleitet: Wiki]
- 7360 SL/v1/v2: HWRevision 181/183 vs. 196 entscheidet das Image [abgeleitet: Wiki]
- 4020 hört evtl. auf 169.254.157.1, 1750E im Recovery-Modus auf 169.254.78.1 [geprüft: Commit 4020; abgeleitet: Wiki 1750E]

### avm-eva-ramboot (4 Geräte: 3390, 7362 SL, 7412, 7430)

Gemeinsamer Ablauf:
- Rechner fest 192.168.178.x/24; wenige Sekunden nach dem Einschalten `eva_ramboot.py 192.168.178.1 <OpenWrt-initramfs>` (Python 3) [geprüft: Commits, Skript am Pin]
- initramfs muss lzma-komprimiert sein, bei lantiq Standard [geprüft: Commit, Config-images.in am Pin]
- OpenWrt im RAM unter 192.168.1.1 (ssh root ohne Passwort), Gluon-sysupgrade per scp nach /tmp, sysupgrade [geprüft: Commits]
- linux_fs_start=1 ist die häufigste Falle (FRITZ!OS bootet wieder oder doppelter Neustart); per EVA-FTP `quote SETENV linux_fs_start 0` [geprüft: Commits 7412/7430/7362 SL; abgeleitet: Wiki 7412]
- Ersatzadresse 169.254.120.1 nach Firmware-Update/Recovery [geprüft: Commit 7412/7430]
- Rückweg: AVM-Recovery (Windows, laut Wiki 7362 SL auch Wine) [abgeleitet: Wiki]

Quellen: OpenWrt-Commits; scripts/flashing/eva_ramboot.py am Pin; Wiki toh:avm:avm_7362_sl, fritzbox_3390, avm_fritz_box_7412, avm_fritz_box_7430.

Abweichungen: 7362 SL: rot blinkende Power-LED = initramfs läuft [abgeleitet: Wiki]; fritzflash.py unterstützt die 7362 SL ausdrücklich nicht [geprüft: fritz-tools-Doku].

### avm-eva-uboot (4 Geräte: 7520, 7530, Repeater 1200, Repeater 3000)

Gemeinsamer Ablauf:
- Rechner 192.168.178.10/24, sobald Link: `eva_ramboot.py --offset 0x85000000 192.168.178.1 uboot-fritzXXXX.bin` [geprüft: Commits]
- Rechner auf 192.168.1.70/24, TFTP-Server mit OpenWrt-initramfs als FRITZXXXX.bin; U-Boot fragt alle 5 s [geprüft: Commit; U-Boot-Quelltext chunkeey/FritzBox-4040-UBOOT include/configs/fritz*.h: serverip 192.168.1.70, bootfile CONFIG_MODEL ".bin"]
- RAM-Boot bis 2 Minuten; dann U-Boot nach uboot0/uboot1, `ubirmvol` avm_filesys_0/1, `sysupgrade -n` [geprüft: Commits]
- manche Boxen nehmen beim Start 192.168.1.1; im Notfall FRITZ!OS 7.21 per Recovery [abgeleitet: Wiki 7530]
- AX-Modelle (7530 AX, Repeater 1200 AX/3000 AX) gehen nicht [abgeleitet: Wiki 7530; kein Device am Pin]

Quellen: Commits 95b0c07a, 7f187229, 148d29d4; Wiki toh:avm:avm_fritz_box_7530, avm_fritz_repeater_1200, fritz_repeater_3000; package/boot/uboot-fritz4040/Makefile am Pin.

Abweichungen: 7520 = Gluon-Alias der 7530, aber U-Boot uboot-fritz7520.bin und TFTP-Name FRITZ7520.bin [geprüft: U-Boot-Quelltext].

### mikrotik-netboot (9 Geräte)

Gemeinsamer Ablauf:
- vorher in RouterOS prüfen: RouterBOOT "current firmware" < 7, sonst RouterOS v6 + Bootloader zurückstufen [abgeleitet: Wiki toh:mikrotik:common; geprüft: OpenWrt-Commit 36834ea3 "RouterBOOT v7 on NOR devices no longer accepts the YAFFS kernel ELF"]
- Rechner fest 192.168.1.10/24, BOOTP-fähiger DHCP+TFTP-Server (dnsmasq --bootp-dynamic --dhcp-boot=<initramfs> --enable-tftp; Windows: Tiny PXE mit rfc951=1), Kabel an ether1 [abgeleitet: Wiki]
- Strom ab, Reset halten, Strom an, halten bis LED blinkt -> fest -> aus (je etwa 5 s, insgesamt etwa 15 s), loslassen: Gerät sucht Netboot-Server [geprüft: MikroTik-Doku Reset Button]; viele Modelle piepen, wenn das Laden beginnt [abgeleitet: Wiki]
- initramfs läuft im RAM unter 192.168.1.1 an einem LAN-Port, dann sysupgrade (LuCI oder scp + `sysupgrade -n`) [geprüft: Commits; abgeleitet: Wiki]
- Gluon-factory = initramfs nur bei hAP (951Ui), wAP R, hAP ac2; sonst OpenWrt-initramfs nehmen (factory=false) [geprüft: Gluon targets/*mikrotik*, ramips-mt7621]
- Rückweg: MikroTik Netinstall [abgeleitet: Wiki]

Quellen:
- https://openwrt.org/toh/mikrotik/common
- https://help.mikrotik.com/docs/spaces/ROS/pages/24805498/Reset+Button
- Commits je Gerät (alle verweisen nur auf toh/mikrotik/common)

Abweichungen:
- wAP ac zweimal: RBwAPG-5HacT2HnD (ath79) vs. RBwAPG-5HacD2HnD (ipq40xx) [geprüft: Commit 7f54bf6f]
- hEX RB750Gr3: Geräte mit früher getauschtem Bootloader passen nicht [geprüft: Commit 52f2d7d2]
- RouterBOOT-TFTP-Grenze etwa 7 MiB für das initramfs [abgeleitet: Wiki]

### tplink-tftp-recovery (9 Geräte)

Gemeinsamer Ablauf:
- Rechner fest 192.168.0.66/24 (MR3020 v3, MR3420 v5, MR6400 v5: 192.168.0.225/24), TFTP-Server, Kabel an LAN [geprüft: Commits]
- Gluon other/...-bootloader.bin (= OpenWrt -squashfs-tftp-recovery.bin, pad-extra 128k + factory) als tp_recovery.bin ablegen [geprüft: Gluon targets/ramips-mt76x8, mt76x8.mk am Pin, Commits]; Name so streng wie in der Quelle, ob zwingend: [abgeleitet]
- Reset drücken, Strom an, etwa 6-7 s halten bis der Download beginnt (MR6400 v5: mindestens 8 s; WA801ND v5: WPS+Reset 10 s bzw. bis Schloss-LED; WR902AC v4: bis LED blinkt) [geprüft: Commits]
- Router schreibt selbst und startet neu, typisch 1-3 Minuten; nicht vorher Strom ziehen [geprüft: Commits; abgeleitet: Wiki]
- nie über die TP-Link-Weboberfläche (factory zerschossen bzw. sysupgrade bricked) [geprüft: Commit WR841N v13; abgeleitet: Wiki C50/WA801ND]
- Rückweg: TP-Link-Firmware per derselben TFTP-Recovery, je nach Modell ersten 512 Byte abgeschnitten [abgeleitet: Wiki]

Quellen: Commits je Gerät; Wiki toh:tp-link:archer_c20_v4 (LED-Ablauf), archer-c50, tl-mr6400_v5, tl-wa801nd, tl-wr841nd, tl-mr3020_v3.

Abweichungen:
- WR902AC v4: Commit nennt "tp_recover.bin" (ohne y), alle anderen "tp_recovery.bin"; Vorschlag: Datei unter beiden Namen bereitstellen
- C50 v3: laut Wiki nach jedem Versuch 3 Minuten warten, sonst Brick-Gefahr

### tplink-ubootteil-dd (5 Geräte)

Gemeinsamer Ablauf:
- Image muss man selbst bauen: U-Boot-Teil aus der TP-Link-Firmware (passende Version/Region) + Gluon-sysupgrade, mit dd/cat [geprüft: Commits]
- Archer C2 v1 / C20 v1 (MT7620): ArcherC2V1_tp_recovery.bin bzw. ArcherC20V1_tp_recovery.bin, TFTP 192.168.0.66, Recovery schreibt ab Adresse 0 inklusive Bootloader, 20-25 Minuten [geprüft: Commits; abgeleitet: Wiki]
- C20 v5 / C50 v4 / C50 v6 (MT7628, Split-U-Boot): boot.bin über TP-Link-Weboberfläche oder Web-Recovery 192.168.0.1 (Update starten, nach etwa 3 s bei 0 % Strom ziehen; nur WPS-LED an), oder tp_recovery.bin (196608 Nullbytes + U-Boot-Teil ohne 512-Byte-Kopf + sysupgrade) per TFTP, etwa 1 Minute [geprüft: Commits]
- Rückweg Split-U-Boot: TP-Link-Firmware über die Web-Recovery [geprüft: Commit]

Quellen: Commits 8375623a, 161a3be5, 86e7353b, 01dcd574, e9ac1b19; Wiki toh:tp-link:archer_c2_ac750, archer_c20_v1, archer_c20_v5, archer-c50.

Abweichungen: C50 v6 nur CA/EU/RU, ES = Archer C54 [geprüft: Commit]; C2 v1: falsches Image = nur SPI-Programmer [abgeleitet: Wiki].

### Widersprüche zu vorhandenen Feldern

| Gerät | Feld | alt | neu | Quelle |
| --- | --- | --- | --- | --- |
| avm-fritz-box-7520 | weg / uebertragung | "TFTP-Dateiname: ? [abgeleitet]" | FRITZ7520.bin (U-Boot uboot-fritz7520: CONFIG_MODEL "FRITZ7520", CONFIG_BOOTFILE CONFIG_MODEL ".bin", serverip 192.168.1.70) | [geprüft: chunkeey/FritzBox-4040-UBOOT @9d89013f include/configs/fritz7520.h], Wiki 7520/7530 |
| avm-fritz-box-4020 | uebertragung | "Gerät 169.254.157.1 (laut Commit evtl. 192.168.178.1)" | Commit nennt 169.254.157.1 zuerst, "might also be 192.168.178.1"; Wiki 4020 nennt nur 192.168.178.1; fritzflash.py setzt per Discover-Paket 192.168.178.1. Vorschlag: 192.168.178.1, Ersatz 169.254.157.1 | Commit 3f8c5d54, Wiki toh:avm:fritz.box.4020, fritzflash.py |
| tp-link-tl-mr6400-v5 | weg | "Web-UI geht laut Commit nicht beim Einschalten" | Commit b641eb6e sagt dazu nichts, nur "You can flash via tftp recovery ... wait at least 8 seconds" | Commit b641eb6e |
| tp-link-tl-wr902ac-v4 | uebertragung | "Datei tp_recover.bin (so im Commit; vermutlich tp_recovery.bin, ungeprüft)" | Commit wörtlich "tp_recover.bin"; Wiki-Seite für v4 fehlt; Vorschlag: beide Namen bereitstellen | Commit ffa40fcc |

### Offen

- AVM 7530/7520: ob neuere FRITZ!OS-Versionen das Laden des U-Boot per EVA wirklich verhindern (Wiki rät nur im Fehlerfall zu 7.21).
- AVM EVA-FTP: Zeitfenster widersprüchlich (fritzflash 10 s, Wiki 5 s, 7362 SL etwa 4 s); in der Anleitung besser "sofort" schreiben.
- AVM 7362 SL: LED-Verhalten im initramfs (rot blinkende Power-LED) nur im Wiki; gilt vermutlich für alle lantiq-Ramboot-Geräte, nicht belegt.
- Cudy WR3000 v1: Bedeutung des Spiegel-Ordnernamens "without_recovery_TFTP" (geht die Cudy-TFTP-Recovery nach der Zwischenfirmware nicht mehr?).
- Cudy M3000 YT8821: ob die Zwischenfirmware M3000_1.0_2.0 zur YT8821-Variante passt (schon in cudy-installation.md offen).
- Cudy WR3000H: Nutzerberichte über neue Geräte mit YT8821-WAN-PHY, bei denen die Zwischenfirmware 20251119 "File is invalid" meldet; ob unser Gluon-Image cudy-wr3000h-v1 (RTL8221B) auf solchen Geräten überhaupt passt, ist ungeklärt (Kommentar Cudy-FAQ 09.10.2026).
- Cudy TR3000 256MB: Nutzerbericht (SN-Woche 2626, Stock 2.5.21) "startet nach Zwischenfirmware Mai 2025 nicht mehr"; unbestätigt, aber vor Anleitung beachten.
- Cudy AP1300 Outdoor: ob die Cudy-Firmware DHCP macht (sonst feste Rechner-IP 192.168.10.x nötig).
- Cudy M1800: ob die Zwischenfirmware "M1800+V2" zum Gluon-Image cudy-m1800 passt (schon im Feld weg offen).
- MikroTik: Größe der Gluon-initramfs (hAP, wAP R, hAP ac2) gegen die laut Wiki etwa 7-MiB-Grenze von RouterBOOT prüfen.
- MikroTik: ob OpenWrt 24.10 (Gluon 2025.1) mit RouterBOOT v7 bootet; Commit 36834ea3 sagt nein für NOR (bisheriger Weg), Wiki verlangt Downgrade auf v6. Gilt das auch für den hEX (ramips)?
- MikroTik: LED-Stufen beim Reset-Halten sind aus der allgemeinen MikroTik-Doku; Geräte ohne passende LED (z. B. SXTsq) nicht einzeln belegt.
- TP-Link WR902AC v4: echter Recovery-Dateiname (tp_recover.bin oder tp_recovery.bin).
- TP-Link Archer C20 v5: Wiki-Abschnitt "Installation" nennt ein fertiges ...squashfs-tftp-recovery.bin, OpenWrt baut für v5 aber nur sysupgrade (mt76x8.mk am Pin); vermutlich vom v4 kopiert.
- TP-Link Archer C20 v1: welches Image hinter den U-Boot-Teil gehört (Commit: factory, das es nicht mehr gibt; Wiki: 19.07.6-factory); bleibt wie im Feld weg [abgeleitet].

Lizenz dieser Datei: CC BY-SA 4.0.
