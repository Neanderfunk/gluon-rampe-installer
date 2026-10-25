---
gluon_name: gl.inet-gl-ap1300
modell: GL.iNet GL-AP1300
anzeige: GL.iNet GL-AP1300
familie: glinet
gluon_broken: false
sprache: de
level: L3
level_text: Feste Adresse am Rechner
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht]
daten_stand: e9343f57
vorlage_stand: 33a38da8
---

# GL.iNet GL-AP1300: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-AP1300)

GL.iNet-Router haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, startet statt der Firmware eine schlichte
Webseite zum Hochladen. Über die kommt die Freifunk-Firmware auf den Router.
Du brauchst nur einen Browser und eine feste Adresse am Rechner.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-AP1300, und zwar das
  **factory**-Image

## Vorher prüfen

Beim AP1300 kommt im Notfall-Modus das **factory**-Image (Endung `.ubi`)
hoch, nicht das sysupgrade.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.2`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Schalte ein VPN
   am Rechner aus (auch Tailscale oder ZeroTier), das stört sonst.

3. **Kabel stecken.** Steck das Kabel vom Rechner an eine LAN-Buchse.
   Alle anderen Buchsen bleiben frei. Der Router hat noch keinen Strom.

4. **Notfall-Modus starten.** Drück die Reset-Taste, steck den Strom ein und halte sie etwa 10 Sekunden, bis die Power-LED schneller blinkt. Dann loslassen. Die Power-LED blinkt erst 5-mal langsam, leuchtet kurz und blinkt dann dauernd schnell.

5. **Hochladen.** Öffne im Browser `http://192.168.1.1`. Es erscheint die
   schlichte Notfall-Seite. Wähl das factory-Image aus und
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

- geprüft (Weg ab Werk)
- geprüft: Commit (Notweg)
- geprüft: Commit b938918 (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Commit, nand-factory.ubi (Schritte (Normalweg), Datei)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Schritte (Normalweg), Sichtbare Zeichen, Anschluss, Adressen, Programm, Dauer)
- Geräteeintrag: OpenWrt b9389186b012e5bd99ea6523b8220aaee6ca0085
