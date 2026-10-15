---
gluon_name: gl.inet-gl-usb150
modell: GL.iNET GL-USB150
anzeige: GL.iNET GL-USB150
familie: glinet
gluon_broken: false
sprache: de
level: L0
risiko: normal
status: ungeprüft
grundlagen: []
daten_stand: 3b96298
vorlage_stand: 393f161
---

# GL.iNET GL-USB150: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNET%20GL-USB150)

GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Die Freifunk-Firmware lädst du deshalb ganz einfach über die Oberfläche von
GL.iNet hoch, wie ein normales Update. Du brauchst nur einen Browser.

## Was du brauchst

- den Router mit Netzteil (beim GL.iNET GL-USB150 entfällt das: er steckt im USB-Port des Rechners)
- die Freifunk-Firmware deiner Community für den GL.iNET GL-USB150, und zwar das
  **sysupgrade**-Image. Das ist bei GL.iNet richtig, auch wenn es die erste
  Installation ist.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Verbinden.** Steck den GL.iNET GL-USB150 in einen USB-Anschluss des
   Rechners. Er meldet sich dort als Netzwerkkarte.

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

## Woran du erkennst, dass es geklappt hat

- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Prüf, ob es das sysupgrade-Image für
  genau dieses Modell ist. Sonst hilft der Notfall-Modus (unten).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: GL-Doku 'GL-USB150 (Microuter): The LED flashes 5 times', Handhabung beim USB-Stick abgeleitet (Notweg)
- abgeleitet: Wiki toh/gl.inet/gl-usb150 (Schritte (Normalweg), Anschluss)
- geprüft (Weg ab Werk, Schritte (Normalweg), Quelle (OpenWrt-Commit))
- geprüft: Commit a1b5a43 (Schritte (Normalweg), Taste und Zeitpunkt, Programm, Datei)
- Geräteeintrag: a1b5a43fc4b0edda5bbbb4eb0130ba9160dc515b [geprüft]
