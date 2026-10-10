# Gluon-RAMpe (gluon-rampe-installer)

Die **Gluon-RAMpe**: ein Gluon, das aus dem RAM läuft und genau eine
Seite hat – Community-Firmware hochladen.

**Nach einer Idee von oszilloskop:
[UBNT_ERX_Gluon_Factory-Image](https://github.com/oszilloskop/UBNT_ERX_Gluon_Factory-Image).**
Die Controller-Dateien, die die Startseite auf „Firmware aktualisieren“
umbiegen, der Kniff, den Config-Mode im initramfs zu erzwingen, und das
Weglassen von „Einstellungen behalten“ stammen aus diesem Projekt
(MIT-Lizenz, Copyright (c) 2018 Oszilloskop, siehe `LICENSE.oszilloskop`).
Danke!

Viele Router lassen sich nur zweistufig mit Gluon bespielen: erst ein
Zwischenimage über die Hersteller-Firmware oder -Recovery, dann das eigentliche
Gluon. Üblich ist als Zwischenschritt ein OpenWrt mit LuCI – samt Navigation
durch ein fremdes Menü und der Aufforderung, ein Passwort zu setzen.

Die Gluon-RAMpe ersetzt diesen Zwischenschritt: ein abgespecktes Gluon
in Gluon-Optik, das genau eine Seite hat – **sysupgrade-Image hochladen**. Er
ist community-unabhängig: hochgeladen wird das Image der eigenen Community,
geflasht wird ohne Einstellungen (`sysupgrade -n`), danach startet die
Freifunk-Firmware im Config-Mode wie gewohnt.

## Bauen

Am einfachsten im Container (Docker), der alle Werkzeuge mitbringt:

```sh
contrib/docker/run.sh ./build.sh mediatek-filogic d-link-aquila-pro-ai-m30-a1
```

Die Images landen in `out/`. Ohne Container: `./build.sh …` auf einem Host
mit Gluons Bauabhängigkeiten (siehe `contrib/docker/Dockerfile`).

Optionen per Umgebung: `GLUON_REF` (Default `v2025.1.3`), `JOBS`,
`GLUON_DIR`, `GLUON_REPO`. Kein Parallelbetrieb, keine Domain-Schleifen –
ein RAMpe-Image je Gerät reicht für alle Communities.

## Geräte

| Gerät | Target | Einspielen | Stand |
|---|---|---|---|
| D-Link AQUILA PRO AI M30 A1 | mediatek-filogic | `…-recovery.bin` über die D-Link-Recovery (192.168.200.1) | gebaut, **auf Hardware ungetestet** |
| x86-64 | x86-64 | `…-initramfs-kernel.bin` per QEMU `-kernel` | Ende-zu-Ende getestet (`test/qemu-x86-64.sh`) |

Weitere Kandidaten und wie man ein Gerät ergänzt: `docs/GERAETE.md`.
Wie jedes Gerät mit Gluon 2025.1 ab Werk installiert wird (Übertragungsweg,
serielle Konsole, Links, Eignung für die Gluon-RAMpe):
[`docs/ERSTINSTALLATION-2025.1.md`](docs/ERSTINSTALLATION-2025.1.md).
Dieselben Daten maschinenlesbar: [`data/geraete-2025.1.json`](data/geraete-2025.1.json)
(die gepflegte Quelle; das Markdown erzeugt `scripts/erstinstallation.py`).
Wie es funktioniert: `docs/FUNKTIONSWEISE.md`.

## Benutzen (Beispiel M30)

1. Router mit gedrückter Reset-Taste einschalten, Rechner auf
   192.168.200.10/24, http://192.168.200.1 öffnen, das RAMpe-Image
   `gluon-rampe-…-d-link-aquila-pro-ai-m30-a1-recovery.bin` hochladen.
2. Nach dem Neustart Rechner auf DHCP (oder 192.168.1.10/24),
   http://192.168.1.1 öffnen – die Seite der Gluon-RAMpe erscheint.
3. Das **sysupgrade**-Image der eigenen Community für die M30 hochladen und
   bestätigen. Der Router startet mit der Freifunk-Firmware im Config-Mode neu.

## Lizenzen

- eigene Skripte und Dateien: BSD-3-Clause (`LICENSE`)
- `overlay/lib/gluon/config-mode/controller/*/index.lua` und die Idee hinter
  `overlay/lib/preinit/91_installer_initramfs`: MIT, oszilloskop
  (`LICENSE.oszilloskop`)
- `overlay/lib/gluon/config-mode/view/admin/upgrade.html`: abgeleitet von
  Gluons gleichnamiger Datei, Apache-2.0 (Kopfzeilen dort)
- das Image selbst enthält `/usr/share/doc/gluon-rampe/CREDITS`
