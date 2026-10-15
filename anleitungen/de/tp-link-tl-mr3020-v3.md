---
gluon_name: tp-link-tl-mr3020-v3
modell: TP-Link TL-MR3020 v3
anzeige: TP-Link TL-MR3020 v3
familie: tplink-tftp-recovery
gluon_broken: false
sprache: de
stufe: mit scripts/Netzwerktools
status: ungeprüft
grundlagen: [feste-ip, tftp-server]
daten_stand: 3b96298
vorlage_stand: cc34fa6
---

# TP-Link TL-MR3020 v3: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20TL-MR3020%20v3)

Bei diesem Router nimmt die Weboberfläche von TP-Link die Freifunk-Firmware
zwar an, beschädigt sie aber beim Schreiben. **Lade sie dort also nicht
hoch.** Der Weg führt stattdessen über den Notfall-Modus des Bootloaders:
Beim Einschalten mit gedrückter Reset-Taste holt sich der Router eine Datei
von deinem Rechner und schreibt sie selbst. Dein Rechner spielt dafür den
TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)). Rechne
mit einer halben Stunde.

## Was du brauchst

- den Router und Strom über USB
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- einen TFTP-Server auf dem Rechner
  ([TFTP-Server einrichten](grundlagen/tftp-server.md))
- die Freifunk-Firmware deiner Community für den TP-Link TL-MR3020 v3, und zwar das
  Image, das auf **`-bootloader.bin`** endet. Im Firmware-Selector wählst du
  dafür unter "Wähle Deine Installationsart" den Knopf
  **Bootloader-Image**. Benenn die Datei in **`tp_recovery.bin`** um.

## Schritte

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.0.225`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Router den TFTP-Server.

2. **TFTP-Server starten** mit dem Ordner, in dem `tp_recovery.bin` liegt.
   Erlaube ihm in der Firewall den Zugriff.

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an eine LAN-Buchse des
   Routers. Strom noch nicht anschließen.

4. **Notfall-Modus starten.** Halt die Reset-Taste gedrückt, steck das USB-Stromkabel ein und halt sie noch etwa 7 Sekunden weiter.
   **Prüfen:** Im Protokoll des TFTP-Servers erscheint, dass
   `tp_recovery.bin` abgeholt wird.
   Sonst Strom ziehen und noch einmal.

5. **Warten.** Der Router schreibt die Freifunk-Firmware und startet von
   selbst neu. Das dauert einige Minuten. **Strom nicht ziehen.**

6. **Fertig.** Stell den Rechner wieder auf "automatisch". Je nach Community
   kommt zuerst eine Einrichtungsseite unter `http://192.168.1.1`, oder der
   Router geht gleich in Betrieb.

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 zeigt der TFTP-Server den Abruf der Datei.
- Nach Schritt 5 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Der Router holt die Datei nicht.** Prüf der Reihe nach: feste Adresse
  `192.168.0.225`, Kabel an einer LAN-Buchse (nicht WAN), Firewall,
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

- abgeleitet (Schritte (Normalweg), Anschluss, Programm, Dauer, Rückweg zur Herstellerfirmware)
- abgeleitet: Regel strengster Name (Datei)
- abgeleitet: Wiki (Programm, Typenschild/Verwechslung)
- abgeleitet: Wiki C20 v4/MR6400 v5/WA801ND v5 (Dauer)
- abgeleitet: Wiki C50/MR6400 v5 (Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki MR3020 v3 (Taste und Zeitpunkt, Sichtbare Zeichen)
- abgeleitet: Wiki; abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk)
- geprüft: Commit (Schritte (Normalweg), Taste und Zeitpunkt, Adressen, Datei)
- geprüft: Commit "write it to flash and reboot" (Schritte (Normalweg), Sichtbare Zeichen)
- geprüft: Gluon targets/ramips-mt76x8 extra_images (Datei)
- geprüft: Gluon targets/ramips-mt76x8 extra_images; geprüft: Commit (Schritte (Normalweg))
- geprüft: Gluon targets/ramips-mt76x8 v2025.1.3 (Datei)
- Geräteeintrag: 6bbb2202551be394fead2efd99eb946f846fc63d
