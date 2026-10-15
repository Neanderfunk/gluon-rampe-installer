---
gluon_name: gl.inet-gl-mt2500
modell: GL.iNet GL-MT2500 (MaxLinear-PHY)
anzeige: GL.iNet GL-MT2500 (MaxLinear-PHY)
familie: glinet
gluon_broken: false
sprache: de
stufe: mit scripts/Netzwerktools
status: ungeprüft
grundlagen: []
daten_stand: 9e7cd27
vorlage_stand: 393f161
---

# GL.iNet GL-MT2500 (MaxLinear-PHY): Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-MT2500%20%28MaxLinear-PHY%29)

GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Die Freifunk-Firmware lädst du deshalb ganz einfach über die Oberfläche von
GL.iNet hoch, wie ein normales Update. Du brauchst nur einen Browser.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-MT2500 (MaxLinear-PHY), und zwar das
  **sysupgrade**-Image. Das ist bei GL.iNet richtig, auch wenn es die erste
  Installation ist.

## Vorher prüfen

Neuere MT2500 haben einen anderen Netzwerkchip (Airoha statt MaxLinear).
Für diese Variante gibt es in OpenWrt ein eigenes Image, das Gluon nicht
baut; diese Anleitung gilt nur für die MaxLinear-Variante. Woran man die
Variante von außen erkennt, nennt keine unserer Quellen.

Einen Notfall-Modus beschreibt GL.iNet auch für den MT2500 (Power-LED blinkt
5-mal blau, dann dauerhaft weiß). Laut OpenWrt nimmt der Bootloader dort aber
keine fremden Images an.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Verbinden.** Steck das Kabel vom Rechner in eine LAN-Buchse des Routers und
   schalte ihn ein. Der Rechner holt sich seine Adresse automatisch.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.8.1`. Beim ersten Mal
   fragt GL.iNet nach Sprache und einem Passwort für die Verwaltung: Leg eins
   fest, du brauchst es nur für diese Installation.

4. **Firmware hochladen.** Geh zu dem Bereich für
   Firmware-Updates (meist "Upgrade") und wähl das
   sysupgrade-Image aus. **Einstellungen nicht behalten:** Entfern den Haken
   bei "Keep Settings" (oder wähl "Do not keep configuration"). Dann das
   Update starten.

5. **Warten.** Der Router schreibt die Firmware und startet neu, einige
   Minuten. **Strom nicht ziehen.**

6. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Prüf, ob es das sysupgrade-Image für
  genau dieses Modell ist. Sonst hilft der Notfall-Modus (unten).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Übertragung)
- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: 24.10.8-Liste (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit 1239668 (Taste und Zeitpunkt, Notweg)
- geprüft: Commit 1239668; Adresse aus GL-Doku (Schritte (Normalweg), Adressen, Programm, Datei)
- geprüft: GL-Doku (Typenschild/Verwechslung, Notweg)
- geprüft: GL-Doku 'GL-MT2500/GL-MT2500A' (Notweg)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Notweg)
- geprüft: vorhandenes Feld weg, OpenWrt-24.10.8-Liste (Typenschild/Verwechslung)
- Geräteeintrag: OpenWrt 12396686484a488dff1c4a1ee8b5197c552572fe
