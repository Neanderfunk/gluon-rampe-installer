{#-
Vorlage sonderweg-totolink-x5000r (TOTOLINK X5000R): Die Weboberfläche des
Herstellers nimmt das sysupgrade-Image direkt (OpenWrt-Commit 23be410,
OpenWrt-Wiki toh:totolink:x5000r). Neuere Herstellerfirmware (V9.1.0cu.1929,
V9.1.0cu.2089) lehnt es ab ("Invalid upgrade firmware file"); dann zuerst
über den Notfall-Modus des Bootloaders die ältere V9.1.0u.6118_B20201102
aufspielen (OpenWrt-Forum t/113153, t/124500 #3, t/110595, Wiki "Back to
stock firmware"). Die Downloadseite von TOTOLINK ist inzwischen 404.
Abnahme 16.10.2026 (Test Neanderfunk, totolink-x5000r-2026-10-16.md,
cb40898): Menüweg und Knopf
"Upgrade" bei 6118, Oberfläche nennt "X5000RU", Notfall-Seite dreht endlos,
"PAGE NOT FOUND" nach OpenWrt im selben Browser, /index.html hilft.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    alt_url              Download der älteren Herstellerfirmware V9.1.0u.6118
    alt_datei            Dateiname dieses Downloads
    alt_sha256           SHA256 dieses Downloads (gezeigt nur ohne alt_web;
                         beim ZIP gilt "Auspacken ohne Fehler" als Prüfung,
                         adorfer 15.10.2026)

  optional
    alt_web              Name der .web-Datei im ZIP (wenn der Download ein ZIP ist)
    alt_hinweis          ganzer Satz zur Herkunft der Datei, z. B. "TOTOLINK
                         bietet sie nicht mehr an; der Link führt auf die
                         Originaldatei im Internet Archive."
    sicherheit, sicherheit_hinweis   siehe _status.md
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Beim {{ modell }} nimmt die Weboberfläche von TOTOLINK die Freifunk-Firmware
direkt an. Manche neueren Versionen der TOTOLINK-Firmware lehnen die Datei
allerdings ab. Dann spielst du zuerst über
den Notfall-Modus des Routers eine ältere TOTOLINK-Firmware auf und danach
die Freifunk-Firmware. Rechne mit einer Viertelstunde, mit Umweg mit einer
halben Stunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image
- nur für den Umweg: die ältere TOTOLINK-Firmware
  [{{ w.alt_datei }}]({{ w.alt_url }}).
  {%- if w.get("alt_hinweis") %} {{ w.get("alt_hinweis") }}{% endif %}
  {%- if not w.get("alt_web") %} SHA256 `{{ w.alt_sha256 }}`.{% endif %}
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Rechner anschließen.** Steck das Kabel vom Rechner in eine
   LAN-Buchse des Routers und schalte ihn ein. Der Rechner bleibt auf
   "automatisch" (DHCP).

2. **Weboberfläche öffnen.** Öffne im Browser `http://192.168.0.1` (oder
   `http://itotolink.net`) und melde dich an. Nennt die Oberfläche das Gerät
   **X5000RU**, ist das derselbe Router: Die Freifunk-Firmware für den
   {{ modell }} passt.

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

{% if w.get("alt_web") -%}
1. **ZIP auspacken.** Pack `{{ w.alt_datei }}` aus. Kommt dabei keine
   Fehlermeldung, ist die Datei heil. Gebraucht wird
   `{{ w.get("alt_web") }}` darin.

{% else -%}
1. **Datei prüfen.** Prüf die SHA256 der heruntergeladenen Datei: unter
   Linux `sha256sum {{ w.alt_datei }}`, unter macOS
   `shasum -a 256 {{ w.alt_datei }}`, in der Windows-PowerShell
   `Get-FileHash {{ w.alt_datei }}`. Das Ergebnis muss
   `{{ w.alt_sha256 }}` lauten (Groß- und Kleinschreibung spielt keine
   Rolle).

{% endif -%}
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

6. **Ältere Firmware hochladen.** Wähl
   {%- if w.get("alt_web") %} `{{ w.get("alt_web") }}`{% else %} die
   heruntergeladene Datei{% endif %} aus und klick **"Update firmware"**. Die
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
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

## Zurück zur TOTOLINK-Firmware

Über den Notfall-Modus (Umweg, Schritte 2 bis 7) nimmt der Router jede
TOTOLINK-Firmware an, auch eine neuere.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
