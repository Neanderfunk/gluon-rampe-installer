---
gluon_name: avm-fritz-box-3370-rev-2-micron-nand
modell: "AVM FRITZ!Box 3370 Rev. 2, Micron-NAND (Gluon: broken)"
anzeige: AVM FRITZ!Box 3370 Rev. 2, Micron-NAND
familie: avm-eva-ftp
gluon_broken: true
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [avm-eva, feste-ip]
daten_stand: a7be2dd
vorlage_stand: 869501c
---

# AVM FRITZ!Box 3370 Rev. 2, Micron-NAND: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Die Freifunk-Firmware für dieses Gerät gilt bei Gluon als nicht ausreichend
> getestet ("broken"); nicht jede Community bietet sie an.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20AVM%20FRITZ%21Box%203370%20Rev.%202%2C%20Micron-NAND)

AVM-Geräte haben einen Bootloader, der in den ersten Sekunden nach dem
Einschalten Verbindungen per FTP annimmt. Darüber kommt die
Freifunk-Firmware direkt in den Speicher. Eine Taste brauchst du nicht, nur
das richtige Timing. Wie der Bootloader funktioniert, steht unter
[Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md).

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel; ein einfacher Switch dazwischen hilft beim Timing
- einen Rechner mit Linux oder macOS (für `ftp`)
- die Freifunk-Firmware deiner Community für dieses Gerät, die Dateien, die in Schritt 4 genannt sind

## Vorher prüfen

- Die 3370 Rev. 2 gibt es mit zwei verschiedenen Speicherchips (Hynix und
  Micron), und jede Sorte braucht ihr eigenes Image. **Von außen sieht man
  das nicht**, nur nach dem Öffnen. Wer nicht öffnen will: einfach mit einer
  Sorte anfangen. Startet die Box danach immer wieder neu, war es die
  falsche; dann dasselbe mit der anderen. Laut OpenWrt geht die Box dabei
  nicht kaputt. Ein Chip von ST-Micro (512 MB) läuft mit dem Hynix-Image.
- Nur ab Hardware-Revision 2 (`quote GETENV HWSubRevision`).
- Bei Bootloader-Version 2186 (`quote GETENV urlader-version`) startet die
  Box nach 30 Sekunden von selbst neu. Dann muss alles in diesen 30 Sekunden
  erledigt sein; also die Befehle vorher bereitlegen.
- fritzflash.py kann dieses Gerät nicht, hier geht es von Hand.

Diese Anleitung ist für **Micron**; für Hynix gibt es eine [eigene](avm-fritz-box-3370-rev-2-hynix-nand.md).

## Schritte

1. **Rechner vorbereiten.** Feste Adresse `192.168.178.10`, Netzmaske
   `255.255.255.0`, Gateway `192.168.178.1`, kein DNS
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). WLAN am Rechner
   aus.

2. **Verbinden.** Kabel vom Rechner an die **gelbe LAN-Buchse** der Box
   (wenn vorhanden über einen einfachen Switch). Die Box bleibt vorerst aus
   bzw. läuft noch, das ist egal.

3. **Box einschalten und sofort verbinden.** Strom ziehen, wieder einstecken
   und sofort:

   ```
   ftp 192.168.178.1
   ```

   Benutzer `adam2`, Passwort `adam2`. Klappt es nicht innerhalb weniger
   Sekunden, Strom ziehen und noch einmal.

4. **Befehle eingeben,** einzeln und genau so:

   ```
   binary
   debug
   passive
   quote SETENV linux_fs_start 0
   quote MEDIA FLSH
   put gluon-<community>-<release>-avm-fritz-box-3370-rev-2-micron-nand-eva-kernel.bin mtd1
   put gluon-<community>-<release>-avm-fritz-box-3370-rev-2-micron-nand-eva-filesystem.bin mtd0
   ```

5. **Warten,** bis der letzte Befehl durch ist.
   Startet die Box nicht von selbst neu: Strom aus und wieder an.

6. **Fertig.** Stell den Rechner wieder auf "automatisch". Nach 2 bis 5
   Minuten startet die Freifunk-Firmware deiner Community: je nach Community
   zuerst mit einer Einrichtungsseite unter `http://192.168.1.1` oder gleich
   im Betrieb.

## Woran du erkennst, dass es geklappt hat

- Die Befehle laufen ohne Fehlermeldung durch.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Box antwortet nicht.** Das Zeitfenster ist kurz. Einen einfachen
  Switch zwischen Box und Rechner stecken, WLAN am Rechner aus, und noch
  einmal: Strom ziehen, einstecken, sofort verbinden.

## Zurück zu FRITZ!OS

AVM hat für jedes Gerät ein Wiederherstellungs-Programm (für Windows), das
die Original-Firmware zurückspielt. Es liegt auf dem Download-Server von AVM
im Ordner des Geräts unter "recover". Geräte von Providern (zum Beispiel
1&1) verweigern das eventuell; dann vorher per FTP
`quote UNSETENV provider` ([Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md)).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: OpenWrt-Wiki "AVM recovery tool" (Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki 3370 (Schritte (Normalweg), Sichtbare Zeichen, Adressen, Programm, Typenschild/Verwechslung, Dauer, Fehlerbild)
- abgeleitet: Wiki 3370, mit 24.10.0 geprüft dort (Schritte (Normalweg), Programm)
- abgeleitet: dasselbe Wiki (Rückweg zur Herstellerfirmware)
- abgeleitet: fritz-tools-Doku, Gerät fehlt in der Liste (Programm)
- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit (Typenschild/Verwechslung, Dauer)
- geprüft: Commit 0b62fe5e (Schritte (Normalweg), Typenschild/Verwechslung, Bedingung an die Herstellerfirmware)
- geprüft: Commit, Feld factory (Schritte (Normalweg), Datei)
- geprüft: Commits, fritz-tools/fritzflash.py (Schritte (Normalweg), Taste und Zeitpunkt)
- Geräteeintrag: 0b62fe5ed87ecac52301096b15abb69f96117c8c
