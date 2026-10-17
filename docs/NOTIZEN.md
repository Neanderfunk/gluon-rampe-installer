# Notizen / Übergabe

Arbeitsstand für alle, die hier weitermachen – Mensch oder Claude-Session.
Entstanden am 11.09.2026 in der Neanderfunk-Firmware-Session. Idee: adorfer
(Neanderfunk), Vorbild: oszilloskop.

## Ziel

- Ein Installer-Image je Gerät, **community-unabhängig**. Jede Community
  nutzt dasselbe Image, hochgeladen wird deren sysupgrade.
- Einspielen über den **Hersteller-Weg** (Recovery, Web-UI) statt über ein
  OpenWrt/LuCI-Zwischenimage.
- Genau eine Seite in Gluon-Optik: Upload, Bestätigung, `sysupgrade -n`.
- Einfach zu bauen: ein serielles `build.sh`, Docker als Standardweg. Keine
  Neanderfunk-Werkzeugkette (kein golden tree, keine Worker, keine Domains).

## Entscheidungen

| Entscheidung | Warum |
|---|---|
| Gluon statt reinem OpenWrt | Optik, Sprache und Upload-Logik (inkl. `sysupgrade -T`-Prüfung) gibt es fertig in gluon-web-admin |
| Gluon v2025.1.3 als Basis | aktuellste OpenWrt-Basis (24.10), bringt die Geräte-Unterstützung; das hochgeladene Image darf älter sein (Kompatibilität prüft sysupgrade) |
| initramfs | nichts im Flash außer dem Installer selbst; jeder Neustart landet wieder auf der Upload-Seite |
| Anpassung per `openwrt/files` statt eigenem Paket | vier Dateien, kein Feed nötig; die Controller überschreiben die von Gluon |
| Kein „Einstellungen behalten“ | es gibt nichts zu behalten; `-n` erzwingt den sauberen Erststart der Community-Firmware |
| Geräte-Rezepte als Shellskripte, die `targets/` ändern | kein Patch-Stapel gegen Gluon; `targets/` wird vor jedem Lauf per git zurückgesetzt |
| Release-Name = Datum (`site.mk`) | Installer haben keine Versionslogik; das Datum sagt genug |
| Lizenz BSD-3, oszilloskop-Teile MIT, upgrade.html Apache-2.0 | eigene Arbeit BSD-3; Übernommenes behält seine Lizenz; Credit sichtbar auf der Seite, im Image (CREDITS), im README |

## Befunde

