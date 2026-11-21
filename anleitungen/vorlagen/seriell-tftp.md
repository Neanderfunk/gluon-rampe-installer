{#-
Vorlage seriell-tftp: Geräte, bei denen man über die serielle Konsole den
Bootloader (U-Boot) anhält, ihn per Befehlen auf OpenWrt umstellt und ein
OpenWrt-initramfs per TFTP von einem Rechner lädt. Aus diesem OpenWrt
heraus wird das Gluon-sysupgrade geschrieben. Die Befehle unterscheiden sich
je Gerät stark und stehen deshalb wörtlich in den Werten.

Erstes Gerät: Extreme Networks WS-AP3825i (OpenWrt-Commit 7e61482,
OpenWrt-Wiki toh:extreme_networks:ws-ap3825i, Freifunk-Darmstadt-Forum
t/923, OpenWrt-Issue 17152).

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    initramfs_datei      Dateiname des OpenWrt-initramfs
    initramfs_url        Download-Adresse dieser Datei
    tftp_name            Name, den die Datei im TFTP-Ordner haben muss (steht
                         so in den Befehlen)
    server_ip            feste Adresse des Rechners (TFTP-Server), z. B.
                         "192.168.1.66"
    baud                 Geschwindigkeit der Konsole, z. B. "115200"
    anhalten             ganzer Satz: wann und mit welcher Taste man den
                         Bootloader anhält
    befehle              Befehle im Bootloader, wörtlich, eine pro Zeile; die
                         letzte startet das OpenWrt-initramfs

  optional
    konsole              "rj45" (Vorgabe: Cisco-Konsolenkabel an RJ45),
                         "uart" (Stiftleiste im Gehäuse, USB-Seriell-Adapter
                         3,3 V) oder "usb"
    konsole_ort          wo die Konsolenbuchse bzw. die Stifte sitzen
    login                Zugangsdaten am Bootloader, z. B. "admin / new2day"
    login_hinweis        ganzer Satz, was zu tun ist, wenn sie nicht gehen
    prompt               Eingabeaufforderung nach dem Anhalten, z. B.
                         "Boot (PRI)->"
    tftp_buchse          Netzwerkbuchse für TFTP, z. B. "LAN2"
    ssh_buchse           Netzwerkbuchse für scp/ssh, wenn anders, z. B. "LAN1"
    initramfs_hinweis    ganzer Satz, warum gerade diese OpenWrt-Version
    dauer                ganzer Satz zur Dauer nach dem sysupgrade
    fertig_zeichen       ganzer Satz, woran man das Ende erkennt (z. B. LED)
    rueckweg             ganzer Satz zum Weg zurück zur Herstellerfirmware
    saveenv_folge        ganzer Satz, was das gespeicherte saveenv bewirkt (leer =
                         "Ab jetzt startet das Gerät OpenWrt statt der
                         Herstellerfirmware."; passt nicht, wenn saveenv nur die
                         Signaturprüfung abschaltet, z. B. Acer)
    sicherheit, sicherheit_hinweis   siehe _status.md
    rampe_url            Direktlink auf die RAMpe (initramfs). Gesetzt: Die RAMpe
                         ersetzt das OpenWrt-initramfs (gleicher tftp_name,
                         gleiche Befehle), die Freifunk-Firmware kommt über
                         die RAMpe-Seite im Browser statt per scp/ssh;
                         OpenWrt steht nur noch unter "Anderer Weg"
                         (adorfer 15.11.2026: "bitte alles auf RAMpe umstellen")
    rampe_datei          Dateiname dazu
    rampe_buchse         Buchse, an der die RAMpe-Seite antwortet, wenn sie
                         nicht ssh_buchse ist. Die RAMpe-Seite liegt an den
                         Ports des Gluon-Konfigurationsmodus: LAN, bei einem
                         Port der eine, bei Outdoor-Geräten WAN (Buildsystem
                         15.11.2026, gluon-setup-mode 320-setup-ifname)
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set konsole = w.get("konsole") or "rj45" -%}
{%- set tftp_buchse = w.get("tftp_buchse") -%}
{%- set ssh_buchse = w.get("ssh_buchse") -%}
{%- set saveenv = "saveenv" in w.befehle -%}
{%- set rampe = w.get("rampe_url") -%}
{%- set rampe_buchse = w.get("rampe_buchse") or ssh_buchse -%}
{%- set zw = "die RAMpe" if rampe else "OpenWrt" -%}
{%- import "_rampe_schritte.md" as rs with context -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Dieses Gerät nimmt keine fremde Firmware über seine Weboberfläche an. Der
Weg führt über die **serielle Konsole**, also ein Kabel, über das du den
Bootloader des Geräts direkt bedienst. Er hat zwei Etappen:

{% if rampe -%}
1. **Die RAMpe starten.** Du stellst den Bootloader so ein, dass er die
   **Gluon-RAMpe** per TFTP von deinem Rechner holt und startet: eine kleine
   Firmware, die nur eins kann, die Freifunk-Firmware deiner Community
   annehmen. Sie läuft nur im Arbeitsspeicher.
2. **Die Freifunk-Firmware aufspielen.** Auf der Seite der RAMpe lädst du
   im Browser die Freifunk-Firmware deiner Community hoch.

Dafür brauchst du zwei Werkzeuge, die auf eigenen Seiten erklärt sind:
[Serielle Konsole benutzen](grundlagen/serielle-konsole.md) und
[TFTP-Server einrichten](grundlagen/tftp-server.md). Rechne beim ersten Mal
mit einer Stunde.
{%- else %}
1. **OpenWrt starten.** Du stellst den Bootloader so ein, dass er ein
   kleines OpenWrt per TFTP von deinem Rechner holt und startet. Es läuft
   nur im Arbeitsspeicher.
2. **Die Freifunk-Firmware aufspielen.** Aus diesem OpenWrt heraus
   installierst du die Freifunk-Firmware deiner Community.

Dafür brauchst du drei Werkzeuge, die auf eigenen Seiten erklärt sind:
[Serielle Konsole benutzen](grundlagen/serielle-konsole.md),
[TFTP-Server einrichten](grundlagen/tftp-server.md) und
[SSH und scp benutzen](grundlagen/ssh-scp.md). Rechne beim ersten Mal mit
einer Stunde.
{%- endif %}

## Was du brauchst

- das Gerät mit Stromversorgung (Netzteil oder PoE-Injektor), einen Rechner
  mit Netzwerkanschluss und ein Netzwerkkabel
{%- if konsole == "uart" %}
- einen **USB-Seriell-Adapter für 3,3 V** und kurze Steckkabel. Die
  Konsole liegt auf Stiften im Gehäuse
  {%- if w.get("konsole_ort") %} ({{ w.get("konsole_ort") }}){% endif %}; du
  musst das Gerät also öffnen.
{%- elif konsole == "usb" %}
- ein USB-Kabel für die Konsolenbuchse
  {%- if w.get("konsole_ort") %} ({{ w.get("konsole_ort") }}){% endif %}.
{%- else %}
- ein **Cisco-Konsolenkabel**: RJ45-Stecker auf der einen Seite, USB (oder
  die alte 9-polige serielle Buchse plus USB-Adapter) auf der anderen. Die
  Konsolenbuchse
  {%- if w.get("konsole_ort") %} sitzt {{ w.get("konsole_ort") }}{% else %} ist
  eine RJ45-Buchse{% endif %}. Ein einfacher USB-Seriell-Adapter für 3,3 V
  passt hier **nicht**: Die Buchse arbeitet mit den höheren Spannungen der
  alten seriellen Schnittstelle (RS-232).
{%- endif %}
{%- if rampe %}
- ein Terminalprogramm und einen TFTP-Server (siehe die zwei Seiten oben)
- diese Dateien:
  1. die RAMpe für den {{ modell }}:
     [{{ w.get("rampe_datei") or "RAMpe-Datei" }}]({{ w.rampe_url }}).
     Leg sie in den Ordner deines TFTP-Servers und benenn sie dort genau in
     **`{{ w.tftp_name }}`** um.
  2. die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar
     das **sysupgrade**-Image.
{%- else %}
- ein Terminalprogramm, einen TFTP-Server und `ssh`/`scp` (siehe die drei
  Seiten oben)
- diese Dateien:
  1. das OpenWrt-initramfs:
     [{{ w.initramfs_datei }}]({{ w.initramfs_url }}).
     {%- if w.get("initramfs_hinweis") %} {{ w.get("initramfs_hinweis") }}{% endif %}
     Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
     **`{{ w.tftp_name }}`** um.
  2. die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.
{%- endif %}
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

### {% if rampe %}Die RAMpe{% else %}OpenWrt{% endif %} starten

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `{{ w.server_ip }}`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht das Gerät den TFTP-Server.

2. **TFTP-Server starten.** Starte den TFTP-Server mit dem Ordner, in dem
   `{{ w.tftp_name }}` liegt
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an
   {%- if tftp_buchse %} die Buchse **{{ tftp_buchse }}**.
   {%- else %} die Netzwerkbuchse des Geräts.{% endif %}
   Das Konsolenkabel an die Konsole, das andere Ende an den Rechner. Strom
   noch nicht anschließen.

4. **Terminal öffnen.** Starte das Terminalprogramm mit **{{ w.baud }}**
   Baud, 8N1, ohne Flusssteuerung
   ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).

