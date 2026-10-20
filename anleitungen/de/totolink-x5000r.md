---
gluon_name: totolink-x5000r
modell: TOTOLINK X5000R
anzeige: TOTOLINK X5000R
familie: sonderweg-totolink-x5000r
gluon_broken: false
sprache: de
level: L1
level_text: Zwei Schritte im Browser
risiko: normal
status: erprobt
erprobt_am: 2026-10-16
erprobt_mit: Gluon 2025.1 (26100702bro), vorher TOTOLINK-Firmware V9.1.0u.6118 über den Notfall-Modus
grundlagen: [browser-https, browser-not-found, feste-ip, router-antwortet-nicht]
daten_stand: a459f9d4
vorlage_stand: 33a38da8
---

# TOTOLINK X5000R: Freifunk-Firmware installieren

> **Am Gerät erprobt** am 16.10.2026 mit `Gluon 2025.1 (26100702bro), vorher TOTOLINK-Firmware V9.1.0u.6118 über den Notfall-Modus`.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TOTOLINK%20X5000R)

Beim TOTOLINK X5000R nimmt die Weboberfläche von TOTOLINK die Freifunk-Firmware
direkt an. Manche neueren Versionen der TOTOLINK-Firmware lehnen die Datei
allerdings ab. Dann spielst du zuerst über
den Notfall-Modus des Routers eine ältere TOTOLINK-Firmware auf und danach
die Freifunk-Firmware. Rechne mit einer Viertelstunde, mit Umweg mit einer
halben Stunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TOTOLINK X5000R, und zwar das
  **sysupgrade**-Image
- nur für den Umweg: die ältere TOTOLINK-Firmware
  [X5000R_V9.1.0u.6118_B20201102.zip](https://download.ffnef.de/other/dump/X5000R_V9.1.0u.6118_B20201102.zip). TOTOLINK bietet sie nicht mehr an; wir stellen die Originaldatei bereit.

## Schritte

1. **Rechner anschließen.** Steck das Kabel vom Rechner in eine
   LAN-Buchse des Routers und schalte ihn ein. Der Rechner bleibt auf
   "automatisch" (DHCP).

2. **Weboberfläche öffnen.** Öffne im Browser `http://192.168.0.1` (oder
   `http://itotolink.net`) und melde dich an. Nennt die Oberfläche das Gerät
   **X5000RU**, ist das derselbe Router: Die Freifunk-Firmware für den
   TOTOLINK X5000R passt.

3. **Freifunk-Firmware hochladen.** Such den Menüpunkt für das
   Firmware-Update. Bei der TOTOLINK-Firmware V9.1.0u.6118 ist das
   **Advanced**, links **Tools**, oben **Upgrade**, dann **Local Upgrade**.
   Wähl über "Durchsuchen…" das sysupgrade-Image deiner Community aus. Die
   Oberfläche lädt die Datei sofort hoch ("Uploading…"), schreibt sie aber
   noch nicht. Danach erscheint ein Knopf **"Upgrade"**: Erst der Klick
   darauf startet das Schreiben ("Upgrading…" mit Prozentzahl). Ohne den
   Klick passiert nichts. Bleibt es bei "Uploading…" und kein Knopf
   erscheint, lade die Seite neu und wähl die Datei noch einmal aus.

   **Meldet die Oberfläche "Invalid upgrade firmware file"** oder etwas
   Ähnliches, ist die TOTOLINK-Firmware zu neu. Dann zuerst den Abschnitt
   "Umweg: ältere TOTOLINK-Firmware aufspielen" unten, danach diese Schritte
   noch einmal.

4. **Fertig.** Der Router schreibt die Freifunk-Firmware und startet neu,
   einige Minuten, Strom nicht ziehen. Die TOTOLINK-Seite im Browser bleibt
   dabei stehen oder wird leer, das ist normal. Danach startet die Freifunk-Firmware
   deiner Community: je nach Community zuerst mit einer Einrichtungsseite
   unter `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Umweg: ältere TOTOLINK-Firmware aufspielen

Der Router hat einen Notfall-Modus im Bootloader, der jede
TOTOLINK-Firmware annimmt, auch eine ältere. Danach nimmt die Weboberfläche
auch wieder die Freifunk-Firmware.

1. **ZIP auspacken.** Pack `X5000R_V9.1.0u.6118_B20201102.zip` aus. Kommt dabei keine
   Fehlermeldung, ist die Datei heil. Gebraucht wird
   `TOTOLINK_C8343R-1C_X5000R_IP04433_MT7621A_SPI_16M256M_V9.1.0u.6118_B20201102_ALL.web` darin.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.10`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

3. **Notfall-Modus starten.** Zieh den Stecker des Netzteils. Halt die
   **Reset**-Taste gedrückt und steck das Netzteil wieder ein. Halt die
   Taste weiter, bis **alle LAN-LEDs** grün leuchten und kurz darauf die
   blaue Status-LED einmal blinkt. Dann loslassen.

4. **Kabel an LAN1.** Steck das Kabel vom Rechner in die Buchse **LAN1**.

5. **Notfall-Seite öffnen.** Öffne im Browser `http://192.168.1.1`. Es
   erscheint eine schlichte Seite "FIRMWARE UPDATE". Kommt "PAGE NOT FOUND"
   und in der Adresszeile steht `cgi-bin/luci`, öffne
   `http://192.168.1.1/index.html` (mehr unter
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md)). Kommt
   gar nichts, prüf mit `ping 192.168.1.1`, ob der Router antwortet. Wenn
   nicht, fang bei Schritt 3 wieder an.

