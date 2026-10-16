{#-
Vorlage sonderweg-d-link-dir-505 (D-Link DIR-505, Rev. A1/A2). Auftrag
adorfer 17.10.2026: nur der steinige Weg als Ausweg, kein Kauf- oder
Einsatzgerät. Entwurf Content, 17.10.2026.

Weg: D-Link-Oberfläche (192.168.0.1, admin ohne Passwort, Maintenance →
Firmware; D-Link-FAQ "uk_dir-505_upgrade-the-firmware.pdf") nimmt ein altes
ar71xx-factory-Image (LEDE 17.01.7, Name "dir-505-a1" gilt für alle Rev. A,
auch D-Links eigene Datei heißt so) [abgeleitet: OpenWrt-Wiki
toh:d-link:dir-505 "Installation", Forum t/52322 für A2; am Gerät NICHT
geprüft]. Von dort sysupgrade auf Gluon 2025.1 (ath79, Name ohne rev-a1/a2)
ohne Einstellungen [abgeleitet; LuCI-17.01-Bezeichnungen aus
luci lede-17.01 flashops.htm/upgrade.htm].
[geprüft: Test Neanderfunk 16./17.10.2026, d-link-dir-505-a2-2026-10-17.md,
d01400c] D-Link-Recovery (A2, PCT) meldet "Upgrade successfully!", schreibt
aber nichts (Sackgasse-factory, LEDE 17.01.7, D-Link FW110B02). Aus dem
Konfigurationsmodus von Gluon 2018.2.1 (ar71xx) direkt per Firmware-Update
auf 2025.1, ohne Fehlermeldung, Knoten lief.
Schiebeschalter: Repeater = Netzwerkbuchse aus (OpenWrt-Wiki); verrutscht
leicht beim Reset-Drücken (Test Neanderfunk). Im Betrieb ist die einzige
Buchse Uplink/WAN (Test Neanderfunk).

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    zwischen_url         Download des alten OpenWrt (LEDE 17.01.7 factory)
    zwischen_datei       Dateiname dazu
    zwischen_sha256      SHA256 dazu

  optional
    sackgasse_a1_url     factory-Image der Sackgasse (Gluon 2021.1) für Rev. A1
    sackgasse_a2_url     dasselbe für Rev. A2 (beide gesetzt = Absatz erscheint)
    sicherheit, sicherheit_hinweis   siehe _status.md
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Der {{ modell }} ist ein alter Reise-Router. Für die aktuelle
Freifunk-Firmware gibt es keine Datei, die die D-Link-Oberfläche direkt
annimmt. Der Weg führt deshalb über ein altes OpenWrt als Zwischenstufe.
Das ist umständlich und lohnt sich für ein Gerät, das schon da ist. Zum
Kaufen empfehlen wir den {{ modell }} nicht mehr.

> **Nicht über die Notfall-Seite von D-Link.** Hält man beim Einstecken die
> Reset-Taste, startet die "D-Link Router Recovery Mode"-Seite. Bei uns hat
> sie jedes Mal "Upgrade successfully!" gemeldet, aber nichts geschrieben,
> egal welche Datei. Nimm den Weg über die normale D-Link-Oberfläche unten.

## Was du brauchst

- den Router und einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- als Zwischenstufe das alte OpenWrt (LEDE 17.01.7):
  [{{ w.zwischen_datei }}]({{ w.zwischen_url }}), SHA256
  `{{ w.zwischen_sha256 }}`. Das "a1" im Namen passt für alle
  {{ modell }} der Revision A, auch für A2.
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image. Sein Name endet auf `-d-link-dir-505-sysupgrade.bin`,
  ohne "a1" oder "a2", und passt für beide Revisionen.
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

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
   über "Browse" die Datei `{{ w.zwischen_datei }}` und klick "Upload". Der
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
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).
   Im Betrieb ist die eine Netzwerkbuchse des {{ modell }} sein Anschluss
   ans Internet: Steck sie an deinen Router zu Hause.

## Schon eine ältere Freifunk-Firmware drauf?

Läuft auf dem {{ modell }} schon eine alte Freifunk-Firmware, geht es
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
{%- if w.get("sackgasse_a1_url") and w.get("sackgasse_a2_url") %}

Statt LEDE kannst du in Schritt 4 auch die alte Freifunk-Firmware
"Sackgasse" von Neanderfunk als Zwischenstufe nehmen, passend zur Revision
auf dem Aufkleber: [Rev. A1]({{ w.sackgasse_a1_url }}) oder
[Rev. A2]({{ w.sackgasse_a2_url }}). Sie startet danach gleich im
Konfigurationsmodus; weiter ab Punkt 2 dieses Abschnitts.
{%- endif %}

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
  format".** Prüf, ob es das sysupgrade-Image für den {{ modell }} ist.
- **Nach dem Upload startet wieder die D-Link-Firmware.** Lief der Upload
  über die Notfall-Seite (Reset beim Einstecken), ist das bekannt: Sie
  schreibt nichts. Nimm die normale Oberfläche (Schritt 3).
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

## Zurück zur D-Link-Firmware

Einen verlässlichen Weg zurück kennen wir nicht. Die Notfall-Seite von D-Link
hat bei uns auch die eigene Firmware von D-Link nicht geschrieben.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
