{#-
Vorlage glinet (GL.iNet): entweder über die GL.iNet-Oberfläche
(GL-OpenWrt, meist 192.168.8.1) oder über die U-Boot-Weboberfläche
(Reset beim Einschalten, 192.168.1.1). Entwurf Content, 15.10.2026.
Weg "gl-luci" (16.10.2026, Test Neanderfunk GL-B1300 mit GL-Firmware 4.3.25,
glinet-gl-b1300-2026-10-16.md, 9aea90d): Die GL-Seite "Lokale Aktualisierung"
lehnt Gluon ab ("Der Test der Firmware mit sysupgrade ist fehlgeschlagen",
compat 1.0 -> 1.1, swconfig -> DSA); LuCI unter /cgi-bin/luci nimmt es mit
"Force upgrade" ohne "Keep settings". Notfall-Seite: Ladekreis endlos.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    weg                  "gl-ui" (GL.iNet-Oberfläche, U-Boot als Notfall),
                         "gl-luci" (GL.iNet-Oberfläche → LuCI mit "Force upgrade",
                         U-Boot als Notfall) oder "uboot" (U-Boot-Weboberfläche
                         als Hauptweg)

  U-Boot (bei weg = uboot nötig; bei gl-ui optional für den Notfall-Abschnitt)
    taste                ganzer Satz, wie man in den U-Boot-Modus kommt, z. B.
                         "Drück die Reset-Taste fest, steck den Strom ein und halte
                         die Taste, bis die rote LED 5-mal geblinkt hat. Dann loslassen."
    led_uboot            optional: woran man den U-Boot-Modus erkennt, ganzer Satz
    uboot_datei          optional: "sysupgrade" (Vorgabe) oder "factory"
    dateiname            optional: Name, in den das Image umbenannt werden muss
    uboot_abschnitt      optional: wo auf der Seite hochgeladen wird, z. B.
                         "im Abschnitt „NOR flash“ mit „update nor firmware“"
    anschluss            optional: welche Buchse, nach "Steck das Kabel an …"
    led_schreiben        optional: was die LEDs beim Schreiben/fertig zeigen, ganzer Satz
    dauer_uboot          optional: wie lange das Schreiben über die Notfall-Seite
                         dauert, z. B. "etwa 9 Minuten" (leer = "etwa 3 Minuten")
    kabel_ziehen         optional true: nach dem Hochladen Kabel ziehen, bevor das
                         Gerät neu startet

  Zwischenschritt OpenWrt (nur wenn Gluon kein passendes Image für den U-Boot baut)
    zwischen_datei       Dateiname des OpenWrt-factory-Image
    zwischen_url         Download-Adresse

  GL.iNet-Oberfläche (bei weg = gl-ui oder gl-luci)
    gl_url               optional: z. B. http://192.168.8.1 (leer = Hinweis auf den Aufkleber)
    gl_menue             optional: z. B. "Upgrade → Local Upgrade" (leer = "meist Upgrade")
    per_wlan             optional true: nur per WLAN erreichbar (Ethernet ist WAN)
    usb                  optional true: das Gerät steckt im USB-Port des Rechners

  RAMpe als zweiter Weg (siehe _rampe.md, alles optional)
    rampe_url            Direktlink auf die RAMpe-Datei für dieses Gerät
    rampe_datei          Dateiname dazu
    rampe_weg            ganzer Satz, wie die RAMpe statt OpenWrt aufs Gerät kommt
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set ud = w.uboot_datei if w.uboot_datei else "sysupgrade" -%}
{%- set gl = w.weg in ("gl-ui", "gl-luci") -%}
{%- set du = w.get("dauer_uboot") or "etwa 3 Minuten" -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

{% if w.weg == "gl-ui" -%}
GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Die Freifunk-Firmware lädst du deshalb ganz einfach über die Oberfläche von
GL.iNet hoch, wie ein normales Update. Du brauchst nur einen Browser.
{%- elif w.weg == "gl-luci" -%}
GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Deren Update-Seite nimmt die Freifunk-Firmware beim {{ modell }} zwar nicht
an, die mitgelieferte OpenWrt-Oberfläche **LuCI** aber schon. Du brauchst
nur einen Browser.
{%- else -%}
GL.iNet-Router haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, startet statt der Firmware eine schlichte
Webseite zum Hochladen. Über die kommt die Freifunk-Firmware auf den Router.
Du brauchst nur einen Browser und eine feste Adresse am Rechner.
{%- endif %}

## Was du brauchst

- den Router mit Netzteil{% if w.usb %} (beim {{ modell }} entfällt das: er steckt im USB-Port des Rechners){% endif %}
{%- if not w.per_wlan and not w.usb %}
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
{%- elif w.per_wlan %}
- einen Rechner oder Laptop mit WLAN
{%- endif %}
{%- if w.zwischen_datei %}
- OpenWrt für den {{ modell }}:
  [{{ w.zwischen_datei }}]({{ w.zwischen_url }}). Die Freifunk-Firmware
  gibt es nicht in der Form, die der Notfall-Modus annimmt; deshalb kommt
  erst OpenWrt drauf und darüber die Freifunk-Firmware.
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image
{%- elif w.weg == "uboot" %}
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **{{ ud }}**-Image
{%- else %}
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image. Das ist bei GL.iNet richtig, auch wenn es die erste
  Installation ist.
{%- endif %}
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte
{%- if gl %}

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Verbinden.**
   {%- if w.per_wlan %} Verbinde dich per **WLAN** mit dem Router. Sein
   Netzwerkanschluss ist ab Werk für den Internetzugang gedacht (WAN), darüber
   kommst du nicht an die Oberfläche. Name und Passwort des WLANs stehen auf
   dem Aufkleber.
   {%- elif w.usb %} Steck den {{ modell }} in einen USB-Anschluss des
   Rechners. Er meldet sich dort als Netzwerkkarte.
   {%- else %} Steck das Kabel vom Rechner in eine LAN-Buchse des Routers und
   schalte ihn ein. Der Rechner holt sich seine Adresse automatisch.
   {%- endif %}

3. **Oberfläche öffnen.** Öffne im Browser
   {%- if w.gl_url %} `{{ w.gl_url }}`.{% else %} die Oberfläche von GL.iNet;
   die Adresse steht auf dem Aufkleber, meist ist es `http://192.168.8.1`.{% endif %} Beim ersten Mal
   fragt GL.iNet nach Sprache
   {%- if w.weg == "gl-luci" %} (wähl **Deutsch**, dann passen die Namen in
   Schritt 4){% endif %} und einem Passwort für die Verwaltung: Leg eins
   fest, du brauchst es nur für diese Installation.
{%- if w.weg == "gl-luci" %}

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
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
{%- else %}

4. **Firmware hochladen.** Geh zu
   {%- if w.gl_menue %} **{{ w.gl_menue }}**{% else %} dem Bereich für
   Firmware-Updates (meist "Upgrade"){% endif %} und wähl das
   sysupgrade-Image aus. **Einstellungen nicht behalten:** Entfern den Haken
   bei "Keep Settings" (oder wähl "Do not keep configuration"). Dann das
   Update starten.

5. **Warten.** Der Router schreibt die Firmware und startet neu, einige
   Minuten. **Strom nicht ziehen.**

6. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
   {%- if w.per_wlan %} Für die Einrichtung brauchst du jetzt ein
   Netzwerkkabel, das WLAN des Herstellers gibt es nicht mehr.{% endif %}
{%- endif %}
{%- else %}

1. **Datei bereitlegen.** Lade
   {%- if w.zwischen_datei %} OpenWrt und das Freifunk-sysupgrade-Image
   {%- else %} das {{ ud }}-Image{% endif %} herunter.
   {%- if w.dateiname %} Benenne {% if w.zwischen_datei %}OpenWrt{% else %}es{% endif %} in `{{ w.dateiname }}` um, genau so.{% endif %}

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.2`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Schalte ein VPN
   am Rechner aus (auch Tailscale oder ZeroTier), das stört sonst.

3. **Kabel stecken.** Steck das Kabel vom Rechner an
   {%- if w.anschluss %} {{ w.anschluss }}{% else %} eine LAN-Buchse{% endif %}.
   Alle anderen Buchsen bleiben frei. Der Router hat noch keinen Strom.

4. **Notfall-Modus starten.** {{ w.taste }}
   {%- if w.led_uboot %} {{ w.led_uboot }}{% endif %}

5. **Hochladen.** Öffne im Browser `http://192.168.1.1`. Es erscheint die
   schlichte Notfall-Seite. Wähl
   {%- if w.zwischen_datei %} die OpenWrt-Datei
   {%- else %} das {{ ud }}-Image{% endif %}
   {%- if w.uboot_abschnitt %} {{ w.uboot_abschnitt }}{% endif %} aus und
   starte das Hochladen ("Update firmware"). Die Seite zeigt dann
   "UPDATE IN PROGRESS" mit einem Ladekreis, der sich endlos weiterdreht,
   auch wenn der Router längst fertig ist. Das ist normal.
   {%- if w.kabel_ziehen %} Ist die Datei übertragen, zieh das Netzwerkkabel,
   bevor der Router neu startet.{% endif %}

6. **Warten.** Der Router schreibt die Firmware, das dauert
   {{ du }}.{% if w.led_schreiben %} {{ w.led_schreiben }}{% endif %}
   **Strom nicht ziehen.**
{%- if w.zwischen_datei %}

7. **Freifunk-Firmware über OpenWrt.** Nach dem Neustart läuft OpenWrt.
   Öffne `http://192.168.1.1`, melde dich an (Passwort-Feld leer), geh zu
   **System → Backup / Flash Firmware**, "Flash image…", wähl das
   Freifunk-sysupgrade-Image, **entfern den Haken bei "Keep settings"** und
   klick **Continue**. Wieder einige Minuten warten.

8. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
{%- else %}

7. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
{%- endif %}
{%- endif %}

## Woran du erkennst, dass es geklappt hat

{% if w.weg == "uboot" -%}
- In Schritt 4 zeigen die LEDs, dass der Notfall-Modus erreicht ist, und
  unter `http://192.168.1.1` kommt die Notfall-Seite.
{% elif w.weg == "gl-luci" -%}
- In Schritt 6 steht in der roten Meldung "The device is supported".
{% endif -%}
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

{% if w.weg == "uboot" -%}
- **Unter `http://192.168.1.1` kommt nichts.** Prüf die feste Adresse
  (Schritt 2), schalte VPN-Programme aus, zieh das Kabel am Rechner einmal
  kurz ab ([Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md))
  und versuch Schritt 4 noch einmal, diesmal genau auf die LEDs achtend. Kommt "Not Found" oder "PAGE NOT
  FOUND", siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
{% elif w.weg == "gl-luci" -%}
- **Die GL.iNet-Seite "Lokale Aktualisierung" meldet "Der Test der Firmware
  mit sysupgrade ist fehlgeschlagen".** Diese Seite nimmt die
  Freifunk-Firmware beim {{ modell }} nie an. Nimm den Weg über LuCI
  (Schritt 4).
- **LuCI meldet "not supported by this image".** Das Image ist für ein
  anderes Gerät. "Cancel" und das richtige Image holen (Schritt 6).
- Klappt es gar nicht, hilft der Notfall-Modus (unten).
{% else -%}
- **Die Oberfläche lehnt die Datei ab.** Prüf, ob es das sysupgrade-Image für
  genau dieses Modell ist. Sonst hilft der Notfall-Modus (unten).
{% endif -%}
{{ zusatz.fehler }}
{%- if gl and w.taste %}

## Notfall: U-Boot-Weboberfläche

Klappt es über die GL.iNet-Oberfläche nicht, oder startet der Router nicht
mehr, hilft der eingebaute Notfall-Modus:

1. Rechner fest auf `192.168.1.2`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)), VPN am Rechner
   aus. Kabel an
   {%- if w.anschluss %} {{ w.anschluss }}{% else %} eine LAN-Buchse{% endif %},
   alle anderen Buchsen frei.
2. {{ w.taste }}{% if w.led_uboot %} {{ w.led_uboot }}{% endif %}
3. Im Browser `http://192.168.1.1` öffnen, das sysupgrade-Image auswählen,
   "Update firmware". Der Ladekreis auf der Seite dreht sich danach endlos
   weiter, das ist normal.
4. {{ du[0]|upper }}{{ du[1:] }} warten, Strom nicht ziehen.
{%- endif %}

{% include "_rampe.md" %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
