# Anleitungsfamilien: Rechercheergebnisse

Grundlage für die Installationsanleitungen (eine je Anleitungsfamilie, siehe
[ERSTINSTALLATION-2025.1.md](ERSTINSTALLATION-2025.1.md), Abschnitt "Spalten").
Je Familie: gemeinsamer Ablauf, beste Quellen, Abweichungen. Die Werte je Gerät
stehen in [`data/geraete-2025.1.json`](../data/geraete-2025.1.json) (Felder
`taste`, `zeichen`, `rechner`, `verwechslung`, `stock_bedingung`, `dauer`,
`rueckweg`). Recherchiert in vier Teilen am 10.10.2026, nichts auf Hardware
geprüft.

Belegmarken: **[geprüft: …]** nur für Quellen im Original (Commit, Makefile,
DTS, Skript am Pin, Herstellerdoku, Projekt-README). **[Wiki-Zusammenfassung: …]**
heißt: Das OpenWrt-Wiki (bzw. ein anderes Wiki) ließ sich nur über eine
Zusammenfassung lesen, nicht im Rohtext; das ist schwächer als "geprüft" und
vor einer Anleitung am Original nachzulesen (Wunsch Content, 10.10.2026).
**[abgeleitet: …]** ist eigener Schluss oder Analogie. **[Forum-Zusammenfassung: …]** wie Wiki-Zusammenfassung, Quelle ein Forum. "Widersprüche zu vorhandenen Feldern" sind nicht eingearbeitet, sondern
zur Klärung gesammelt.

## Teil A: k0-webui und image-auf-datentraeger

Stand 10.10.2026, 99 Geräte.
Hinweis zu den Belegmarken: Das OpenWrt-Wiki ließ sich nur per WebFetch lesen
(Botsperre gegen curl). WebFetch liefert eine Zusammenfassung durch ein Hilfsmodell,
keinen Rohtext. "[Wiki-Zusammenfassung: ...]" heißt also "so in der Wiedergabe der Wiki-Seite
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
  [geprüft: archer_c7, tl-wr1043nd, tl-wr842nd, tl-wr902ac_v1, cpe510; Wiki-Zusammenfassung: archer-c5-c7-wdr7500]
  - Pharos: höchstens 68 Zeichen. [Wiki-Zusammenfassung: cpe510]
  - Archer A7 v5: Umbenennen nicht nötig. [Wiki-Zusammenfassung: archer_a7_v5]
- Während des Schreibens nicht ausschalten und nicht neu laden. Bei TP-Link löscht der
  Bootloader vorher den ganzen Flash. [Wiki-Zusammenfassung: archer-c5-c7-wdr7500]
  - Dauer meist 1 bis 5 Minuten. Bei Repeatern (RE200) bis 20 Minuten. [Wiki-Zusammenfassung: je Gerät]
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
  - [geprüft: nanopi_r2s, openwrt_x86; Wiki-Zusammenfassung: raspberry_pi, FriendlyElec-Wiki]
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
| netgear-wndr3700, -v2, wndr3800(ch), netgear-wndr4300, netgear-nighthawk-x4s-r7800, netgear-wax220 | weg | "[abgeleitet: Commit ohne Anleitung / Image-Rezept]" | Wiki beschreibt den Web-Upload des factory.img ausdrücklich, könnte also [Wiki-Zusammenfassung: OpenWrt-Wiki] werden | Wiki toh/netgear/wndr3700, wndr3800, wndr4300, r7800, wax220 |
| tp-link-tl-wdr3600-v1, tl-wdr4300-v1, archer-c25-v1, archer-c5-v1, tl-wr1043nd-v2..v4, tl-wr2543n-nd, tl-wdr4900-v1 | weg | "[abgeleitet: Commit ohne Anleitung]" | Wiki beschreibt den Web-Upload, könnte [Wiki-Zusammenfassung: OpenWrt-Wiki] werden | Wiki je Gerät |

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
- Stock-Firmware nimmt nur von Cudy signierte Images; daher erst Cudys signiertes OpenWrt ("Zwischenfirmware", "intermediate firmware"), dann Gluon-**sysupgrade** ohne "Einstellungen behalten" [geprüft: Commits, Neanderfunk-Notizen]
- Cudy-Oberfläche http://192.168.10.1, Passwort admin (AP1300 Outdoor: 192.168.10.254) [geprüft: Neanderfunk-Notiz, Commit c6e59d06]; Menü Erweiterte Einstellungen > System > Firmware; MD5 nach dem Hochladen mit der Tabelle vergleichen [geprüft: Neanderfunk-Notiz]
- danach LuCI http://192.168.1.1, Passwort leer, System > Backup / Firmware Update, Haken "Einstellungen beibehalten" weg [geprüft: Neanderfunk-Notiz, Commit M3000 v2]
- nur solange die Cudy-Originaloberfläche läuft [geprüft: Cudy-FAQ]
- Seriennummer ab 2543 (Woche 43/2025, neuer Flash F50L1G41LC): betroffen AP3000 Outdoor 1.0, AP3000 Wall 1.0, M3000 1.0/2.0, TR3000 1.0, WR3000E/H/S/P 1.0; nur Zwischenfirmware vom 19.11.2025 oder neuer, sonst startet das Gerät nicht mehr; OpenWrt braucht >= 24.10.5, am Gluon-2025.1-Pin ist der Treiber-Backport (422-...F50L1G41LC) drin [geprüft: Cudy-FAQ, OpenWrt-Pin a1ea57bd]
- Rückweg für alle: Cudy-Firmware als recovery.bin, Rechner 192.168.1.88, Reset halten beim Einschalten, LEDs schnell blinkend = Übertragung, langsam = fertig; TR1200 über WAN statt LAN [geprüft: Cudy-FAQ Recovery]; Cudy beschreibt das nur für Windows mit tftp32 und abgeschalteter Firewall [geprüft: dieselbe Seite]

Quellen:
- Neanderfunk-Notizen
- https://www.cudy.com/blogs/faq/openwrt-software-download (Flash-Hinweis, Bedingung Cudy-Oberfläche)
- https://www.cudy.com/en-us/blogs/faq/how-to-recovery-the-cudy-router-from-openwrt-firmware-to-cudy-official-firmware (Rückweg, LEDs)
- Spiegel https://firmware.ffnef.de/other/Cudy_Intermediary_OpenWRT_Firmware-20251124/

Abweichungen:
- M3000: zwei Images nach WAN-PHY (rtl8221b / yt8821), Unterscheidung im Cudy-Systemprotokoll [geprüft: Commit 45b51eba]
- WR3000U: nicht im Spiegel, Zwischenfirmware nur im Cudy-Google-Drive [geprüft: Commit]
- AP1300 Outdoor, AP3000 Outdoor/Wall: nur PoE-Versorgung
- WR1300 v1, X6 v1: in LuCI ggf. "Force upgrade" nötig [geprüft: Commit]
- WR3000 v1: Spiegel-Ordner "without_recovery_TFTP"
- TR1200 v1, AP1300 Outdoor: nicht in Neanderfunk-Notiz; Zwischenfirmware liegt im Spiegel (TR1200_V1/TR1200-OpenWRT-Flash.bin, AP1300_Outdoor_V1.0/...flash.bin)

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
- Cudy M3000 YT8821: ob die Zwischenfirmware M3000_1.0_2.0 zur YT8821-Variante passt (schon in Neanderfunk-Notiz offen).
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

## Teil B: ap51-flash, GL.iNet, Netgear NMRP, Ubiquiti, devolo, TP-Link EAP, SSH, Recovery-Web, D-Link

Stand 10.10.2026. Felder je Gerät in B.json. Belegmarken: [geprüft: ...] = in
Commit/DTS/Image-Rezept/Herstellerdoku gelesen, [abgeleitet: ...] = Wiki,
Analogie, eigener Schluss.

### ap51-flash (26 Geräte: OpenMesh A40/A42/A60/A62, MR600/MR900/MR1750, OM2P*, OM5P*, Plasma Cloud PA300/PA300E/PA1200/PA2200)

Gemeinsamer Ablauf:
- Rechner per LAN-Kabel direkt (oder über einen einfachen unmanaged Switch) mit dem Gerät verbinden, Gerät bleibt aus [geprüft: ap51-flash-Doku getting-started].
- ap51-flash mit root-/Administratorrechten starten: `sudo ./ap51-flash <interface> <gluon-factory>.bin`; keine feste IP nötig, aber keine aus 192.168.1.0/24, 192.168.99.0/24, 192.168.100.0/24; kein anderer TFTP-Server [geprüft: ap51-flash-Doku].
- Erst danach Gerät einschalten; keine Taste: Open Mesh/Plasma Cloud fragen bei jedem Start nach ap51-flash [geprüft: ap51-flash-Doku].
- Fortschritt nur am Rechner sichtbar: "device type ... detected", "image successfully transmitted - writing image to flash", "flash complete. Device ready to unplug." [geprüft: ap51-flash-Doku].
- Zwischen "image successfully transmitted" und "flash complete" nicht Strom ziehen [geprüft: ap51-flash-Doku]. Dauer laut Schätzformel 10 s + 1 s je 64 KiB, ath79 (7 MB Partition) höchstens etwa 2-3 min, ipq40xx (15 MB) höchstens etwa 4-5 min [abgeleitet].
- Datei: das Gluon-factory (Open-Mesh-"CE"-Container), nicht das sysupgrade [geprüft: ap51-flash-Doku "Which image file to use"; OpenWrt generic.mk `openmesh-image ce_type=...`].
- Notweg (nicht für Laien): serielle Konsole, U-Boot, initramfs per TFTP (Server z. B. 192.168.1.21, Gerät 192.168.1.1), dann sysupgrade [geprüft: Commits der ath79-Geräte].

Beste Quellen:
- https://ap51-flash.readthedocs.io/en/latest/getting-started/ (Repo docs/getting-started/index.rst, Stand 3c80049, 03.10.2026)
- https://ap51-flash.readthedocs.io/en/latest/how-it-works/ (Dauer-Schätzformel, Adressen)
- OpenWrt-Commits der Geräte (Feld quelle), target/linux/{ath79,ipq40xx}/image/generic.mk am Pin (CE-Typen)

Abweichungen:
- CE-Typ entscheidet, welches Image der Bootloader annimmt; mehrere Modelle teilen sich einen Typ: OM2P = OM2P v1/v2/v4 + OM2P-HS v1-v4 + OM2P-LC; A60 = A40 + A60; MR600/MR900/MR1750 je v1+v2; OM5P = OM5P + OM5P-AN; OM5PAC = OM5P-AC v1+v2; PA300 = PA300 + PA300E [geprüft: generic.mk]. Ein Image der falschen Revision wird also nicht abgewiesen: Typenschild genau lesen [abgeleitet]. Eigene Typen: A42, A62, PA1200, PA2200.
- A42, A62: nur PoE-Versorgung (Ethernet 1: 802.3af bzw. bei A62 802.3at; Ethernet 2: passiv 18-24 V) [geprüft: Commit].
- OM2P v2: zum Flashen die Ethernet-Buchse nahe der Stromversorgung [abgeleitet: Wiki toh/openmesh/om2p].
- PA300E steht nicht in der ap51-flash-Testliste, nutzt aber ce_type=PA300 [geprüft: generic.mk].
- Rückweg (OM2P-Familie): Herstellerfirmware wieder per ap51-flash/Open-Mesh-Tool [abgeleitet: Wiki].

