---
gluon_name: avm-fritz-wlan-repeater-450e
modell: AVM FRITZ!WLAN Repeater 450E
anzeige: AVM FRITZ!WLAN Repeater 450E
familie: avm-eva-ftp
gluon_broken: false
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [avm-eva, feste-ip]
daten_stand: 93737b0
vorlage_stand: 869501c
---

# AVM FRITZ!WLAN Repeater 450E: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20AVM%20FRITZ%21WLAN%20Repeater%20450E)

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
- die Freifunk-Firmware deiner Community für dieses Gerät, und zwar das **sysupgrade**-Image. Das ist hier richtig, auch
  für die erste Installation.

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

- abgeleitet (Dauer)
- abgeleitet: Commit 7360 v2, Wiki 4020/7360 (Sichtbare Zeichen)
- abgeleitet: OpenWrt-Wiki "AVM recovery tool" (Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki 4020/3370 (Programm)
- abgeleitet: Wiki 4040 (Sichtbare Zeichen)
- abgeleitet: dasselbe Wiki (Rückweg zur Herstellerfirmware)
- abgeleitet: fritzflash.py-Quelltext (Typenschild/Verwechslung)
- geprüft (Weg ab Werk, Schritte (Normalweg), Quelle (OpenWrt-Commit))
- geprüft: Commit (Schritte (Normalweg), Dauer)
- geprüft: Commits, fritz-tools/fritzflash.py (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: fritz-tools-Doku (Schritte (Normalweg), Anschluss, Programm)
- geprüft: fritz-tools/fritzflash.py (Sichtbare Zeichen, Adressen)
- geprüft: fritz-tools/fritzflash.py, Wiki toh:avm:avm_fritz_wlan_repeater_1750e (Anschluss)
- geprüft: fritz-tools/fritzflash.py; abgeleitet: Commit 7360 v2, Wiki 4020/7360 (Schritte (Normalweg))
- geprüft: fritz-tools/fritzflash.py; geprüft: fritz-tools-Doku (Schritte (Normalweg))
- Geräteeintrag: 8d9c1087e4d07d625a9fef61d5dce71d850732ae [geprüft]
