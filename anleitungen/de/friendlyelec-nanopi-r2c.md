---
gluon_name: friendlyelec-nanopi-r2c
modell: FriendlyElec NanoPi R2C
anzeige: FriendlyElec NanoPi R2C
familie: image-auf-datentraeger
gluon_broken: false
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [image-schreiben]
daten_stand: 07a2d93
vorlage_stand: 6eae926
---

# FriendlyElec NanoPi R2C: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20FriendlyElec%20NanoPi%20R2C)

Beim FriendlyElec NanoPi R2C gibt es keine Firmware, die man über eine Oberfläche
hochlädt. Die Freifunk-Firmware wird als fertiges Abbild direkt auf
eine microSD-Karte geschrieben, und das Gerät startet davon.

## Was du brauchst

- das Gerät und eine microSD-Karte
- einen Rechner, an dem du eine microSD-Karte beschreiben kannst
- ein Netzwerkkabel für die Einrichtung
- die Freifunk-Firmware deiner Community für den FriendlyElec NanoPi R2C, und zwar das
  **sysupgrade**-Image (Endung `.img.gz`). Das ist hier richtig, auch für die
  erste Installation: Für dieses Gerät gibt es kein factory-Image.

## Vorher prüfen

Der R2C sieht aus wie der [R2S](friendlyelec-nanopi-r2s.md), hat aber einen
anderen Netzwerkchip und braucht sein eigenes Image. Den R2C Plus (mit
eingebautem Speicher) gibt es nicht als Freifunk-Firmware.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Image schreiben.** Schreib das ausgepackte Image auf eine microSD-Karte,
   und zwar auf den ganzen Datenträger. Wie das geht, steht unter
   [Image auf einen Datenträger schreiben](grundlagen/image-schreiben.md).
   **Alles, was vorher darauf war, ist danach weg.**

3. **Einsetzen.** Steck den frisch beschriebenen Datenträger in das Gerät
   bzw. schließ ihn an.

4. **Verbinden und einschalten.** Steck das Netzwerkkabel vom Rechner an
   die LAN-Buchse (nicht WAN). Der Rechner holt sich seine Adresse automatisch. Dann
   das Gerät einschalten. Die rote SYS-LED blinkt erst schnell und beim ersten Start dann langsam (etwa 1 Sekunde an, 0,3 aus).

5. **Fertig.** Die Freifunk-Firmware startet: je nach Community zuerst mit
   einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.

**Karte nicht tauschen:** Das Gerät leitet seine Netzwerkadresse (MAC) aus
der Seriennummer der Speicherkarte ab. Mit einer anderen Karte bekommt es eine
andere Adresse und erscheint in der Freifunk-Karte als neuer Knoten.

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
- abgeleitet: Gluons Setup-Mode läuft an den LAN-Buchsen, nicht an WAN (Anschluss)
- abgeleitet: Imagegröße aus Config-images.in (Schritte (Normalweg), Dauer)
- abgeleitet: OpenWrt diag.sh (Sichtbare Zeichen)
- abgeleitet: targets/rockchip-armv8 (Weg ab Werk, Schritte (Normalweg), Datei)
- geprüft: OpenWrt rockchip/image/Makefile append-metadata; gzip-Verhalten abgeleitet (Fehlerbild)
- geprüft: OpenWrt-Commits 8f578c15/78226647; Gluon targets/rockchip-armv8 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: OpenWrt-Patch led-boot/running = sys_led, diag.sh, Gluon gluon-setup-mode S96led (Sichtbare Zeichen)
- geprüft: Wiki toh:raspberry_pi_foundation:raspberry_pi (Schritte (Normalweg), Programm)
- geprüft: Wiki toh:raspberry_pi_foundation:raspberry_pi, Wiki toh:friendlyarm:nanopi_r2s (dd, gzip -d); Win32DiskImager: Wiki-Zusammenfassung: FriendlyElec-Wiki, nicht lokal (Programm)
- geprüft: rpi-imager CommonStrings.qml, etcher supported-formats.ts (Schritte (Normalweg), Programm)
- Geräteeintrag: Gluon targets/rockchip-armv8; R2C: gluon-patches-hardware devices/add-nanopi-r2c
