---
gluon_name: netgear-r6260
modell: NETGEAR R6260
anzeige: NETGEAR R6260
familie: netgear-nmrp
gluon_broken: false
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [nmrpflash]
daten_stand: a602f5a
vorlage_stand: 393f161
---

# NETGEAR R6260: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20NETGEAR%20R6260)

Viele Netgear-Geräte fragen direkt nach dem Einschalten im Netzwerk, ob
jemand eine Firmware für sie hat. Das Programm **nmrpflash** auf deinem
Rechner antwortet darauf und schickt die Freifunk-Firmware. Das geht auch
dann, wenn die Netgear-Oberfläche fremde Firmware nicht annimmt.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- das Programm nmrpflash ([nmrpflash benutzen](grundlagen/nmrpflash.md))
- die Freifunk-Firmware deiner Community für den NETGEAR R6260, und zwar das
  **factory**-Image

## Vorher prüfen

R6260, R6350 und R6850 haben dieselbe Platine, brauchen aber je ihr eigenes
Image. Prüf den Aufkleber. Für nmrpflash das Kabel an LAN 1 (die Buchse
neben WAN), nicht an WAN.

## Schritte

1. **nmrpflash bereitlegen.** Lade nmrpflash herunter und richte es ein, wie
   unter [nmrpflash benutzen](grundlagen/nmrpflash.md) beschrieben. Leg das factory-Image
   in denselben Ordner und benenne es in `firmware.img` um.

2. **Verbinden.** Das Gerät ist **aus**. Steck das Kabel vom Rechner an LAN 1 (die Buchse neben WAN), nicht WAN. Schalte die
   Firewall am Rechner für die Dauer aus.

3. **Anschluss finden.** Im Terminal (als Administrator bzw. mit `sudo`):

   ```
   nmrpflash -L
   ```

   Merk dir den Namen des Anschlusses, an dem das Kabel steckt, zum Beispiel
   `eth0` oder `net1`.

4. **nmrpflash starten.** Mit diesem Namen statt `eth0`:

   ```
   nmrpflash -i eth0 -f firmware.img
   ```

5. **Gerät einschalten,** sobald `Waiting for Ethernet connection` erscheint.

6. **Warten.** nmrpflash meldet `Uploading … OK` und dann `Waiting for remote
   to respond.` Jetzt schreibt das Gerät, das dauert meist wenige Minuten,
   manchmal 15 Minuten und mehr. **Strom nicht ziehen,** bis
   `Reboot your device now.` erscheint.

7. **Neu starten.** Schalte das Gerät aus und wieder ein.

8. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- nmrpflash endet mit `Reboot your device now.`
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **"No response after 60 seconds."** Reihenfolge einhalten: erst nmrpflash
  starten, dann das Gerät einschalten. Manche Netgear-Geräte brauchen beim
  Einschalten zusätzlich die gedrückte Reset-Taste. Eine andere LAN-Buchse
  probieren.
- **"Timeout while waiting for ACK(0)/OACK."** Meist die Firewall am Rechner.
- Weitere Meldungen erklärt [nmrpflash benutzen](grundlagen/nmrpflash.md).
- **Nach dem Flashen über die Netgear-Oberfläche startet keine
  Freifunk-Firmware.** Laut OpenWrt: noch einmal flashen. Fragt die
  Oberfläche, ob du eine ältere Version einspielen willst, bestätigen.

## Anderer Weg: Netgear-Oberfläche

Bei diesem Gerät nimmt auch die normale Netgear-Oberfläche das factory-Image
an, unter Firmware-Update. Das ist einfacher, aber schlechter belegt als der
Weg mit nmrpflash.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: ToH "GUI OEM"; Commit ohne Text (Weg ab Werk, Datei)
- abgeleitet: Wiki (Fehlerbild, Notweg)
- abgeleitet: Wiki toh/netgear/r6260 (Schritte (Normalweg), Anschluss, Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki toh/netgear/r6260, Commit 6cea968 'same image for R6260, R6350 & R6850' (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: nmrpflash-README (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Anschluss, Adressen, Programm, Datei, Dauer)
- Geräteeintrag: 6cea9688af4a05f407266ed1de5a739e5c984b8c (ohne Installationstext)
