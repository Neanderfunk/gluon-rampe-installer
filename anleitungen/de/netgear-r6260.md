---
gluon_name: netgear-r6260
modell: NETGEAR R6260
anzeige: NETGEAR R6260
familie: netgear-nmrp
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, nmrpflash, router-antwortet-nicht]
daten_stand: 25f2bbde
vorlage_stand: 33a38da8
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

Bei diesem Gerät nimmt die normale Weboberfläche von Netgear die
Freifunk-Firmware an. Das ist der einfache Weg. Klappt er nicht, gibt es
unten einen zweiten Weg mit dem Programm nmrpflash.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die Freifunk-Firmware deiner Community für den NETGEAR R6260, und zwar das
  **factory**-Image (im Firmware-Selector unter "Wähle Deine
  Installationsart" der Knopf **Erstinstallation**)

## Vorher prüfen

R6260, R6350 und R6850 haben dieselbe Platine, brauchen aber je ihr eigenes
Image. Prüf den Aufkleber. Für nmrpflash das Kabel an LAN 1 (die Buchse
neben WAN), nicht an WAN.

## Schritte

1. **Anschließen.** Steck das Kabel vom Rechner an LAN 1 (die Buchse neben WAN), nicht WAN und schalte es ein. Der Rechner bleibt auf "automatisch"
   (DHCP). Warte zwei Minuten.

2. **Netgear-Oberfläche öffnen.** Die Adresse steht auf dem Aufkleber des
   Geräts; bei Netgear-Routern ist es meist `http://routerlogin.net`, bei
   Repeatern `http://mywifiext.net`. Melde dich an; im Werkszustand fragt
   das Gerät zuerst nach einem neuen Passwort.

3. **Freifunk-Firmware hochladen.** Such den Menüpunkt für das
   Firmware-Update (meist unter "Erweitert" bzw. "Advanced" und dann
   "Verwaltung" bzw. "Administration"), wähl das factory-Image aus und
   starte das Update. Fragt die Oberfläche nach, ob sie wirklich diese
   Datei nehmen soll, bestätige.

4. **Warten.** Das Gerät schreibt die Freifunk-Firmware und startet neu,
   einige Minuten. **Strom nicht ziehen.**

5. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je
   nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 nimmt die Oberfläche die Datei an und zeigt den Fortschritt.
- Nach Schritt 4 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Prüf, ob du das factory-Image für
  genau dein Modell genommen hast. Sonst nimm den Weg mit nmrpflash unten.
- **Das Gerät startet nach dem Update nicht richtig.** Auch dann hilft der
  Weg mit nmrpflash: Der Bootloader nimmt die Firmware auch dann noch an.
- **Nach dem Flashen über die Netgear-Oberfläche startet keine
  Freifunk-Firmware.** Laut OpenWrt: noch einmal flashen. Fragt die
  Oberfläche, ob du eine ältere Version einspielen willst, bestätigen.

## Anderer Weg: mit nmrpflash

Netgear-Geräte fragen direkt nach dem Einschalten im Netzwerk, ob jemand
eine Firmware für sie hat. Das Programm **nmrpflash** auf deinem Rechner
antwortet darauf und schickt die Freifunk-Firmware
([nmrpflash benutzen](grundlagen/nmrpflash.md)).

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
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

Wenn nmrpflash Fehler meldet:

- **"No response after 60 seconds."** Reihenfolge einhalten: erst nmrpflash
  starten, dann das Gerät einschalten. Manche Netgear-Geräte brauchen beim
  Einschalten zusätzlich die gedrückte Reset-Taste. Eine andere LAN-Buchse
  probieren.
- **"Timeout while waiting for ACK(0)/OACK."** Meist die Firewall am Rechner.
- Weitere Meldungen erklärt [nmrpflash benutzen](grundlagen/nmrpflash.md).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: ToH "GUI OEM"; Commit ohne Text (Weg ab Werk, Datei)
- abgeleitet: Wiki (Fehlerbild, Notweg)
- abgeleitet: Wiki toh/netgear/r6260 (Schritte (Normalweg), Anschluss, Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki toh/netgear/r6260, Commit 6cea968 'same image for R6260, R6350 & R6850' (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: nmrpflash-README (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Anschluss, Adressen, Programm, Datei, Dauer)
- Geräteeintrag: 6cea9688af4a05f407266ed1de5a739e5c984b8c (ohne Installationstext)
