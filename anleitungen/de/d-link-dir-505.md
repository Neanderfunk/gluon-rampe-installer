---
gluon_name: d-link-dir-505
modell: D-Link DIR-505
anzeige: D-Link DIR-505
familie: sonderweg-d-link-dir-505
gluon_broken: false
sprache: de
level: L1
level_text: Zwei Schritte im Browser
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, router-antwortet-nicht]
daten_stand: 188d88d2
vorlage_stand: 33a38da8
---

# D-Link DIR-505: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20D-Link%20DIR-505)

Der D-Link DIR-505 ist ein alter Reise-Router. Für die aktuelle
Freifunk-Firmware gibt es keine Datei, die die D-Link-Oberfläche direkt
annimmt. Der Weg führt deshalb über ein altes OpenWrt als Zwischenstufe.
Das ist umständlich und lohnt sich für ein Gerät, das schon da ist. Zum
Kaufen empfehlen wir den D-Link DIR-505 nicht mehr.

> **Nicht über die Notfall-Seite von D-Link.** Hält man beim Einstecken die
> Reset-Taste, startet die "D-Link Router Recovery Mode"-Seite. Bei uns hat
> sie jedes Mal "Upgrade successfully!" gemeldet, aber nichts geschrieben,
> egal welche Datei. Nimm den Weg über die normale D-Link-Oberfläche unten.

## Was du brauchst