### glinet (22 Geräte)

Gemeinsamer Ablauf (U-Boot-Weboberfläche, bei allen GL.iNet als Weg oder Notweg):
- Gerät aus, Rechner per Kabel an einen LAN-Port, alle anderen Ports frei [geprüft: GL-Doku debrick].
- Rechner feste IP 192.168.1.2, Netzmaske 255.255.255.0 [geprüft: GL-Doku].
- Reset-Taste fest drücken und gleichzeitig Strom einstecken; halten, bis das LED-Muster wechselt (je Modell 3x, 4x, 5x oder 6x Blinken), dann loslassen [geprüft: GL-Doku, Tabelle je Modell].
- Browser auf http://192.168.1.1, Datei wählen, "Update firmware"; VPN/Proxy am Rechner aus [geprüft: GL-Doku].
- Etwa 3 Minuten warten, nicht Strom ziehen [geprüft: GL-Doku].
- Datei: meist das Gluon-sysupgrade (GL-U-Boot nimmt NOR-sysupgrade), AP1300 das factory (.ubi), XE300/E750 brauchen ein factory.img [geprüft: Commits].
- Alternative bei vielen: Stock-Firmware ist ein GL.iNet-OpenWrt (Oberfläche 192.168.8.1), dort Gluon-sysupgrade hochladen, Einstellungen NICHT behalten [geprüft: Commits AR300M-Lite, AR750, USB150, MT2500, microuter/VIXMINI, MT300N-V2].

Beste Quellen:
- https://docs.gl-inet.com/router/en/4/faq/debrick/ (LED-Tabelle je Modell, Stand 12.08.2026)
- OpenWrt-Commits (Feld quelle), Wiki toh/gl.inet/{6416,gl-ar150,gl-ar300m,gl-mt3000,gl-mt6000,gl-usb150}

Abweichungen:
- LED beim U-Boot: MT300A/MT300N 3x; B1300 4x (alte B1300 5x), Commit sagt "bis drei LEDs dauerhaft leuchten"; AR150/AR300M/AR750/AR750S/USB150/microuter/MT300N-V2 5x; AP1300 5x langsam, dann dauernd schnell; MT1300 blau, dann weiß; MT2500 5x blau, dann weiß; MT3000/MT6000 6x blau, dann weiß; XE300 LAN-LED 5x (Reset UND Power-Taste); E750 Display "Please Open Web 192.168.1.1" [geprüft: GL-Doku].
- 6416: grün-rot-grün, beim roten Blinken loslassen [abgeleitet: Wiki]. MT750: in keiner Quelle, vermutlich wie MT300A [abgeleitet].
- MT6000: U-Boot-Weg nicht über LAN 1 [geprüft: GL-Doku]; nur sysupgrade, nie factory [abgeleitet: Wiki].
- B1300: sysupgrade laut Commit (2017) in `lede-gl-b1300.bin` umbenennen, TFTP-Server 192.168.1.2 wird automatisch abgefragt [geprüft: Commit 04d3308].
- microuter-N300/VIXMINI: Stock-Oberfläche nur per WLAN, Ethernet-Port ist WAN [geprüft: Commits].
- E750: GL-Firmware 3.100 nur per U-Boot [geprüft: Commit 68ac3f2].
- AR300M-Familie: Ende 2024 noch Geräte mit altem U-Boot, das neue Images ablehnen kann [abgeleitet: Wiki].
- Rückweg: XE300 Stock per U-Boot [geprüft: Commit]; MT6000 GL-sysupgrade [abgeleitet: Wiki]; generell GL-U-Boot nimmt die "U-Boot compatible firmware" von GL.iNet [abgeleitet: GL-Doku].

### netgear-nmrp (15 Geräte)

Gemeinsamer Ablauf:
- nmrpflash besorgen (Linux, macOS, Windows mit Npcap "WinPcap Compatibility") [geprüft: nmrpflash-README].
- Rechner per LAN-Kabel direkt an den LAN-Port des Geräts (oft blau; bei mehreren den mit "1"); Firewall aus [geprüft: README].
- Gerät AUS, `nmrpflash -i <interface> -f <gluon-factory>` starten; bei "Waiting for Ethernet connection" Gerät einschalten (manche Geräte brauchen dabei die Reset-Taste) [geprüft: README].
- IPs vergibt nmrpflash selbst (10.164.183.252/253); bei Problemen Rechner fest 10.164.183.253 [geprüft: README, Orbi-Commit].
- Nach "Uploading ... OK" schreibt das Gerät ("Waiting for remote to respond", Keep-alive); nicht Strom ziehen bis "Reboot your device now." [geprüft: README]; Dauer meist Minuten, bis 15 min und mehr berichtet [geprüft: README].
- Viele Modelle nehmen das Gluon-factory auch in der Netgear-Weboberfläche (EX*, EAX12, WAX202, WAX206, R6220, R6260) [geprüft: Commits; Wiki-Zusammenfassung: R6220/R6260 Wiki].

Beste Quellen:
- https://github.com/jclehner/nmrpflash (README)
- OpenWrt-Commits (Feld quelle), ramips-Image-Rezepte am Pin; Wiki toh/netgear/r6220, r6260

Abweichungen:
- R6020, R6120: nur nmrpflash; R6020 an LAN-Port 1, nach Ende einmal aus/an [geprüft: Commits].
- Orbi RBR50/RBS50/SRR60/SRS60: Gluon nur auf Boot-Partition 1; Netgear-Oberfläche schreibt in die andere -> nmrpflash, Kabel am Port nahe der Ein/Aus-Taste; oder Telnet-Umweg `artmtd -w boot_part 02` [geprüft: Commit 2cb24b3].
- EX6150: Netgear-Oberfläche unter 192.168.1.250 [geprüft: Commit].
- WAX202/EAX12: Stock nimmt nur verschlüsselte Images, Gluon-factory ist verschlüsselt (NETGEAR_ENC_REGION US) [geprüft: Commit, mt7621.mk].
- R6260: LAN 1 nächst WAN; Downgrade-Rückfrage in der Oberfläche bestätigen [abgeleitet: Wiki].
- Verwechslung: EX3700=EX3800 (ein Image), EX6130 gleiche Platine aber eigenes Image; EAX12=EAX11 v2=EAX15 v2; R6020 vs R6080; R6260/R6350/R6850 gleiche Platine; RBR50 v1 vs v2; EX6150 v1 vs v2; WNDR3700 v5 vs v1-v4.
- Rückweg: Netgear-Image per nmrpflash (Orbi, R6220 geprüft; EAX12/WAX202/WAX206 "TFTP/NMRP" geprüft; R6260 Wiki).

### ubiquiti-unifi-ssh (15 Geräte)

Gemeinsamer Ablauf:
- Gerät im Werkszustand per PoE (Injektor oder PoE-Switch) versorgen, Rechner per Kabel daran [geprüft: Commit U6+; übrige abgeleitet].
- Rechner feste IP aus 192.168.1.0/24, nicht .20 (Commit U6+: 192.168.1.2) [geprüft: Commit 75ee554].
- `ssh ubnt@192.168.1.20`, Passwort ubnt; Gluon-sysupgrade per `scp -O` nach /tmp [geprüft: Commits bf94e0a, 4c8446b, 4e46beb, 634c13c].
- je nach Modell Schreibschutz aufheben (`echo 5edfacbf > /proc/ubnthal/.uf`), bootselect-Flag nullen, Image per `dd` in kernel0 (und kernel1) schreiben; Partitionsnummern vorher in /proc/mtd prüfen [geprüft: Commits].
- Neustart; erster Start dauert einige Minuten (AC-Reihe etwa 2 min, U6 LR etwa 4 min) [abgeleitet: Wiki].
- Rückweg: Ubiquiti-TFTP-Recovery (Reset beim Einschalten etwa 15 s, LED weiß/blau/aus, `tftp put` an 192.168.1.20) [abgeleitet: Wiki unifiac; AC HD geprüft: Commit].

Beste Quellen:
- OpenWrt-Commits (Feld quelle), v. a. bf94e0a (UK Ultra), 634c13c (U6 LR), fb4d7a9 (U6 Lite), 75ee554 (U6+), 4c8446b (nanoHD), 4e46beb (AC HD)
- https://openwrt.org/toh/ubiquiti/unifiac (AC-Reihe: Stock-Versionen, LED)
- https://openwrt.org/toh/ubiquiti/unifi_6_lr (v1/v2/v3, Stock 6.2+)
- https://openwrt.org/toh/ubiquiti/unifi_6_lite, unifi_6_plus

Abweichungen / Stock-Versionen:
- nanoHD: Anleitung für Stock v3.9.27, sonst downgraden [geprüft: Commit].
- AC-Reihe: 3.7.58 bevorzugt (mtd vorhanden), ab 6.5.28 nur dd; .uf-Entsperren scheitert bei manchen Versionen still [abgeleitet: Wiki].
- U6 Lite: ab Stock 6.5 auf 6.0.14 downgraden [abgeleitet: Wiki]; zusätzlich `fw_setenv devmode TRUE` usw. [geprüft: Commit].
- U6 LR: ab Stock 6.2 .uf-Entsperren nötig, steht nicht im Commit [abgeleitet: Wiki].
- U6+: eMMC, kernel/root aus dem sysupgrade-tar per dd, getestet bis Stock 6.6.55 [geprüft: Commit; Version abgeleitet: Wiki].
- AP Outdoor+: `fwupdate.real -m <datei> -d` statt dd [geprüft: Commit].
- Verwechslung: U6 LR v1 (RGB-LED-Leiste) / v2 (zwei LEDs) / v3 (RTL8211FS-PHY, ab etwa KW 34/2022); AC Lite = AC LR = AC Mesh (Hardware, eigene Images); AC Pro = AC Mesh Pro (bis auf USB); U6 Lite vs. U6 IW/Mesh/Extender/LR-EA (alle MT7621).
- Werkszustand nötig: adoptierte Geräte haben Controller-Zugangsdaten [abgeleitet].

### ubiquiti-tftp (4 Geräte: NanoStation M XW, NanoStation Loco M XW, Rocket M XM, UniFi AP Pro)

Gemeinsamer Ablauf:
- Rechner feste IP aus 192.168.1.0/24, nicht .20 (Commits: .21/.25) [geprüft: Commits 633c430, 40530c8].
- Reset (am Gerät oder am PoE-Netzteil) gedrückt halten, Strom per PoE anstecken, halten bis die Signal-LEDs abwechselnd blinken (LED1+3 / LED2+4; bis zu 25 s), loslassen [geprüft: Commits].
- Gerät ist jetzt TFTP-Server auf 192.168.1.20: `tftp 192.168.1.20`, `binary`, `put <gluon-factory>.bin` [geprüft: Commits].
- Gerät schreibt und startet neu; nicht Strom ziehen, solange die LEDs laufen [abgeleitet: Wiki ubiquiti_tftp]; UniFi AP Pro etwa 2 min [geprüft: Commit b7da0d2].
- Dateiname: keine Quelle verlangt einen bestimmten; kurzer Name mit .bin [abgeleitet].
- Rückweg: gleicher Weg mit AirOS-Image [abgeleitet: Wiki ubiquiti_tftp].

