---
gluon_name: gl.inet-gl-b1300
modell: GL.iNet GL-B1300
anzeige: GL.iNet GL-B1300
familie: glinet
gluon_broken: false
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [feste-ip, tftp-server]
daten_stand: 96d57cf
vorlage_stand: 393f161
---

# GL.iNet GL-B1300: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-B1300)

GL.iNet-Router haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, startet statt der Firmware eine schlichte
Webseite zum Hochladen. Über die kommt die Freifunk-Firmware auf den Router.
Du brauchst nur einen Browser und eine feste Adresse am Rechner.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-B1300, und zwar das
  **sysupgrade**-Image

## Vorher prüfen

**Dateiname:** Laut OpenWrt (Stand 2017) muss die Datei genau
`lede-gl-b1300.bin` heißen. Ob neuere Bootloader das noch verlangen, ist
nicht geklärt; mit diesem Namen bist du auf der sicheren Seite.

**LEDs im Notfall-Modus:** Laut GL.iNet bleibt die Power-LED an, die rechte
WLAN-LED blinkt 4-mal, dann leuchtet die mittlere LED. Bei alten B1300
blinken mittlere und rechte LED 5-mal und bleiben dann an.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter. Benenne es in `lede-gl-b1300.bin` um, genau so.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.2`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Schalte ein VPN
   am Rechner aus (auch Tailscale oder ZeroTier), das stört sonst.

3. **Kabel stecken.** Steck das Kabel vom Rechner an eine LAN-Buchse.
   Alle anderen Buchsen bleiben frei. Der Router hat noch keinen Strom.

4. **Notfall-Modus starten.** Drück die Reset-Taste, steck den Strom ein und halte die Taste, bis die LEDs dauerhaft leuchten. Dann loslassen.

5. **Hochladen.** Öffne im Browser `http://192.168.1.1`. Es erscheint die
   schlichte Notfall-Seite. Wähl das sysupgrade-Image aus und
   starte das Hochladen ("Update firmware").

6. **Warten.** Der Router schreibt die Firmware, das dauert etwa
   3 Minuten. Beim Schreiben blinkt die WLAN-LED.
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

## Notfall für Erfahrene: TFTP

Liegt die Datei `lede-gl-b1300.bin` auf einem TFTP-Server mit der Adresse
`192.168.1.2` ([TFTP-Server einrichten](grundlagen/tftp-server.md)), holt
der Bootloader sie im Notfall-Modus selbst ab.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: offen (Datei)
- geprüft: Commit (Notweg)
- geprüft: Commit 04d3308 (Schritte (Normalweg), Sichtbare Zeichen)
- geprüft: Commit 04d3308 'three leds constantly on' (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Commit von 2017, ob neuere U-Boots denselben Namen erwarten: offen (Weg ab Werk, Schritte (Normalweg))
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Schritte (Normalweg), Taste und Zeitpunkt, Anschluss, Adressen, Programm, Dauer)
- Geräteeintrag: OpenWrt 04d3308b6248ef21a6f0bc3378b342906c2d2865
