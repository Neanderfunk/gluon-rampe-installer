---
gluon_name: avm-fritz-box-7362-sl
modell: AVM FRITZ!Box 7362 SL
anzeige: AVM FRITZ!Box 7362 SL
familie: avm-eva-ramboot
gluon_broken: false
sprache: de
level: L5
level_text: Besondere Programme
risiko: normal
status: ungeprüft
rampe_image: gluon-rampe-20261015-avm-fritz-box-7362-sl-initramfs-kernel.bin
grundlagen: [avm-eva, browser-https, browser-not-found, feste-ip]
daten_stand: f73c9aa2
vorlage_stand: 883c350d
---

# AVM FRITZ!Box 7362 SL: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20AVM%20FRITZ%21Box%207362%20SL)

Der Bootloader von AVM nimmt in den ersten Sekunden nach dem Einschalten
Verbindungen per FTP an ([Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md)).
Darüber kommt zuerst die **Gluon-RAMpe** in den Arbeitsspeicher: eine kleine
Firmware, die nur eins kann, nämlich die Freifunk-Firmware deiner Community
annehmen. Die lädst du dann im Browser hoch.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel; ein einfacher Switch dazwischen hilft beim Timing
- Python 3 und das kleine Programm
  [eva_ramboot.py](https://raw.githubusercontent.com/openwrt/openwrt/a1ea57bd050c172fdc2b851824ebd9782aafb055/scripts/flashing/eva_ramboot.py) von OpenWrt
- die RAMpe für dieses Gerät:
  [gluon-rampe-20261015-avm-fritz-box-7362-sl-initramfs-kernel.bin](https://download.ffnef.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261015-avm-fritz-box-7362-sl-initramfs-kernel.bin)
- die Freifunk-Firmware deiner Community für dieses Gerät, und zwar das
  **sysupgrade**-Image

## Vorher prüfen

Bei der 7362 SL ist das Zeitfenster besonders kurz, etwa 4 Sekunden. Ein
einfacher Switch zwischen Box und Rechner hilft.

## Schritte

1. **Rechner vorbereiten.** Feste Adresse `192.168.178.10`, Netzmaske
   `255.255.255.0` ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
   WLAN am Rechner aus. Leg eva_ramboot.py und die RAMpe in einen Ordner und
   öffne dort ein Terminal.

2. **Verbinden.** Kabel vom Rechner an eine LAN-Buchse der Box, wenn
   vorhanden über einen einfachen Switch.

3. **Den richtigen Firmware-Speicher wählen.** Die Box hat zwei Speicher für
   die Firmware. Damit die Freifunk-Firmware später auch startet, muss der
   erste gewählt sein. Strom an der Box ziehen, wieder einstecken und
   **sofort**:

   ```
   python3 -c "from ftplib import FTP; f=FTP('192.168.178.1','adam2','adam2'); print(f.sendcmd('SETENV linux_fs_start 0'))"
   ```

   Kommt eine Fehlermeldung, war das Zeitfenster vorbei: Strom ziehen und
   noch einmal. Geklappt hat es, wenn eine Antwort mit `200` kommt.

4. **RAMpe laden.** Strom an der Box noch einmal ziehen, wieder einstecken
   und nach wenigen Sekunden:

   ```
   python3 eva_ramboot.py 192.168.178.1 gluon-rampe-20261015-avm-fritz-box-7362-sl-initramfs-kernel.bin
   ```

   Das Programm zeigt, was es mit der Box bespricht, und endet von selbst.
   Kommt eine Fehlermeldung, Strom ziehen und noch einmal.

5. **Die RAMpe.** Die Box startet jetzt die RAMpe aus dem Arbeitsspeicher. Die Power-LED blinkt dann rot. Stell den Rechner auf
   "automatisch" und öffne nach etwa einer Minute
   `http://192.168.1.1/cgi-bin/config`. Es erscheint die Seite "Firmware
   aktualisieren". Kommt "Not Found", hat sich der Browser eine Seite von
   früher gemerkt: Tipp die Adresse vollständig ein, mit `/cgi-bin/config` am
   Ende. Hilft das nicht, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"](../bilder/allgemein/rampe-seite.png)

   Die RAMpe läuft nur im Arbeitsspeicher. Geht der Strom aus, ist sie weg:
   dann wieder ab Schritt 4.

6. **Freifunk-Firmware hochladen.** Wähl das sysupgrade-Image deiner
   Community und klick "Datei hochladen". Die RAMpe zeigt die Prüfsumme
   (SHA256); vergleich sie mit der Angabe deiner Community und klick
   "Fortfahren".

   ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"](../bilder/allgemein/rampe-pruefsumme.png)

7. **Fertig.** Die Box schreibt die Firmware und startet neu, **Strom nicht
   ziehen**. Der erste Start kann etwas länger dauern. Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- Schritt 3 antwortet mit `200`.
- Nach Schritt 4 erscheint unter `http://192.168.1.1` die Seite der RAMpe.
- Nach Schritt 7 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Box antwortet nicht.** Das Zeitfenster ist kurz. Einen einfachen
  Switch zwischen Box und Rechner stecken, WLAN am Rechner aus, und noch
  einmal.
- **Nach Schritt 7 startet wieder FRITZ!OS.** Dann stand der
  Firmware-Speicher noch auf dem zweiten. Schritt 3 wiederholen, dann ab
  Schritt 4 noch einmal.
- **Unter `http://192.168.1.1` kommt eine Zertifikatswarnung.** Siehe
  [Browser macht https daraus](grundlagen/browser-https.md).
- **Die Power-LED blinkt grün statt rot.** Das wurde auch schon beobachtet.
  Einfach `http://192.168.1.1` aufrufen.

## Zurück zu FRITZ!OS

AVM hat für jedes Gerät ein Wiederherstellungs-Programm (für Windows), das
die Original-Firmware zurückspielt. Es liegt auf dem Download-Server von AVM
im Ordner des Geräts unter "recover". Geräte von Providern (zum Beispiel
1&1) verweigern das eventuell; dann vorher per FTP
`quote UNSETENV provider` ([Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md)).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Dauer, Gluon-RAMpe passt)
- abgeleitet: OpenWrt-Wiki "AVM recovery tool" (Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki 7362 SL (Schritte (Normalweg), Sichtbare Zeichen, Anschluss, Fehlerbild, Rückweg zur Herstellerfirmware)
- abgeleitet: dasselbe Wiki (Rückweg zur Herstellerfirmware)
- geprüft (Weg ab Werk, Schritte (Normalweg), Datei)
- geprüft: Commit (Sichtbare Zeichen)
- geprüft: Commit 7362 SL (Dauer)
- geprüft: Commit, Skript am Pin (Programm)
- geprüft: Commit; config/Config-images.in am Pin (Datei)
- geprüft: Commits 7412/7430/7362 SL (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Commits 7412/7430; abgeleitet: Wiki 7362 SL (Schritte (Normalweg), Adressen)
- geprüft: fritz-tools-Doku (Typenschild/Verwechslung)
- geprüft; abgeleitet (Schritte (Normalweg))
- geprüft; geprüft: Commit; config/Config-images.in am Pin (Schritte (Normalweg))
- Geräteeintrag: eae6cac6a30b95bef04d033ed8a303b7e35a078b