Beste Quellen:
- OpenWrt-Commits 633c430 (Loco M XW), 40530c8 (NanoStation M XW), b7da0d2 (UniFi AP Pro)
- https://openwrt.org/docs/guide-user/installation/recovery_methods/ubiquiti_tftp
- https://openwrt.org/toh/ubiquiti/common (XM/XW, AirOS-Versionsgrenzen)

Abweichungen:
- XW: OpenWrt-Installation laut Wiki nur bis AirOS 6.0.4; neuere XW-Revisionen nur über XW.v6.1.7.32555 + fwupdate.real [abgeleitet: Wiki common]; ob das auch den TFTP-Weg betrifft: offen.
- XM (Rocket M XM): mit AirOS 5.6+ erst auf 5.5 zurück, sonst nicht flashen [abgeleitet: Wiki common].
- UniFi AP Pro: Reset 10 s beim Einstecken [geprüft: Commit].

### ubiquiti-edgerouter (2 Geräte: ER-X, ER-X-SFP)

Gemeinsamer Ablauf:
- Rechner an eth0, feste IP 192.168.1.x; EdgeOS unter 192.168.1.1, Login ubnt/ubnt [abgeleitet: Wiki; Bestand uebertragung].
- OpenWrt-initramfs-factory.tar (Fremdquelle, OpenWrt baut es nicht mehr) über Web-UI "System" oder `add system image` einspielen, neu starten [abgeleitet: Wiki; Bestand weg geprüft].
- Danach OpenWrt auf eth1, root@192.168.1.1 [abgeleitet: Wiki].
- OpenWrt-sysupgrade (alt), dann Migration auf das 24.10-Layout (darkxst/erx-migration), dann Gluon [abgeleitet: Wiki; Neanderfunk-Notiz laut Bestand].
- Notweg seriell: U-Boot-Menü "1", TFTP nur an eth0, 57600 Baud [abgeleitet: Wiki; Bestand seriell].

Beste Quellen:
- https://openwrt.org/toh/ubiquiti/edgerouter_x_er-x_ka
- Commits 4e31b2e, 9715beb

Abweichungen:
- ER-X-SFP: ER-X-factory geht, danach sysupgrade mit `--force`; Einzelbericht: EdgeOS 2.0.9 -> 2.0.3 -> OpenWrt 18.06-factory [abgeleitet: Wiki].
- Wiki empfiehlt vorher neueste EdgeOS v2 + Bootloader-Update (TFTP-Recovery per Reset) [abgeleitet].

### devolo-ssh (6 Geräte: WiFi pro 1200e/1200i/1750c/1750e/1750i/1750x)

Gemeinsamer Ablauf:
- Stock-Weboberfläche öffnen (laut Wiki 192.168.1.1) und beim ersten Einrichten das root-Passwort setzen [geprüft: Commits; Adresse abgeleitet: Wiki].
- Gluon-sysupgrade per scp nach /tmp, Benutzer root mit diesem Passwort [geprüft: Commits].
- `sysupgrade -n -F /tmp/<datei>` [geprüft: Commits].
- Danach: blaue Status-LED = läuft, rote = Upgrade/Failsafe; 1750x nur rot [geprüft: DTS].

Beste Quellen: OpenWrt-Commits (Feld quelle, alle mit gleichem Installationstext); Wiki toh/devolo/wifi_pro_1750e.

Abweichungen: 1750e danach an LAN 2 (PoE) [abgeleitet: Wiki]. Keine Taste, keine Stock-Versionsgrenze in den Quellen.

### tplink-eap-ssh (5 Geräte: EAP225-Outdoor v1/v3, EAP225-Wall v2, EAP613 v1, EAP615-Wall v1)

Gemeinsamer Ablauf:
- Gerät per PoE versorgen, Stock-Weboberfläche öffnen, SSH einschalten [geprüft: Commits EAP613/EAP615].
- `ssh admin@<geräte-ip>` (ohne DHCP 192.168.0.254; alte SSH-Algorithmen freischalten) [abgeleitet: Forum/Suchergebnis].
- `cliclientd stopcs` ausführen (schaltet die Signaturprüfung ab, Antwort "Success.") [geprüft: Commits; Wirkung abgeleitet].
- Gluon-factory in der Weboberfläche als Firmware-Update hochladen, ggf. Dateinamen kürzen (z. B. `factory.bin`) [geprüft: Commits; Kürzen Commit EAP613].
- Debrick/Rückweg nur seriell mit Gehäuseöffnen und Löten [geprüft: Commits].

Beste Quellen: OpenWrt-Commits 4f86edf, 7e4de89, c9f51a9, 11588c5, a1b8a4d.

Abweichungen: EAP225-Outdoor braucht Stock ab v1.6.0, EAP225-Wall v2 "aktuelle" (getestet 1.20.0) [geprüft: Commits]; EAP225-Outdoor v1 vs v3 (AR8033 vs RTL8211FS).

### ssh-stock (3 Geräte: 8devices Jalapeno, VoCore2, Xiaomi MiWiFi Mini)

Kein gemeinsamer Ablauf außer "Stock-Firmware ist (fast) OpenWrt, per SSH/Telnet sysupgrade":
- Jalapeno: altes LEDE ab Werk, `sysupgrade -n -F`; alte U-Boots: "FIT configuration not found" -> U-Boot-Umgebung anpassen [geprüft: Commit 1e341bb].
- VoCore2: Ethernet oder WLAN "VoCore2", `ssh root@192.168.1.1` (vocore), `sysupgrade -n`; danach WLAN aus [geprüft: Commit 3f31029].
- MiWiFi Mini: telnetd per Code-Injection in der Stock-Oberfläche (dokumentiert für Stock v2.6.17, v2.7.11, v2.8.91, v2.2.105), Rückweg/Downgrade per USB-Stick `miwifi.bin`, orange LED -> blau [abgeleitet: Wiki toh/xiaomi/miwifi_mini].

### recovery-web (8 Geräte: ALFA AP121F, Joy-IT JT-OR750i, Onion Omega, RAVPower RP-WD009, Teltonika RUT230 v1, Wavlink WS-WN572HP3 4G, ZBT WG3526 16M/32M)

Gemeinsamer Ablauf (Bootloader-Webseite, Adressen je Gerät verschieden):
- Rechner per Kabel, feste IP im Netz der Recovery (Ausnahme Joy-IT: DHCP) [geprüft: Commits].
- Reset beim Einstecken des Stroms halten, bis ein Gerätezeichen kommt (Blinkmuster/LED), loslassen [geprüft: Commits AP121F, RP-WD009, RUT230, Wavlink].
- Recovery-Seite im Browser öffnen, Image hochladen; je nach Gerät sysupgrade (AP121F, Joy-IT, Wavlink) oder factory (RP-WD009, RUT230, Onion) [geprüft: Commits].
- Gerät schreibt und startet selbst neu (RP-WD009 etwa 1 min, Wavlink etwa 2 min) [geprüft: Commits].

Adressen und Zeichen je Gerät:
| Gerät | Recovery | Rechner | Taste/Zeichen | Beleg |
| --- | --- | --- | --- | --- |
| AP121F | 192.168.1.1 | 192.168.1.2/24 | erstes Blinken aller LEDs, dann 3 weitere | ar71xx-Commit 0c6165d |
| JT-OR750i | 10.123.123.1 | DHCP | ab Werk nur Bootloader, keine Taste; TFTP-Notweg: Server 192.168.0.66, Datei `jt-or750i_firmware.bin`, Reset 4 s/6 s | Commit 55b4b36 |
| Onion Omega | 192.168.1.1 | 192.168.1.2/24 | Taste nicht genannt; Normalweg SSH root/onioneer | Commit d98738b |
| RP-WD009 | 10.10.10.128 | 10.10.10.1/24 | Reset +10 s bis Globus-LED leuchtet | Commit e959048 |
| RUT230 v1 | 192.168.1.1 | 192.168.1.10/24 | Signal-LEDs 3x | Commit 6cf1dfd |
| WS-WN572HP3 4G | 192.168.10.1 | 192.168.10.x [abgeleitet] | Reset 10 s | Commit dce6689 |
| ZBT WG3526 | 192.168.1.1 | [nicht belegt] | Reset ~10 s, chinesische Recovery-Seite | Wiki wg2626 [abgeleitet] |

Browser: Wavlink nur Chromium (Firefox 106 nicht), Joy-IT umgekehrt "Firefox nehmen, wenn es nicht geht" [geprüft: Commits].

### dlink-recovery-web (6 Geräte: AQUILA PRO AI M30/M60, DAP-1620 B1, DAP-X1860, DIR-878, DIR-882)

Gemeinsamer Ablauf:
- Rechner feste IP im Recovery-Netz, kein DHCP: M30/M60 192.168.200.x (Recovery .1), DAP 192.168.0.65 (Recovery .50), DIR 192.168.0.2 (Recovery .1) [geprüft: Commits; Neanderfunk-Notizen].
- Reset mit Büroklammer halten, Strom einstecken, halten bis die LED blinkt (AQUILA: rot; DIR: Power-LED orange, etwa 10 s) [geprüft: Commits].
- Erreichbarkeit per HTTP prüfen, nie per Ping (Recovery antwortet nicht auf ICMP) [geprüft: Neanderfunk-Notiz].
- Hochladen per curl: `curl -H "Expect:" -F "firmware=@<image>;type=application/octet-stream" http://<recovery-ip>/upload.cgi` (DIR-Commits: `curl -v -i -F "firmware=@<datei>" 192.168.0.1`); Browser nur Chromium-basiert [geprüft: Commits, Neanderfunk-Notiz].
- Erfolgsmeldung/Fortschritt der Seite ist ein JavaScript-Timer (80 s), fertig erst, wenn die neue Firmware bootet; kann über 10 min dauern, nicht abbrechen [geprüft: Neanderfunk-Notiz, M60 gemessen].
- AQUILA/DAP-X1860: OpenWrt-Image als Zwischenschritt, dann Gluon-sysupgrade über 192.168.1.1 [geprüft: Neanderfunk-Notiz].

Beste Quellen:
- OpenWrt-Commits 29cca6c (M30), 7271ee5 (M60), e4c7703 (DAP-1620 B1), 3c31f6b (DAP-X1860), d7233b0 (DIR-878), 73e8f23 (DIR-882)
- Neanderfunk-Notizen (Neanderfunk, erste Hand am M60)

Abweichungen:
- AQUILA M30/M60: zwei UBI-Partitionen, Recovery schreibt in die aktive, OpenWrt bootet nur aus der ersten; M60: UBI-Switch-Image, M30: OEM-Umweg [geprüft: Commits]. Mehrfach-Pack-Geräte (M60-2, M30/CP): MAC-Lage anders, eigener Odm-Parser [geprüft: Notiz].
- DIR-878/882: laut Commits Web-Recovery auf 192.168.0.1 mit curl-Alternative; Neanderfunk-Notiz sagt "DIR-Reihe über TFTP im U-Boot" (Widerspruch, siehe unten).
- DAP-X1860: Commit sagt factory.bin in die Recovery, Neanderfunk-Notiz OpenWrt-initramfs (Widerspruch, steht schon im Bestand).
- Rückweg: entschlüsselte D-Link-Firmware per Recovery (M30, DAP-1620, DAP-X1860; Befehle im Commit) [geprüft: Commits].

