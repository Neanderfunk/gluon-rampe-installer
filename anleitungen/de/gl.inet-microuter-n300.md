---
gluon_name: gl.inet-microuter-n300
modell: GL.iNet microuter-N300
anzeige: GL.iNet microuter-N300
familie: glinet
gluon_broken: false
sprache: de
level: L0
level_text: Einfach hochladen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip]
daten_stand: 2da2e5be
vorlage_stand: 25ed43f7
---

# GL.iNet microuter-N300: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20microuter-N300)

GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Die Freifunk-Firmware lädst du deshalb ganz einfach über die Oberfläche von
GL.iNet hoch, wie ein normales Update. Du brauchst nur einen Browser.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner oder Laptop mit WLAN
- die Freifunk-Firmware deiner Community für den GL.iNet microuter-N300, und zwar das
  **sysupgrade**-Image. Das ist bei GL.iNet richtig, auch wenn es die erste
  Installation ist.

## Vorher prüfen

microuter-N300 und VIXMINI sehen gleich aus, haben aber verschieden viel
Speicher und je ihr eigenes Image (nicht [VIXMINI](gl.inet-vixmini.md)).

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Verbinden.** Verbinde dich per **WLAN** mit dem Router. Sein
   Netzwerkanschluss ist ab Werk für den Internetzugang gedacht (WAN), darüber
   kommst du nicht an die Oberfläche. Name und Passwort des WLANs stehen auf
   dem Aufkleber.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.8.1`. Beim ersten Mal
   fragt GL.iNet nach Sprache und einem Passwort für die Verwaltung: Leg eins
   fest, du brauchst es nur für diese Installation.

4. **Firmware hochladen.** Geh zu **Update → Local Update** und wähl das
   sysupgrade-Image aus. **Einstellungen nicht behalten:** Entfern den Haken
   bei "Keep Settings" (oder wähl "Do not keep configuration"). Dann das
   Update starten.

5. **Warten.** Der Router schreibt die Firmware und startet neu, einige
   Minuten. **Strom nicht ziehen.**

6. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md). Für die Einrichtung brauchst du jetzt ein
   Netzwerkkabel, das WLAN des Herstellers gibt es nicht mehr.

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
2. Drück die Reset-Taste fest, steck den Strom ein und halte die Taste, bis die LED 5-mal geblinkt hat. Dann loslassen.
3. Im Browser `http://192.168.1.1` öffnen, das sysupgrade-Image auswählen,
   "Update firmware". Der Ladekreis auf der Seite dreht sich danach endlos
   weiter, das ist normal.
4. Etwa 3 Minuten warten, Strom nicht ziehen.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit (Notweg)
- geprüft: Commit b30f228 (Schritte (Normalweg), Anschluss, Adressen, Programm, Datei, Typenschild/Verwechslung)
- geprüft: Commit b30f228, GL-Doku 'microuter-N300: 5 times' (Taste und Zeitpunkt, Notweg)
- geprüft: Commit, GL-Doku (Notweg)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Notweg)
- Geräteeintrag: b30f2281cce6649567e0194d203f06517d173115