6. **Ältere Firmware hochladen.** Wähl `TOTOLINK_C8343R-1C_X5000R_IP04433_MT7621A_SPI_16M256M_V9.1.0u.6118_B20201102_ALL.web` aus und klick **"Update firmware"**. Die
   Seite zeigt "UPDATE IN PROGRESS" mit einem Ladekreis.

7. **Warten.** Die Seite bleibt so stehen, der Ladekreis dreht sich endlos
   weiter. Das ist normal. Der Router schreibt die Firmware und startet von
   selbst neu, das dauert etwa 3 Minuten. Danach geht das Licht an den
   LAN-Buchsen aus, bis auf die Buchse mit deinem Kabel, und die blaue
   Status-LED blinkt langsam. Strom bis dahin nicht ziehen.

8. **Zurück zum Anfang.** Stell den Rechner wieder auf "automatisch" und
   mach oben mit Schritt 2 weiter: Die TOTOLINK-Oberfläche ist wieder unter
   `http://192.168.0.1` erreichbar.

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 zeigt die Oberfläche nach dem Klick auf "Upgrade"
  "Upgrading…" mit Prozentzahl.
- Nach Schritt 4 meldet sich die Freifunk-Firmware.
- Beim Umweg erscheint in Schritt 5 die Notfall-Seite, und nach Schritt 7
  meldet sich wieder die TOTOLINK-Oberfläche unter `http://192.168.0.1`.

## Wenn etwas schiefgeht

- **Die Weboberfläche lehnt die Datei ab.** Siehe "Umweg" oben.
- **Nach "Uploading…" passiert nichts, der Router startet nicht neu.** Der
  Klick auf "Upgrade" fehlt (Schritt 3). Seite neu laden, Datei noch einmal
  auswählen und dann "Upgrade" klicken.
- **Die Notfall-Seite erscheint nicht.** Prüf die feste Adresse am Rechner,
  ob das Kabel in LAN1 steckt und ob die Reset-Taste schon vor dem Strom
  gedrückt war. Manche Browser machen aus `http` von selbst `https`, siehe
  [Browser macht https daraus](grundlagen/browser-https.md).
- **Der Router startet nach dem Update nicht richtig.** Der Notfall-Modus
  steckt im Bootloader und bleibt erhalten. Spiel über ihn die ältere
  TOTOLINK-Firmware auf (Umweg) und fang von vorn an.

## Zurück zur TOTOLINK-Firmware

Über den Notfall-Modus (Umweg, Schritte 2 bis 7) nimmt der Router jede
TOTOLINK-Firmware an, auch eine neuere.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: sysupgrade startet neu (Schritte (Normalweg))
- abgeleitet: webui-upload (Schritte (Normalweg))
- geprüft (Weg ab Werk, Schritte (Normalweg), Datei)
- geprüft: Commit 23be410 (Schritte (Normalweg), Programm)
- geprüft: Test Neanderfunk 16.10.2026 (Sichtbare Zeichen, Typenschild/Verwechslung, Notweg)
- geprüft: forum.openwrt.org t/113153 #1, #3 (2021-11-28); t/124500 #1, #3 (2022-04-05) (Bedingung an die Herstellerfirmware)
- geprüft: geladen und gehasht 15.10.2026 (Bedingung an die Herstellerfirmware)
- Geräteeintrag: 23be410b3d1267c752bf9f6e5c8f5a514dc562c4