5. **Bootloader anhalten.** Schließ jetzt den Strom an. {{ w.anhalten }}
   {%- if w.get("login") %} Melde dich mit **{{ w.get("login") }}** an
   (Benutzer / Passwort).
   {%- if w.get("login_hinweis") %} {{ w.get("login_hinweis") }}{% endif %}
   {%- endif %}
   **Prüfen:** Es erscheint die Eingabeaufforderung des Bootloaders
   {%- if w.get("prompt") %} `{{ w.get("prompt") }}`{% endif %}. Sonst Strom
   ziehen und noch einmal.

6. **{% if saveenv %}Bootloader einstellen und {% endif %}{% if rampe %}die RAMpe{% else %}OpenWrt{% endif %} laden.** Gib
   diese Befehle ein, jede Zeile einzeln. Warte nach jeder Zeile, bis die
   Eingabeaufforderung wieder erscheint
   {%- if saveenv %}; `saveenv` kann ein paar Sekunden brauchen, dabei
   **nicht den Strom ziehen**{% endif %}:

   ```
{%- for zeile in w.befehle.splitlines() %}
   {{ zeile }}
{%- endfor %}
   ```

   Die Befehle holen `{{ w.tftp_name }}` von deinem Rechner und starten
   {{ zw }}; das Terminal zeigt viele Zeilen. Warte, bis
   `Please press Enter to activate this console.` erscheint.
   {%- if saveenv %}

   {{ w.get("saveenv_folge") or ("Ab jetzt startet das Gerät nicht mehr die Herstellerfirmware." if rampe else "Ab jetzt startet das Gerät OpenWrt statt der Herstellerfirmware.") }}
   {%- endif %}

