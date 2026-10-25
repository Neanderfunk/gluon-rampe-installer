---
gluon_name: netgear-ex3700
modell: NETGEAR EX3700/EX3800 (Alias netgear-ex3800)
anzeige: NETGEAR EX3700/EX3800
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

# NETGEAR EX3700/EX3800: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20NETGEAR%20EX3700/EX3800)

Bei diesem Gerät nimmt die normale Weboberfläche von Netgear die
Freifunk-Firmware an. Das ist der einfache Weg. Klappt er nicht, gibt es
unten einen zweiten Weg mit dem Programm nmrpflash.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die Freifunk-Firmware deiner Community für den NETGEAR EX3700/EX3800, und zwar das
  **factory**-Image (im Firmware-Selector unter "Wähle Deine
  Installationsart" der Knopf **Erstinstallation**)

## Vorher prüfen

EX3700 und EX3800 nehmen dasselbe Image. Der [EX6130](netgear-ex6130.md)
hat dieselbe Platine, braucht aber ein eigenes.

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

- geprüft (Weg ab Werk, Datei)
- geprüft: Commit 0cbd2c7 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Commit de33a4c (Datei, Notweg)
- geprüft: mt7620.mk 'EX3700/EX3800' (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: nmrpflash-README (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Anschluss, Adressen, Programm, Dauer)
- Geräteeintrag: de33a4cef0411f13df397ada2dc3634c5748a457
