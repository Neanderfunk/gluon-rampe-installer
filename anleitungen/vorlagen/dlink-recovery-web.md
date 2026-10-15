{#-
Vorlage dlink-recovery-web (D-Link-Web-Recovery: AQUILA PRO AI M30/M60,
DAP-1620 B1, DAP-X1860, DIR-878, DIR-882). Entwurf Content, 15.10.2026.

Vom Skript: bilder (Name -> Pfad relativ zur Seite; gesucht in
bilder/<gluon_name>/<name>.png, dann bilder/allgemein/<name>.png; fehlt ein
Bild, entfällt es), modell, status, erprobt_am, erprobt_mit, erprobt_mit_aelter
(true, wenn das aktuelle Image neuer ist als das erprobte), zusatz.fehler und
zusatz.text (aus zusatz/<gluon_name>.md, sonst leer), herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    recovery_ip          Adresse der Recovery, z. B. 192.168.200.1
    rechner_ip           feste Adresse für den Rechner, z. B. 192.168.200.66
                         (Netzmaske immer 255.255.255.0)
    datei_art            "rampe" (RAMpe-recovery.bin, danach sysupgrade)
                         oder "factory" (Gluon-factory direkt in die Recovery)
    dauer_neustart       Zeit vom Upload-Start bis zum Neustart, z. B. "gut 2 Minuten"
    upload_pfad          Pfad für den Upload, z. B. "/upload.cgi" oder "/"
    datei_beispiel       Dateiname im curl-Befehl, z. B. gluon-rampe-20261015-…-recovery.bin

  bei datei_art = "rampe"
    rampe_datei          Dateimuster, z. B. gluon-rampe-<Datum>-…-recovery.bin
    rampe_bytes          vollständige Menge in Worten, z. B. "etwa 52,4 Millionen"
    rampe_ip             Adresse der RAMpe, z. B. 192.168.1.1
    led_rampe            z. B. "blinkt gleichmäßig, etwa einmal pro Sekunde"
    dauer_gluon          z. B. "unter 2 Minuten"

  optional (leer = Satz entfällt)
    led_recovery         sichtbares Zeichen der Recovery, als Satzende nach
                         "bis die LED …", z. B. "rot blinkt"; leer = nicht belegt
    anschluss            nach "und zwar mit …", z. B. "der Buchse LAN1" oder
                         "einer der LAN-Buchsen, nicht mit WAN"
    taste_hinweis        z. B. "Nur die Reset-Taste führt in die Recovery, keine andere."
    led_falsch           was NICHT die Recovery ist
    recovery_wartezeit   Wartezeit, bis die Recovery-Seite bereit ist
    seitentitel          Titel der Recovery-Seite im Browser
    herstellerseite_gleiche_ip   true: die Herstellerfirmware antwortet unter derselben Adresse
    dauer_lang           längste beobachtete Dauer, z. B. "über 10 Minuten"
    rampe_url            Download-Ort der RAMpe-Datei (Verzeichnis oder Datei)
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Der {{ modell }} hat eine eingebaute Notfall-Seite von D-Link, die
**Recovery**. Sie nimmt eine Firmware-Datei an und schreibt sie in den
Speicher, auch wenn sonst nichts mehr geht.
{%- if w.datei_art == "rampe" %} Über sie kommt zuerst die
**Gluon-RAMpe** auf den Router: eine kleine Seite, die nur eins kann, die
Freifunk-Firmware deiner Community annehmen. Du brauchst dafür kein SSH und
kein Passwort.
{%- else %} Über sie kommt die Freifunk-Firmware direkt auf den Router.
{%- endif %}

## Was du brauchst

- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- eine Büroklammer für die Reset-Taste
{%- if w.datei_art == "rampe" %}
- die RAMpe-Datei für dieses Gerät: `{{ w.rampe_datei }}`
  {%- if w.rampe_url %} ([herunterladen]({{ w.rampe_url }})){% endif %}
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image
{%- else %}
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **factory**-Image
{%- endif %}
- das Programm **curl** zum Hochladen. Unter Linux und macOS ist es meist
  schon da, unter Windows 10 und 11 heißt es `curl.exe` und ist eingebaut
  ([curl benutzen](grundlagen/curl.md)).

WLAN am Rechner schaltest du für die Installation am besten aus, damit er
wirklich über das Kabel spricht.

## Schritte

1. **Dateien bereitlegen.** Lade
   {%- if w.datei_art == "rampe" %} die RAMpe-Datei und das sysupgrade-Image
   {%- else %} das factory-Image{% endif %} herunter und leg sie in einen
   Ordner, den du wiederfindest, zum Beispiel "Downloads".

2. **Feste Adresse am Rechner.** Stell den Netzwerkanschluss deines Rechners
   auf die feste Adresse `{{ w.rechner_ip }}` mit der Netzmaske
   `255.255.255.0`. Ein Gateway brauchst du nicht. Wie das geht, steht unter
   [Feste IP-Adresse einstellen](grundlagen/feste-ip.md).

3. **Kabel stecken.** Verbinde den Rechner mit dem Router
   {%- if w.anschluss %}, und zwar mit {{ w.anschluss }}{% endif %}.
   Der Router hat noch keinen Strom.

4. **Router in die Recovery bringen.** Drück mit der Büroklammer die
   Reset-Taste und halte sie gedrückt. Steck jetzt den Strom ein und halte
   {%- if w.led_recovery %}
   die Taste weiter, bis die LED **{{ w.led_recovery }}**. Dann loslassen.
   {%- else %}
   die Taste weiter gedrückt. Woran man bei diesem Gerät sieht, dass die
   Recovery bereit ist, wissen wir noch nicht. Lass nach etwa 10 Sekunden los
   und prüf in Schritt 5, ob die Recovery-Seite erscheint; wenn nicht, noch
   einmal und länger halten.
   {%- endif %}
   {%- if w.taste_hinweis %}
   {{ w.taste_hinweis }}
   {%- endif %}
   {%- if w.led_falsch %}
   {{ w.led_falsch }} Dann Strom ab und noch einmal.
   {%- endif %}

5. **Prüfen, ob die Recovery da ist.**
   {%- if w.recovery_wartezeit %} Warte {{ w.recovery_wartezeit }}.{% endif %}
   Öffne im Browser `http://{{ w.recovery_ip }}`.
   {%- if w.seitentitel %} Es erscheint eine schlichte Seite
   "{{ w.seitentitel }}".{% else %} Es erscheint die Recovery-Seite von D-Link.{% endif %}
   **Lade dort nichts hoch.** Ihr Fortschrittsbalken läuft nur nach der Uhr
   und sagt nichts darüber, ob die Datei ankam. Die Seite zeigt dir nur, dass
   die Recovery bereit ist.
   {%- if w.herstellerseite_gleiche_ip %}
   Kommt stattdessen eine aufwendigere Seite, die nach einem Passwort fragt,
   ist das die normale D-Link-Firmware, nicht die Recovery: zurück zu
   Schritt 4.
   {%- endif %}
   Ein `ping` hilft hier nicht, die Recovery antwortet nicht darauf.
   {%- if b.get("recovery-seite") %}

   ![Die Recovery-Seite im Browser: Überschrift, Feld für die Datei, Knopf "Upgrade". Hier nichts hochladen.]({{ b["recovery-seite"] }})
   {%- endif %}

6. **Datei mit curl hochladen.** Öffne ein Terminal (unter Windows die
   **PowerShell**), wechsle in den Ordner mit der Datei und gib ein:

   Linux und macOS:

   ```sh
   curl -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o /dev/null -F "firmware=@{{ w.datei_beispiel }};type=application/octet-stream" http://{{ w.recovery_ip }}{{ w.upload_pfad }}
   ```

   Windows (PowerShell):

   ```
   curl.exe -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o antwort.bin -F "firmware=@{{ w.datei_beispiel }};type=application/octet-stream" http://{{ w.recovery_ip }}{{ w.upload_pfad }}
   ```

   Den echten Dateinamen statt `{{ w.datei_beispiel }}` einsetzen. Unter
   Windows `curl.exe` genau so ausschreiben; `antwort.bin` nimmt nur die
   Antwort des Routers auf und kann danach weg. Mehr unter
   [curl benutzen](grundlagen/curl.md).

7. **Warten.** curl überträgt die Datei und wartet dann weiter, während die
   Recovery schreibt.{% if w.led_recovery %} Die LED bleibt dabei wie in Schritt 4.{% endif %} Bis zum
   Neustart vergehen meist {{ w.dauer_neustart }}
   {%- if w.dauer_lang %}, es kann aber auch {{ w.dauer_lang }} dauern{% endif %}.
   **Nicht abbrechen, Strom nicht ziehen.**
   {%- if w.datei_art == "rampe" %}
   Am Ende zeigt curl, wie viel ankam. Geklappt hat es bei
   **{{ w.rampe_bytes }} Bytes**. Steht da 0, kam nichts an (siehe "Wenn
   etwas schiefgeht").
   {%- endif %}
{%- if w.datei_art == "rampe" %}

8. **Die RAMpe.** Nach dem Neustart {{ w.led_rampe }}. Stell den Rechner
   wieder auf "automatisch" (DHCP) und öffne `http://{{ w.rampe_ip }}`. Es
   erscheint die Seite "Firmware aktualisieren".
   Die RAMpe bleibt auf dem Router, bis die Freifunk-Firmware sie ersetzt.
   Startet der Router zwischendurch neu, ist das harmlos: Seite einfach
   wieder aufrufen.
   Zeigt der Browser stattdessen eine Warnung vor einem unsicheren
   Zertifikat, hat er von sich aus `https://` vor die Adresse gesetzt. Klick
   auf "Erweitert" und "Trotzdem fortfahren" (je nach Browser etwas anders
   benannt), dann kommt die Seite. Mehr dazu unter
   [Browser macht https daraus](grundlagen/browser-https.md).
   {%- if b.get("rampe-seite") %}

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"]({{ b["rampe-seite"] }})
   {%- endif %}

9. **Freifunk-Firmware hochladen.** Wähl das sysupgrade-Image deiner
   Community aus und klick "Datei hochladen". Die RAMpe zeigt die Prüfsumme
   (SHA256) der Datei. Vergleich sie mit der Prüfsumme, die deine Community
   zur Datei angibt. Stimmt sie, klick "Fortfahren".
   {%- if b.get("rampe-pruefsumme") %}

   ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"]({{ b["rampe-pruefsumme"] }})
   {%- endif %}
   {%- if b.get("rampe-flash-laeuft") %}

   Danach erscheint der Hinweis, dass die Firmware jetzt geschrieben wird.
   Jetzt den Strom nicht unterbrechen.

   ![Hinweis der RAMpe: Die Firmware wird jetzt aktualisiert, Stromversorgung nicht unterbrechen]({{ b["rampe-flash-laeuft"] }})
   {%- endif %}

10. **Fertig.** Nach {{ w.dauer_gluon }} startet die Freifunk-Firmware
    deiner Community: je nach Community zuerst mit einer Einrichtungsseite
    unter `http://192.168.1.1` oder gleich im Betrieb. Wie es weitergeht,
    beschreibt deine Community.
{%- else %}

8. **Fertig.** Nach dem Neustart startet die Freifunk-Firmware deiner
   Community: je nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb. Wie es weitergeht, beschreibt
   deine Community.
{%- endif %}

## Woran du erkennst, dass es geklappt hat
{% if w.datei_art == "rampe" %}
- curl meldet am Ende **{{ w.rampe_bytes }} Bytes**. Wie lange das gedauert
  hat, ist egal, es zählt die Menge.
  {%- if b.get("curl-ausgabe") %}

  ![curl in der PowerShell: oben ein Fehlversuch mit "Failed to connect" und 0 Bytes, unten ein vollständiger Upload mit 50.00M bei 100 %]({{ b["curl-ausgabe"] }})
  {%- endif %}
- Nach dem Neustart {{ w.led_rampe }}, und unter `http://{{ w.rampe_ip }}`
  steht "Firmware aktualisieren".
{%- else %}
- Nach dem Neustart meldet sich die Freifunk-Firmware.
{%- endif %}
- Die Erfolgsmeldung der D-Link-Seite zählt nicht, sie erscheint immer.

## Wenn etwas schiefgeht

- **curl meldet "Failed to connect", HTTP 000 und 0 Bytes.** Die Recovery war
  nicht erreichbar. Prüf die feste Adresse (Schritt 2) und das Kabel, dann
  Router noch einmal in die Recovery bringen (Schritt 4).
- **Nach dem Upload startet wieder die normale D-Link-Firmware.** Die Datei
  ist nicht vollständig angekommen, zum Beispiel wegen eines Tippfehlers im
  Dateinamen. Das ist harmlos: noch einmal ab Schritt 4.
- **Der Browser-Upload war nach einer Sekunde "fertig".** Dann ist nichts
  übertragen worden. Das passiert auch in Chromium-Browsern. Nimm curl.
- **Aus der WSL unter Windows kommt keine Verbindung zustande.** Nimm curl.exe
  direkt in Windows, nicht in der WSL.
{{ zusatz.fehler }}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
