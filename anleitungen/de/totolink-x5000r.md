---
gluon_name: totolink-x5000r
modell: TOTOLINK X5000R
anzeige: TOTOLINK X5000R
familie: sonderweg-totolink-x5000r
gluon_broken: false
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [browser-https, feste-ip]
daten_stand: 979581e
vorlage_stand: 674e643
---

# TOTOLINK X5000R: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
> Den Umweg über die ältere TOTOLINK-Firmware kennen wir nur aus Berichten im OpenWrt-Forum.
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
  [f468696a985bdf6e544cdcadbc1585ec.zip](https://web.archive.org/web/20251202002316id_/https://www.totolink.net/data/upload/20201223/f468696a985bdf6e544cdcadbc1585ec.zip), SHA256 `4fdb1bbf1773a3e7bb3d2f36953411e93a7da52277ee8e79e1dd54909e74daeb`. TOTOLINK bietet sie auf der eigenen Seite nicht mehr an; der Link führt auf die Originaldatei von totolink.net im Internet Archive. Pack das ZIP aus; gebraucht wird die Datei
  `TOTOLINK_C8343R-1C_X5000R_IP04433_MT7621A_SPI_16M256M_V9.1.0u.6118_B20201102_ALL.web` darin.

## Schritte

1. **Rechner anschließen.** Steck das Kabel vom Rechner in eine
   LAN-Buchse des Routers und schalte ihn ein. Der Rechner bleibt auf
   "automatisch" (DHCP).

2. **Weboberfläche öffnen.** Öffne im Browser `http://192.168.0.1` (oder
   `http://itotolink.net`) und melde dich an.

3. **Freifunk-Firmware hochladen.** Such den Menüpunkt für das
   Firmware-Update (bei neueren Versionen **Tools → Upgrade → Local
   Upgrade**) und wähl das sysupgrade-Image deiner Community aus. Starte das
   Update.

   **Meldet die Oberfläche "Invalid upgrade firmware file"** oder etwas
   Ähnliches, ist die TOTOLINK-Firmware zu neu. Dann zuerst den Abschnitt
   "Umweg: ältere TOTOLINK-Firmware aufspielen" unten, danach diese Schritte
   noch einmal.

4. **Fertig.** Der Router schreibt die Freifunk-Firmware und startet neu,
   einige Minuten, Strom nicht ziehen. Danach startet die Freifunk-Firmware
   deiner Community: je nach Community zuerst mit einer Einrichtungsseite
   unter `http://192.168.1.1` oder gleich im Betrieb.

## Umweg: ältere TOTOLINK-Firmware aufspielen

Der Router hat einen Notfall-Modus im Bootloader, der jede
TOTOLINK-Firmware annimmt, auch eine ältere. Danach nimmt die Weboberfläche
auch wieder die Freifunk-Firmware.

1. **Datei prüfen.** Prüf die SHA256 der heruntergeladenen Datei: unter
   Linux `sha256sum f468696a985bdf6e544cdcadbc1585ec.zip`, unter macOS
   `shasum -a 256 f468696a985bdf6e544cdcadbc1585ec.zip`, in der Windows-PowerShell
   `Get-FileHash f468696a985bdf6e544cdcadbc1585ec.zip`. Das Ergebnis muss
   `4fdb1bbf1773a3e7bb3d2f36953411e93a7da52277ee8e79e1dd54909e74daeb` lauten (Groß- und Kleinschreibung spielt keine
   Rolle). Dann das ZIP auspacken.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.10`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

3. **Notfall-Modus starten.** Zieh den Stecker des Netzteils. Halt die
   **Reset**-Taste gedrückt und steck das Netzteil wieder ein. Halt die
   Taste weiter, bis **alle LAN-LEDs** grün leuchten und kurz darauf die
   blaue Status-LED einmal blinkt. Dann loslassen.

4. **Kabel an LAN1.** Steck das Kabel vom Rechner in die Buchse **LAN1**.

5. **Notfall-Seite öffnen.** Öffne im Browser `http://192.168.1.1`. Es
   erscheint eine schlichte Seite zum Aktualisieren der Firmware. Kommt
   nichts, prüf mit `ping 192.168.1.1`, ob der Router antwortet. Wenn
   nicht, fang bei Schritt 3 wieder an.

6. **Ältere Firmware hochladen.** Wähl `TOTOLINK_C8343R-1C_X5000R_IP04433_MT7621A_SPI_16M256M_V9.1.0u.6118_B20201102_ALL.web` aus und starte das Update. Die Seite
   zeigt "Update in Progress".

7. **Warten.** Der Router schreibt die Firmware und startet von selbst neu.
   Danach geht das Licht an den LAN-Buchsen aus, bis auf die Buchse mit
   deinem Kabel, und die blaue Status-LED blinkt langsam. Dann ist er
   fertig. Strom bis dahin nicht ziehen.

8. **Zurück zum Anfang.** Stell den Rechner wieder auf "automatisch" und
   mach oben mit Schritt 2 weiter.

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 nimmt die Weboberfläche die Datei an und zeigt den Fortschritt.
- Nach Schritt 4 meldet sich die Freifunk-Firmware.
- Beim Umweg erscheint in Schritt 5 die Notfall-Seite, und nach Schritt 7
  meldet sich wieder die TOTOLINK-Oberfläche unter `http://192.168.0.1`.

## Wenn etwas schiefgeht

- **Die Weboberfläche lehnt die Datei ab.** Siehe "Umweg" oben.
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
- geprüft: forum.openwrt.org t/113153 #1, #3 (2021-11-28); t/124500 #1, #3 (2022-04-05) (Bedingung an die Herstellerfirmware)
- geprüft: geladen und gehasht 15.10.2026 (Bedingung an die Herstellerfirmware)
- Geräteeintrag: 23be410b3d1267c752bf9f6e5c8f5a514dc562c4
