---
gluon_name: gl.inet-gl-b1300
modell: GL.iNet GL-B1300
anzeige: GL.iNet GL-B1300
familie: glinet
gluon_broken: false
sprache: de
level: L0
level_text: Einfach hochladen
risiko: normal
status: erprobt
erprobt_am: 2026-10-16
erprobt_mit: Gluon 2023.2.6 (26091920sta) über LuCI der GL-Firmware 4.3.25; für 2025.1 erwartet gleich (gleiche Metadaten)
grundlagen: [browser-not-found, feste-ip, tftp-server]
daten_stand: cc1cb06c
vorlage_stand: 25ed43f7
---

# GL.iNet GL-B1300: Freifunk-Firmware installieren

> **Am Gerät erprobt** am 16.10.2026 mit `Gluon 2023.2.6 (26091920sta) über LuCI der GL-Firmware 4.3.25; für 2025.1 erwartet gleich (gleiche Metadaten)`.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-B1300)

> **Achtung:** Nicht mit dem **Cudy WR1300** verwechseln: Die Dateinamen sehen sich
> ähnlich (`…-gl.inet-gl-b1300-sysupgrade.bin` und
> `…-cudy-wr1300-v1-sysupgrade.bin`). Meldet LuCI beim Hochladen "not
> supported by this image", ist es die falsche Datei.

GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Deren Update-Seite nimmt die Freifunk-Firmware beim GL.iNet GL-B1300 zwar nicht
an, die mitgelieferte OpenWrt-Oberfläche **LuCI** aber schon. Du brauchst
nur einen Browser.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den GL.iNet GL-B1300, und zwar das
  **sysupgrade**-Image. Das ist bei GL.iNet richtig, auch wenn es die erste
  Installation ist.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Verbinden.** Steck das Kabel vom Rechner in eine LAN-Buchse des Routers und
   schalte ihn ein. Der Rechner holt sich seine Adresse automatisch.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.8.1`. Beim ersten Mal
   fragt GL.iNet nach Sprache (wähl **Deutsch**, dann passen die Namen in
   Schritt 4) und einem Passwort für die Verwaltung: Leg eins
   fest, du brauchst es nur für diese Installation.

4. **Zur OpenWrt-Oberfläche.** Die Update-Seite von GL.iNet
   ("Lokale Aktualisierung") nimmt die Freifunk-Firmware nicht an, lass sie
   aus. Geh stattdessen zu **SYSTEM → Erweiterte Einstellungen** und klick
   dort auf den Link, der auf `/cgi-bin/luci` endet. Es öffnet sich LuCI,
   die Oberfläche von OpenWrt. Melde dich mit dem Benutzer `root` und dem
   Passwort aus Schritt 3 an.

5. **Firmware hochladen.** Geh in LuCI zu **System → Backup / Flash
   Firmware**, klick **"Flash image…"**, wähl das sysupgrade-Image aus und
   klick **"Upload"**.

6. **Prüfung übergehen.** Es erscheint das Fenster "Flash image?" mit einer
   roten Meldung "Image check failed: The device is supported, but the
   config is incompatible to the new image …". Das ist hier normal: Die
   Freifunk-Firmware ist neuer als das OpenWrt von GL.iNet, die alten
   Einstellungen passen nicht dazu. Entfern den Haken bei **"Keep
   settings…"** (die Meldung bleibt trotzdem stehen), setz den Haken bei
   **"Force upgrade"** und klick **"Continue"**.

   Steht dort stattdessen **"not supported by this image"**, ist es das
   Image für ein anderes Gerät. Dann **"Cancel"** und das richtige Image
   holen, hier nie "Force upgrade".

7. **Warten.** Der Router schreibt die Firmware und startet neu, einige
   Minuten. **Strom nicht ziehen.**

8. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 6 steht in der roten Meldung "The device is supported".
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die GL.iNet-Seite "Lokale Aktualisierung" meldet "Der Test der Firmware
  mit sysupgrade ist fehlgeschlagen".** Diese Seite nimmt die
  Freifunk-Firmware beim GL.iNet GL-B1300 nie an. Nimm den Weg über LuCI
  (Schritt 4).
- **LuCI meldet "not supported by this image".** Das Image ist für ein
  anderes Gerät. "Cancel" und das richtige Image holen (Schritt 6).
- Klappt es gar nicht, hilft der Notfall-Modus (unten).

## Notfall: U-Boot-Weboberfläche

Klappt es über die GL.iNet-Oberfläche nicht, oder startet der Router nicht
mehr, hilft der eingebaute Notfall-Modus:

1. Rechner fest auf `192.168.1.2`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)), VPN am Rechner
   aus. Kabel an eine LAN-Buchse,
   alle anderen Buchsen frei.
2. Drück die linke Hälfte der Wippe (Kreispfeil), steck den Strom ein und halte weiter, bis die linke und die mittlere LED dauerhaft grün leuchten. Dann loslassen. Erst leuchten alle drei LEDs kurz grün, dann blinkt die rechte, dann leuchten die linke und die mittlere dauerhaft grün.
3. Im Browser `http://192.168.1.1` öffnen, das sysupgrade-Image auswählen,
   "Update firmware". Der Ladekreis auf der Seite dreht sich danach endlos
   weiter, das ist normal.
4. Etwa 9 Minuten warten, Strom nicht ziehen.

## Notfall-Modus: Dateiname und LEDs

**Dateiname:** Laut OpenWrt (Stand 2017) muss die Datei genau
`lede-gl-b1300.bin` heißen. Ob neuere Bootloader das noch verlangen, ist
nicht geklärt; mit diesem Namen bist du auf der sicheren Seite.

**LEDs:** Bei alten B1300 blinken laut GL.iNet mittlere und rechte LED
5-mal und bleiben dann an.

## Zurück zur GL.iNet-Firmware

Über den Notfall-Modus nimmt der B1300 auch die Firmware von GL.iNet wieder
an. Lade sie unter
[dl.gl-inet.com/router/b1300/stable](https://dl.gl-inet.com/router/b1300/stable)
herunter und spiel sie über die Notfall-Seite auf, wie oben beschrieben.
Bei uns hat das geklappt: Nach etwa 9 Minuten war die GL.iNet-Oberfläche
wieder unter `http://192.168.8.1` erreichbar.

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
- geprüft: Commit von 2017, ob neuere U-Boots denselben Namen erwarten: offen (Schritte (Normalweg))
- geprüft: Commit; Dateiname, DHCP und TFTP am Gerät nicht geprüft (Weg ab Werk)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Schritte (Normalweg), Taste und Zeitpunkt, Anschluss, Adressen, Programm, Dauer)
- geprüft: Test Neanderfunk 16.10.2026 (Weg ab Werk, Taste und Zeitpunkt, Rückweg zur Herstellerfirmware)
- Geräteeintrag: OpenWrt 04d3308b6248ef21a6f0bc3378b342906c2d2865
