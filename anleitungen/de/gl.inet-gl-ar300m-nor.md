---
gluon_name: gl.inet-gl-ar300m-nor
modell: GL.iNet GL-AR300M NOR
anzeige: GL.iNet GL-AR300M NOR
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

# GL.iNet GL-AR300M NOR: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-AR300M%20NOR)

GL.iNet-Router haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, startet statt der Firmware eine schlichte
Webseite zum Hochladen. Über die kommt die Freifunk-Firmware auf den Router.
Du brauchst nur einen Browser und eine feste Adresse am Rechner.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-AR300M NOR, und zwar das
  **sysupgrade**-Image

## Vorher prüfen

GL-AR300M (mit zusätzlichem NAND-Speicher), GL-AR300M16 (nur 16 MB NOR) und
GL-AR300M-Lite (nur ein Netzwerkanschluss) brauchen je ihr eigenes Image.

Noch Ende 2024 wurden AR300M mit einem alten Bootloader verkauft, der neue
Images ablehnen kann. Laut OpenWrt lässt er sich über
`http://192.168.1.1/uboot.html` im Notfall-Modus aktualisieren.

Die Freifunk-Firmware kommt hier in den NOR-Speicher. Der Bootloader fällt nach
drei misslungenen Starts aus dem NAND-Speicher von selbst auf NOR zurück.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.2`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Schalte ein VPN
   am Rechner aus (auch Tailscale oder ZeroTier), das stört sonst.

3. **Kabel stecken.** Steck das Kabel vom Rechner an eine LAN-Buchse.
   Alle anderen Buchsen bleiben frei. Der Router hat noch keinen Strom.

4. **Notfall-Modus starten.** Drück die Reset-Taste fest, steck den Strom ein und halte die Taste, bis die LED 5-mal geblinkt hat. Dann loslassen.

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

- abgeleitet, Adresse im Commit nicht genannt (Übertragung)
- abgeleitet: Wiki toh/gl.inet/gl-ar300m (Bedingung an die Herstellerfirmware)
- geprüft (Weg ab Werk, Quelle (OpenWrt-Commit))
- geprüft: Commit 55e6c90 (Schritte (Normalweg), Datei, Typenschild/Verwechslung)
- geprüft: Commits 55e6c90, b591cab, fefa34d (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: GL-Doku (Sichtbare Zeichen)
- geprüft: GL-Doku 'GL-AR300M (Shadow): The LED flashes 5 times' (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Schritte (Normalweg), Taste und Zeitpunkt, Anschluss, Adressen, Programm, Dauer)
- Geräteeintrag: 55e6c903ae20bd8e694f4626166766e59602f87c (NOR/NAND-Aufteilung, Anleitung); 6e78d546d1197d7a3ec4cbc7aab22286ad49fb0f (Umbenennung) [geprüft]