### Freifunk-Firmware aufspielen
{%- if rampe %}

7. **Rechner vorbereiten.**
   {%- if rampe_buchse %} Steck das Netzwerkkabel jetzt in die Buchse
   **{{ rampe_buchse }}**.{% endif %}
   {%- if not w.server_ip.startswith("192.168.1.") %} Die RAMpe antwortet
   unter `192.168.1.1`. Stell deinen Rechner deshalb jetzt auf die feste
   Adresse `192.168.1.10` um, Netzmaske `255.255.255.0`.
   {%- else %} Die feste Adresse `{{ w.server_ip }}` passt auch für die
   RAMpe unter `192.168.1.1`.{% endif %}

{{ rs.seite(8, ram=5) }}

10. **Warten.** Das Gerät schreibt die Freifunk-Firmware und startet neu.
    {%- if w.get("dauer") %} {{ w.get("dauer") }}{% endif %}
    **Strom nicht ziehen.**
    {%- if w.get("fertig_zeichen") %} {{ w.get("fertig_zeichen") }}{% endif %}

11. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet
    die Freifunk-Firmware deiner Community: je nach Community zuerst mit
    einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im
    Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
{%- else %}

7. **Freifunk-Firmware kopieren.**
   {%- if ssh_buchse %} Steck das Netzwerkkabel jetzt in die Buchse
   **{{ ssh_buchse }}**.{% endif %}
   {%- if not w.server_ip.startswith("192.168.1.") %} OpenWrt antwortet
   unter `192.168.1.1`. Stell deinen Rechner deshalb jetzt auf die feste
   Adresse `192.168.1.10` um, Netzmaske `255.255.255.0`.{% endif %}
   Öffne ein zweites Terminal im Ordner mit `gluon.bin` und gib ein:

   ```
   scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
   ssh root@192.168.1.1 "sysupgrade -n /tmp/gluon.bin"
   ```

   Ein Passwort gibt es nicht. Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS
   CHANGED", siehe [SSH und scp benutzen](grundlagen/ssh-scp.md). Nach dem
   zweiten Befehl bricht die Verbindung ab, oft mit einer Meldung wie
   `Command failed: … (Connection failed)`. Das ist harmlos.

