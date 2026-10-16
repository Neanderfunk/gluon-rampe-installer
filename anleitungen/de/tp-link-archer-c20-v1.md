---
gluon_name: tp-link-archer-c20-v1
modell: TP-Link Archer C20 v1
anzeige: TP-Link Archer C20 v1
familie: tplink-ubootteil-dd
gluon_broken: false
sprache: de
level: L5
level_text: Besondere Programme
risiko: bootloader
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, tftp-server]
daten_stand: 3d3f59fa
vorlage_stand: 883c350d
---

# TP-Link Archer C20 v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Der Weg von OpenWrt nutzt ein Image, das es nicht mehr gibt; wir nehmen stattdessen wie beim Archer C2 v1 das sysupgrade.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20Archer%20C20%20v1)

> **Achtung, Bootloader:** Bei diesem Gerät wird der Bootloader verändert,
> also das kleine Programm, das vor jeder Firmware startet. Geht dabei etwas
> schief, etwa durch einen Stromausfall oder eine falsche Datei, startet das
> Gerät womöglich nicht mehr. Ohne Flash-Programmer gibt es dann meist kein
> Zurück. Lies die Anleitung vorher einmal ganz durch und halte dich genau an
> die Befehle.

> **Wichtig: Nimm nie die Freifunk-Datei allein.** Der Firmware-Selector
> bietet für dieses Gerät nur den Knopf **Upgrade** an. Lädst du diese Datei
> über die TP-Link-Oberfläche hoch, ist das Gerät danach nur noch über die
> serielle Konsole zu retten. Benennst du sie für den Notfall-Modus einfach
> um, überschreibt der Router damit seinen Bootloader, und dann hilft nur
> noch ein Flash-Programmer. Die Datei muss vorher mit einem Stück der
> TP-Link-Firmware zusammengesetzt werden, wie unten beschrieben.

Beim TP-Link Archer C20 v1 geht die Freifunk-Firmware nur über den Notfall-Modus des
Bootloaders auf das Gerät: Beim Einschalten mit gedrückter Taste holt er
sich eine Datei per TFTP und schreibt sie **ab dem Anfang des Speichers,
samt Bootloader**. Deshalb muss vorn in dieser Datei der Bootloader aus der
TP-Link-Firmware stehen, dahinter die Freifunk-Firmware. Rechne mit einer
Stunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- einen TFTP-Server auf dem Rechner
  ([TFTP-Server einrichten](grundlagen/tftp-server.md))
