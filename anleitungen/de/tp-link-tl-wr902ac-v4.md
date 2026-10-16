---
gluon_name: tp-link-tl-wr902ac-v4
modell: TP-Link TL-WR902AC v4
anzeige: TP-Link TL-WR902AC v4
familie: tplink-tftp-recovery
gluon_broken: false
sprache: de
level: L4
level_text: Netzwerkwerkzeuge
risiko: normal
status: ungeprüft
grundlagen: [feste-ip, tftp-server]
daten_stand: 9936ce50
vorlage_stand: cc34fa66
---

# TP-Link TL-WR902AC v4: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Der Commit von OpenWrt nennt einen anderen Dateinamen als bei allen Schwestergeräten; deshalb legst du die Datei unter beiden Namen ab.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20TL-WR902AC%20v4)

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
- die Freifunk-Firmware deiner Community für den TP-Link TL-WR902AC v4, und zwar das
  Image, das auf **`-bootloader.bin`** endet. Im Firmware-Selector wählst du
  dafür unter "Wähle Deine Installationsart" den Knopf
  **Bootloader-Image**. Benenn die Datei in **`tp_recovery.bin`** um und leg zusätzlich eine Kopie mit dem Namen
  **`tp_recover.bin`** daneben. Die Quellen nennen beide Namen; so passt es in
  jedem Fall.

## Schritte

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.0.66`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Router den TFTP-Server.

2. **TFTP-Server starten** mit dem Ordner, in dem `tp_recovery.bin` liegt.
   Erlaube ihm in der Firewall den Zugriff.

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an eine LAN-Buchse des
   Routers. Strom noch nicht anschließen.

4. **Notfall-Modus starten.** Halt die Reset-Taste gedrückt, schalte den Router ein und lass sie los, sobald die LED blinkt.
   **Prüfen:** Im Protokoll des TFTP-Servers erscheint, dass
   `tp_recovery.bin` oder `tp_recover.bin` abgeholt wird.
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

- abgeleitet (Schritte (Normalweg), Anschluss, Programm, Dauer, Rückweg zur Herstellerfirmware)
- abgeleitet: Commit ffa40fcc vs. Schwestergeräte (Datei)
- abgeleitet: Regel strengster Name (Datei)
- abgeleitet: Wiki (Programm)
- abgeleitet: Wiki C20 v4/MR6400 v5/WA801ND v5 (Dauer)
- abgeleitet: Wiki C50/MR6400 v5 (Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki MR3020 v3 (Sichtbare Zeichen)
- abgeleitet: Wiki; abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk)
- geprüft: Commit (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Adressen, Datei, Typenschild/Verwechslung)
- geprüft: Commit "write it to flash and reboot" (Schritte (Normalweg), Sichtbare Zeichen)
- geprüft: Gluon targets/ramips-mt76x8 extra_images (Datei)
- geprüft: Gluon targets/ramips-mt76x8 extra_images; abgeleitet: Commit ffa40fcc vs. Schwestergeräte (Schritte (Normalweg))
- geprüft: Gluon targets/ramips-mt76x8 v2025.1.3 (Datei)
- geprüft: OpenWrt-Commit ffa40fc; Lösung abgeleitet (Datei)
- Geräteeintrag: ffa40fcc7fe1aee041775e097bccecb9be83cd21
