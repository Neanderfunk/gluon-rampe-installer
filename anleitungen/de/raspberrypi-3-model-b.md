---
gluon_name: raspberrypi-3-model-b
modell: Raspberry Pi 3 Model B/B+
familie: image-auf-datentraeger
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [image-schreiben]
daten_stand: 0a4f2b3
vorlage_stand: deba706
---

> **Noch nicht am Gerät erprobt.** Diese Anleitung ist aus Quellen
> zusammengestellt, aber noch niemand hat sie an einem Raspberry Pi 3 Model B/B+ Schritt
> für Schritt nachvollzogen. Wenn du es tust: Schreib uns an
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de), ob es geklappt hat.

# Raspberry Pi 3 Model B/B+: Freifunk-Firmware installieren

Beim Raspberry Pi 3 Model B/B+ gibt es keine Firmware, die man über eine Oberfläche
hochlädt. Die Freifunk-Firmware wird als fertiges Abbild direkt auf
eine microSD-Karte geschrieben, und das Gerät startet davon.

## Was du brauchst

- das Gerät und eine microSD-Karte
- einen Rechner, an dem du eine microSD-Karte beschreiben kannst
- ein Netzwerkkabel für die Einrichtung
- die Freifunk-Firmware deiner Community für den Raspberry Pi 3 Model B/B+, und zwar das
  **factory**-Image (Endung `.img.gz`)

## Vorher prüfen

Dieses Image ist für den Raspberry Pi 3 Model B und B+. Laut OpenWrt starten
auch 3A+, Zero 2 W und Compute Module 3 damit; für sie führt die
Freifunk-Firmware aber keinen eigenen Eintrag, automatische Updates finden
dort vermutlich kein Image.

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
- geprüft: Gluon targets/bcm27xx-bcm2710, OpenWrt Makefile; Autoupdater-Folge abgeleitet (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Wiki toh:raspberry_pi_foundation:raspberry_pi (Schritte (Normalweg), Programm)
- geprüft: Wiki toh:raspberry_pi_foundation:raspberry_pi, Wiki toh:friendlyarm:nanopi_r2s (dd, gzip -d); Win32DiskImager: Wiki-Zusammenfassung: FriendlyElec-Wiki, nicht lokal (Programm)
- geprüft: rpi-imager CommonStrings.qml, etcher supported-formats.ts (Schritte (Normalweg), Programm)
- geprüft: targets/bcm27xx.inc (Weg ab Werk, Schritte (Normalweg), Datei)
- Geräteeintrag: Gluon targets/bcm27xx-bcm2710