- **initramfs-Gluon startet nie im Config-Mode.** `70_initramfs_test`
  bricht `preinit_main` ab, `90_setup_mode` läuft nicht. Lösung:
  `boot_hook_add initramfs setup_mode_enable` (`91_installer_initramfs`).
  Das erklärt, warum Gluons recovery-Images für M30/M60 „nicht
  funktionierten“ – Gluon hat das M30-recovery deshalb entfernt (#3816).
  Das M60-recovery in v2025.1.x hat vermutlich denselben Fehler.
- procd liest `/tmp/rc_d_path` (Gluon-Patch an procd). Darüber schaltet
  `setup_mode_enable` auf die rc.d des Config-Mode um.
- gluon-web lehnt POST ohne passenden `Origin`-Header mit 400 ab. Das
  betrifft nur Tests per curl, keine Browser.
- `/` leitet per meta-refresh weiter; Einstieg für Skripte ist
  `/cgi-bin/config`.
- Gluon 2025.1 braucht clang/llvm zum Bauen (bpf-headers). Ohne clang bricht
  der Bau an `bpf-headers` ab.
- Bauen auf aktuellen Hosts (GCC 15) scheitert an OpenWrt-Host-Werkzeugen,
  daher Bookworm im Container.
- Die Docker-Einbindung braucht **denselben absoluten Pfad** wie auf dem Host,
  sonst baut OpenWrt alles neu (absolute Pfade in den Stempeldateien).
- `mesh-batman-adv-15` steht nur drin, weil Gluon ein Mesh-Protokoll
  verlangt. Aktiv wird es im Installer nie.

## Getestet

- x86-64 in QEMU (`test/qemu-x86-64.sh`): Installer → Upload-Seite
  (keepcfg-Feld fehlt, Credit da) → Upload des sysupgrade einer
  Neanderfunk-2023.2-Firmware (24_dusukw) → „Upgrade completed“ → Start von
  der Platte in deren Wizard. Grün.
- Beide Bauten über `contrib/docker/run.sh` (Bild frisch aus dem
  Dockerfile): x86-64 in 22 min mit vorhandenem Baum, samt `make update`;
  M30 danach in 6 min. Das x86-64-Image aus dem Container hat den QEMU-Test
  bestanden.
- D-Link M30: Image gebaut (52 MB, Header `DLK6E6110001` wie bei OpenWrt),
  cpio-Inhalt geprüft (preinit-Hook, Controller, View, CREDITS).
  **Auf Hardware nicht getestet.**
- **D-Link M60 A1, erster Hardware-Test der Gluon-RAMpe (13.10.2026, adorfer,
  Windows-Rechner): erfolgreich.** `gluon-rampe-20261010-d-link-aquila-pro-ai-m60-a1-recovery.bin`
  (SHA256 `345c917b…5129f1`) per `curl.exe` an `http://192.168.200.1/upload.cgi`; die
  RAMpe kam danach unter `http://192.168.1.1` (Information: v2025.1.3, Release
  `20261010`, Site Gluon-RAMpe). Hochgeladen wurde das Neanderfunk-sysupgrade
  `gluon-nef-21_dias-26101300bro-d-link-aquila-pro-ai-m60-a1-sysupgrade.bin`
  (SHA256 `8833d7c5…`, 9.790.274 Bytes); Prüfsummenseite und Flash liefen, das
  Gerät läuft mit der Firmware. Das UBI-Switch-Image war nicht nötig.
  - Das `-recovery.bin` des M60 enthält das initramfs (OpenWrt 124f61eddb):
    Die D-Link-Recovery schreibt es in den Flash, U-Boot lädt es bei jedem
    Start, die RAMpe läuft im RAM. Sie kommt deshalb nach jedem Neustart wieder
    im Config-Mode mit der Upload-Seite hoch, bis das sysupgrade sie ersetzt
    (adorfer, 15.10.2026). Für eine squashfs-RAMpe belegt das nichts.
  - Zeiten und LED (zweiter Durchgang gemessen): Datenübertragung etwa 31 s für
    50 MB, curl wartet danach auf die Antwort; LED blinkt rot während Upload und
    Schreiben (wie Commit 7271ee5), Neustart etwa 1:45 min nach Upload-Start,
    1-Hz-Blinken = RAMpe im Config-Mode gut 2 Minuten nach Upload-Start
    (Testplatz 30.09. mit OpenWrt-Image gleicher Größe: rund 11 Minuten). Ein
    orangefarbenes Dimmen ist nicht die Recovery; nur die Reset-Taste führt
    hinein. Maßstab für Erfolg ist die Menge (etwa 52,4 Mio. Bytes), nicht die
    Dauer; der Fehlversuch war "Failed to connect", HTTP 000, 0 Bytes.
  - Die RAMpe zeigt MAC `06:00:dc:ea:e7:af` (Hostname `0600dceae7af`): die
    bekannte falsche MAC aus Odm-Offset 0x81, weil die RAMpe ohne
    gluon-patches-hardware gebaut ist. Ohne Folgen, da mit `sysupgrade -n`
    geflasht wird und die Neanderfunk-Firmware die MAC selbst richtig liest
    [abgeleitet, am Gerät noch bestätigen].
  - Stolperfallen beim Upload, **nicht RAMpe-spezifisch**: Sie liegen an der
    D-Link-Recovery bzw. am Upload-Weg und treten genauso unter Linux mit dem
    OpenWrt-initramfs auf (am Wochenende 10./11.10. sind zwei Nutzer daran
    gescheitert). Ein unvollständiger Upload (hier: Datei nicht gefunden,
    PowerShell-Variable in cmd) ist harmlos, der Router startet wieder die
    Herstellerfirmware. Rechner-Eigenheiten: unter Windows `curl.exe`; aus WSL2
    im Mirrored-Modus kam keine Verbindung zu `192.168.200.1` zustande, aus
    Windows schon.
  - Nach dem sysupgrade aus der RAMpe: Neanderfunk-Firmware nach unter 2
    Minuten da, primäre MAC = Aufkleber (Odm-Fix wirkt beim Erststart),
    Vorgabe-Hostname nach Neanderfunk-Schema, WLAN-Mesh läuft, beide Radios mit
    Client-Netz und OWE. Nicht notiert: ob sie über den Config-Mode kam.
  - Die Herstellerfirmware antwortet mit ihrem Admin-Login ebenfalls unter
    `192.168.200.1`; wer nach dem Upload eine Seite mit Passwortabfrage sieht,
    ist zurück in der Herstellerfirmware.
  - Browser-Upload in die Recovery war bei den zwei Nutzern vom Wochenende auch
    in Chromium nach unter 1 s "fertig", ohne Übertragung: curl ist der Weg.

## Offen / nächste Schritte

1. **M30-Hardware-Test.** Dazu gleich prüfen, ob das WLAN nach dem Wechsel
   auf die Community-Firmware geht; FFRN berichtete ein WLAN-Problem nach
   sysupgrade, bei Gluon 2023.2 auf der M30.
2. M60: Gluons recovery-Image in v2025.1.x prüfen. Ist es derselbe Fehler, gibt es zwei Wege:
   Neanderfunk-2025.1 wirft es raus (wie bei der M30), oder das
   Installer-Image ersetzt es.
3. Weitere Geräte aus `docs/GERAETE.md` ("Passt"), zuerst Genexis Pulse
   EX400, ASUS RT-AX52/RT-AX53U, MikroTik. (COVR-X1860 ist laut Inventar
   10.10.2026 kein Kandidat.)
4. ERX: erledigt, kein Kandidat unter 2025.1 (6.6-Kernel größer als der
   3-MB-Slot, kein factory.tar in OpenWrt 24.10.8); dafür die ERX-Migration.
5. Release-Weg: fertige Images als GitHub-Release anhängen (SHA256SUMS
   liegt schon bei). Evtl. per CI; Gluon rechnet mit 5 GB plus 10 GB je
   Target und mehr als einer Stunde Bauzeit. Für GitHub-Runner ist das grenzwertig.
6. Optional: den Hinweistext auf der Seite nach ersten Nutzer-Rückmeldungen
   schärfen (sysupgrade statt factory, Community-Download-Seite finden).
7. Optional: Gluon-Version im Image-Namen, falls mehrere Basen parallel
   gebaut werden.
8. **Langfristig: alle RAMpe-Bauten auf dem Buildhost** (adorfer
   15.10.2026). Ein Skript, das im Container alle Rezepte durchbaut, ein
   `build.sh`-Lauf je Target wie in `docs/GERAETE.md` "Bau-Läufe". Bisher
   lief das von Hand mit einem lokalen Wrapper je Welle. Dazu ein zweiter
   Strang für den **WS-AP3825i** auf älterer Basis: Jedes OpenWrt-initramfs
   ab 23.05 hängt dort bei `ft_fixup_l2cache: FDT_ERR_NOTFOUND`, nur 22.03.0
   startet (OpenWrt-Issue 17152). Kandidat ist eine RAMpe auf Gluon v2022.1
   (OpenWrt 22.03). Dann gehört die Gluon-Basis in den Image-Namen (Punkt 7).

## Fallstricke beim Weiterbauen

- Targets derselben Architektur teilen sich `staging_dir/target-<arch>`
  (filogic/qualcommax, ath79-*/lantiq, ipq40xx-generic/-mikrotik). Ohne
  Neuverpacken von `package/kernel/linux` je Lauf prüft OpenWrt Kernel-Pakete
  gegen die `provides`-Liste des anderen Targets (15.10.2026: TUF-Lauf,
  `usbcore.ko` fehlt). `build.sh` macht das seitdem vor jedem Lauf.
- Alle eingesammelten Images tragen seit 15.10.2026 die Release-Kennung
  (Baudatum) im Namen, auch das rohe initramfs: `gluon-rampe-<Datum>-<gerät>-…`.
- `gluon/` ist ein normaler Gluon-Checkout. Handänderungen darin gehen beim
  nächsten `build.sh` in `targets/` verloren (`git checkout -- targets`).
  `openwrt/files` wird jedes Mal komplett ersetzt.
- Der Rezeptname muss exakt der Gluon-Gerätename sein (erster Parameter von
  `device(...)`); `build.sh` gibt ihn als `GLUON_DEVICES` weiter und sucht
  die Images danach.
- `pkill -f qemu` / `pgrep -f` treffen die eigene Shell, wenn „qemu“ in
  deren Kommandozeile steht. Das Muster `[q]emu` verwenden.
- Hochgeladen gehört das **sysupgrade**-Image. Ein factory-Image fällt in
  der Regel schon bei `sysupgrade -T` durch, die Seite zeigt dann den Fehler.

## Herkunft

- Repo: github.com/Neanderfunk/gluon-rampe-installer (public), seit
  10.10.2026 so benannt (adorfer), vorher `gluon-ramboot-installer`; GitHub
  leitet die alte Adresse weiter. Projektname seit 10.10.2026 **Gluon-RAMpe**
  („RAM“ für Ramboot, auch wenn nicht jedes Gerät aus dem RAM bootet), vorher
  „Freifunk-Installer“.
- Dateinamen seit 10.10.2026 einheitlich: `gluon-rampe-<datum>-…` (nach
  `site_code`), die rohen initramfs-Kernel `gluon-rampe-<gerät>-initramfs-kernel.bin`.

- Prototyp in `~/projekte/freifunk/installer` (Neanderfunk-Arbeitsplatz),
  zuvor ein Wegwerf-Baum ohne git. Gebaute Artefakte des Prototyps:
  `~/projekte/freifunk/scratch/2026-09-11-m30/`.
- Neanderfunk-Firmware (github.com/Adorfer/firmware) hat mit dem Installer
  nichts zu tun, außer dass die dort gebauten sysupgrade-Images hochgeladen
  werden.

## Stand 01.10.2026: das Projekt ruht

adorfer am 01.10.2026: Das Projekt liegt vorerst still, das Ziel bleibt aber
bestehen. Wir wollen eigene Liveboot-Images (ramboot) anbieten, die man in die
Recovery des Herstellers lädt - bei D-Link und anderen -, um danach das
eigentliche Gluon bequem über die Weboberfläche einzuspielen.

Eine Falle für alle, die hier weitermachen: In den Anleitungen zur
D-Link-Recovery ist immer das **OpenWrt-initramfs** gemeint, auch wenn die
Benennung etwas anderes nahelegt. Die Namen sind sowohl in fremden Anleitungen
als auch im OpenWrt-Wiki uneinheitlich, und der Linktext stimmt dort regelmäßig
nicht mit dem Dateinamen überein. Wer sich auf den Linktext verlässt, lädt das
falsche Abbild.

Wie die D-Link-Geräte geflasht werden, steht in der Router-Werkstatt unter
`docs/dlink-flashen.md`.

## Stand 10.10.2026: wieder aufgenommen

- **Name:** Projekt heißt **Gluon-RAMpe**, Repo `Neanderfunk/gluon-rampe-installer`
  (vorher Freifunk-Installer bzw. `gluon-ramboot-installer`). Dateien
  `gluon-rampe-*`, `site_code = 'rampe'`, Docker-Image `gluon-rampe-build`.
  Der preinit-Hook heißt weiter `91_installer_initramfs`.
- **Inventar:** `docs/ERSTINSTALLATION-2025.1.md`, alle 351 Geräte der
  Neanderfunk-Firmware 2025.1 mit Weg ab Werk, Übertragung (TFTP-Server/-Client,
  FTP, Web, SSH …), serieller Konsole/Gehäuse, Links, Stock-Teilen, RAM und
  Eignung für die RAMpe. Erstellt aus OpenWrt-Commits und Image-Makefiles,
  nichts auf Hardware getestet. Ergebnis: passt bei 24 Geräten, teilweise bei 38.
  Kandidatenliste daraus in `docs/GERAETE.md`.
- **Regeln (adorfer):** Im Zweifel das RAMpe-Image mitbauen, auch wenn Gluon
  schon ein "factory" hat, das vielleicht nicht taugt (MikroTik). TFTP- und
  Recovery-Dateinamen in Anleitungen immer in der strengsten Fassung.
- **Rezepte heute:** M30 (gebaut), x86-64 (getestet), dazu neu, noch nie gebaut:
  `mercusys-mr90x-v1.sh`, `mercusys-mr80x-v3.sh`. Der MR80X ist in Gluon
  v2025.1.3 nicht enthalten; das Rezept trägt ihn über `ensure_device` (neu in
  `devices/lib.sh`) ein. Für die Community-Firmware gibt es ihn seit dem
  Backport gluon-patches-hardware `ab19bf1` (Neanderfunk 2025.1, 10.10.2026).
- **In Arbeit:** Rezeptentwürfe für alle Geräte, bei denen die RAMpe passt
  oder teilweise passt (rund 50 Geräte, zwei Gruppen: A filogic/ramips/ipq/
  qualcommax, B MikroTik/AVM-EVA/OCEDO/ZTE/serielle Unternehmens-APs). Offene
  Fragen dabei: Sammelt Gluons `extra_images` OpenWrt-ARTIFACTS ein
  (`initramfs.trx`, `web-ui-factory.fit`, `initramfs-factory.ubi`, `.ari`)?
  Welche Target-Schalter (initramfs, Kompression) braucht jedes Gerät? Passt
  ein Gluon-initramfs bei 64 MB RAM? Wo fehlt ein Vorbereitungsschritt vor dem
  sysupgrade (Aruba `ubiformat`, AVM U-Boot/`ubirmvol`, OCEDO, Sophos RED),
  und kann die RAMpe ihn geräteabhängig übernehmen?
- **Nächster Bau:** filogic in einem Lauf:
  `contrib/docker/run.sh ./build.sh mediatek-filogic d-link-aquila-pro-ai-m30-a1 mercusys-mr90x-v1 mercusys-mr80x-v3`
  (dabei prüfen: Dateinamen `gluon-rampe-…`, Seite zeigt "Gluon-RAMpe").

## Stand 13.10.2026

- **Rezepte:** 57 in `devices/` (24 aus Gruppe A, 29 aus Gruppe B, dazu M30,
  x86-64, MR90X, MR80X), plus 5 Aliasnamen ohne eigenes Rezept (Instant On
  AP11/AP11D/AP17, FRITZ!Box 7520, DISC Lite5 ac). Alle per Trockenlauf gegen
  `targets/` von Gluon v2025.1.3 geprüft (Lua gültig, Geräte bekannt).
  `lib.sh`: `ensure_target_config_value`, `ensure_device` mit Lua-Option,
  `ensure_device_option`, `ensure_site_packages`, `ensure_site_unbroken`,
  `ensure_openwrt_backport` (`RAMPE_HW_PATCHES`). `build.sh`: Rezepte vor
  `make update`, sammelt jedes `-initramfs*` ein, warnt bei nichts
  eingesammelt bzw. ab 32 MiB. Bau-Läufe je Target in `docs/GERAETE.md`.
- **Gebaut (lokal, 10.10.2026), Hardware-Test offen:** M30 und M60
  `-recovery.bin` (D-Link-Header und `91_installer_initramfs` geprüft; das
  M60-Image noch am selben Tag am Gerät erprobt, siehe "Getestet"), MR80X
  v3 und MR90X v1 `initramfs-kernel.bin` (je etwa 8.1 MB). Liegen in `out/`.
- **Vorbereitung vor dem sysupgrade** (Aruba, AVM 7530/Repeater, MF289F,
  OCEDO, RED 15w, MF281, AVM 7412/7430): zwei Entwürfe in
  `docs/ENTWURF-VORBEREITUNG.md` (Controller-Haken bzw.
  `platform_pre_upgrade`), bewusst nicht übernommen (ungetesteter Flash-Code).
- **Inventar:** gepflegt wird nur `data/geraete-2025.1.json`;
  `scripts/erstinstallation.py` erzeugt daraus `ERSTINSTALLATION-2025.1.md`
  und die Rezepttabelle in `GERAETE.md` (`--check`). Felder für die
  Anleitungen nach Content-Vorschlag: `schritte` (Liste, Normalweg), `warnung`,
  `notweg` (mit Art `[Notfall]`/`[Alternative]`/`[einfacher, schlechter
  belegt]`), `fehlerbild`, `anschluss`, `adressen`, `programm`, `zugang`,
  `datei`, `taste`, `zeichen`, `verwechslung`, `stock_bedingung`, `dauer`,
  `rueckweg` (nice to have), `hw_test`. Befüllt für 343 von 351 Geräten; es
  fehlen die 8 Xiaomi-Exploit-Geräte (der Sicherheitsfilter der Agenten brach
  ab), 15 Exploit-/Bootloader-Geräte sind nur mechanisch übernommen
  (`[noch nicht aufgeteilt]`). Familiennotizen, Widersprüche und Hardwaretest-
  Kandidaten in `docs/ANLEITUNGSFAMILIEN.md`.
- **Belegmarken:** `[geprüft: …]` nur für Quellen im Original. Die Wiki-Angaben
  sind am DokuWiki-Rohtext nachgeprüft (809 Marken, rund 740 jetzt
  `[geprüft: Wiki …]`, 14 Angaben korrigiert, u. a. EA8300 `fw_setenv
  kernsize 500000`). 67 bleiben `[Wiki-Zusammenfassung]` (Seite fehlt).
- **Hardware-Tests geplant:** M30 (M60 erledigt, siehe "Getestet") (RAMpe-`recovery.bin` per `curl` in die
  D-Link-Recovery, siehe GERAETE.md), MR80X v3 (erst prüfen, ob die Stock-
  Firmware SSH 20001 und IPTV/Hotplug wie der MR90X hat), dazu die zwölf
  Geräte mit `[einfacher, schlechter belegt]`.
- ~~Mercusys MR3000X v2.0 nicht in Gluon 2025.1~~ überholt 17.10.2026: als
  Backport (Target qualcommax-ipq50xx) auf dem Zweig v2025.1.x-next, siehe
  "Stand 17.10.2026 abends".

## Stand 15.10.2026: alle Rezepte gebaut

- **Veröffentlicht** (adorfer, 15.10.2026): https://download.ffnef.de/other/Gluon-Installer-RAMpe/
- **67 Rezepte, 85 Dateien** `gluon-rampe-20261015-*`, alle 14 Bauläufe
  ohne Fehler und ohne "nichts eingesammelt". Seit 15.10.2026 (Wunsch
  adorfer) baut `build.sh` in ein eigenes Verzeichnis `out/images/`, das nur
  Veröffentlichbares enthält und "as is" auf den Server gespiegelt wird:
  Images, `uboot-fritz*.bin`, `SHA256SUMS` und `LISTE.md` (Gerät, Datei, Art,
  Größe, SHA256; `scripts/rampe-liste.py`). Logs in `out/logs/`, ältere Stände
  eines Geräts verschiebt `build.sh` beim Neubau nach `out/archiv/`.
- Neu in allen Images: `gluon.css?v=<Release>` (Browser-Cache) und die
  Umleitung https -> http auf Port 443 (selbstsigniertes Zertifikat je Lauf,
  `libustream-mbedtls`). x86-64 in QEMU bestanden (`test/qemu-x86-64.sh`,
  prüft beides mit).
- `build.sh`: Kernel-Modulpakete je Lauf neu verpacken (gemeinsames Staging
  gleicher Architekturen), Release-Kennung in allen Dateinamen.
- Zehn neue Rezepte (dauerhafte RAMpe im Hersteller-Format bzw. initramfs):
  GL-E750, GL-XE300, MR8300, WNDR3700 v5, Xiaomi Mi 3G, Mi AC2100, Redmi
  AC2100, Archer C60 v1, DIR-825 B1, DAP-X1860.
- DIR-825 B1: RAMpe-initramfs 6.257.577 Bytes (6111 KiB), also unter den
  6144k der D-Link-Recovery; das OpenWrt-initramfs 24.10.8 lag mit 6145 KB
  knapp darüber. Ob die Recovery es nimmt, ist weiter offen.
- Die Stände ohne Cache-Schutz vom 14.10. sind gelöscht (adorfer, 15.10.2026);
  der am M60 erprobte Stand vom 10.10. liegt in `out/archiv/`.
- **Vorbereitung vor dem sysupgrade** (adorfer 15.10.2026: "RAMpe
  ergänzen", für FRITZ!Box 7520/7530 und FRITZ!Repeater 1200/3000):
  Controller `overlay/.../controller/admin/upgrade.lua` (Kopie von Gluons
  upgrade.lua) ruft in Schritt 3 synchron
  `/lib/gluon-rampe/prepare/<board_name>.sh` auf; scheitert es, wird nicht
  geflasht und die Seite zeigt das Protokoll. AVM-Skripte schreiben den
  OpenWrt-U-Boot nach uboot0/uboot1 und entfernen avm_filesys_0/1 (Befehle
  wie in den Commits). 7520/7530: U-Boot nach HWRevision aus dem TFFS (236 /
  247), sonst Abbruch ohne Schreiben. Die U-Boot-Datei kommt über
  `package/gluon-rampe-uboot-fritz` ins Image (die u-boot-fritz*-Pakete
  lassen sich in Gluon nicht je Gerät wählen). x86-64 in QEMU bestanden
  (Fehlschlag flasht nicht, Erfolg läuft vor dem sysupgrade); ipq40xx-Images
  neu gebaut, U-Boot-Dateien darin byteweise gleich den veröffentlichten.
  **Am Gerät ungetestet.** Offen: eine per HWRevision zur 7530 umgestellte
  7520 (EVA-Offset im U-Boot unterscheidet sich).

## Stand 16.10.2026: 249 Anleitungen, Levels, AVM-Vorbereitung

**Anleitungen** (Vorlagen und Texte von Content, Werte und Erzeugung hier,
Verdrahtung im Selector durch Supernode-Betrieb; live erst nach adorfers
Deploy):
- 249 Seiten. Seit 15.10. dazugekommen: AVM (eva-ftp, eva-ramboot,
  eva-uboot), Zyxel WSM20 (erprobt), Genexis EX400, Aruba APBoot (6),
  TOTOLINK X5000R, NanoBeam M5 XW, Cudy TR3000 v1 (Zwischenfirmware statt
  seriell), ASUS TUF-AX4200/AX6000, TP-Link EAP (5), UniFi 6 LR v2/v3,
  Sophos (6), devolo WiFi pro (6), seriell-tftp (WS-AP3825i, 3705i, 3710i,
  3805i, Siemens AP3610), 7360 v1, HPE MSM460, TP-Link tftp-recovery (9),
  Archer C50 v4 (erprobt 15.10. durch adorfer), C20 v5, C50 v6, C2 v1,
  C20 v1.
- Zurückgezogen: Rocket M XM (XM ist Sackgasse), WS-AP3715i (das
  2025.1-sysupgrade bootet nicht, Gluon #3842, Fix OpenWrt-PR #25541 offen;
  Werte in `440a725` zum Zurückholen).
- **Levels L0 bis L8 und Risiko** (Einteilung adorfer 15.10.2026) ersetzen
  die vier Stufen: `scripts/level.py` (Definitionen, Bezeichnungen für Lesende
  von Content), je Gerät `level_merkmale` mit festen Werten, `risiko`
  (normal/bootloader/offen) und `level_grund` für Einzelentscheidungen. Neue
  Geräte bekommen ihre Merkmale von Hand: Familie = Hauptweg der Vorlage, feste
  IP ergibt sich aus `rechner_ip`, GL.iNet aus `weg`. Entscheidungen adorfer:
  Netgear mit nutzbarer Oberfläche nach dem leichtesten Weg (L0.1), feste IP
  ohne Taste = L3, Image auf Datenträger = L4, AVM mit OpenWrt-U-Boot als zweiter
  Stufe (EVA bleibt) = Risiko normal. Inventar mit Spalten Level/Risiko und
  Zählung; `index.json` mit `level`/`risiko` statt `stufe`; Übersicht als
  Tabelle Gerät | Stand | Level mit Legende, auf dem Handy ohne seitlichen
  Überlauf.
- Generator (`scripts/anleitungen.py`): Jinja-Lader für `{% include %}`,
  sauberer Anzeigename und Feld `anzeige`, `gluon_broken`, YAML-Kopf gequotet,
  Abschnitt "## Achtung" als Warnkasten, verwaiste Seiten werden entfernt,
  Hinweis bei ungesicherten Daten. **Reihenfolge:** erst die Daten committen
  (auch nach `--verlinken`), dann erzeugen, sonst steht `daten_stand: lokal`
  auf allen Seiten.
- Belegmarken erscheinen öffentlich unter "Herkunft der Angaben": dort keine
  internen Sitzungsnamen ("Content"), eigene Tests als "Test Neanderfunk".
- Spiegel und Downloads: Cudy-Zwischenfirmware als Direktlinks in
  `firmware.ffnef.de/other/cudy-mirror-20261015/`; AP11-Bootloader und
  X5000R-Altfirmware als ZIP in `download.ffnef.de/other/dump/`.

**RAMpe:**
- Vorbereitung vor dem sysupgrade für FRITZ!Box 7520/7530 und FRITZ!Repeater
  1200/3000 eingebaut und im QEMU-Test geprüft (siehe Abschnitt 15.10.),
  Images auf dem Server; am Gerät ungetestet.
- WS-AP3825i: Das RAMpe-initramfs (Kernel 6.6) startet vermutlich nicht.
  Ursache laut OpenWrt #25302: Bei größeren Images linkt der Bootwrapper den
  Loader an eine andere Adresse als im uImage-Kopf. Fix PR #25541.
- Langfristig (adorfer 16.10.): alle RAMpe-Bauten als ein Skript im Container
  auf dem Buildhost, dazu ein Strang auf Gluon v2022.1 für den WS-AP3825i
  (Punkt 8 unter "Offen").
- WS-AP3825i/mpc85xx: Der Loader-Fix ist seit 16.10. als eigener Patch in
  gluon-patches-hardware (`188dff9`, `kernel/mpc85xx-simpleimage-loader`).
  Die RAMpe für mpc85xx muss damit neu gebaut werden (über
  `RAMPE_HW_PATCHES`), der Strang auf v2022.1 ist dann womöglich unnötig.
- **Am Gerät erprobt (Testplatz grw, adorfer und Supernode-Betrieb,
  16.10.):** D-Link M60 (drittes Gerät) und M30 mit RAMpe `20261015`, je
  Recovery, curl-Upload nach Anleitung, RAMpe, Gluon `26100702bro`. Die
  "~11 Minuten" bis curl zurückkommt sind nur das TCP-Timeout der toten
  Verbindung (`Recv failure`, rc 56); der M60 startete nach 18 s neu, die
  RAMpe stand nach ~1 min.
- **`/cgi-bin/luci` leitet auf `/cgi-bin/config`** (Overlay
  `lib/gluon/config-mode/www/cgi-bin/luci`, ab der nächsten RAMpe-Ausgabe).
  Firefox landete nach einer OpenWrt-Oberfläche unter 192.168.1.1 auf
  `/cgi-bin/luci/` und bekam "Not Found". Ursache nicht belegt: Cache (304)
  und Autovervollständigung erklären die Gegenprobe am X5000R-Bootloader nicht
  (half erst ein frisches Firefox-Profil), Verdacht ist eine gespeicherte
  Weiterleitung. Die Umleitung hilft so oder so. QEMU-Test prüft drei LuCI-Pfade, bestanden mit einem
  Testbau `20261016luci` (nicht veröffentlicht).
- Offen: Die RAMpe auf M30/M60 zeigt beim M60 die alte falsche Knoten-ID
  `0600dceae7af` (Odm 0x81). Der Odm-Parser aus gluon-patches-hardware
  (`devices/dlink-aquila-odm-mac`) fehlt im RAMpe-Bau. Folgen hat das nur,
  wenn mehrere solche RAMpes gleichzeitig am selben Netz hängen (gleiche
  MAC). Beim Einzel-M30 mit Odm-Eintrag 0x81 stimmt die MAC.

## Stand 17.10.2026 abends: neue Geräte aus dem Zweig v2025.1.x-next

- **33 Geräte neu im Datensatz** (jetzt 386), alle nur auf dem Zweig
  `v2025.1.x-next` von gluon-patches-hardware/FirmwareConfigs, noch nicht im
  Release-Stand. Ohne Anleitungsfamilie bzw. ohne `werte`, also noch ohne
  Seiten (Content):
  - Mercusys MR80X v2 und Alias MR3000X v2.0 (Target qualcommax-ipq50xx,
    Backport aus OpenWrt main; am Gerät erprobt, Einzelheiten router-werkstatt
    `docs/mercusys-mr3000x-v2.md`).
  - 28 MT7986-Geräte, deren Profil OpenWrt 24.10 schon hat (nur
    Gluon-Eintrag); Wege aus den OpenWrt-Ursprungscommits, entworfen von
    einem Hilfsagenten, Struktur geprüft, Wege nicht Satz für Satz.
  - TP-Link EAP683-LR (+ Alias EAP683-UR) und Zyxel WX5600-T0 im
    OpenWrt-U-Boot-Layout, Backport aus OpenWrt main; lokal gebaut, kein
    Gerät vorhanden.
- Bei Xiaomi-Geräten weiter keine Exploit-Einzelheiten im Datensatz.
- RAMpe-Rezepte für diese Geräte: noch keine. Für EAP683 und WX5600 nicht
  nötig (Installation über die Konsole), für MR80X v2 nicht nötig (Gluon-factory).

## Stand 17.10.2026: Abnahmen am Testplatz

Der Testplatz grw liegt seit 16.10. mittags bei Supernode-Betrieb
(Validierungskampagne, adorfer am Gerät). Ablauf: Supernode meldet Befund und
Protokoll (router-werkstatt `docs/validierung/`), Buildsystem trägt Werte und
`erprobt` in `data/geraete-2025.1.json` ein und erzeugt, Content passt die
Vorlagen an, Supernode verdrahtet den Selector, adorfer deployt.

**Erprobt** (Feld `erprobt`: `am`, `mit`, `weg`, `beleg`):
- Archer C50 v4 (15.10.), Cudy WR3000H v1 (S/N 2513, alter Flash), WR3000
  v1, WR3000S v1 (Gluon 2023.2.6), AP3000 v1, TOTOLINK X5000R, D-Link M60
  und M30 (RAMpe `20261015`), GL-B1300 (LuCI-Weg, Gluon 2023.2.6, 2025.1
  erwartet), TL-WDR3600 v1 (Oberfläche mit 2023.2.6, 2025.1 per TFTP),
  Mercusys MR70X v1 (aus Stock 1.0.11, HW V1.20).
- Nicht erprobt, aber mit Befunden: D-Link DIR-505 (eigene Vorlage
  `sonderweg-d-link-dir-505`, steiniger Weg über LEDE 17.01.7; die
  D-Link-Recovery eines A2/PCT schrieb nichts), TL-WDR3600 Ver 1.1 mit
  PCT-Zeichen und blauen LEDs (keine TFTP-Recovery).

**Regeln, die sich dabei ergeben haben:**
- `erprobt` steht in der Quelle (JSON), nie nur im erzeugten Kopf. `beleg`
  (Protokollpfad, Commit) wird nicht ausgegeben.
- Belegmarken erscheinen öffentlich unter "Herkunft": eigene Tests als
  `[geprüft: Test Neanderfunk <Datum>]`, keine Testplatz-Namen oder
  Werkstatt-Pfade (am 16.10. einmal falsch, a85bacac).
- `erprobt` erst setzen, wenn die Seite den erprobten Weg beschreibt (GL-B1300:
  erst nach der Vorlagen-Variante `gl-luci`).
- Werte müssen in den Satz der Vorlage passen (MR70X: `nach_upload` ist ein
  Satzteil nach "Danach zeigt der Browser …"). Einen Wert leeren kann einen
  Vorgabesatz zurückholen (AP3000: leeres `rueckweg_buchse` ergab wieder "eine
  LAN-Buchse").
- `level_merkmale` folgen dem Hauptweg der Seite: GL-B1300 L0 (vorher L3),
  AP3000 L3 (vergibt keine Adressen), DIR-505 L1.

**Befunde, die über ein Gerät hinausgehen:**
- Cudy: Die LED-Angaben der Cudy-FAQ zur TFTP-Recovery stimmten am WR3000H
  nicht; bei den anderen Cudy stehen die beobachteten als [abgeleitet].
  `rueckweg_url` je Modell gegen das og:title der Seite geprüft, weil Cudy auch
  für erfundene Pfade 200 liefert. Cudy-APs (AP3000) vergeben ab Werk keine
  Adressen und nehmen nach etwa einer Minute 192.168.10.254; AP3000
  Outdoor/Wall und AP1300 Outdoor sind darauf nicht geprüft.
- GL.iNet-Firmware 4.x (OpenWrt 21.02) prüft in der eigenen Oberfläche immer
  mit "Einstellungen behalten" und lehnt deshalb Gluon mit compat 1.1 ab;
  LuCI mit "Keep settings" aus und "Force upgrade" an geht, `sysupgrade -n`
  per SSH auch. Eine Flash-RAMpe mit `DEVICE_COMPAT_VERSION 1.0` war
  vorbereitet und ist verworfen (nicht nötig).
- DIR-505: Das factory kam beim Umzug nach ath79 nie mit (OpenWrt
  c9ac7b1729, ohne D-Link-Bootloader nicht testbar); `mkcameofw` ist in
  firmware-utils von 24.10 noch da, das Flash-Layout ist gleich.
- "Not Found" unter `/cgi-bin/luci` nach einer OpenWrt-Oberfläche:
  Ursache im Browser nicht belegt (Cache, Autovervollständigung oder
  gespeicherte Weiterleitung), half nur ein frisches Profil. Grundlagen
  `browser-not-found` und `router-antwortet-nicht` (Content).

**Offen für die nächste RAMpe-Ausgabe (Entscheidung adorfer, wann):** die
Umleitung `/cgi-bin/luci` (im Overlay, QEMU-getestet), der mpc85xx-Loader
(gluon-patches-hardware `188dff9` über `RAMPE_HW_PATCHES`, AP3825i-initramfs)
und der Odm-Parser für M30/M60. Danach neu veröffentlichen.

## Idee: EdgeRouter X/X-SFP in einem Schritt (15.10.2026, ungeprüft)

Auftrag adorfer, nur festgehalten, nicht begonnen. Heute braucht die
Neuinstallation aus EdgeOS drei Etappen: OpenWrt-22.03-initramfs-factory.tar
(stman) in EdgeOS, darkxst-Umstellung auf das 6-MB-Kernel-Layout mit OpenWrt
24.10 als `/tmp/sysupgrade.img`, dann Gluon-sysupgrade über LuCI. Eine RAMpe
auf Gluon-2025.1-Basis passt nicht in den 3-MB-Slot, den EdgeOS beschreibt
(Kernel 6.6 allein 3.173.556 Byte).

- darkxst `ubnt_erx_migrate.sh` (Commit d29f71a) prüft am Image nur, ob im
  Tar `sysupgrade-*/kernel` und `root` liegen; Board `ubnt,edgerouter-x` oder
  `-x-sfp`. Den Rest macht `ubnt_erx_stage2.sh` (Boot-Index in factory
  Offset 160 auf 0, Kernel über kernel1/kernel2, Rootfs ins UBI).
- Idee: ein Spezial-Image im EdgeOS-factory.tar-Format auf älterer Basis mit
  kleinem Kernel (wie stman 22.03, 3.010.560 Byte), das statt LuCI nur die
  RAMpe-Upload-Seite mitbringt und nach dem Hochladen des Gluon-2025.1-
  sysupgrade die darkxst-Umstellung mit genau diesem Image ausführt. Dann
  hieße es: factory.tar in EdgeOS, danach im Browser das Gluon-Image.
- Ob sich das lohnt, entscheidet adorfer. Die Laienanleitung bleibt beim
  belegten Weg über OpenWrt 24.10; eine Abkürzung "Gluon-Image direkt als
  `/tmp/sysupgrade.img`" kommt dort nicht hinein (adorfer).
