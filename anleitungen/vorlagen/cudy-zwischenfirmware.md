{#-
Vorlage cudy-zwischenfirmware (Cudy: erst Cudys signierte
OpenWrt-Zwischenfirmware über die Cudy-Oberfläche, dann Gluon-sysupgrade über
LuCI). Entwurf Content, 15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.fehler, zusatz.text, herkunft (wie bei
dlink-recovery-web), dazu zusatz.vorher (Abschnitt "## Vorher prüfen" der
Zusatzdatei; fehlt er, entfällt der Abschnitt).

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    cudy_ip              Adresse der Cudy-Oberfläche, z. B. 192.168.10.1
    zwischen_url         Download der Zwischenfirmware: heute der Ordner im
                         Spiegel, später ein Deeplink auf die Datei
    zwischen_url_text    Linktext, z. B. "Ordner WR3000S_1.0 in unserem Spiegel"

  optional (leer = Satz entfällt)
    zwischen_datei       Dateiname der Zwischenfirmware
    zwischen_md5         MD5 der Zwischenfirmware, wie die Cudy-Oberfläche sie zeigt
    zwischen_nur_cudy    true: nicht bei uns, nur in Cudys Ablage (Google Drive)
    neuer_flash          true: Modell mit neuem Flash-Chip ab Seriennummer 2543
    strom                wenn nicht das Netzteil, z. B. "über PoE nach 802.3af
                         (37-57 V), also mit einem PoE-Injektor oder PoE-Switch"
    anschluss            Buchse für Schritt 2, nach "steck den Rechner per Kabel an …",
                         leer = "eine LAN-Buchse" (bzw. "seine einzige Netzwerkbuchse")
    eine_buchse          true: Gerät hat nur eine Netzwerkbuchse (Access Point);
                         dann kein "andere Buchse"-Tipp, und Schritt 10 sagt, dass
                         sie im Betrieb der Anschluss ans Internet ist
    rechner_ip           feste Adresse für den Rechner in Teil 1 und am Ende des
                         Rückwegs, wenn das Gerät ab Werk keine Adressen vergibt
                         (Access Point), z. B. 192.168.10.100; leer = automatisch
    cudy_warten          Wartezeit, bis das Gerät ohne DHCP auf cudy_ip zurückfällt,
                         z. B. "etwa eine Minute" (nur mit rechner_ip)
    luci_rechner_ip      feste Adresse für Teil 2 (OpenWrt unter 192.168.1.1), wenn
                         unklar ist, ob die Zwischenfirmware Adressen vergibt,
                         z. B. 192.168.1.100; leer = automatisch
    led_zwischen         ganzer Satz zu den LEDs beim Schreiben der Zwischenfirmware
                         (Schritt 6), leer = Lauflicht, dann Blinken/Flackern
    luci_buchse          Buchse für Schritt 7, z. B. "den Port „1Gbps LAN“"
    force_upgrade        true: LuCI braucht laut OpenWrt "Force upgrade"
    rueckweg_buchse      Buchse für die Recovery, leer = "eine LAN-Buchse"
    rueckweg_halten      z. B. "mindestens 8 Sekunden"
    rueckweg_led         woran man beim Halten der Taste das Loslassen erkennt, nach
                         "bis …", z. B. "die LED abwechselnd orange und rot blinkt";
                         leer = "alle LEDs einmal kurz aufleuchten" (WR3000-Bild)
    rueckweg_fertig      woran man das Ende erkennt, nach "Der Router ist fertig,
                         wenn …"; leer = System-LED ruhig (bei eine_buchse: Satz entfällt)
    rueckweg_ab_version  Cudy-Firmware, ab der der Bootloader TFTP kann, z. B. "2.4.7"
                         (AP3000: ältere U-Boots finden den 2.5G-PHY nicht)
    rueckweg_quelle      woher die Cudy-Firmware kommt, leer = Cudys Download-Seite
    rueckweg_url         Direktlink auf die Download-Seite des Modells bei Cudy, z. B.
                         https://www.cudy.com/pages/download-center/wr3000h-1-0

  Validierung: WR3000H v1 mit Cudy-Firmware 2.5.30 am Testplatz (adorfer 16.10.2026,
  Test Neanderfunk, cudy-wr3000h-v1-2026-10-16.md, 7253238)
  und WR3000 v1 mit 2.4.19 (cudy-wr3000-v1-2026-10-16.md, f4b4c2f; Fehlermeldungen mit
  falschen Images: cudy-wr3000-v1-geraet2-2026-10-16.md, 432ad4b; red-herrings Fall 11). Menüpfade und
  LED-Zeichen sind dort belegt, für andere Modelle/Versionen vermutet. WPS statt Reset
  beim Rückweg: nur am WR3000 beobachtet [abgeleitet].
  AP3000 v1 (Test Neanderfunk 17.10.2026, cudy-ap3000-v1-2026-10-17.md): eine Buchse,
  192.168.10.254, mehrfarbige LED; TFTP erst ab Cudy-Firmware 2.4.7 (OpenWrt-Wiki
  toh:cudy:ap3000_v1), mit 2.4.4 kein RRQ. Ab Werk kein DHCP-Server, nach etwa
  einer Minute ohne DHCP Ersatzadresse 192.168.10.254 [geprüft: Mitschnitt
  17.10.2026]; ob die Zwischenfirmware DHCP vergibt, offen (Testplatz hatte
  192.168.1.88 fest) [abgeleitet: luci_rechner_ip vorsichtshalber].
  Warnkasten "Nicht ins Heimnetz" bei eine_buchse: adorfer über Supernode
  17.10.2026 [abgeleitet: Gluon-Einrichtungsseite vergibt Adressen; am
  AP3000 mit 2025.1 nicht gemessen].
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Router von Cudy nehmen ab Werk nur Firmware an, die Cudy selbst
unterschrieben hat. Deshalb geht es in zwei Schritten: Zuerst kommt eine
**Zwischenfirmware von Cudy** auf den Router, ein OpenWrt, das Cudy
unterschrieben hat. Darüber spielst du dann die **Freifunk-Firmware** deiner
Community ein. Beides geht im Browser, du brauchst kein Zusatzprogramm.

{%- if w.neuer_flash %}

> **Achtung, neuer Speicherchip.** Cudy baut in dieses Modell seit Ende 2025
> einen anderen Flash-Chip ein (Seriennummer ab 2543, also ab Woche 43/2025).
> Solche Geräte starten mit einer älteren Zwischenfirmware nicht mehr. Nimm
> nur die Zwischenfirmware vom 19.11.2025 oder neuer, wie sie unten verlinkt
> ist, nie eine ältere Datei aus Foren oder alten Downloads.
{%- endif %}
{%- if w.get("eine_buchse") %}

> **Nicht ins Heimnetz.** Häng den {{ modell }} zum Einrichten direkt an
> deinen Rechner, nicht an deinen Router zu Hause. Startet nach dem
> Einspielen die Einrichtungsseite der Freifunk-Firmware, verteilt er selbst
> Adressen und stört damit deinen Router. Erst wenn die Freifunk-Firmware
> eingerichtet ist, kommt er an deinen Router.
{%- endif %}

## Was du brauchst

- den Router und
  {%- if w.strom %} Strom {{ w.strom }}
  {%- else %} sein Netzteil{% endif %}
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die **Zwischenfirmware von Cudy** für genau dieses Modell:
  [{{ w.zwischen_url_text }}]({{ w.zwischen_url }})
  {%- if w.zwischen_datei %}, Datei `{{ w.zwischen_datei }}`{% endif %}
  {%- if w.zwischen_nur_cudy %}. Sie liegt nicht bei uns, sondern nur in
  Cudys eigener Ablage (ein Google-Drive-Ordner mit einem Eintrag je Modell,
  meist als ZIP-Datei mit der `.bin`-Datei darin){% endif %}
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image, nicht "factory". Das ist bei Cudy richtig, auch wenn
  es die erste Installation ist.

Modell und Version stehen auf dem Aufkleber unter dem Gerät. Vergleich sie
genau mit "{{ modell }}", bevor du anfängst.
{%- set vorher = zusatz.vorher if zusatz.vorher is defined else "" %}
{%- if vorher or w.get("rueckweg_ab_version") %}

## Vorher prüfen
{%- if w.get("rueckweg_ab_version") %}

**Weg zurück offenhalten:** Den Notfall-Weg zurück zur Cudy-Firmware (unten)
hat der {{ modell }} laut OpenWrt erst ab Cudy-Firmware
**{{ w.rueckweg_ab_version }}**; ältere Bootloader holen sich keine Datei.
Welche Version läuft, zeigt die Cudy-Oberfläche. Ist sie älter, spiel
zuerst die neueste Cudy-Firmware ein (Download wie unten unter "Zurück zur
Cudy-Firmware"), an derselben Stelle wie in Schritt 4 die Zwischenfirmware.
Warte den Neustart ab und mach dann mit Schritt 4 weiter. Ob der Notfall-Weg
danach auch unter der Freifunk-Firmware erhalten bleibt, haben wir noch
nicht geprüft.
{%- endif %}
{%- if vorher %}

{{ vorher }}
{%- endif %}
{%- endif %}

## Schritte

### Teil 1: Zwischenfirmware von Cudy

1. **Dateien bereitlegen.** Lade die Zwischenfirmware und das
   sysupgrade-Image herunter und leg sie in einen Ordner, den du
   wiederfindest.

2. **Verbinden.** Versorg den Router mit Strom und steck den Rechner per
   Kabel an
   {%- if w.get("anschluss") %} {{ w.anschluss }}
   {%- elif w.get("eine_buchse") %} seine einzige Netzwerkbuchse
   {%- else %} eine **LAN**-Buchse{% endif %}.
   {%- if w.get("rechner_ip") %} Der {{ modell }} vergibt selbst keine
   Adressen. Stell deinen Rechner deshalb fest auf `{{ w.rechner_ip }}`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
   {%- if w.get("cudy_warten") %} Nach dem Einschalten braucht er
   {{ w.cudy_warten }}, bis er unter seiner Adresse antwortet.{% endif %}
   {%- else %} Der Rechner holt sich seine
   Adresse automatisch, so wie er normalerweise eingestellt ist.{% endif %}

3. **Cudy-Oberfläche öffnen.** Öffne im Browser `http://{{ w.cudy_ip }}`.
   Ab Werk verlangt die Oberfläche zuerst ein **eigenes Admin-Passwort**
   (mindestens 8 Zeichen). Denk dir eins aus und merk es dir. Ältere
   Cudy-Firmware fragt stattdessen nach dem Passwort `admin`. Danach startet
   der Assistent "Schnelleinrichtung": Den kannst du mit **"« Beenden"**
   überspringen (bei manchen Versionen heißt der Knopf "« Ausfahrt").

4. **Zwischenfirmware hochladen.** Geh zum Reiter **"Allgemeine
   Einstellungen"**, klick in der Symbolspalte links ganz unten auf
   **"Firmware"** und im Abschnitt **"Lokales Update"** auf
   **"Durchsuchen …"**. Wähl dort die Zwischenfirmware aus. Gibt es den
   Reiter nicht, such oben **Erweiterte Einstellungen** und links den
   Eintrag **Firmware** (bei älterer Cudy-Firmware unter **System**).
   {%- if b.get("cudy-firmware-seite") %}

   ![Die Firmware-Seite der Cudy-Oberfläche]({{ b["cudy-firmware-seite"] }})
   {%- endif %}

5. **Prüfsumme vergleichen.** Nach dem Hochladen zeigt der Router im
   Fenster "Lokales Update" eine MD5-Prüfsumme und die Größe.
   {%- if w.zwischen_md5 %} Sie muss genau so aussehen:

   ```
   {{ w.zwischen_md5 }}
   ```

   Stimmt sie, klick auf **Fortfahren**.
   {%- else %} Vergleich sie mit der Prüfsumme, die an der Download-Stelle
   steht. Stimmt sie, klick auf **Fortfahren**.
   {%- endif %}

6. **Warten.** Die Oberfläche zeigt "System - Firmware wird installiert…".
   {%- if w.get("led_zwischen") %}
   {{ w.led_zwischen }}
   {%- else %}
   Die LEDs zeigen erst ein Lauflicht (bis etwa eine halbe Minute), dann
   blinken oder flackern sie kurz, dann startet der Router einmal neu.
   {%- endif %} Bei
   uns dauerte das weniger als eine Minute. **Strom nicht ziehen.**

### Teil 2: Freifunk-Firmware

7. **OpenWrt-Oberfläche öffnen.**
   {%- if w.luci_buchse %} Steck das Kabel jetzt an {{ w.luci_buchse }}.{% endif %}
   {%- if w.get("luci_rechner_ip") %} Stell den Rechner jetzt fest auf
   `{{ w.luci_rechner_ip }}`, Netzmaske `255.255.255.0`.
   {%- elif w.get("rechner_ip") %} Stell den Rechner jetzt wieder auf
   "automatisch".{% endif %}
   Öffne `http://192.168.1.1`. Es erscheint die Anmeldung von OpenWrt
   ("LuCI"). Das Passwort-Feld bleibt leer, einfach anmelden.

8. **Freifunk-Firmware hochladen.** Geh zu **System → Backup / Firmware
   Update** (englisch "Backup / Flash Firmware"). Klick ganz unten auf
   **"Firmware aktualisieren…"** (englisch "Flash image…"). Es erscheint das
   Fenster "Datei wird hochgeladen…": Wähl dort das sysupgrade-Image deiner
   Community aus und klick auf **"Hochladen"**.

9. **Einstellungen nicht behalten.** Danach zeigt OpenWrt das Fenster
   "Image schreiben?" (englisch "Flash image?"). Dort ist der Haken bei **"Einstellungen beibehalten und die
   aktuelle Konfiguration sichern"** (englisch "Keep settings …") schon
   gesetzt. **Entfern diesen Haken.** Die beiden Haken darunter sind schon
   aus. Es darf kein Haken mehr gesetzt sein.
   {%- if w.force_upgrade %}
   Meldet OpenWrt, dass das Image nicht zum Gerät passt, obwohl du sicher die
   Datei für den {{ modell }} hast, setz zusätzlich den Haken bei
   "Erzwinge Upgrade" (englisch "Force upgrade"). Bei diesem Modell ist das
   laut OpenWrt nötig, weil die Zwischenfirmware das Gerät anders benennt.
   {%- endif %}
   Dann **Fortfahren**.

10. **Fertig.** Der Router schreibt die Freifunk-Firmware und startet neu,
    wieder einige Minuten, Strom nicht ziehen.
    {%- if w.get("luci_rechner_ip") %} Stell den Rechner wieder auf
    "automatisch".{% endif %} Danach startet die
    Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
    Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
    Kommt dort "Not Found", siehe [Der Browser zeigt
    "Not Found"](grundlagen/browser-not-found.md). Wie
    es weitergeht, beschreibt deine Community.
    {%- if w.get("eine_buchse") %} Im Betrieb ist die einzige
    Netzwerkbuchse des {{ modell }} sein Anschluss ans Internet: Verbinde
    sie erst nach der Einrichtung mit deinem Router zu Hause.{% endif %}

## Woran du erkennst, dass es geklappt hat

- Nach Schritt 5 stimmt die Prüfsumme genau.
- Nach Schritt 6 zeigt `http://192.168.1.1` die Anmeldung von OpenWrt.
- Nach Schritt 10 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Prüfsumme stimmt nicht.** Nicht fortfahren. Lad die Datei neu herunter
  und prüf, ob es die für dein Modell und deine Version ist.
- **Die Cudy-Oberfläche meldet "Datei ist nicht verfügbar. Bitte versuchen
  Sie es erneut."** Die Meldung führt in die Irre: Gemeint ist, dass die
  Datei nicht von Cudy unterschrieben ist. Es ist also die falsche Datei,
  etwa schon die Freifunk-Firmware oder die Zwischenfirmware eines anderen
  Modells. Nicht noch einmal versuchen, sondern die Zwischenfirmware für
  genau dieses Modell nehmen (Aufkleber vergleichen).
- **OpenWrt meldet "not supported by this image" oder "Überprüfung der
  Abbilddatei fehlgeschlagen"** (in Schritt 9, mit einem Haken "Erzwinge
  Upgrade").
  {%- if w.force_upgrade %} Bei diesem Modell ist das in Ordnung, wenn unter
  "Supported devices" dein Modell steht (siehe Schritt 9). Steht dort ein
  anderes Modell, ist es das falsche Image: **"Abbrechen"** und das richtige
  holen.
  {%- else %} Dann ist es das Image für ein anderes Modell. **"Erzwinge
  Upgrade" nie anhaken**, sondern **"Abbrechen"** und das richtige Image
  holen.{% endif %}
{%- if not w.get("eine_buchse") %}
- **Nach Schritt 6 antwortet `http://192.168.1.1` nicht.** Steck das Kabel in
  eine andere Buchse. Bei manchen Modellen tauschen LAN und WAN nach dem
  Wechsel auf OpenWrt die Rolle.
{%- endif %}
- **Unter `http://{{ w.cudy_ip }}` kommt keine Cudy-Seite, sondern schon
  OpenWrt.** Dann ist die Zwischenfirmware vermutlich schon drauf: weiter bei
  Schritt 7. Läuft dort eine ganz andere Firmware, geht die Zwischenfirmware
  nicht mehr. Cudy nimmt sie nur an, solange die Original-Oberfläche läuft.
  Dann zuerst zurück zur Cudy-Firmware (unten).
{{ zusatz.fehler }}

## Zurück zur Cudy-Firmware

Wenn der Router nicht mehr richtig startet oder du wieder die
Original-Firmware willst, hat Cudy einen Notfall-Weg. Er braucht etwas
Werkzeug: einen TFTP-Server auf deinem Rechner
([TFTP-Server einrichten](grundlagen/tftp-server.md)) und eine feste
Adresse am Rechner ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
{%- if w.get("rueckweg_ab_version") %}
Beim {{ modell }} geht das nur, wenn vorher mindestens Cudy-Firmware
{{ w.rueckweg_ab_version }} lief (siehe "Vorher prüfen"). Mit einem älteren
Bootloader holt er sich keine Datei, dann gibt es keinen einfachen Weg
zurück.
{%- endif %}

1. {% if w.get("rueckweg_url") %}Lade die Cudy-Firmware für dein Modell von der
   [Download-Seite von Cudy]({{ w.get("rueckweg_url") }}) herunter, und zwar
   die oberste, also neueste Version.
   {%- elif w.rueckweg_quelle %}Die Cudy-Firmware für dein Modell bekommst du
   {{ w.rueckweg_quelle }}.
   {%- else %}Lade die Cudy-Firmware für dein Modell von der Download-Seite von
   Cudy herunter, die neueste Version.{% endif %}
   Kommt sie als ZIP-Archiv, pack es aus: Darin liegt die `.bin`-Datei,
   manchmal zusätzlich eine `md5.txt`. Die `.bin`-Datei heißt bei Cudy oft
   "…-sysupgrade.bin". Das ist trotzdem die Cudy-Firmware, nicht die
   Freifunk-Firmware. Benenn sie in `recovery.bin` um (genau so) und leg sie
   in den Ordner des TFTP-Servers.
2. Stell deinen Rechner fest auf `192.168.1.88`, Netzmaske `255.255.255.0`,
   und starte den TFTP-Server.
3. Steck das Kabel an
   {%- if w.rueckweg_buchse %} {{ w.rueckweg_buchse }}
   {%- elif w.get("eine_buchse") %} seine einzige Netzwerkbuchse
   {%- else %} eine
   LAN-Buchse{% endif %}. Der Router hat noch keinen Strom.
4. Drück die Reset-Taste (versenkt, mit einer Büroklammer) und halte sie
   gedrückt, steck den Strom ein und halte
   weiter{% if w.rueckweg_halten %} (laut Cudy {{ w.rueckweg_halten }}){% endif %},
   {%- if w.get("rueckweg_led") %} bis {{ w.rueckweg_led }}. Dann loslassen.
   {%- else %}
   bis **alle LEDs einmal kurz aufleuchten**, etwa eine halbe Sekunde lang.
   Dann loslassen. Hältst du weiter, fängt der Router etwa alle 20 Sekunden
   von vorn an.{% endif %} Im TFTP-Server siehst du, dass `recovery.bin` abgeholt wird.
   {%- if not w.get("eine_buchse") %}
   Klappt es mit der Reset-Taste nicht, versuch es genauso mit der
   WPS-Taste. Bei einem unserer Geräte ging es zuerst nur damit.
   {%- endif %}
5. Warten: Das Schreiben dauert ein paar Minuten. Die LEDs können dabei
   flackern, und die Netzwerkverbindung geht zwischendurch weg und wieder an.
   **Strom nicht ziehen.**
   {%- if w.get("rueckweg_fertig") %} Der Router ist fertig, wenn
   {{ w.rueckweg_fertig }}.
   {%- elif not w.get("eine_buchse") %} Der Router ist fertig, wenn die **System-LED ruhig
   leuchtet** (steckt ein Kabel in der WAN-Buchse, leuchtet zusätzlich
   "Internet").{% endif %}
   {%- if w.get("rechner_ip") %} Danach den Rechner fest auf
   `{{ w.rechner_ip }}` stellen wie in Schritt 2; die Cudy-Oberfläche ist
   unter `http://{{ w.cudy_ip }}` erreichbar
   {%- if w.get("cudy_warten") %}, nach dem Neustart braucht er dafür wieder
   {{ w.cudy_warten }}{% endif %}.
   {%- else %} Danach den
   Rechner wieder auf "automatisch" stellen; die Cudy-Oberfläche ist unter
   `http://{{ w.cudy_ip }}` erreichbar.{% endif %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