- die **TP-Link-Firmware** für genau dieses Modell, von der
  [Download-Seite bei TP-Link](https://www.tp-link.com/en/support/download/archer-c20/v1/). Nimm die Datei mit „up_boot“ im Namen.
- die Freifunk-Firmware deiner Community für den TP-Link Archer C20 v1: im
  Firmware-Selector unter "Wähle Deine Installationsart" der Knopf
  **Upgrade** (die Datei endet auf `-sysupgrade.bin`). **Nicht allein
  verwenden**, siehe oben.
- zum Zusammensetzen: unter Linux und macOS die Befehle `dd` und `cat`,
  unter Windows **Python 3** (<https://www.python.org/downloads/>)

## Vorher prüfen

Diese Anleitung gilt nur für den **Archer C20 v1** (mit USB-Buchse). Der
Archer C20 v4 und v5 sind andere Geräte, ebenso der
[Archer C20i](tp-link-archer-c20i.md). Die Version steht auf dem Typenschild
unten am Gerät ("Ver: 1.0").

Laut OpenWrt-Wiki nimmt die TP-Link-Oberfläche beim C20 v1 eine fremde
Firmware zwar an, beschädigt sie aber; danach hilft nur noch die serielle
Konsole. Deshalb geht es hier nur über den Notfall-Modus.

## Schritte

1. **Dateien bereitlegen.** Leg einen Ordner an. Pack die TP-Link-Firmware
   (ein ZIP-Archiv) dort aus und benenn die `.bin`-Datei darin in
   `tpl.bin` um. Leg die Freifunk-Datei daneben und benenn sie in
   `gluon.bin` um. Die Namen bei TP-Link enthalten oft Leerzeichen oder
   eckige Klammern, die im Terminal Ärger machen. Pack und benenn deshalb am
   besten im Dateimanager, dann musst du die langen Namen nie abtippen.

2. **Zusammensetzen.** Öffne ein Terminal in dem Ordner und gib ein:

   - Linux und macOS:

     ```
     dd if=tpl.bin of=uboot.bin bs=512 count=256 skip=1
     cat uboot.bin gluon.bin > ArcherC20V1_tp_recovery.bin
     ```

   - Windows (PowerShell oder Eingabeaufforderung), geht auch unter Linux
     und macOS mit `python3` statt `py`:

     ```
     py -c "open('ArcherC20V1_tp_recovery.bin','wb').write(open('tpl.bin','rb').read(131584)[512:]+open('gluon.bin','rb').read())"
     ```

   **Prüfen:** `ArcherC20V1_tp_recovery.bin` ist genau **131.072 Bytes größer** als
   `gluon.bin` (Größe in Bytes: Windows `dir`, Linux und macOS `ls -l`).
   **Stimmt das nicht, auf keinen Fall weitermachen**: Mit einer falschen
   Datei überschreibt der Router seinen Bootloader.

3. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.0.66`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

4. **TFTP-Server starten** mit dem Ordner, in dem `ArcherC20V1_tp_recovery.bin`
   liegt. Groß- und Kleinschreibung des Namens genau so.

5. **Kabel anschließen.** Netzwerkkabel vom Rechner an eine LAN-Buchse des
   Routers. Strom noch nicht anschließen.

6. **Notfall-Modus starten.** Halt die Reset-Taste gedrückt, schalte den Router ein und halt sie etwa 6 bis 7 Sekunden weiter, bis der Router die Datei holt. **Prüfen:** Im Protokoll des
   TFTP-Servers erscheint, dass `ArcherC20V1_tp_recovery.bin` abgeholt wird.

7. **Warten.** Der Router schreibt Bootloader und Freifunk-Firmware und
   startet von selbst neu.
   **Auf keinen Fall den Strom ziehen**, solange er schreibt.

8. **Fertig.** Stell den Rechner wieder auf "automatisch". Je nach Community
   kommt zuerst eine Einrichtungsseite unter `http://192.168.1.1`, oder der
   Router geht gleich in Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 2 ist die Datei 131.072 Bytes größer als `gluon.bin`.
- In Schritt 6 zeigt der TFTP-Server den Abruf.
- Nach Schritt 7 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Der Router holt die Datei nicht.** Prüf feste Adresse `192.168.0.66`,
  Kabel an einer LAN-Buchse, Firewall und den Dateinamen. Windows blendet
  Dateiendungen gern aus. Dann den Notfall-Modus noch einmal starten.
- **Er hat die Datei geholt, startet aber nicht.** Warte länger, das
  Schreiben kann lange dauern. Kommt auch nach einer halben Stunde nichts,
  schreib uns.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Programm)
- abgeleitet: Wiki C20 v1 (Warnung, Taste und Zeitpunkt, Sichtbare Zeichen, Adressen, Dauer)
- abgeleitet: Wiki C20 v1; geprüft: Commit (Schritte (Normalweg))
- geprüft für den Weg, abgeleitet für die Image-Wahl (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Programm, Datei)
- geprüft: Commit 8375623, "WARNING: This method also overwrites the bootloader partition!" (Programm)
- geprüft: Commits; abgeleitet: Wiki (Typenschild/Verwechslung)
- geprüft: Test Neanderfunk 15.10.2026 (Programm)
- Geräteeintrag: 161a3be5adb21135eb75da81247fa5e04b6ea676
