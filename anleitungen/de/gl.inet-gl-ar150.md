---
gluon_name: gl.inet-gl-ar150
modell: GL.iNet GL-AR150
anzeige: GL.iNet GL-AR150
familie: glinet
gluon_broken: false
sprache: de
stufe: mit scripts/Netzwerktools
status: ungeprüft
grundlagen: [feste-ip]
daten_stand: 440a725
vorlage_stand: 393f161
---

# GL.iNet GL-AR150: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-AR150)

GL.iNet-Router haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, startet statt der Firmware eine schlichte
Webseite zum Hochladen. Über die kommt die Freifunk-Firmware auf den Router.
Du brauchst nur einen Browser und eine feste Adresse am Rechner.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-AR150, und zwar das
  **sysupgrade**-Image

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.2`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Schalte ein VPN
   am Rechner aus (auch Tailscale oder ZeroTier), das stört sonst.

3. **Kabel stecken.** Steck das Kabel vom Rechner an eine LAN-Buchse.
   Alle anderen Buchsen bleiben frei. Der Router hat noch keinen Strom.

4. **Notfall-Modus starten.** Drück die Reset-Taste fest, steck den Strom ein und halte die Taste, bis die rote LED 5-mal geblinkt hat; beim 6. Blinken loslassen. Leuchtet nur noch die linke grüne LED, ist der Notfall-Modus erreicht.

5. **Hochladen.** Öffne im Browser `http://192.168.1.1`. Es erscheint die
   schlichte Notfall-Seite. Wähl das sysupgrade-Image aus und
   starte das Hochladen ("Update firmware").

6. **Warten.** Der Router schreibt die Firmware, das dauert etwa
   3 Minuten. Gehen alle LEDs aus, ist das Schreiben fertig.
   **Strom nicht ziehen.**

7. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 zeigen die LEDs, dass der Notfall-Modus erreicht ist, und
  unter `http://192.168.1.1` kommt die Notfall-Seite.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Unter `http://192.168.1.1` kommt nichts.** Prüf die feste Adresse
  (Schritt 2), schalte VPN-Programme aus und versuch Schritt 4 noch einmal,
  diesmal genau auf die LEDs achtend. Hilft ein anderer Browser oder ein
  privates Fenster, lag es am Zwischenspeicher des Browsers.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Übertragung, Gluon-RAMpe passt, Quelle (OpenWrt-Commit))
- abgeleitet: Commit 53c474a ohne Anleitung, Verfahren wie bei den anderen GL.iNet (Weg ab Werk, Schritte (Normalweg), Datei)
- abgeleitet: Wiki (Dauer)
- abgeleitet: Wiki toh/gl.inet/gl-ar150 (Schritte (Normalweg), Sichtbare Zeichen)
- abgeleitet: Wiki, Stock ist GL.iNet-OpenWrt (Notweg)
- geprüft: GL-Doku 5x; '6. Blinken' abgeleitet: Wiki toh/gl.inet/gl-ar150 (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Schritte (Normalweg), Taste und Zeitpunkt, Anschluss, Adressen, Programm, Dauer)
- Geräteeintrag: 53c474abbdfef8eb3499e2d10c9ad491788b8a72 (erstes ath79-Target, ohne Anleitung) [abgeleitet]
