---
gluon_name: gl.inet-6416
modell: GL.iNet 6416
anzeige: GL.iNet 6416
familie: glinet
gluon_broken: false
sprache: de
level: L3
level_text: Feste Adresse am Rechner
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht]
daten_stand: 188d88d2
vorlage_stand: 33a38da8
---

# GL.iNet 6416: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%206416)

GL.iNet-Router haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, startet statt der Firmware eine schlichte
Webseite zum Hochladen. Über die kommt die Freifunk-Firmware auf den Router.
Du brauchst nur einen Browser und eine feste Adresse am Rechner.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet 6416, und zwar das
  **sysupgrade**-Image

## Vorher prüfen

6408 und 6416 sehen gleich aus und unterscheiden sich nur im Speicher (8 MB
bzw. 16 MB). Nimm das Image für genau dein Gerät. Es gibt auch Ausführungen
mit nur einem Netzwerkanschluss von anderen Anbietern.

Der Notfall-Modus ist beim 6416 nur aus dem OpenWrt-Wiki beschrieben, und
woran man das Ende des Schreibens erkennt, nennt keine Quelle. Einfacher, aber
schlechter belegt: Das sysupgrade-Image direkt über die GL.iNet-Oberfläche
hochladen.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.2`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Schalte ein VPN
   am Rechner aus (auch Tailscale oder ZeroTier), das stört sonst.

3. **Kabel stecken.** Steck das Kabel vom Rechner an eine LAN-Buchse.
   Alle anderen Buchsen bleiben frei. Der Router hat noch keinen Strom.

4. **Notfall-Modus starten.** Strom ab, Reset-Taste halten, Strom wieder an. Die LED blinkt einige Male grün, dann ganz kurz rot: beim roten Blinken loslassen.

5. **Hochladen.** Öffne im Browser `http://192.168.1.1`. Es erscheint die
   schlichte Notfall-Seite. Wähl das sysupgrade-Image aus und
   starte das Hochladen ("Update firmware"). Die Seite zeigt dann
   "UPDATE IN PROGRESS" mit einem Ladekreis, der sich endlos weiterdreht,
   auch wenn der Router längst fertig ist. Das ist normal.

6. **Warten.** Der Router schreibt die Firmware, das dauert
   etwa 3 Minuten.
   **Strom nicht ziehen.**

7. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 zeigen die LEDs, dass der Notfall-Modus erreicht ist, und
  unter `http://192.168.1.1` kommt die Notfall-Seite.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Unter `http://192.168.1.1` kommt nichts.** Prüf die feste Adresse
  (Schritt 2), schalte VPN-Programme aus, zieh das Kabel am Rechner einmal
  kurz ab ([Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md))
  und versuch Schritt 4 noch einmal, diesmal genau auf die LEDs achtend. Kommt "Not Found" oder "PAGE NOT
  FOUND", siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Wiki (Sichtbare Zeichen)
- abgeleitet: Wiki toh/gl.inet/6416 (Schritte (Normalweg), Taste und Zeitpunkt)
- abgeleitet: Wiki; Geräteadresse 192.168.1.1 geprüft: Commit b4d3110 (Schritte (Normalweg), Anschluss, Adressen, Programm)
- geprüft (Weg ab Werk, Schritte (Normalweg), Quelle (OpenWrt-Commit))
- geprüft: Commit (Datei, Notweg)
- geprüft: Commit b4d3110 (Typenschild/Verwechslung)
- Geräteeintrag: b4d3110ac1f1f1962f812ac139c437837a448cff [geprüft]