8. **Warten.** Das Gerät schreibt die Freifunk-Firmware und startet neu.
   {%- if w.get("dauer") %} {{ w.get("dauer") }}{% endif %}
   **Strom nicht ziehen.**
   {%- if w.get("fertig_zeichen") %} {{ w.get("fertig_zeichen") }}{% endif %}

9. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet
   die Freifunk-Firmware deiner Community: je nach Community zuerst mit
   einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im
   Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
{%- endif %}

## Woran du erkennst, dass es geklappt hat

- In Schritt 5 erscheint die Eingabeaufforderung des Bootloaders.
- In Schritt 6 holt der Bootloader die Datei, und {{ zw }} startet.
{%- if rampe %}
- In Schritt 8 zeigt `http://192.168.1.1` die RAMpe-Seite "Firmware
  aktualisieren".
{%- endif %}
- Nach Schritt {% if rampe %}10{% else %}8{% endif %} meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Im Terminal erscheint nichts oder nur wirre Zeichen.** Prüf die
  Geschwindigkeit ({{ w.baud }}) und das Kabel
  ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).
- **In Schritt 6 kommt die Datei nicht an.** Prüf die feste Adresse
  `{{ w.server_ip }}`, die Firewall deines Rechners und den Dateinamen
  `{{ w.tftp_name }}`
  {%- if tftp_buchse %}, und ob das Kabel in {{ tftp_buchse }} steckt{% endif %}.
- **In Schritt {% if rampe %}8{% else %}7{% endif %} antwortet nichts.** Warte noch eine Minute, {{ zw }}
  braucht etwas.
  {%- if ssh_buchse %} Prüf, ob das Kabel jetzt in {{ ssh_buchse }}
  steckt.{% endif %}
- **Nach Schritt {% if rampe %}10{% else %}8{% endif %} meldet sich lange nichts.** Weiter warten und nicht den
  Strom ziehen. Erst wenn nach einer halben Stunde noch nichts kommt, schreib
  uns, am besten mit der Mitschrift des Terminals.
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}
{%- if rampe %}

## Anderer Weg: über OpenWrt

Statt der RAMpe startet der Bootloader in Schritt 6 auch OpenWrt:
[{{ w.initramfs_datei }}]({{ w.initramfs_url }}), ebenfalls unter dem Namen
`{{ w.tftp_name }}` in den TFTP-Ordner.
{%- if w.get("initramfs_hinweis") %} {{ w.get("initramfs_hinweis") }}{% endif %}
Danach kommt die Freifunk-Firmware per scp und ssh statt über den Browser
([SSH und scp benutzen](grundlagen/ssh-scp.md)): das sysupgrade-Image in
`gluon.bin` umbenennen, Rechner wie in Schritt 7 vorbereiten, dann

```
scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
ssh root@192.168.1.1 "sysupgrade -n /tmp/gluon.bin"
```

Ein Passwort gibt es nicht. Nach dem zweiten Befehl bricht die Verbindung
ab, das ist harmlos.
{%- endif %}
{%- if w.get("rueckweg") %}

## Zurück zur Herstellerfirmware

{{ w.get("rueckweg") }}
{%- endif %}

{{ zusatz.text }}

