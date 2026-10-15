---
gluon_name: avm-fritz-box-4040
modell: AVM FRITZ!Box 4040
anzeige: AVM FRITZ!Box 4040
familie: avm-eva-ftp
gluon_broken: false
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [avm-eva, feste-ip]
daten_stand: 05f68f3
vorlage_stand: 869501c
---

# AVM FRITZ!Box 4040: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20AVM%20FRITZ%21Box%204040)

AVM-Geräte haben einen Bootloader, der in den ersten Sekunden nach dem
Einschalten Verbindungen per FTP annimmt. Darüber kommt die
Freifunk-Firmware direkt in den Speicher. Eine Taste brauchst du nicht, nur
das richtige Timing. Wie der Bootloader funktioniert, steht unter
[Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md).

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel; ein einfacher Switch dazwischen hilft beim Timing
- Python 3 und das Programm
  [fritzflash.py](https://github.com/freifunk-darmstadt/fritz-tools)
- die Freifunk-Firmware deiner Community für dieses Gerät, und zwar das Image mit **„-bootloader.bin“**
  am Ende, nicht das sysupgrade

## Vorher prüfen

- Die 4040 braucht ein eigenes Image: das mit **„-bootloader.bin“** am Ende.
  Es enthält einen neuen Bootloader und die Freifunk-Firmware zusammen. Das
  normale sysupgrade geht hier nicht. Nicht mit der
  [4020](avm-fritz-box-4020.md) verwechseln.
- Laut OpenWrt muss FRITZ!OS auf der 4040 vorher **einmal eingerichtet**
  worden sein (im Browser unter `http://192.168.178.1`: Sprache, Land, erste
  Anmeldung). Sonst nimmt der Bootloader keine FTP-Verbindung an.

Das Hochladen kann bei der 4040 erst bis zu 2 Minuten nach dem Start
beginnen; insgesamt dauert es 2 Minuten und mehr. Geduld haben.

## Schritte

1. **Rechner vorbereiten.** Feste Adresse `192.168.178.2`, Netzmaske
   `255.255.255.0`, Gateway `192.168.178.1`, kein DNS
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). WLAN am Rechner
   aus.

2. **Verbinden.** Kabel vom Rechner an die **gelbe LAN-Buchse** der Box
   (wenn vorhanden über einen einfachen Switch). Die Box bleibt vorerst aus
   bzw. läuft noch, das ist egal.

3. **fritzflash.py starten.** Leg das Image in denselben Ordner wie
   fritzflash.py und starte im Terminal:

   ```
   python3 fritzflash.py --image <Freifunk-Image>
   ```

4. **Box neu starten, wenn das Programm es sagt.** Enter drücken, dann den
   Strom an der Box ziehen und wieder einstecken. fritzflash.py sucht die Box
   und schreibt die Firmware.

5. **Warten.** Während des Schreibens leuchtet die rote Info-LED. Das ist
   normal. **Strom nicht ziehen.** Das dauert bis zu 2 Minuten.
   Danach startet die Box neu.

6. **Fertig.** Stell den Rechner wieder auf "automatisch". Nach 2 bis 5
   Minuten startet die Freifunk-Firmware deiner Community: je nach Community
   zuerst mit einer Einrichtungsseite unter `http://192.168.1.1` oder gleich
   im Betrieb.

## Woran du erkennst, dass es geklappt hat

- fritzflash.py meldet am Ende, dass das Schreiben geklappt hat.
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
- abgeleitet: Wiki 4020/3370 (Programm)
- abgeleitet: Wiki 4020/4040 (Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki 4040 (Schritte (Normalweg), Sichtbare Zeichen, Programm, Bedingung an die Herstellerfirmware)
- abgeleitet: Wiki 4040, upload-to-f4040.sh (Schritte (Normalweg), Sichtbare Zeichen)
- abgeleitet: Wiki 4040; upload-to-f4040.sh "2 minutes+" (Dauer)
- abgeleitet: dasselbe Wiki (Rückweg zur Herstellerfirmware)
- geprüft: 70e6ea31 (Weg ab Werk)
- geprüft: 70e6ea31; abgeleitet: Wiki 4040 (Schritte (Normalweg))
- geprüft: 70e6ea31; geprüft: fritz-tools-Doku (Schritte (Normalweg))
- geprüft: Commits, fritz-tools/fritzflash.py (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: fritz-tools-Doku (Schritte (Normalweg), Anschluss, Programm, Datei, Typenschild/Verwechslung)
- geprüft: fritz-tools/fritzflash.py (Sichtbare Zeichen, Adressen, Dauer)
- geprüft: fritz-tools/fritzflash.py, Wiki toh:avm:avm_fritz_wlan_repeater_1750e (Anschluss)
- geprüft: fritz-tools/fritzflash.py; geprüft: fritz-tools-Doku (Schritte (Normalweg))
- Geräteeintrag: OpenWrt 1cb406d019dc84497a8405c470f0b0394d5ff64a + 70e6ea319d3bfdfdb34be540dc7d89aa175b5587