- den Router und einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- als Zwischenstufe das alte OpenWrt (LEDE 17.01.7):
  [lede-17.01.7-ar71xx-generic-dir-505-a1-squashfs-factory.bin](https://archive.openwrt.org/releases/17.01.7/targets/ar71xx/generic/lede-17.01.7-ar71xx-generic-dir-505-a1-squashfs-factory.bin), SHA256
  `13f357a3ebd73c872a85cf8db592e7d2e313723370513cc56a271d99244aa5ed`. Das "a1" im Namen passt für alle
  D-Link DIR-505 der Revision A, auch für A2.
- die Freifunk-Firmware deiner Community für den D-Link DIR-505, und zwar das
  **sysupgrade**-Image. Sein Name endet auf `-d-link-dir-505-sysupgrade.bin`,
  ohne "a1" oder "a2", und passt für beide Revisionen.

## Schritte

1. **Schalter auf Router/AP.** Oben auf dem Router ist ein Schiebeschalter.
   Stell ihn auf **Router/AP**. In der Stellung "Repeater" ist die
   Netzwerkbuchse aus.

2. **Verbinden.** Steck das Kabel vom Rechner in die Netzwerkbuchse des
   Routers und steck den Router in die Steckdose. Der Rechner bleibt auf
   "automatisch" (DHCP).

3. **D-Link-Oberfläche öffnen.** Öffne im Browser `http://192.168.0.1`.
   Erscheint ein Einrichtungsassistent, brich ihn ab ("Cancel"). Melde dich
   mit dem Benutzer `admin` an, das Passwort bleibt ab Werk leer.

4. **Altes OpenWrt aufspielen.** Geh zu **Maintenance → Firmware**, wähl
   über "Browse" die Datei `lede-17.01.7-ar71xx-generic-dir-505-a1-squashfs-factory.bin` und klick "Upload". Der
   Router schreibt sie und startet neu, laut D-Link etwa 150 Sekunden.
   **Strom nicht ziehen.**

5. **OpenWrt öffnen.** Öffne `http://192.168.1.1` (neue Adresse). Melde
   dich mit dem Benutzer `root` an, das Passwort-Feld bleibt leer, und klick
   "Login". Die Warnung "No password set!" kannst du hier übergehen.

6. **Freifunk-Firmware aufspielen.** Geh zu **System → Backup / Flash
   Firmware**. Unten unter "Flash new firmware image" **entfern den Haken
   bei "Keep settings"**, wähl bei "Image" das sysupgrade-Image deiner
   Community und klick **"Flash image..."**. Auf der nächsten Seite steht
   "Note: Configuration files will be erased." Klick **"Proceed"**.

7. **Warten.** Der Router schreibt die Freifunk-Firmware und startet neu,
   einige Minuten. **Strom nicht ziehen.**

8. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
   Im Betrieb ist die eine Netzwerkbuchse des D-Link DIR-505 sein Anschluss
   ans Internet: Steck sie an deinen Router zu Hause.

## Schon eine ältere Freifunk-Firmware drauf?

Läuft auf dem D-Link DIR-505 schon eine alte Freifunk-Firmware, geht es
kürzer, ganz ohne Zwischenstufe. Bei uns ist ein Router so direkt von einer
Freifunk-Firmware aus dem Jahr 2018 auf die aktuelle gewechselt.

1. Bring den Router in den Konfigurationsmodus: Drück im Betrieb die
   Reset-Taste etwa 10 Sekunden lang. Pass dabei auf, dass der
   Schiebeschalter oben nicht verrutscht.
2. Der Rechner bleibt auf "automatisch". Öffne `http://192.168.1.1`.
3. Geh zu **Erweiterte Einstellungen → Firmware aktualisieren**, wähl das
   sysupgrade-Image, **entfern den Haken bei "Konfiguration behalten"**,
   lade die Datei hoch und bestätige mit **"Fortfahren"**.
4. Weiter wie oben ab Schritt 7.

Statt LEDE kannst du in Schritt 4 auch die alte Freifunk-Firmware
"Sackgasse" von Neanderfunk als Zwischenstufe nehmen, passend zur Revision
auf dem Aufkleber: [Rev. A1](https://firmware.ffnef.de/firmware/sackgasse/21_dias/factory/gluon-nef-21_dias_EOL-24112319sackgasse-d-link-dir-505-rev-a1.bin) oder
[Rev. A2](https://firmware.ffnef.de/firmware/sackgasse/21_dias/factory/gluon-nef-21_dias_EOL-24112319sackgasse-d-link-dir-505-rev-a2.bin). Sie startet danach gleich im
Konfigurationsmodus; weiter ab Punkt 2 dieses Abschnitts.

## Woran du erkennst, dass es geklappt hat

- Nach Schritt 4 antwortet unter `http://192.168.1.1` OpenWrt (LEDE).
- Nach Schritt 7 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Über das Kabel kommt gar keine Verbindung.** Prüf den Schiebeschalter
  oben: Er muss auf "Router/AP" stehen. Er verrutscht leicht, etwa beim
  Drücken der Reset-Taste.
- **Die D-Link-Oberfläche fragt nach einem Passwort, und leer geht nicht.**
  Dann hat jemand eins gesetzt. Setz den Router auf Werkseinstellungen
  zurück ([so beschreibt es D-Link](https://eu.dlink.com/uk/en/support/faq/routers/mobile-routers/dir-series/dir-505/how-do-i-reset-my-dir-505-to-factory-default-settings))
  und fang bei Schritt 3 wieder an.
- **OpenWrt meldet "The uploaded image file does not contain a supported
  format".** Prüf, ob es das sysupgrade-Image für den D-Link DIR-505 ist.
- **Nach dem Upload startet wieder die D-Link-Firmware.** Lief der Upload
  über die Notfall-Seite (Reset beim Einstecken), ist das bekannt: Sie
  schreibt nichts. Nimm die normale Oberfläche (Schritt 3).

## Zurück zur D-Link-Firmware

Einen verlässlichen Weg zurück kennen wir nicht. Die Notfall-Seite von D-Link
hat bei uns auch die eigene Firmware von D-Link nicht geschrieben.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Wiki toh:d-link:dir-505; am Gerät nicht geprüft, es lief keine D-Link-Firmware (Weg ab Werk, Schritte (Normalweg))
- abgeleitet: am Gerät nicht geprüft (Schritte (Normalweg))
- geprüft: Commit (Weg ab Werk, Datei, Fehlerbild, Notweg, Quelle (OpenWrt-Commit))
- geprüft: D-Link-FAQ DIR-505 Firmware-Upgrade (Schritte (Normalweg), Anschluss, Adressen, Zugang)
- geprüft: LuCI-Quelltext lede-17.01 (Schritte (Normalweg))
- geprüft: Test Neanderfunk 17.10.2026 (Weg ab Werk, Schritte (Normalweg), Warnung, Fehlerbild, Notweg)
- geprüft: Wiki toh:d-link:dir-505 (Schritte (Normalweg), Typenschild/Verwechslung, Fehlerbild, Notweg, Rückweg zur Herstellerfirmware)
- geprüft: archive.openwrt.org sha256sums (Schritte (Normalweg), Datei)
- Geräteeintrag: c9ac7b17296ff29d9df39db8a68c449ef1514bbd [geprüft: Commit]
