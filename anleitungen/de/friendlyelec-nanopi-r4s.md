---
gluon_name: friendlyelec-nanopi-r4s
modell: FriendlyElec NanoPi R4S (4 GB)
anzeige: FriendlyElec NanoPi R4S (4 GB)
familie: image-auf-datentraeger
gluon_broken: false
sprache: de
level: L4
level_text: Network-Tools
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, image-schreiben, router-antwortet-nicht]
daten_stand: cfa733f38
vorlage_stand: ae4d4370f
---

# FriendlyElec NanoPi R4S (4 GB): Freifunk-Firmware installieren

> Schreib uns, ob es geklappt hat. Und wenn es irgendwo hakt: Melde dich,
> wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20FriendlyElec%20NanoPi%20R4S%20%284%20GB%29)

Beim FriendlyElec NanoPi R4S (4 GB) gibt es keine Firmware, die man über eine Oberfläche
hochlädt. Die Freifunk-Firmware wird als fertiges Abbild direkt auf
eine microSD-Karte geschrieben, und das Gerät startet davon.

## Was du brauchst

- das Gerät und eine microSD-Karte
- einen Rechner, an dem du eine microSD-Karte beschreiben kannst
- ein Netzwerkkabel für die Einrichtung
- die Freifunk-Firmware deiner Community für den FriendlyElec NanoPi R4S (4 GB), und zwar das
  **sysupgrade**-Image (Endung `.img.gz`). Das ist hier richtig, auch für die
  erste Installation: Für dieses Gerät gibt es kein factory-Image.

## Vorher prüfen

Nur die Variante mit **4 GB** Arbeitsspeicher. Die 1-GB-Variante ist laut
OpenWrt nicht unterstützt, und die "Enterprise Edition" ist ein eigenes
Gerät, das die Freifunk-Firmware nicht kennt. Woran man die Varianten von
außen unterscheidet, nennt keine unserer Quellen.

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
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

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
