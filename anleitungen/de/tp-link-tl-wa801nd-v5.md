---
gluon_name: tp-link-tl-wa801nd-v5
modell: TP-Link TL-WA801ND v5
anzeige: TP-Link TL-WA801ND v5
familie: tplink-tftp-recovery
gluon_broken: false
sprache: de
level: L4
level_text: Network-Tools
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht, tftp-server]
daten_stand: c6d8e279
vorlage_stand: 33a38da8
---

# TP-Link TL-WA801ND v5: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20TL-WA801ND%20v5)

Bei diesem Router nimmt die Weboberfläche von TP-Link die Freifunk-Firmware
zwar an, beschädigt sie aber beim Schreiben. **Lade sie dort also nicht
hoch.** Der Weg führt stattdessen über den Notfall-Modus des Bootloaders:
Beim Einschalten mit gedrückter Reset-Taste holt sich der Router eine Datei
von deinem Rechner und schreibt sie selbst. Dein Rechner spielt dafür den
TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)). Rechne
mit einer halben Stunde.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- einen TFTP-Server auf dem Rechner
  ([TFTP-Server einrichten](grundlagen/tftp-server.md))
- die Freifunk-Firmware deiner Community für den TP-Link TL-WA801ND v5, und zwar das
  Image, das auf **`-bootloader.bin`** endet. Im Firmware-Selector wählst du
  dafür unter "Wähle Deine Installationsart" den Knopf
  **Bootloader-Image**. Benenn die Datei in **`tp_recovery.bin`** um.

## Schritte

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.0.66`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Router den TFTP-Server.

2. **TFTP-Server starten** mit dem Ordner, in dem `tp_recovery.bin` liegt.
   Erlaube ihm in der Firewall den Zugriff.

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an eine LAN-Buchse des
   Routers. Strom noch nicht anschließen.

4. **Notfall-Modus starten.** Halt die WPS- und die Reset-Taste zusammen gedrückt, schalte das Gerät ein und halt sie etwa 10 Sekunden weiter, bis die Schloss-LED (ganz rechts) leuchtet.
   **Prüfen:** Im Protokoll des TFTP-Servers erscheint, dass
   `tp_recovery.bin` abgeholt wird.
   Sonst Strom ziehen und noch einmal.

5. **Warten.** Der Router schreibt die Freifunk-Firmware und startet von
   selbst neu. Das dauert einige Minuten. **Strom nicht ziehen.**

6. **Fertig.** Stell den Rechner wieder auf "automatisch". Je nach Community
   kommt zuerst eine Einrichtungsseite unter `http://192.168.1.1`, oder der
   Router geht gleich in Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 zeigt der TFTP-Server den Abruf der Datei.
- Nach Schritt 5 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Der Router holt die Datei nicht.** Prüf der Reihe nach: feste Adresse
  `192.168.0.66`, Kabel an einer LAN-Buchse (nicht WAN), Firewall,
  Dateiname. Windows blendet Dateiendungen gern aus; heißt die Datei im
  Explorer `tp_recovery.bin`, kann sie in Wirklichkeit
  `tp_recovery.bin.bin` heißen. Dann den Notfall-Modus noch einmal starten und
  die Taste diesmal etwas kürzer oder länger halten.
- **Du hast die Datei schon über die Weboberfläche hochgeladen** und der
  Router startet nicht mehr richtig: Kein Problem, genau dafür ist dieser
  Weg. Fang bei Schritt 1 an.

## Zurück zur TP-Link-Firmware

Über denselben Notfall-Modus nimmt der Router auch eine TP-Link-Firmware an.
Je nach Modell muss die Datei dafür vorher angepasst werden; das steht im
OpenWrt-Wiki zu deinem Gerät.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg), Anschluss, Programm, Rückweg zur Herstellerfirmware)
- abgeleitet: Regel strengster Name (Datei)
- abgeleitet: Wiki (Programm)
- abgeleitet: Wiki C50/MR6400 v5 (Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki WA801ND (Typenschild/Verwechslung)
- abgeleitet: Wiki WA801ND v5 (Warnung)
- abgeleitet: Wiki; abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk)
- geprüft: Commit (Schritte (Normalweg), Sichtbare Zeichen, Adressen, Datei, Dauer)
- geprüft: Commit "write it to flash and reboot" (Schritte (Normalweg))
- geprüft: Commit; abgeleitet: Wiki (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Gluon targets/ramips-mt76x8 extra_images (Datei)
- geprüft: Gluon targets/ramips-mt76x8 extra_images; geprüft: Commit (Schritte (Normalweg))
- geprüft: Gluon targets/ramips-mt76x8 v2025.1.3 (Datei)
- Geräteeintrag: ce31bdc20c3f2eb387a84c277dff76324a8e39c7
