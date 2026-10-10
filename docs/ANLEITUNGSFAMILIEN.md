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

Lizenz dieser Datei: CC BY-SA 4.0.