### Widersprüche zu vorhandenen Feldern

Nicht korrigiert, nur gelistet.

| Gerät | Feld | alt | neu | Quelle |
| --- | --- | --- | --- | --- |
| gl.inet-gl-mt2500 | weg/uebertragung | weg: "U-Boot-Recovery nimmt laut Commit keine Images"; uebertragung nennt recovery-web [abgeleitet] | GL-Doku debrick führt MT2500/MT2500A mit LED-Muster (5x blau, dann weiß) für die U-Boot-Recovery; ob sie OpenWrt/Gluon annimmt, bleibt offen | GL-Doku debrick vs. Commit 1239668 |
| gl.inet-gl-b1300 | weg | "bis drei LEDs leuchten" [geprüft: Commit] | stimmt mit Commit; GL-Doku heute: WLAN-LED 4x, dann Mesh-LED an (alte B1300: 5x) | GL-Doku debrick |
| gl-mt300a, gl-mt300n, gl-mt750 | weg | "Reset beim Einstecken mind. 3 s halten" [abgeleitet: Wiki] | GL-Doku: halten bis die LED 3x geblinkt hat (MT300A/MT300N; MT750 nicht genannt) | GL-Doku debrick |
| gl.inet-gl-ap1300 | weg | "Reset 10 s, bis die Power-LED schneller blinkt" | ergänzt: GL-Doku "5x langsam, kurz an, dann dauernd schnell"; kein Widerspruch, nur genauer | GL-Doku debrick |
| gl.inet-gl-mt6000 | uebertragung | "recovery-web (GL.iNet-U-Boot, Reset beim Einschalten) [abgeleitet]" | U-Boot-Weg bestätigt, aber nicht über LAN 1 (GL-Doku); Wiki: dort das sysupgrade | GL-Doku, Wiki toh/gl.inet/gl-mt6000 |
| netgear-r6120 | weg | "Web-UI laut Commit nicht [geprüft]" | Commit 5543d63 sagt nur "To flash use nmrpflash with the provided factory.img", nichts über die Web-UI (anders als R6020: "requires nmrpflash") | Commit 5543d63 |
| ubiquiti-unifi-6-lr-v1/v2/v3 | weg | "SSH (ubnt/ubnt), bootselect nullen, dd nach kernel0/kernel1" ohne Entsperren | Wiki: ab Stock 6.2 vorher `echo 5edfacbf > /proc/ubnthal/.uf`; ältere Stock-Firmware evtl. unter 192.168.1.34 | Wiki toh/ubiquiti/unifi_6_lr |
| ubiquiti-unifi-6-lite | weg | kein Hinweis auf Stock-Version | Wiki: ab Stock 6.5 Downgrade auf 6.0.14 nötig | Wiki toh/ubiquiti/unifi_6_lite |
| ubiquiti-unifi-ac-lite/lr/mesh/mesh-pro/pro | weg | "sysupgrade nach kernel0/kernel1 schreiben" [abgeleitet aus UK Ultra] | Wiki-Weg: `mtd write ... kernel0`, `mtd erase kernel1`, bs nullen; kein echter Widerspruch, nur zweite Variante; Stock 3.7.58 empfohlen | Wiki toh/ubiquiti/unifiac |
| ubiquiti-rocket-m-xm | weg | "Ubiquiti-TFTP-Recovery wie bei den XW-Geräten [abgeleitet]" | Wiki: XM mit AirOS 5.6+ NICHT direkt flashen (Partitionslayout geändert), erst auf AirOS 5.5 zurück | Wiki toh/ubiquiti/common |
| d-link-dir-878-a1, d-link-dir-882-a1 | weg | Bestand nennt schon den Widerspruch Commit (Web-Recovery 192.168.0.1) vs. Neanderfunk-Notiz ("DIR-Reihe über TFTP", ToH: Bootloader TFTP-Server 192.168.0.1, Rechner .101) | Commits d7233b0/73e8f23 beschreiben eindeutig die Web-Recovery mit curl `-F firmware=@...` auf 192.168.0.1; Felder hier nach Commit gefüllt | Commits d7233b0, 73e8f23 |
| d-link-dir-878-a1 | uebertragung | "Rechner 192.168.0.2/24" | bestätigt (Commit); zusätzlich "Kabel an LAN1, etwa 30 s warten bis die Recovery-Seite bereit ist" | Commit d7233b0 |
| d-link-dap-x1860-a1 | weg | factory.bin (Commit) vs. OpenWrt-initramfs (Notiz) | unverändert offen; Gluon baut für den DAP-X1860 kein Recovery-Image (Notiz) | Commit 3c31f6b, Neanderfunk-Notiz |
| d-link-aquila-pro-ai-m30-a1 | uebertragung | "Rechner 192.168.200.10/24" | für den Rückweg nennt der Commit 192.168.200.2; beides im selben Netz, kein echter Widerspruch | Commit 29cca6c |
| joy-it-jt-or750i | uebertragung | "Server 192.168.0.66, Datei jt-or750i_firmware.bin" | bestätigt; Commit: Web-Weg "Use Firefox if flashing does not work" (anders als bei Wavlink/D-Link) | Commit 55b4b36 |
| zbtlink-zbt-wg3526-* | uebertragung | "recovery-web (Adresse ?)" | Wiki wg2626: Recovery-Seite unter 192.168.1.1 (chinesisch), Reset ~10 s beim Einstecken | Wiki toh/zbtlink/wg2626 [abgeleitet] |

### Offen

- ap51-flash: Welche Ethernet-Buchse der Bootloader beim Flashen nutzt, steht nur für OM2P v2 (Wiki); bei Geräten mit Ethernet 1/2 offen
- gl.inet-gl-ar300m-nor: Bootet der OEM-U-Boot das NOR-Gluon, wenn im NAND noch eine Stock-Firmware liegt? Commit 55e6c90: Fallback nur NAND->NOR nach 3 Fehlstarts, Seitenschalter wählt nicht NOR/NAND
- gl.inet-gl-mt2500: Woran man die Airoha-PHY-Revision außen erkennt (Typenschild?), in keiner gelesenen Quelle
- gl.inet-gl-mt3000: Ob der GL-U-Boot das Gluon-sysupgrade annimmt (GL-Doku spricht von "U-Boot compatible firmware")
- gl.inet-gl-usb150: U-Boot-Weg am USB-Stick (Taste beim Einstecken) nicht belegt
- netgear-nmrp: nmrpflash-README widerspricht sich bei den Default-IPs: Usage "-a target [10.164.183.253], -A interface [10.164.183.252]", Fließtext umgekehrt; Orbi-Commit rät Rechner 10.164.183.253. Für die Anleitung nur "vergibt nmrpflash selbst" schreiben
- netgear-eax12, netgear-wax202: Gluon-factory ist mit NETGEAR_ENC_REGION US verschlüsselt; ob eine EU-Stock-Oberfläche es annimmt, nicht belegt (nmrpflash/Bootloader nimmt beides)
- netgear-nmrp: Bei welchen Modellen die Reset-Taste beim Einschalten nötig ist, nennt nmrpflash nicht je Modell
- ubiquiti-unifi-6-lr-v2/v3: Außen sichtbarer Unterschied v2/v3 nur über Produktionsdatum (Wiki); Folge eines falschen Images (vermutlich kein Ethernet) nicht belegt
- ubiquiti-unifi-ap-outdoor+: Welches Image `fwupdate.real` nimmt (factory/sysupgrade), Commit sagt nur "Firmware update"
- ubiquiti-unifi-ap: keine Quelle für den Installationsweg (Commit und Wiki-Seite fehlen)
- ubiquiti-nanostation-*-xw: Gilt die AirOS-Grenze 6.0.4 / Signaturpflicht (6.1.7, neue HW-Revision) auch für den TFTP-Recovery-Weg? Freifunk-Forum-Thread "Ubnt XW/AirOS 6.1.7 nicht auf OpenWRT umflashbar" deutet darauf hin, nicht gelesen
- ubiquiti-edgerouter-x*: Dauer und LED-Zeichen in keiner Quelle; der ganze Weg hängt an Fremd-factory.tar
- tp-link-eap225-outdoor-v3: Forum-Thread "EAP225-outdoor v3 firmware is incompatible" (AddiHardwareVer) nicht gelesen; mögliche Stock-Versions-/Revisionsfalle
- 8devices-jalapeno: IP und Zugangsdaten des Werks-LEDE in keiner Quelle
- tplink-eap-ssh: Stock-Adresse 192.168.0.254 / Login admin nur aus Suchergebnis (Forum), nicht aus Commit oder TP-Link-Doku gelesen
- dlink-recovery-web: DAP-1620 B1: Rechner-IP nicht belegt (192.168.0.65 nur vom DAP-X1860 übertragen)
- zbtlink-zbt-wg3526-*: Rechner-IP für die Recovery und Unterscheidung 16 MB/32 MB von außen nicht belegt
- onion-omega: Taste für die U-Boot-Weboberfläche nicht genannt

## Teil D: seriell + TFTP, Aruba APBoot, Einzelfälle

Stand 10.10.2026. Felder in D.json; hier gemeinsamer Ablauf, Quellen, Abweichungen.

### Familie aruba-apboot (AP-303, AP-303H, AP-365, Instant On AP11D, AP17)

Gemeinsamer Ablauf:
- Konsole: 9600 8N1, 3,3 V. AP-303/303H: Micro-USB-Buchse "Console" ist nur UART-Stecker, eigenes Kabel aus altem Micro-USB-Kabel + USB-TTL-Adapter; nie normales USB-Kabel an den Rechner [geprüft: Commits 102c8c5, c6e972c]. AP-365: echte USB-Konsole (CP2101), normales Kabel [geprüft: Commit 300b7fe].
- Boot unterbrechen: Enter bei "Hit <Enter> to stop autoboot" (Countdown ca. 2 s) [geprüft: Commits; Wiki-Zusammenfassung: Countdown Wiki-Bootlog].
- Rechner: feste IP 192.168.1.75/24, TFTP-Server, OpenWrt- bzw. RAMpe-initramfs als `ipq40xx.ari` [geprüft: Commits]. AP-303H: TFTP nur über Port E0 [geprüft].
- apboot-Variablen setzen, saveenv, `run ramboot_openwrt`; die Meldung "Invalid image format version" nach dem Laden ist normal [Wiki-Zusammenfassung: toh/aruba/ap-303].
- Im initramfs: sysupgrade per scp nach /tmp, `ubidetach`/`ubiformat` der UBI-Partition, `sysupgrade -n` [geprüft: Commits].
- Rückweg: `setenv bootcmd "boot"; saveenv` [geprüft: Commits].

Beste Quellen:
- Commits: https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=102c8c55f217606cdbdc9a449667e034676b3e75 (AP-303), c6e972c8772a628a1a2f2e5590d7c6f4acef9ab0 (AP-303H), 300b7fe85a743ab0e039457a5a551819b49450da (AP-365)
- https://openwrt.org/toh/aruba/ap-303 (Hinweis "Invalid image format version", billige USB-UART-Adapter versagten, DHCP-Variante), https://openwrt.org/toh/aruba/ap-303h (Rückweg mit `upgrade os`), https://openwrt.org/toh/aruba/ap-365

