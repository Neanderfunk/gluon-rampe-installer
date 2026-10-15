---
gluon_name: raspberrypi-4-model-b
modell: Raspberry Pi 4 Model B
anzeige: Raspberry Pi 4 Model B
familie: image-auf-datentraeger
gluon_broken: false
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [image-schreiben]
daten_stand: c45cd1b
vorlage_stand: 393f161
---

# Raspberry Pi 4 Model B: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Raspberry%20Pi%204%20Model%20B)

Beim Raspberry Pi 4 Model B gibt es keine Firmware, die man über eine Oberfläche
hochlädt. Die Freifunk-Firmware wird als fertiges Abbild direkt auf
eine microSD-Karte geschrieben, und das Gerät startet davon.

## Was du brauchst

- das Gerät und eine microSD-Karte
- einen Rechner, an dem du eine microSD-Karte beschreiben kannst
- ein Netzwerkkabel für die Einrichtung
- die Freifunk-Firmware deiner Community für den Raspberry Pi 4 Model B, und zwar das
  **factory**-Image (Endung `.img.gz`)

## Vorher prüfen

Dieses Image ist für den Raspberry Pi 4 Model B. Pi 400 und Compute Module 4
starten laut OpenWrt auch damit, die Freifunk-Firmware führt sie aber nicht.
Der **Raspberry Pi 5 geht nicht.**

Beim Raspberry Pi gibt es kein eindeutiges Zeichen an den LEDs, dass die
Firmware fertig gestartet ist; die grüne LED flackert nur, wenn auf die Karte
zugegriffen wird. Gib ihm nach dem Einschalten ein, zwei Minuten.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Image schreiben.** Schreib das ausgepackte Image auf eine microSD-Karte,
   und zwar auf den ganzen Datenträger. Wie das geht, steht unter
   [Image auf einen Datenträger schreiben](grundlagen/image-schreiben.md).
   **Alles, was vorher darauf war, ist danach weg.**

3. **Einsetzen.** Steck den frisch beschriebenen Datenträger in das Gerät
   bzw. schließ ihn an.

4. **Verbinden und einschalten.** Steck das Netzwerkkabel vom Rechner an
   die Netzwerkbuchse. Der Rechner holt sich seine Adresse automatisch. Dann
   das Gerät einschalten.

5. **Fertig.** Die Freifunk-Firmware startet: je nach Community zuerst mit
   einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- Nach einer Minute oder zwei meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Das Gerät startet nicht.** Meist wurde das Image in eine Partition oder
  als Datei geschrieben statt auf den ganzen Datenträger, oder es wurde nicht
  ausgepackt. Noch einmal nach
  [Image auf einen Datenträger schreiben](grundlagen/image-schreiben.md).
- **Beim Auspacken kommt "trailing garbage ignored".** Das ist harmlos.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg), Anschluss)
- abgeleitet: Imagegröße aus Config-images.in (Schritte (Normalweg), Dauer)
- geprüft: Gluon targets/bcm27xx-bcm2711, OpenWrt Makefile, kein bcm2712-Target in Gluon (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Wiki toh:raspberry_pi_foundation:raspberry_pi (Programm)
- geprüft: Wiki toh:raspberry_pi_foundation:raspberry_pi (dd auf /dev/sdX) (Schritte (Normalweg))
- geprüft: Wiki toh:raspberry_pi_foundation:raspberry_pi, toh:friendlyarm:nanopi_r2s (dd, gzip -d); Wiki-Zusammenfassung: FriendlyElec-Wiki (Win32DiskImager) (Programm)
- geprüft: rpi-imager CommonStrings.qml, etcher supported-formats.ts (Schritte (Normalweg), Programm)
- geprüft: targets/bcm27xx.inc (Weg ab Werk, Schritte (Normalweg), Datei)
- Geräteeintrag: Gluon targets/bcm27xx-bcm2711
