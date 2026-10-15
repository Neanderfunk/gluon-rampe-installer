---
gluon_name: ubiquiti-rocket-m-xm
modell: Ubiquiti Rocket M XM
anzeige: Ubiquiti Rocket M XM
familie: ubiquiti-tftp
gluon_broken: false
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [feste-ip, tftp-client]
daten_stand: 154f6f8
vorlage_stand: 393f161
---

# Ubiquiti Rocket M XM: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Ubiquiti%20Rocket%20M%20XM)

Ubiquiti-Geräte haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, wartet das Gerät darauf, dass ihm jemand eine
Firmware per **TFTP** schickt. Genau darüber kommt die Freifunk-Firmware
drauf. Du brauchst dafür ein kleines Programm auf dem Rechner, den
TFTP-Client ([TFTP-Client benutzen](grundlagen/tftp-client.md)), und eine
feste Adresse am Rechner.

## Was du brauchst

- das Gerät mit seinem PoE-Netzteil (PoE-Injektor)
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- eine Büroklammer für die Reset-Taste
- die Freifunk-Firmware deiner Community für den Ubiquiti Rocket M XM, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"
- einen TFTP-Client ([TFTP-Client benutzen](grundlagen/tftp-client.md))

## Vorher prüfen

- Die Rocket M gibt es als XM, XW und TI. Diese Firmware ist nur für die
  Bauart **XM**. Die Bauart steht in der Versionsangabe der
  Ubiquiti-Firmware (AirOS), zum Beispiel "XM.v5.5…".
- **Wichtig:** Läuft AirOS 5.6 oder neuer, **nicht** direkt die
  Freifunk-Firmware aufspielen. Laut OpenWrt muss das Gerät erst auf AirOS
  5.5 zurück, weil sich mit 5.6 die Aufteilung des Speichers geändert hat.
  Den Weg dorthin beschreibt OpenWrt unter
  <https://openwrt.org/toh/ubiquiti/common>.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter und benenne es in
   einen kurzen Namen um, zum Beispiel `factory.bin`. Einen bestimmten Namen
   verlangt das Gerät nicht, ein kurzer erspart aber Tippfehler.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf die feste Adresse
   `192.168.1.21` mit der Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Nicht
   `192.168.1.20`, die braucht das Gerät.

3. **Verbinden.** Steck das Kabel vom Rechner an die Buchse **LAN** des
   PoE-Injektors. Die Buchse **PoE** des Injektors geht zum Gerät.

4. **Gerät in den TFTP-Modus bringen.** Zieh den Injektor aus der Steckdose. Drück mit der Büroklammer
   die Reset-Taste und
   halte sie gedrückt. Steck den Injektor wieder ein.
   Halte die Taste weiter gedrückt: etwa 8 Sekunden, bis die Signal-LEDs abwechselnd blinken. Dann loslassen.

5. **Firmware schicken.** Öffne ein Terminal im Ordner mit der Datei und
   schick sie an das Gerät.

   Linux und macOS:

   ```
   tftp 192.168.1.20
   binary
   put factory.bin
   quit
   ```

   Windows (Eingabeaufforderung "cmd", TFTP-Client muss eingeschaltet sein):

   ```
   tftp -i 192.168.1.20 PUT factory.bin
   ```

   Die Übertragung dauert nur Sekunden.

6. **Warten.** Das Gerät schreibt die Firmware und startet neu. Das
   dauert einige Minuten.
   **Strom nicht ziehen, solange die LEDs laufen.**

7. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb. Wie
   es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 zeigen die LEDs, dass der TFTP-Modus erreicht ist.
- Der TFTP-Client meldet die Übertragung ohne Fehler.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Der TFTP-Client meldet eine Zeitüberschreitung.** Das Gerät war nicht im
  TFTP-Modus oder die Adresse am Rechner stimmt nicht. Prüf Schritt 2 und
  bring das Gerät noch einmal in den TFTP-Modus. Unter Windows kann auch die
  Firewall stören.
- **Das Gerät nimmt die Datei an, startet aber wieder mit der alten
  Firmware.** Vermutlich passt das Image nicht zur Hardware (siehe "Vorher
  prüfen"), oder die Herstellerfirmware ist zu neu.

## Zurück zur Ubiquiti-Firmware

Derselbe Weg geht auch rückwärts: Gerät wie in Schritt 4 in den TFTP-Modus
bringen und statt der Freifunk-Firmware die Original-Firmware von Ubiquiti
schicken, möglichst genau die Version, die vorher drauf war.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Weg ab Werk, Übertragung, Datei, Quelle (OpenWrt-Commit))
- abgeleitet: Wiki docs/.../recovery_methods/ubiquiti_tftp (Schritte (Normalweg), Sichtbare Zeichen, Dauer, Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki docs/.../recovery_methods/ubiquiti_tftp, ap51-flash-Doku; Commit ohne Anleitung (Schritte (Normalweg), Taste und Zeitpunkt)
- abgeleitet: Wiki toh/ubiquiti/common (Schritte (Normalweg), Warnung, Typenschild/Verwechslung, Bedingung an die Herstellerfirmware)
- abgeleitet: XW-Commits, Commit des Geräts ohne Anleitung (Schritte (Normalweg), Anschluss, Adressen, Programm)
- abgeleitet: ap51-flash-Doku (Notweg)
- abgeleitet: better safe than sorry (Datei)
- Geräteeintrag: 53c474abbdfef8eb3499e2d10c9ad491788b8a72 (erstes ath79-Target, ohne Anleitung) [abgeleitet]
