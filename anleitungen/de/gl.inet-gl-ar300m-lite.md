---
gluon_name: gl.inet-gl-ar300m-lite
modell: GL.iNet GL-AR300M Lite
anzeige: GL.iNet GL-AR300M Lite
familie: glinet
gluon_broken: false
sprache: de
level: L0
level_text: Einfach hochladen
risiko: normal
status: ungeprüft
grundlagen: [feste-ip]
daten_stand: c21be24c
vorlage_stand: 393f1614
---

# GL.iNet GL-AR300M Lite: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-AR300M%20Lite)

GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Die Freifunk-Firmware lädst du deshalb ganz einfach über die Oberfläche von
GL.iNet hoch, wie ein normales Update. Du brauchst nur einen Browser.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-AR300M Lite, und zwar das
  **sysupgrade**-Image. Das ist bei GL.iNet richtig, auch wenn es die erste
  Installation ist.

## Vorher prüfen

GL-AR300M (mit zusätzlichem NAND-Speicher), GL-AR300M16 (nur 16 MB NOR) und
GL-AR300M-Lite (nur ein Netzwerkanschluss) brauchen je ihr eigenes Image.

Noch Ende 2024 wurden AR300M mit einem alten Bootloader verkauft, der neue
Images ablehnen kann. Laut OpenWrt lässt er sich über
`http://192.168.1.1/uboot.html` im Notfall-Modus aktualisieren.

Der AR300M-Lite hat nur **einen** Netzwerkanschluss.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Verbinden.** Steck das Kabel vom Rechner in eine LAN-Buchse des Routers und
   schalte ihn ein. Der Rechner holt sich seine Adresse automatisch.

3. **Oberfläche öffnen.** Öffne im Browser die Oberfläche von GL.iNet;
   die Adresse steht auf dem Aufkleber, meist ist es `http://192.168.8.1`. Beim ersten Mal
   fragt GL.iNet nach Sprache und einem Passwort für die Verwaltung: Leg eins
   fest, du brauchst es nur für diese Installation.

4. **Firmware hochladen.** Geh zu **Advanced** und wähl das
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

## Notfall: U-Boot-Weboberfläche

Klappt es über die GL.iNet-Oberfläche nicht, oder startet der Router nicht
mehr, hilft der eingebaute Notfall-Modus:

1. Rechner fest auf `192.168.1.2`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)), VPN am Rechner
   aus. Kabel an eine LAN-Buchse,
   alle anderen Buchsen frei.
2. Drück die Reset-Taste fest, steck den Strom ein und halte die Taste, bis die LED 5-mal geblinkt hat. Dann loslassen.
3. Im Browser `http://192.168.1.1` öffnen, das sysupgrade-Image auswählen,
   "Update firmware".
4. Etwa 3 Minuten warten, Strom nicht ziehen.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: GL-Doku AR300M (Notweg)
- abgeleitet: GL-Doku-Eintrag 'GL-AR300M (Shadow)' (Notweg)
- abgeleitet: Wiki toh/gl.inet/gl-ar300m (Bedingung an die Herstellerfirmware)
- geprüft (Weg ab Werk, Schritte (Normalweg), Quelle (OpenWrt-Commit))
- geprüft: Commit fefa34d (Schritte (Normalweg), Taste und Zeitpunkt, Programm, Datei)
- geprüft: Commits fefa34d, b591cab, 55e6c90 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Notweg)
- Geräteeintrag: fefa34def84561688e6af2feeec2dbb390ba4486 [geprüft]
