---
gluon_name: gl-mt300n
modell: GL.iNet GL-MT300N (v1)
anzeige: GL.iNet GL-MT300N (v1)
familie: glinet
gluon_broken: false
sprache: de
level: L0
level_text: Einfach hochladen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip]
daten_stand: 33ff3500
vorlage_stand: 25ed43f7
---

# GL.iNet GL-MT300N (v1): Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-MT300N%20%28v1%29)

GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Die Freifunk-Firmware lädst du deshalb ganz einfach über die Oberfläche von
GL.iNet hoch, wie ein normales Update. Du brauchst nur einen Browser.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-MT300N (v1), und zwar das
  **sysupgrade**-Image. Das ist bei GL.iNet richtig, auch wenn es die erste
  Installation ist.

## Vorher prüfen

Nur der GL-MT300N **v1** (64 MB Arbeitsspeicher). Der
[GL-MT300N-V2 "Mango"](gl-mt300n-v2.md) ist ein anderes Gerät mit eigenem
Image; achte auf dem Aufkleber auf "-V2".

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
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Prüf, ob es das sysupgrade-Image für
  genau dieses Modell ist. Sonst hilft der Notfall-Modus (unten).

## Notfall: U-Boot-Weboberfläche

Klappt es über die GL.iNet-Oberfläche nicht, oder startet der Router nicht
mehr, hilft der eingebaute Notfall-Modus:

1. Rechner fest auf `192.168.1.2`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)), VPN am Rechner
   aus. Kabel an eine LAN-Buchse,
   alle anderen Buchsen frei.
2. Drück die Reset-Taste fest, steck den Strom ein und halte die Taste, bis die LED 3-mal geblinkt hat. Dann loslassen.
3. Im Browser `http://192.168.1.1` öffnen, das sysupgrade-Image auswählen,
   "Update firmware". Der Ladekreis auf der Seite dreht sich danach endlos
   weiter, das ist normal.
4. Etwa 3 Minuten warten, Strom nicht ziehen.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Wiki, Commit ohne Installationstext (Weg ab Werk, Schritte (Normalweg), Taste und Zeitpunkt, Programm, Datei, Notweg)
- geprüft: Commits be53e5a, abbfcc8; Typenschild-Aufdruck abgeleitet (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: GL-Doku (Notweg)
- geprüft: GL-Doku 'GL-MT300N and GL-MT300A: The LED flashes 3 times' (Notweg)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Notweg)
- Geräteeintrag: be53e5a154931109dd76a8015583123201c4b602 (ohne Installationstext) + Wiki toh:gl.inet
