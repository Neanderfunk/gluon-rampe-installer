---
gluon_name: netgear-r6220
modell: NETGEAR R6220
anzeige: NETGEAR R6220
familie: netgear-nmrp
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, nmrpflash, router-antwortet-nicht]
daten_stand: e9343f57
vorlage_stand: 33a38da8
---

# NETGEAR R6220: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20NETGEAR%20R6220)

Bei diesem Gerät nimmt die normale Weboberfläche von Netgear die
Freifunk-Firmware an. Das ist der einfache Weg. Klappt er nicht, gibt es
unten einen zweiten Weg mit dem Programm nmrpflash.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die Freifunk-Firmware deiner Community für den NETGEAR R6220, und zwar das
  **factory**-Image (im Firmware-Selector unter "Wähle Deine
  Installationsart" der Knopf **Erstinstallation**)

## Vorher prüfen

Die Netgear-Oberfläche nimmt das factory-Image laut OpenWrt auch an, unter
ADVANCED → Administration → Firmware Update. Mit nmrpflash dauert das
Schreiben nach dem Upload laut OpenWrt bis etwa 4 Minuten.

## Schritte

1. **Anschließen.** Steck das Kabel vom Rechner an eine LAN-Buchse des
   Geräts und schalte es ein. Der Rechner bleibt auf "automatisch"
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

## Anderer Weg: mit nmrpflash

Netgear-Geräte fragen direkt nach dem Einschalten im Netzwerk, ob jemand
eine Firmware für sie hat. Das Programm **nmrpflash** auf deinem Rechner
antwortet darauf und schickt die Freifunk-Firmware
([nmrpflash benutzen](grundlagen/nmrpflash.md)).

1. **nmrpflash bereitlegen.** Lade nmrpflash herunter und richte es ein, wie
   unter [nmrpflash benutzen](grundlagen/nmrpflash.md) beschrieben. Leg das factory-Image
   in denselben Ordner und benenne es in `firmware.img` um.

2. **Verbinden.** Das Gerät ist **aus**. Steck das Kabel vom Rechner an die LAN-Buchse (bei
   Netgear oft blau; bei mehreren die mit "1"). Schalte die
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

- abgeleitet: ToH "GUI OEM"; Commit beschreibt Telnet-Debug + USB + mtd_write, damals ohne factory (Weg ab Werk, Datei)
- abgeleitet: Wiki (Programm)
- abgeleitet: Wiki toh/netgear/r6220 (Dauer, Notweg)
- geprüft: Commit 38bee61 (Rückweg zur Herstellerfirmware)
- geprüft: nmrpflash-README (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Anschluss, Adressen, Programm, Datei, Dauer)
- Geräteeintrag: 38bee61dab029a7608088f64da71c19cfc8cf267