Abweichungen:
- AP-303H/AP11D: TFTP an E0, scp danach an E1-E3; ubiformat /dev/mtd16.
- AP-365/AP17: echte USB-Konsole; Partition mit Label "ubi" nehmen.
- AP11D/AP17: ob das Instant-On-apboot wie beim AP11 gesperrt ist (bootet nur signierte Images), ist nicht belegt.

### Familie seriell-tftp (22 Geräte)

Gemeinsamer Ablauf:
- Konsole anschließen: entweder Cisco-Konsolenkabel am RJ45 "Console" (RS232-Pegel; Enterasys/Extreme/Siemens/Aerohive) oder USB-TTL 3,3 V an Pins/Testpunkten in geöffnetem Gehäuse (Cudy, ZTE, Xiaomi, TP-Link, Sophos AP15, AP3805i). USB-TTL an RS232-Port geht nicht und kann Schaden nehmen [Wiki-Zusammenfassung: toh/aerohive/ap121]. 3V3/VCC-Pin nie anschließen [geprüft: Commits MF281; Wiki-Zusammenfassung: 4A].
- Terminal 115200 8N1, Ausnahme Aerohive 9600 [geprüft: Commits].
- Boot unterbrechen: gerätespezifische Taste im Terminal (Enter, Leertaste, `s`, `t`, ESC, Ctrl-C, Ctrl+B, beliebig), oft nur 1-2 s Zeitfenster; U-Boot-Login bei Enterasys/Extreme admin/new2day, Aerohive `AhNf?d@ta06`/`administrator` [geprüft: Commits].
- Rechner: TFTP-Server mit fester IP laut Gerät (192.168.1.66 bei David-Bauer-Ports, sonst verschieden), Datei mit vorgegebenem Namen; wo `tftpboot` ohne Dateinamen läuft (AP3705i, Siemens), ist der Name (Geräte-IP in Hex, z. B. 1401A8C0.img = 192.168.1.20) zwingend [abgeleitet: U-Boot-Standard].
- Meist: bootcmd auf OpenWrt umstellen + saveenv, initramfs booten, sysupgrade per scp, `sysupgrade -n` [geprüft: Commits]. Xiaomi RA75/4A und TD-W8980/D50 flashen das sysupgrade direkt aus U-Boot.
- Rückweg oft: Stock-bootcmd in Variable boot_flash bzw. eigenes Backup [geprüft: Commits AP3710i/3825i].

Beste Quellen:
- OpenWrt-Commits (Feld quelle), dazu Wiki: https://openwrt.org/toh/aerohive/ap121, https://openwrt.org/toh/aerohive/hiveap-330, https://openwrt.org/toh/extreme_networks/ws-ap3935i, https://openwrt.org/toh/extreme_networks/ws-ap3825i, https://openwrt.org/toh/sophos_red_15w_rev_1, https://openwrt.org/toh/tp-link/td-w8980_v1, https://openwrt.org/toh/zte/mf289f, https://openwrt.org/toh/cudy/tr3000, https://openwrt.org/toh/d-link/dir-505
- Deutschsprachig: Freifunk Aachen zur MF289F: https://freifunk-aachen.de/2025/04/09/installationsanleitung-zte-mf289f/
- Werkzeug für WS-AP3710i: https://github.com/grische/extremeflash (automatisiert Konsole + TFTP)
- EAP620 HD v1: Commits nur auf GitHub (lokal fehlend): https://github.com/openwrt/openwrt/commit/4b6e7da0f7499acb69feaacca79e0ee826c0b8db, https://github.com/openwrt/openwrt/commit/8a15a75e9414bbb839ac457701b041454e89bbc4

Abweichungen (Kurzliste):
- Aerohive: 9600 Baud, Leertaste, Bootloader-Versionsprüfung mit `version`.
- AP3935: beliebige Taste außer `d`; Watchdog/SecImg-Falle.
- AP3915i: Taste `s`. TD-W8980: Taste `t`. MF289F: ESC. MR80X: Ctrl-C. EAP620: Ctrl+B.
- Cudy TR3000: Reset beim Einschalten 5 s, U-Boot-Shell kommt nach gescheiterter OEM-Recovery von selbst.
- Xiaomi RA75/4A: U-Boot-Menü Option 2, schreibt das sysupgrade direkt.
- DIR-505: zusätzlich D-Link-Recovery (Reset, rote LED blinkt) mit altem ar71xx-factory als Weg ohne Seriell.

### Einzelfälle (sonderweg-*, 31 Geräte)

Je Gerät ein Abschnitt: Kern-Ablauf, beste Quelle(n), Besonderheit. Details in D.json.

