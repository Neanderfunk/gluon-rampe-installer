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
- D-Link M30: Image gebaut (52 MB, Header `DLK6E6110001` wie bei OpenWrt),
  cpio-Inhalt geprüft (preinit-Hook, Controller, View, CREDITS).
  **Auf Hardware nicht getestet.**

## Offen / nächste Schritte

1. **M30-Hardware-Test.** Dazu gleich prüfen, ob das WLAN nach dem Wechsel
   auf die Community-Firmware geht; FFRN berichtete ein WLAN-Problem nach
   sysupgrade, bei Gluon 2023.2 auf der M30.
2. M60: Gluons recovery-Image in v2025.1.x prüfen. Ist es derselbe Fehler, gibt es zwei Wege:
   Neanderfunk-2025.1 wirft es raus (wie bei der M30), oder das
   Installer-Image ersetzt es.
3. Weitere Geräte aus `docs/GERAETE.md`, zuerst COVR-X1860 und ASUS.
4. ERX: oszilloskops Original-Anwendungsfall. Das EdgeOS-Upgrade will ein
   tar mit Kernel und Rootfs. Prüfen, ob das OpenWrt-initramfs-factory dafür
   reicht.
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

- Prototyp in `~/projekte/freifunk/installer` (Neanderfunk-Arbeitsplatz),
  zuvor ein Wegwerf-Baum ohne git. Gebaute Artefakte des Prototyps:
  `~/projekte/freifunk/scratch/2026-09-11-m30/`.
- Neanderfunk-Firmware (github.com/Adorfer/firmware) hat mit dem Installer
  nichts zu tun, außer dass die dort gebauten sysupgrade-Images hochgeladen
  werden.
