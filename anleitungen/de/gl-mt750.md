---
gluon_name: gl-mt750
modell: GL.iNet GL-MT750
anzeige: GL.iNet GL-MT750
familie: glinet
gluon_broken: false
sprache: de
level: L0
level_text: Einfach hochladen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht]
daten_stand: 188d88d2
vorlage_stand: 33a38da8
---

# GL.iNet GL-MT750: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-MT750)

GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Die Freifunk-Firmware lädst du deshalb ganz einfach über die Oberfläche von
GL.iNet hoch, wie ein normales Update. Du brauchst nur einen Browser.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-MT750, und zwar das
  **sysupgrade**-Image. Das ist bei GL.iNet richtig, auch wenn es die erste
  Installation ist.

## Vorher prüfen

Für den MT750 beschreibt keine Quelle das LED-Zeichen des Notfall-Modus.
Vermutlich blinkt die LED wie bei MT300A und MT300N 3-mal.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Verbinden.** Steck das Kabel vom Rechner in eine LAN-Buchse des Routers und
   schalte ihn ein. Der Rechner holt sich seine Adresse automatisch.

3. **Oberfläche öffnen.** Öffne im Browser die Oberfläche von GL.iNet;
   die Adresse steht auf dem Aufkleber, meist ist es `http://192.168.8.1`. Beim ersten Mal
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
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Prüf, ob es das sysupgrade-Image für
  genau dieses Modell ist. Sonst hilft der Notfall-Modus (unten).
- **Im Notfall-Modus zeigt der Browser eine alte Seite.** Laut OpenWrt hilft
  `http://192.168.1.1/index.html?index` gegen den Zwischenspeicher des
  Browsers.

## Notfall: U-Boot-Weboberfläche

Klappt es über die GL.iNet-Oberfläche nicht, oder startet der Router nicht
mehr, hilft der eingebaute Notfall-Modus:

1. Rechner fest auf `192.168.1.2`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)), VPN am Rechner
   aus. Kabel an eine LAN-Buchse,
   alle anderen Buchsen frei.
2. Drück die Reset-Taste fest, steck den Strom ein und halte die Taste, bis die LED blinkt (vermutlich 3-mal wie beim MT300A). Dann loslassen.
3. Im Browser `http://192.168.1.1` öffnen, das sysupgrade-Image auswählen,
   "Update firmware". Der Ladekreis auf der Seite dreht sich danach endlos
   weiter, das ist normal.
4. Etwa 3 Minuten warten, Strom nicht ziehen.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: GL-Doku nennt das MT750 nicht, Wiki ohne Anleitung (Notweg)
- abgeleitet: Wiki toh/gl.inet/gl-mt750 (Notweg)
- abgeleitet: Wiki, Commit ohne Installationstext (Weg ab Werk, Schritte (Normalweg), Programm, Datei, Notweg)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Notweg)
- Geräteeintrag: be7962925927ab5cdc7a13fdb24d1b08792f8f23 (ohne Installationstext) + Wiki toh:gl.inet