#### sonderweg-arcadyan-vgv7510kw22
- Ablauf: OpenWrt-U-Boot (nor) über brnboot in den RAM (seriell: 3x Leertaste, `!`, `sx`) oder per Recovery-Web/16-MB-Vollimage, dann U-Boot in NOR, dann sysupgrade per TFTP [Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/arcadyan/vgv7510kw22, Forum-Thread im Feld anleitung.
- Besonderheit: brn- und nor-Images nicht mischbar.

#### sonderweg-aruba-ap-32x
- Ablauf: Stock-APBoot (9600) -> `diag`, gepatchtes APBoot per netget + `sf write`; danach 115200; NAND löschen, UBI ubifs(1 LEB)+rootfs_data; `.ari` per tftpboot; sysupgrade [geprüft: Commit d2a7502].
- Quellen: https://github.com/openwrt/openwrt/commit/d2a75029a5f8e54e1fd2f252f73b9a430a030116, https://openwrt.org/toh/aruba/ap-325, https://github.com/maurerle/ap325-flashtool (automatisiert alles), https://github.com/lukasstockner/ap325-apboot-openwrt
- Besonderheit: AP-324/AP-325/Scalance W1750D gleiches Image.

#### sonderweg-aruba-instant-on-ap11
- Ablauf: wie AP-303, vorher entsperrtes apboot aus gepatchtem SPI-Dump per netget + `sf protect off; sf erase/write 0xf0000 0xf0000` [geprüft: Neanderfunk-Notiz].
- Quellen: Neanderfunk-Notiz, https://github.com/Sc4ndium90/aruba-ap11-openwrt, https://openwrt.org/toh/aruba/ap-303 (AP11-Bootlog).

#### sonderweg-asus-lyra-map-ac2200
- Ablauf: SSH in Stock, initramfs nach /tmp, `mtd-unlock -d linux`, `mtd-write -d linux -i ...`, `reboot -f`, sysupgrade [geprüft: Commit 9ad3967; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/asus/lyra_map-ac2200 (LED-Ablauf blau).

#### sonderweg-asus-rt-ax52
- Ablauf: Stock-Web-UI nimmt `initramfs.trx`, danach sysupgrade; bei Ablehnung Downgrade per ASUS Firmware Restoration [geprüft: Commit; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/asus/rt-ax52

#### sonderweg-asus-rt-ax59u
- Ablauf: Transit-TRX eines Dritten über Stock-Web-UI oder seriell '4' + TFTP `rtax59u.bin` von 192.168.1.70 [geprüft: Commit 782eb05].
- Quelle: https://openwrt.org/toh/asus/rt-ax59u

#### sonderweg-buffalo-wzr-hp-g450h-wzr-450hp
- Ablauf: versteckte Firmware-Seite (bufpy/otdpopy), factory, ca. 200 s [geprüft: Commit 1df1ea4].

#### sonderweg-comfast-cf-ew71-v2
- Ablauf: Stock (OpenWrt-basiert) nimmt sysupgrade; alternativ Recovery-Web (Reset ca. 5 s beim Einstecken, LEDs blinken schnell, 192.168.1.1) [geprüft: Commit ee3a6ad].

#### sonderweg-d-link-dir825b1
- Ablauf laut Wiki: D-Link-Recovery (Reset bis Power-LED orange blinkt, 192.168.0.100 -> 192.168.0.1, alter Browser) mit OpenWrt-23.05.5-factory, dann sysupgrade [Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/d-link/dir-825

#### sonderweg-devolo-dlan-pro-1200+-wifi-ac
- Ablauf: Bootloader-TFTP: Reset beim Einschalten ca. 15 s, Gerät holt `uploadfile` von 192.168.0.100 [geprüft: Commit 624b85e; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/devolo/dlan_pro_1200_wifi_ac

#### sonderweg-genexis-pulse-ex400
- Ablauf: Stock-Web-UI oder U-Boot-Recovery (Reset beim Einschalten, http://192.168.1.1) nimmt factory, dann sysupgrade [geprüft: Commit dd0c283; Wiki-Zusammenfassung: Darmstadt-Wiki].
- Quelle: https://github.com/freifunk-darmstadt/projects/wiki/90-%E2%80%90-Hardware-%E2%80%90-Genexis-EX400 (deutsch, Gluon-bezogen)

#### sonderweg-google-wifi-gale
- Ablauf: Google-Recovery auf Werkszustand, Gehäuse öffnen, Developer-Mode über Reset + SW7, OpenWrt-factory vom USB-Stick booten, per ssh/dd auf die eMMC [Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/google/wifi (genaue LED-Folge, getestete USB-C-Hubs)

#### sonderweg-hewlett-packard-msm460
- Ablauf: Reset beim Verbinden, Befehlsdatei per `tftp put ... nflashd.cccc9999`, Stock-Bootloader holt Fremd-U-Boot und schreibt ihn, danach factory [geprüft: Commit af329ec].
- Quelle: https://github.com/blocktrron/msm460-flashing

#### sonderweg-librerouter-v1
- Ablauf: OpenWrt/LibreRouterOS ab Werk, sysupgrade über Web oder `sysupgrade -n` [geprüft: Commit 24463d0].

#### sonderweg-linksys-e8450-ubi
- Ablauf heute: owrt-ubi-installer-Image über die Stock-Weboberfläche, Bootchain-Backup sichern, sysupgrade [geprüft: README dangowrt/owrt-ubi-installer; Wiki-Zusammenfassung: OpenWrt-Wiki]; Commit-Weg veraltet (siehe Widersprüche).
- Quellen: https://github.com/dangowrt/owrt-ubi-installer, https://openwrt.org/toh/linksys/e8450

#### sonderweg-meraki-mr33-access-point
- Ablauf: Bootloader-Version prüfen, ubootwrite lädt mr33-uboot.bin (250-300 s), initramfs per `tftp put`, UBI umbauen, sysupgrade [geprüft: Commit 4943afd; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/meraki/mr33

#### sonderweg-mercusys-mr90x-v1
- Ablauf: SSH Port 20001, telnet-Hintertür über 65-iptv + IPTV-Schalter, busybox-arm64, initramfs ins UBI-Volume kernel, fw_setenv, sysupgrade [geprüft: Commit e4fe309; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/mercusys/mr90x_v1

#### sonderweg-netgear-wax218
- Ablauf: Stock-UI System Manager > Firmware > Local Firmware Upgrade nimmt `web-ui-factory.fit`, danach sysupgrade [geprüft: Commit 7801161].

#### sonderweg-totolink-x5000r
- Ablauf: Stock-UI nimmt OpenWrt-sysupgrade [geprüft: Commit 23be410].

#### sonderweg-tp-link-archer-c60-v1
- Ablauf: Web-UI/TFTP-Recovery nur mit factory (fehlt in 24.10), sonst UART [geprüft: Commit 6d313da].
- Quelle: https://openwrt.org/toh/tp-link/archer_c60_v2

#### sonderweg-tp-link-td-w8970
- Ablauf: ohne Öffnen Shell per SSID-Injection oder StatPost (telnet 1023), mit Öffnen seriell `t` + TFTP [Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/tp-link/td-w8970_v1

#### sonderweg-ubiquiti-nanobeam-ac-gen1-xc
- Ablauf: airOS XC v8.7.0/8.7.4, per SSH gepatchtes `fwupdate.real -m <factory>` [Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/ubiquiti/common

#### sonderweg-wavlink-wl-wn573hx3
- Ablauf: versteckte Seite meshUpgrade.html nimmt das sysupgrade, danach Werkseinstellungen [geprüft: Commit ca38f13].

#### sonderweg-xiaomi-ax3600
- Ablauf: SSH per stok-Exploit (Stock CN 1.0.17) oder bdata-Patch, `initramfs-factory.ubi` per ubiformat in die inaktive rootfs-mtd + nvram, sysupgrade [geprüft: Commit 8364f08; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/xiaomi/ax3600

#### sonderweg-xiaomi-mi-router-3g
- Ablauf: SSH (Entwickler-Firmware + miwifi_ssh.bin vom USB-Stick) oder OpenWRTInvasion, kernel1/rootfs0 per mtd [geprüft: Commit 6e283cd; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/xiaomi/mir3g

#### sonderweg-xiaomi-mi-router-ax3000t / -openwrt-u-boot-layout
- Ablauf: SSH per API-Lücke (Stock-abhängig), Backup, initramfs-factory.ubi per ubiformat + nvram, sysupgrade; ubootmod zusätzlich UBI-Neuaufbau + OpenWrt-Bootloader [geprüft: Commit 7dbcc12].
- Quelle: https://openwrt.org/toh/xiaomi/ax3000t (Tabelle Stock-Version -> Exploit, Hardware-Varianten)

#### sonderweg-xiaomi-redmi-router-ax6s
- Ablauf: Telnet (ab Werk oder Closed-Beta 1.2.7 beim RB03), Passwort aus Seriennummer, nvram, factory per wget + mtd [geprüft: Commit 9f9477b; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quelle: https://openwrt.org/toh/xiaomi/ax3200; Neanderfunk-Notiz

#### sonderweg-zte-mf286r
- Ablauf: Root-Shell per URL-Filter-Exploit (telnet 4719) oder busybox-Nachladen, Backup, initramfs per nandwrite in "firmware", reboot, sysupgrade [geprüft: Commit 7ac8da0].
- Quelle: Commit; https://openwrt.org/toh/zte/mf286r (empfiehlt seriell als einfachsten Weg)

#### sonderweg-zyxel-nbg6616
- Ablauf: zloader per ATSE/ATEN-Challenge entsperren, bootcmd auf boot_openwrt, saveenv, factory als `ras.bin` per WPS-TFTP-Recovery [geprüft: Commit 459c8c9]; laut Wiki auch ohne Seriell über 19.07.10-ar71xx (siehe Widersprüche).
- Quelle: https://openwrt.org/toh/zyxel/nbg6616

#### sonderweg-zyxel-wsm20
- Ablauf: versteckte Seite /gui/#/main/debug/firmwareupgrade nimmt initramfs-kernel.bin, danach sysupgrade [geprüft: Commit 28df7f7; Wiki-Zusammenfassung: OpenWrt-Wiki].
- Quellen: https://openwrt.org/toh/zyxel/wsm20 (LED-Folge), https://freifunk-aachen.de/2024/01/04/installationsanleitung-zyxel-wsm20/

### Widersprüche zu vorhandenen Feldern

| Gerät | Feld | alt | neu | Quelle |
|---|---|---|---|---|
| aerohive-hiveap-330 | weg/uebertragung | initramfs (+ .fdt) per TFTP, sysupgrade per scp | Seit der Neupartitionierung (DEVICE_COMPAT_VERSION 2.0, OpenWrt > 21.02) zusätzlich U-Boot patchen (owrt_boot setzen, im initramfs opkg kmod-mtd-rw, u-boot-Partition patchen und schreiben), sonst bootet der Stock-U-Boot den installierten Kernel nicht; kein .fdt mehr nötig, Datei per tftpboot 1000000 192.168.1.101:<name> | Wiki toh/aerohive/hiveap-330, Pin p1020.mk DEVICE_COMPAT_MESSAGE |
| aerohive-hiveap-121 | weg | nand erase 0x800000 0x800000 (Commit) | Wiki: nand erase 0x800000 0x7400000 (beide Stock-Kernel und rootfs), nand write 0x${filesize} | Wiki toh/aerohive/ap121 |
| cudy-tr3000-v1 | weg | Cudy-Zwischenfirmware fehlt im Spiegel und bei Cudy (Stand 08.10.2026) | Wiki nennt Cudy-Intermediate-Firmware "TR3000 V1.zip" bzw. "TR3000 V1_20251118.zip" (cudy_tr3000-v1-sysupgrade.bin) unter cudy.com/blogs/faq/openwrt-software-download und Google Drive; nicht nachgeprüft, ob dort noch abrufbar | Wiki toh/cudy/tr3000 |
| extreme-networks-ap3935 | weg | bootcmd 'ping 192.168.1.1; run boot_flash' (Commit) | Wiki: vorher `nand erase.part PriImg` und `SecImg`, `env default -f; saveenv`, bootcmd mit MOSTRECENTKERNEL 0, WATCHDOG_COUNT 0, WATCHDOG_LIMIT 0, ping 255.255.255.255; sonst kopiert sich das Stock-SecImg nach Watchdog-Neustarts über OpenWrt | Wiki toh/extreme_networks/ws-ap3935i |
| sophos-red-15w-rev.1 | weg | bootargs_owrt/bootcmd laut Commit (nand read 0x1000000 ... bootm 0x1000000) | Wiki: ab OpenWrt 24.10 bootcmd `setenv bootargs console=ttyS0,115200\; nand read 0x1800000 0x300000 0x800000\; bootm 0x1800000`, initramfs nach 0x2000000; bei bootdelay 0 erst per Stock-Failsafe fw_setenv bootdelay=3 | Wiki toh/sophos_red_15w_rev_1 |
| d-link-dir-505 | weg/seriell | nur U-Boot-TFTP seriell | Wiki: ohne Seriell über Stock-Web-UI oder D-Link-Recovery (Reset beim Einstecken, 192.168.0.1) mit altem ar71xx-factory, danach sysupgrade auf ath79; ToH: Installationsmethoden "GUI OEM, D-Link Recovery GUI" | Wiki toh/d-link/dir-505, ToH |
| xiaomi-mi-router-4a-100m-edition | seriell | ja | Wiki nennt Weg ohne UART: Xiaomi-TFTP-Recovery (Reset beim Einstecken bis gelbe LED blinkt, DHCP+TFTP, test.bin = Stock 2.18.28; fertig, wenn LED blau blinkt), dann OpenWRTInvasion, mtd write OS1; passt eher zur Familie xiaomi-openwrtinvasion | Wiki toh/xiaomi/mi_router_4a_mir4a_100m |
| extreme-networks-ws-ap3825i | zeichen (Commit) | LEDs unter OpenWrt ohne Funktion | Wiki: Power-LED blinkt nach sysupgrade bis Speicherprüfung fertig, dann dauerhaft (vermutlich bootloadergesteuert) | Commit 7e61482 vs Wiki |
| linksys-e8450-ubi | weg/werkzeug | Commit-Weg (initramfs-recovery.itb über Stock-UI, preloader/fip per mtd write); UBI-Installer nur "alternativ" | Wiki: Erstinstallation nur noch mit dangowrt/owrt-ubi-installer (`...-ubi-initramfs-recovery-installer.itb`, ab Stock 1.2.00.273012 die _signed-Variante); "Simply flashing an linksys_e8450-ubi-initramfs-recovery.itb image alone is not enough and will brick the device"; seit 2024-02 liegen FIP und Factory im UBI (24.10-Layout) | Wiki toh/linksys/e8450, README owrt-ubi-installer |
| meraki-mr33-access-point | weg/uebertragung | modifizierter U-Boot per ubootwrite, dann sysupgrade per `tftp put` | Wiki: initramfs per tftp put an 192.168.1.1, im initramfs alle UBI-Volumes außer ART löschen, initramfs als statisches Volume part.old anlegen, dann sysupgrade; vorher Bootloader-Version prüfen (nur U-Boot 2012.07-g97ab7f1, sonst Brick); ubootwrite aus github sebastiaanv3/ubootwrite | Wiki toh/meraki/mr33 |
| zyxel-nbg6616 | seriell/kat | ja (K5) | Wiki: ohne Seriell möglich: OpenWrt 19.07.10 ar71xx-factory über die Stock-Weboberfläche, per SSH `fw_setenv boot_openwrt bootm 0x9F120000; fw_setenv bootcmd run boot_openwrt`, dann `sysupgrade -F -n` auf ath79 | Wiki toh/zyxel/nbg6616 |
| zyxel-wsm20 | werkzeug | Zyxel-Cloud-Konto | Wiki: versteckte Upgrade-Seite geht auch ohne Registrierung, nur falls nicht, registrieren; Wiki-URL mit http statt https | Wiki toh/zyxel/wsm20 |
| xiaomi-mi-router-ax3000t | weg/werkzeug | Stock 1.0.47 (arn_switch) | Wiki: fast alle Stock-Versionen (CN bis 1.0.98, INT bis 1.0.104) über xqsystem/start_binding bzw. get_icon angreifbar; nur CN 1.0.106 braucht Downgrade; außerdem RD03v2 (Qualcomm) nicht unterstützt | Wiki toh/xiaomi/ax3000t |
| xiaomi-mi-router-3g | weg | Shell-Zugang offen; kernel0 löschen | Wiki: SSH über Entwickler-Firmware + Xiaomi-Konto + miwifi_ssh.bin vom USB-Stick (Reset halten bis gelbe LED blinkt) oder OpenWRTInvasion; Wiki setzt statt `mtd erase kernel0` `nvram set flag_try_sys1_failed=1; nvram commit` | Wiki toh/xiaomi/mir3g |
| d-link-dir825b1 | weg/uebertragung/seriell | ? (Weg ab Werk nicht beschrieben) | Wiki: D-Link-Recovery (Reset beim Einschalten bis Power-LED orange blinkt, PC 192.168.0.100/24, http://192.168.0.1, nur mit alten Browsern) mit OpenWrt-23.05.5-factory, danach sysupgrade; ohne Seriell | Wiki toh/d-link/dir-825 |

### Offen

- siemens-ws-ap3610: Commit setzt boot_openwrt, aber kein `setenv bootcmd 'run boot_openwrt'` (anders als AP3705i); ob Stock-bootcmd OpenWrt trotzdem bootet, ist offen
- aruba-instant-on-ap11: Baudrate: Commit/Wiki AP-303 9600, github Sc4ndium90/aruba-ap11-openwrt nennt 115200 für den AP11
- enterasys-ws-ap3705i: ToH nennt 3.3 V Pegel für die Cisco-RJ45-Konsole; sonst RS232 üblich. Pegel offen
- aruba-instant-on-ap11d, aruba-instant-on-ap17: apboot-Sperre (nur signierte Images) wie AP11? nicht belegt
- extreme-networks-ws-ap3825i: Gehäuse identisch mit Enterasys WS-AP3725i / Adtran BSAP-2030; Image-Kompatibilität offen
- tp-link-eap620-hd-v1: OpenWrt-Commits 4b6e7da und 8a15a75 fehlen im lokalen OpenWrt-Baum (nur GitHub gelesen)
- xiaomi-mi-router-ax3000t-openwrt-u-boot-layout: Wiki: Geräte mit AN8855-Switch und/oder Foresee-NAND sind erst ab OpenWrt 25.12.0 voll mit dem OpenWrt-U-Boot verträglich; Gluon 2025.1 baut auf 24.10. Prüfen, ob der ubootmod-Weg für diese Varianten gesperrt werden muss
- xiaomi-mi-router-ax3000t: Foresee-NAND braucht OpenWrt ab 24.10.3 (Bugfix), AN8855 ab 24.10.0-rc7: gegen den OpenWrt-Stand der Gluon-2025.1-Basis prüfen
- ubiquiti-nanobeam-ac-gen1-xc: Wiki: OpenWrt-24.10-Releases vor 24.10.3 mit Read-only-Flash-Fehler auf vielen Ubiquiti-Geräten; Stand der Gluon-Basis prüfen. Außerdem: Wiki-XC-Verfahren (fwupdate.real patchen) laut Wiki mit neueren Snapshots zeitweise nicht mehr funktionierend
- google-wifi-gale: Wiki: OpenWrt-factory per dd auf den Stick klappt oft nicht, nur mit OnHub Recovery Utility (Chrome, nicht Linux)
- hewlett-packard-msm460: Erfolgs-LED-Muster nur als GIF im blocktrron-Repo, nicht in Worten
- aruba-ap-32x: Wie das Stock-APBoot unterbrochen wird, steht weder im Commit noch im README; Enter wie bei AP-303 nur abgeleitet
- asus-rt-ax52: RT-AX52 Pro: gleiches Image? nicht belegt
- Allgemein: Feld `dauer` ist bei fast allen seriell-tftp-Geräten leer, weil keine Quelle Zeiten nennt.
- Allgemein: die ToH nennt bei manchen Geräten mit Cisco-RJ45-Konsole 3.3 V (z. B. Enterasys WS-AP3705i), Wiki/Aerohive sagen RS232; Pegel vor dem Schreiben der Anleitung am Gerät prüfen.

### Lokale Quelltexte

Commit-Texte je Gerät: D-commits/<gluon_name>.txt; Wiki-Rohtexte: D-wiki/*.txt (Abruf 10.10.2026).

## Teil C3: ASUS Firmware Restoration, ASUS TUF, OCEDO, Sophos XG

Stand 10.10.2026. Gerätewerte in C3.json (neue Feldstruktur); hier gemeinsamer Ablauf je Familie, Quellen, Abweichungen.

### ocedo-tftp (3 Geräte: ocedo-koala, ocedo-raccoon, ocedo-panda)

Gemeinsamer Ablauf:
- Reset-Taste halten, Strom anstecken; der Hersteller-Bootloader holt per TFTP von 192.168.100.8 ein initramfs (Panda zusätzlich DTB) und startet es im RAM [geprüft: Commits c493171, 6476148, b368373]
- Rechner braucht nur einen TFTP-Server mit fester IP 192.168.100.8 (/24 laut Panda-Commit), kein Öffnen, keine Konsole [geprüft: Commits]
- Gluon baut für diese Geräte kein initramfs/factory; man nimmt das OpenWrt-24.10.8-initramfs (Download-Link im Inventar) [geprüft: Inventar, Image-Rezepte am Pin]
- im initramfs vor dem sysupgrade den Bootloader umstellen: Koala/Raccoon `fw_setenv bootcmd run bootcmd_1` (Flip-Flop-Bootloader), Panda `ubirmvol` der Hersteller-Volumes + drei `fw_setenv` [geprüft: Commits]; OpenWrts sysupgrade macht das nicht selbst [geprüft: platform.sh am Pin, Rezepte devices/ocedo-*.sh]
- dann Gluon-sysupgrade per scp und `sysupgrade -n` [geprüft: Panda-Commit; Koala/Raccoon "sysupgrade or mtd"]
- Statusanzeige unter OpenWrt/Gluon: blaue SYS-LED (led-boot/running/upgrade) [geprüft: DTS am Pin; Blinkverhalten abgeleitet]

Quellen:
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=c4931713df8ffb3c4e5c1be7d0b6d4aa96a7dd4c (Koala)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=647614803473757e3b2d93d46938afccd61a5a5d (Raccoon)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=b368373fab45f31963cd2bc1c6ab90e0a577e611 (Panda)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=eded295cd7fd53bfa5afcb67a1b91cfda0523ba6 (Koala/Raccoon: OS-Partitionen zusammengelegt, Größengrenze Erstinstallation)
- OpenWrt-Wiki: keine Geräteseiten (toh/ocedo/koala existiert nicht); ToH-Datensatz zitiert nur den Commit
- Rezepte devices/ocedo-koala.sh, ocedo-panda.sh, docs/ENTWURF-VORBEREITUNG.md im Installer-Repo

Abweichungen:
- Koala/Raccoon: Dateiname `<modell>-uImage-initramfs-lzma.bin`, je nach Herstellersoftware `<modell>-uimage-factory`; beide ablegen [geprüft: Commits]
- Raccoon: U-Boot startet nicht mit angeschlossener serieller Konsole (erst nach 3 s anstecken), nur für den Notweg wichtig [geprüft: Commit 6476148]
- Panda: zwei Dateien `panda-uimage-factory` + `panda.fdt`; 8 LAN + WAN, TFTP-Port nicht belegt; Löschen von kernel2/rootfs2/devicetree2/storage verbaut den Rückweg [geprüft: Commit b368373]
- Koala/Raccoon: seit eded295 ist die firmware-Partition 0xe80000 groß (IMAGE_SIZE 14848k); Erstinstallation laut Commit mit älterem OpenWrt, falls das Image größer als eine alte OS-Partition (7424 KiB) wird [geprüft: Commit eded295]

### sophos-xg-awetool (5 Geräte: sophos-ap100, sophos-ap100c, sophos-ap55, sophos-ap55c, sophos-ap15c)

Gemeinsamer Ablauf:
- Sophos-Konto, kostenlose Home-Use-Lizenz für XG Firewall, XG auf PC oder VM installieren, SSH-Konsolenzugang einschalten [geprüft: Commits 6f1efb2, 2d465fb]
- AP an die LAN-Schnittstelle der XG, in der XG-Weboberfläche freigeben, warten bis "Active" (3-5 Minuten) [geprüft: Commits]
- SSH auf die XG, Advanced Console (5, dann 3), `sudo awetool`, SSH auf dem AP einschalten (Yes), 2-3 Minuten warten, AP erneut wählen = Root-Shell auf dem AP [geprüft: Commits]
- Gluon-sysupgrade als `/tmp/openwrt.bin` auf den AP, `mtd -r write /tmp/openwrt.bin astaro_image`, AP startet neu [geprüft: Commits]
- Notweg ohne XG: interne 3.3-V-UART (115200 8N1), TFTP-Server 192.168.99.8/24, `tftpboot`, `cp.b $fileaddr 0x9f070000 $filesize`, `boot` [geprüft: Commits]
- Haken: Sophos hat die AP-Serie zum 31.03.2023 abgekündigt; danach laut Sophos nicht mehr an XG/SFOS betreibbar; laut Websuche (Sophos-Community) verlängert bis 31.12.2023, unterstützt SFOS 15.01.0 bis 19.x, nicht XGS [Forum-Zusammenfassung]; der XG-Weg braucht also eine ältere SFOS-Version [abgeleitet]

Quellen:
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=6f1efb28983758116a8ecaf9c93e1d875bb70af7 (AP100/AP100C/AP55/AP55C)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=2d465fbf570e1f3286210305a26580cd417fec7c (AP15C, Text fast wörtlich übernommen; Fußnote [4] fehlt dort)
- https://www.avanet.com/en/blog/end-of-sale-ap-series-indoor-access-points-retire/ (EOL-Daten, per WebFetch)
- https://community.sophos.com/sophoswireless/b/blog/posts/eol-extension-ap-series-access-points (Verlängerung, SFOS-Versionen; nur über Websuche, WebFetch lieferte leere Seite)
- OpenWrt-Wiki: keine Geräteseiten; ToH-Datensatz: "Sophos Firewall appliance or console access required", 115200 8N1, 3.3 V

Abweichungen:
- TFTP-Dateiname im U-Boot-Notweg: Commit nennt nur `uImage_AP100C` (6f1efb2) bzw. `uImage_AP15C` (2d465fb); für AP100/AP55/AP55C ist der Name nicht belegt (`tftpboot` ohne Argument nutzt U-Boots `bootfile`) [abgeleitet]
- UART-Zugang: AP100/AP55 nach Abnehmen des Deckels; AP100C/AP55C Platine ausbauen (drei Schrauben); AP15C nicht beschrieben [geprüft: Commits]
- RJ45-Konsole außen: AP100/AP55 und AP15C haben eine; bei AP100/AP55 in der Herstellerfirmware abgeschaltet, unter OpenWrt aktiv [geprüft: Commits]; ToH: RS-232-Pegel
- LEDs unter OpenWrt: AP100/AP55-Familie grün/rot, AP15C grün/gelb [geprüft: DTS am Pin]
- Strom: AP100/AP55-Familie 802.3af oder 12 V 5.5x2.1 [geprüft: Commit]; AP15C 12 V/1 A oder 802.3af [Wiki-Zusammenfassung: ToH]

### asus-firmware-restoration (3 Geräte: asus-rt-ac51u, asus-rt-ac57u-v1, asus-rt-ax53u)

Gemeinsamer Ablauf:
- Rettungsmodus (Rescue Mode) des ASUS-Bootloaders: Strom ziehen, Reset halten, Strom anstecken, halten bis die Power-LED langsam blinkt [geprüft: ASUS-FAQ 1000814, Commits 5f93298, 14e0e4f]
- Gerät ist dann TFTP-Server auf 192.168.1.1; Rechner fest im Netz 192.168.1.0/24, per `tftp put` (binary) senden [geprüft: Commits]; Dateiname beim put frei [abgeleitet]
- Windows-Alternative: ASUS Firmware Restoration (Windows XP bis 11), Rechner 192.168.1.10/24 [geprüft: ASUS-FAQ 1000814]; alle anderen Adapter abschalten [abgeleitet: Wiki]
- fertig, wenn die Power-LED dauerhaft leuchtet, etwa 1 Minute [geprüft: ASUS-FAQ 1000814]
- RT-AC51U und RT-AC57U v1 nehmen das Gluon-sysupgrade direkt; RT-AX53U (NAND) bekommt zuerst das OpenWrt-initramfs, dann Gluon-sysupgrade aus dem initramfs [geprüft: Commits; AX53U abgeleitet: Wiki]
- Rückweg: ASUS-Firmware (.trx) im selben Rettungsmodus [geprüft: ASUS-FAQ 1000814, nennt "third-party firmware"]

Quellen:
- https://www.asus.com/support/faq/1000814/ (Herstellerdoku, per curl im Original gelesen: IP 192.168.1.10/24, LED, 1 Minute, nur Windows)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=5f932988c3b65af14bd6e48a05cc2204b7aeb419 (RT-AC51U)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=14e0e4f138e35c3e2a15cc3a836c939547ee053b (RT-AC57U v1)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=8c00fd9b4519bf0ef8fb3470a6df421b9f38c03c (RT-AX53U, nur seriell)
- https://openwrt.org/toh/asus/rt-ac51u, https://openwrt.org/toh/asus/rt-ac57u, https://openwrt.org/toh/asus/rt-ax53u (Rohtext per ?do=export_raw gelesen, trotzdem als [abgeleitet: Wiki] markiert)

Abweichungen:
- Rechner-IP: Commits RT-AC51U/AC57U 192.168.1.75; ASUS-FAQ und Wiki (Restoration-Tool, AX53U) 192.168.1.10
- Haltezeit: AC57U-Commit 5 s; AC51U "a few seconds" (Wiki 5 s Restoration / 10 s TFTP); AX53U bis die Power-LED "sehr langsam" blinkt
- RT-AC51U: Wiki benennt das sysupgrade für das Restoration-Tool in `factory.trx` um (strengster Name, ob nötig offen); Wiki: Power-LED blinkt schnell beim Schreiben
- RT-AC57U v1: nur v1 (MediaTek, = RT-AC1200GU); v2/v3 andere Hardware; Alternative SSH + `mtd-write -d linux`; UART 57600 8N1
- RT-AX53U = RT-AX1800U, nicht RT-AX1800 (ohne U); Weboberfläche nimmt OpenWrt nicht; Alternative SSH + `mtd-write -d Kernel` mit factory; seriell U-Boot-Menü 2 (Commit)

### asus-tuf-herbetom (2 Geräte: asus-tuf-ax4200, asus-tuf-ax6000)

Gemeinsamer Ablauf:
- Herstellerfirmware einrichten (Assistent, 192.168.50.1), unter Administration -> System SSH mit Passwort-Login einschalten (LAN only, Port 22) [geprüft: Release-Text herbetom filogic-v2, Freifunk-Darmstadt-Wiki]
- Sonderbau "factory-initramfs" (herbetom filogic-v2) als `openwrt.bin` per `python3 -m http.server ... 8080` bereitstellen; auf dem Router in `/etc/hosts` `openwrtimage.lan` auf die Rechner-IP setzen, `wget -O /tmp/openwrt.bin http://openwrtimage.lan:8080/openwrt.bin` [geprüft: Release-Text]
- `mtd-erase -d linux`, `mtd-write -i /tmp/openwrt.bin -d linux`, Power-Cycle [geprüft: Release-Text]
- OpenWrt-initramfs auf 192.168.1.1: Gluon-sysupgrade per `scp -O` nach /tmp, `sysupgrade -n` [geprüft: Release-Text]
- Notweg seriell + TFTP (U-Boot-Taste `4`, `tftpboot 0x46000000 <datei>`, `bootm`) [geprüft: Commits e7c399b, d522cce]; AX6000 ohne Öffnen über drei Gehäuselöcher

Quellen:
- https://github.com/herbetom/openwrt-asus-filogic-factory/releases/tag/filogic-v2 (Release-Text per GitHub-API im Original gelesen; Assets nur AX4200/AX6000-initramfs-kernel.bin)
- https://github.com/freifunk-darmstadt/projects/wiki/90-%E2%80%90-Hardware-%E2%80%90-ASUS-TUF-AX4200 (Rohtext per raw.githubusercontent.com/wiki; nennt filogic-v1 von blocktrron)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=e7c399bee677e9bac66e1bea697aefb8d828edfe (AX4200, seriell)
- https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=d522ccecb28f941aadcaf7a50cd6daa861f468a7 (AX6000, seriell über Gehäuselöcher)
- https://openwrt.org/toh/asus/tuf-ax4200, https://openwrt.org/toh/asus/tuf-ax6000 (Rohtext; inoffizielle initramfs.trx über die ASUS-Weboberfläche, Gehäuse öffnen, Rückweg facinstall)

Abweichungen:
- TFTP-Notweg: AX4200 Server 192.168.1.66, `tufax4200.bin`; AX6000 Server 192.168.1.70, `TUF-AX6000.bin` (Commit) bzw. `tufax6000.bin` (Wiki); AX6000 zusätzlich U-Boot-Menü `1` mit Vorgabe-Dateiname `TUF-AX6000.trx`
- Konsole: AX4200 Gehäuse öffnen (Wiki: 4 Gummifüße, 4 Schrauben), AX6000 drei Löcher außen (von unten RX, TX, GND)
- AX4200 nicht mit AX4200Q verwechseln (Q: zweiter 2.5-GbE-Port, eigenes Image, nicht in Gluon 2025.1)
- OpenWrt hat seit Feb. 2025 für beide einen U-Boot-Workaround ("u-boot-dont-touch-spi-nand", Commit bbe51e7) und seit Feb. 2024 NVMEM-on-UBI (25c9ebc, 1794309); herbetom-Sonderbau ist von Dez. 2023, also älter [geprüft: Commits]; ob das beim sysupgrade auf Gluon 2025.1 stört, ist nicht belegt (siehe Offen)

### Widersprüche zu vorhandenen Feldern

| Gerät | Feld | alt | neu | Quelle |
|---|---|---|---|---|
| asus-rt-ac51u | uebertragung | Rechner 192.168.1.75 | für ASUS Firmware Restoration nennt ASUS 192.168.1.10 (TFTP-Weg laut Commit 192.168.1.75 bleibt) | ASUS-FAQ 1000814, Wiki toh/asus/rt-ac51u |
| asus-rt-ac57u-v1 | uebertragung | Rechner 192.168.1.75 | Restoration-Rückweg laut Wiki 192.168.1.10 (TFTP laut Commit 192.168.1.75 bleibt) | Wiki toh/asus/rt-ac57u |
| asus-tuf-ax6000 | uebertragung | seriell Datei TUF-AX6000.bin (U-Boot-Menü 1 oder 4) | Commit: `TUF-AX6000.bin` bei Menü 4; Menü 1 fragt den Namen ab, Vorgabe `TUF-AX6000.trx`; Wiki nennt `tufax6000.bin` | Commit d522cce, Wiki toh/asus/tuf-ax6000 |
| asus-tuf-ax4200, asus-tuf-ax6000 | weg | SSH + `mtd-write -d linux` | vorher zusätzlich `mtd-erase -d linux`, Power-Cycle statt reboot | Release-Text herbetom filogic-v2 |
| asus-tuf-ax4200 | weg | "OpenWrt-Commit nennt nur UART + TFTP" | Wiki nennt inzwischen auch eine inoffizielle initramfs.trx über die ASUS-Weboberfläche (ohne Öffnen) | Wiki toh/asus/tuf-ax4200 |
| asus-tuf-ax4200 | gehaeuse | "Lage der Konsole ... nicht belegt: ?" | Gehäuse öffnen: 4 Gummifüße, 4 Schrauben, Deckel abziehen; Konsole unten rechts auf der Hauptplatine | Wiki toh/asus/tuf-ax4200 |
| asus-rt-ax53u | uebertragung | Rechner 192.168.1.10, "Dateiname beliebig" | passt; Wiki: initramfs-kernel, nicht factory | Wiki toh/asus/rt-ax53u |
| sophos-ap15c | gehaeuse | RJ45-Konsole außen, "ob im U-Boot nutzbar: ?" | bleibt offen; Commit 2d465fb verweist auf Fußnote [4] des AP100-Commits, die im AP15C-Commit fehlt | Commit 2d465fb |
| sophos-ap100, -ap55, -ap55c | uebertragung | Datei uImage_AP100 / _AP55 / _AP55C | nicht belegt: Commit nennt nur `uImage_AP100C`; `tftpboot` ohne Argument nimmt U-Boots `bootfile` | Commit 6f1efb2 |
| sophos-* (alle 5) | werkzeug | Sophos-XG-Appliance (Home-Use-Lizenz, VM) | Sophos hat die AP-Serie zum 31.03.2023 (verlängert 31.12.2023) abgekündigt; XG muss eine ältere SFOS-Version (bis 19.x, kein XGS) sein | avanet.com, Sophos-Community (Websuche) |

### Offen

- sophos-*: Gibt es die Home-Use-Lizenz und eine SFOS-Version bis 19.x noch zum Download? Nicht geprüft. Lassen sich die C-Modelle (AP15C, AP55C, AP100C) an einer XG verwalten oder nur über Sophos Central? Commit 6f1efb2 sagt XG für alle (Autor hat AP55C/AP100C getestet).
- sophos-*: Sophos-Community-Blog "EOL Extension: AP Series" lieferte per WebFetch keine Seite; Angaben (31.12.2023, SFOS 15.01.0 bis 19.x, nicht XGS) nur aus der Websuche-Zusammenfassung.
- sophos-ap100, -ap55, -ap55c: TFTP-Dateiname im U-Boot nicht belegt (`printenv bootfile`).
- ocedo-panda: an welchem der 8 LAN-Ports bzw. WAN der Bootloader TFTP spricht, nicht belegt.
- ocedo-*: Wie lange die Reset-Taste zu halten ist und welche LED den TFTP-Boot anzeigt, steht nirgends; kein OpenWrt-Wiki zu OCEDO.
- ocedo-koala, ocedo-raccoon: Commit eded295 sagt, die Erstinstallation müsse mit älterem OpenWrt erfolgen, falls das Image größer als eine alte OS-Partition (7424 KiB) wird; warum genau (Flip-Flop-bootcmd_1 lädt evtl. nur bis zur alten Grenze?), steht nicht da. Neanderfunk-sysupgrade bisher etwa 6977 KiB.
- asus-tuf-ax4200, -ax6000: herbetom-Sonderbau (Dez. 2023) vor NVMEM-on-UBI (Feb. 2024) und U-Boot-Workaround (Feb. 2025); `sysupgrade -n` auf Gluon 2025.1 nicht belegt. Darmstadt nutzt den Weg mit Gluon, Version dort nicht genannt.
- asus-tuf-ax4200: Das AX4200Q-Rezept baut eine `initramfs.trx` mit `asus-trx -n TUF-AX4200`; die Wiki-Methode per Weboberfläche nutzt eine fremde trx (openwrt-xiaomi/builder). Ob Gluon/RAMpe so eine trx für den AX4200 bauen könnte, ist offen.
- asus-tuf-*: Ab welcher ASUS-Firmware SSH/`mtd-write` gesperrt sein könnte, nicht belegt.
- asus-rt-ac51u: ob das Restoration-Tool die Endung `.trx` verlangt (Wiki benennt in `factory.trx` um), nicht belegt.

## Kandidaten für Hardwaretests

Wo der einfachere Weg nur schlecht belegt ist, würde ein Test am Gerät die
Anleitung deutlich vereinfachen (Hinweis Content, 10.10.2026): Netgear WAX206,
EX3700, EX6130, EAX12, EX6150, WAX202, R6220, R6260 (Web-UI statt nmrpflash),
GL.iNet 6416 und GL-MT300N v2 (Herstelleroberfläche statt U-Boot-Web),
Genexis Pulse EX400 (Web-UI statt U-Boot-Recovery), TP-Link EAP620 HD (ohne
UART). In den Daten tragen diese Geräte im Notweg `[einfacher, schlechter belegt]`.

Lizenz dieser Datei: CC BY-SA 4.0.
