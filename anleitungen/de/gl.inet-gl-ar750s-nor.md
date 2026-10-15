---
gluon_name: gl.inet-gl-ar750s-nor
modell: GL.iNet GL-AR750S NOR
anzeige: GL.iNet GL-AR750S NOR
familie: glinet
gluon_broken: false
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [feste-ip]
daten_stand: lokal
vorlage_stand: 393f161
---

# GL.iNet GL-AR750S NOR: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-AR750S%20NOR)

GL.iNet-Router haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, startet statt der Firmware eine schlichte
Webseite zum Hochladen. Über die kommt die Freifunk-Firmware auf den Router.
Du brauchst nur einen Browser und eine feste Adresse am Rechner.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-AR750S NOR, und zwar das
  **sysupgrade**-Image

## Vorher prüfen

Der GL-AR750S "Slate" (auch -EXT) ist ein anderes Gerät als der
[GL-AR750 "Creta"](gl.inet-gl-ar750.md). Die Freifunk-Firmware kommt in den
NOR-Speicher; auf der Notfall-Seite gibt es dafür einen eigenen Abschnitt.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.2`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Schalte ein VPN
   am Rechner aus (auch Tailscale oder ZeroTier), das stört sonst.

3. **Kabel stecken.** Steck das Kabel vom Rechner an eine LAN-Buchse.
   Alle anderen Buchsen bleiben frei. Der Router hat noch keinen Strom.

4. **Notfall-Modus starten.** Strom ab, Reset-Taste halten, Strom wieder an und halten, bis die rechte LED 5-mal geblinkt hat. Dann loslassen.

5. **Hochladen.** Öffne im Browser `http://192.168.1.1`. Es erscheint die
   schlichte Notfall-Seite. Wähl das sysupgrade-Image im Abschnitt „NOR flash“ mit „update nor firmware“ aus und
   starte das Hochladen ("Update firmware"). Ist die Datei übertragen, zieh das Netzwerkkabel,
   bevor der Router neu startet.

6. **Warten.** Der Router schreibt die Firmware, das dauert etwa
   3 Minuten.
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

- abgeleitet: Modellnamen; Profil geprüft: Commit b496a22 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft (Weg ab Werk, Schritte (Normalweg), Quelle (OpenWrt-Commit))
- geprüft: Commit af28d8a (Schritte (Normalweg), Sichtbare Zeichen, Anschluss, Adressen, Datei)
- geprüft: Commit af28d8a, GL-Doku 'GL-AR750S-EXT (Slate): 5 times' (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Schritte (Normalweg), Anschluss, Adressen, Programm, Dauer)
- Geräteeintrag: af28d8a539fe64bfc893f798fdbbc49b4e78352a (Einführung, Anleitung); b496a2294c6e663a2dcbf08d714443e758d1269d (NOR/NAND) [geprüft]
