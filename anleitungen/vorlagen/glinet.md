{#-
Vorlage glinet (GL.iNet): entweder über die GL.iNet-Oberfläche
(GL-OpenWrt, meist 192.168.8.1) oder über die U-Boot-Weboberfläche
(Reset beim Einschalten, 192.168.1.1). Entwurf Content, 15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    weg                  "gl-ui" (GL.iNet-Oberfläche, U-Boot als Notfall)
                         oder "uboot" (U-Boot-Weboberfläche als Hauptweg)

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
    kabel_ziehen         optional true: nach dem Hochladen Kabel ziehen, bevor das
                         Gerät neu startet

  Zwischenschritt OpenWrt (nur wenn Gluon kein passendes Image für den U-Boot baut)
    zwischen_datei       Dateiname des OpenWrt-factory-Image
    zwischen_url         Download-Adresse

  GL.iNet-Oberfläche (bei weg = gl-ui)
    gl_url               optional: z. B. http://192.168.8.1 (leer = Hinweis auf den Aufkleber)
    gl_menue             optional: z. B. "Upgrade → Local Upgrade" (leer = "meist Upgrade")
    per_wlan             optional true: nur per WLAN erreichbar (Ethernet ist WAN)
    usb                  optional true: das Gerät steckt im USB-Port des Rechners
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set ud = w.uboot_datei if w.uboot_datei else "sysupgrade" -%}
{%- if status == "ungeprüft" %}
> **Noch nicht am Gerät erprobt.** Diese Anleitung ist aus Quellen
> zusammengestellt, aber noch niemand hat sie an einem {{ modell }} Schritt
> für Schritt nachvollzogen. Wenn du es tust: Schreib uns an
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de), ob es geklappt hat.
{%- else %}
> **Am Gerät erprobt** am {{ erprobt_am }} mit `{{ erprobt_mit }}`.
{%- endif %}

# {{ modell }}: Freifunk-Firmware installieren

{% if w.weg == "gl-ui" -%}
GL.iNet liefert seine Router mit einer eigenen Variante von OpenWrt aus.
Die Freifunk-Firmware lädst du deshalb ganz einfach über die Oberfläche von
GL.iNet hoch, wie ein normales Update. Du brauchst nur einen Browser.
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
{%- if w.weg == "gl-ui" %}

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
   fragt GL.iNet nach Sprache und einem Passwort für die Verwaltung: Leg eins
   fest, du brauchst es nur für diese Installation.

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
   {%- if w.per_wlan %} Für die Einrichtung brauchst du jetzt ein
   Netzwerkkabel, das WLAN des Herstellers gibt es nicht mehr.{% endif %}
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
   starte das Hochladen ("Update firmware").
   {%- if w.kabel_ziehen %} Ist die Datei übertragen, zieh das Netzwerkkabel,
   bevor der Router neu startet.{% endif %}

6. **Warten.** Der Router schreibt die Firmware, das dauert etwa
   3 Minuten.{% if w.led_schreiben %} {{ w.led_schreiben }}{% endif %}
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
{%- else %}

7. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
{%- endif %}
{%- endif %}

## Woran du erkennst, dass es geklappt hat

{% if w.weg == "uboot" -%}
- In Schritt 4 zeigen die LEDs, dass der Notfall-Modus erreicht ist, und
  unter `http://192.168.1.1` kommt die Notfall-Seite.
{% endif -%}
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

{% if w.weg == "uboot" -%}
- **Unter `http://192.168.1.1` kommt nichts.** Prüf die feste Adresse
  (Schritt 2), schalte VPN-Programme aus und versuch Schritt 4 noch einmal,
  diesmal genau auf die LEDs achtend. Hilft ein anderer Browser oder ein
  privates Fenster, lag es am Zwischenspeicher des Browsers.
{% else -%}
- **Die Oberfläche lehnt die Datei ab.** Prüf, ob es das sysupgrade-Image für
  genau dieses Modell ist. Sonst hilft der Notfall-Modus (unten).
{% endif -%}
{{ zusatz.fehler }}
{%- if w.weg == "gl-ui" and w.taste %}

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
   "Update firmware".
4. Etwa 3 Minuten warten, Strom nicht ziehen.
{%- endif %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
