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

## Fallstricke beim Weiterbauen

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
- **Nicht Gluon-RAMpe, aber verwandt:** Mercusys MR3000X v2.0 (= MR80X v2,
  IPQ5018, 256 MB) läuft am Testplatz mit OpenWrt main (c127dev-Build, WLAN
  mit `kmod-ath11k-smallbuffers`); OpenWrt 24.10/25.12 und damit Gluon 2025.1
  kennen das Gerät nicht. Einzelheiten in einer Neanderfunk-Notiz.
