---
gluon_name: hewlett-packard-msm460
modell: HPE MSM460
anzeige: HPE MSM460
familie: sonderweg-hewlett-packard-msm460
gluon_broken: false
sprache: de
level: L4
level_text: Netzwerkwerkzeuge
risiko: bootloader
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, tftp-client, tftp-server]
daten_stand: 18637656
vorlage_stand: 883c350d
---

# HPE MSM460: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Dass der neue Bootloader die Freifunk-Firmware von selbst holt, haben wir aus seinem Quelltext abgeleitet.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20HPE%20MSM460)

> **Achtung, Bootloader:** Bei diesem Gerät wird der Bootloader verändert,
> also das kleine Programm, das vor jeder Firmware startet. Geht dabei etwas
> schief, etwa durch einen Stromausfall oder eine falsche Datei, startet das
> Gerät womöglich nicht mehr. Ohne Flash-Programmer gibt es dann meist kein
> Zurück. Lies die Anleitung vorher einmal ganz durch und halte dich genau an
> die Befehle.

Der MSM460 nimmt keine fremde Firmware über seine Weboberfläche an. Es gibt
aber einen Weg ohne Öffnen des Gehäuses: Im Notfall-Modus nimmt die
HP-Firmware eine Befehlsdatei per Netzwerk an. Damit tauschst du den
Bootloader gegen einen, den ein Freifunk-Entwickler für genau dieses Gerät
gebaut hat. Der neue Bootloader holt sich dann die Freifunk-Firmware von
deinem Rechner und schreibt sie selbst.

Einen einfachen Weg zurück zur HP-Firmware gibt es danach nicht.

Du brauchst einen TFTP-Server und einen TFTP-Client auf deinem Rechner
([TFTP-Server einrichten](grundlagen/tftp-server.md),
[TFTP-Client benutzen](grundlagen/tftp-client.md)). Rechne mit einer halben
Stunde.

## Was du brauchst

- den Access Point und einen **PoE-Injektor**. Der MSM460 bekommt seinen
  Strom über das Netzwerkkabel.
- einen Rechner mit Netzwerkanschluss und zwei Netzwerkkabel (Rechner zum
  Injektor, Injektor zum Access Point)
- diese drei Dateien, alle im Ordner deines TFTP-Servers und genau so
  benannt:
  1. die Befehlsdatei [commands.tftp](https://raw.githubusercontent.com/blocktrron/msm460-flashing/0d1dd58d7187b89dff43d0f5d852502f719e7441/commands.tftp) (genau
     131.072 Bytes)
  2. der neue Bootloader [msm460-uboot.bin](https://raw.githubusercontent.com/blocktrron/msm460-flashing/0d1dd58d7187b89dff43d0f5d852502f719e7441/msm460-uboot.bin)
  3. die Freifunk-Firmware deiner Community für den HPE MSM460, und zwar
     das **factory**-Image (im Firmware-Selector unter "Wähle Deine
     Installationsart" der Knopf **Erstinstallation**). Benenn es in
     **`msm460-factory.bin`** um.

## Schritte

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.66`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

2. **TFTP-Server starten** mit dem Ordner, in dem die drei Dateien liegen.
   Lass ihn bis zum Schluss laufen; in seinem Protokoll siehst du später,
   welche Datei der Access Point gerade holt.

3. **Notfall-Modus starten.** Verbinde den Rechner mit dem LAN-Anschluss
   des PoE-Injektors. Halt die **Reset**-Taste des Access Points gedrückt
   und steck dabei das Kabel vom Injektor (PoE-Anschluss) in den Access
   Point. Die LEDs fangen an zu blinken und blinken nach etwa 15 Sekunden
   schneller. Dann loslassen.

4. **Befehlsdatei schicken.** Öffne ein Terminal im Ordner mit den Dateien
   und gib ein:

   - Linux:

     ```
     tftp 192.168.1.1 -m binary -c put commands.tftp nflashd.cccc9999
     ```

   - Windows (Eingabeaufforderung):

     ```
     tftp -i 192.168.1.1 PUT commands.tftp nflashd.cccc9999
     ```

   - macOS: `tftp 192.168.1.1`, dann nacheinander `binary`,
     `put commands.tftp nflashd.cccc9999` und `quit`.

   Am Ende meldet das Programm **"Transfer timed out"** oder eine
   Zeitüberschreitung. Das ist hier normal.

5. **Warten, Strom nicht ziehen.** Im Protokoll des TFTP-Servers siehst du,
   wie der Access Point zuerst `msm460-uboot.bin` holt. Er schreibt den neuen
   Bootloader und startet neu. Weil noch keine Freifunk-Firmware im Speicher
   ist, holt der neue Bootloader dann von selbst `msm460-factory.bin` und
   schreibt sie. Das dauert einige Minuten. Am Ende zeigen die LEDs ein
   gleichbleibendes Blinkmuster
   ([so sieht es aus](https://github.com/blocktrron/msm460-flashing/blob/0d1dd58d7187b89dff43d0f5d852502f719e7441/images/blink-pattern.gif)).

6. **Neu starten.** Zieh das Kabel am Access Point kurz ab und steck es
   wieder ein. Jetzt startet die Freifunk-Firmware. Stell den Rechner wieder
   auf "automatisch". Je nach Community kommt zuerst eine Einrichtungsseite
   unter `http://192.168.1.1`, oder der Access Point geht gleich in Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 blinken die LEDs nach etwa 15 Sekunden schneller.
- In Schritt 5 zeigt der TFTP-Server erst `msm460-uboot.bin`, später
  `msm460-factory.bin`.
- Nach Schritt 6 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die LEDs blinken nicht schneller.** Kabel abziehen und Schritt 3
  wiederholen. Die Reset-Taste muss schon gedrückt sein, bevor der Strom
  kommt.
- **Der TFTP-Server zeigt keinen Abruf von `msm460-uboot.bin`.** Prüf die
  feste Adresse `192.168.1.66`, die Firewall deines Rechners (der Abruf
  kommt vom Access Point) und die Dateinamen. Dann ab Schritt 3 noch einmal.
- **`msm460-uboot.bin` wurde geholt, `msm460-factory.bin` aber nicht.** Nicht
  den Strom ziehen. Prüf den Namen der Freifunk-Datei; der neue Bootloader
  versucht es immer wieder, bis die Datei da ist.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Gluon-RAMpe passt)
- geprüft (Weg ab Werk)
- geprüft: Commit af329ec, README blocktrron/msm460-flashing (Taste und Zeitpunkt)
- geprüft: Commit, README (Sichtbare Zeichen, Programm)
- Geräteeintrag: af329ec38980e2f706411a11b9f344a62eb0dd8f
