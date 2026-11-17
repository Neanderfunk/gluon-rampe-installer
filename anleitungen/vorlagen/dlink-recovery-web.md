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
                         (zeigt rampe_url auf eine Datei, gilt deren Name)

  bei datei_art = "rampe"
    rampe_datei          Dateimuster, z. B. gluon-rampe-<Datum>-…-recovery.bin
    rampe_bytes          vollständige Menge in Worten, z. B. "etwa 52,4 Millionen"
    rampe_ip             Adresse der RAMpe, z. B. 192.168.1.1 (die RAMpe leitet
                         selbst auf /cgi-bin/config weiter, adorfer 12.11.2026)
    led_rampe            nach "Nach dem Neustart …", z. B. "blinkt die LED
                         gleichmäßig, etwa einmal pro Sekunde"
    dauer_gluon          z. B. "unter 2 Minuten"

  optional (leer = Satz entfällt)
    led_recovery         sichtbares Zeichen der Recovery, als Satzende nach
                         "bis die LED …", z. B. "rot blinkt"; leer = nicht belegt
    anschluss            nach "und zwar mit …", z. B. "der Buchse LAN1" oder
                         "einer der LAN-Buchsen, nicht mit WAN"
    anschluss_warnung    ganzer Satz hinter Schritt 3, z. B. "An der
                         WAN-Buchse funktioniert die Recovery nicht."
                         (adorfer 17.11.2026 für M30/M60)
    taste_hinweis        z. B. "Nur die Reset-Taste führt in die Recovery, keine andere."
    led_falsch           was NICHT die Recovery ist
    led_schreibt         LED, während die Recovery schreibt, nach "dabei …",
                         z. B. "leuchtet die LED ruhig rot, etwas schwächer"
    led_start            LED beim Neustart, nach "beim Neustart …",
                         z. B. "blinkt die LED schnell weiß"
    recovery_wartezeit   Wartezeit, bis die Recovery-Seite bereit ist
    seitentitel          Titel der Recovery-Seite im Browser
    herstellerseite_gleiche_ip   true: die Herstellerfirmware antwortet unter derselben Adresse
    dauer_lang           längste beobachtete Dauer, z. B. "über 10 Minuten"
    rampe_url            Download-Ort der RAMpe-Datei (Verzeichnis oder Datei)
    browser_upload       Browser für das Hochladen, nach "Öffne in …";
                         leer = "Chrome oder Chromium"
    browser_nicht        Browser, mit dem es NICHT geht, z. B. "Firefox"
    upload_knopf         Beschriftung des Knopfs zum Hochladen, z. B. "Upgrade"
    meldung_laeuft       Text der Seite beim Hochladen, z. B.
                         "Device is upgrading the firmware"
    meldung_fertig       Erfolgsmeldung der Seite, z. B. "Upgrade successfully!"
    upload_langsam       true: das Hochladen im Browser dauert spürbar
    led_herstellerfirmware  LED, wenn statt Gluon/RAMpe die D-Link-Firmware
                         startet, in Klammern, z. B. "die LED dimmt langsam
                         orange auf und ab" (adorfer 15.11.2026, M30/M60)

Hochladen im Browser ist bei allen Geräten der Familie der Weg, curl nur der
Notweg (adorfer 15.11.2026: DAP-1620/DAP-X1860 gehen mit Chromium schon
immer, M30/M60 mit Chrome; DIR-878/882 laut OpenWrt-Commits d7233b0/73e8f23
Browser, curl nur als Alternative). Die curl-Schritte stehen im Makro
curl_schritte, gebraucht im Abschnitt "Notweg".
-#}
{%- macro curl_schritte(n) %}
{#- Dateiname im curl-Befehl: der echte Name aus rampe_url, wenn sie auf eine
    Datei zeigt (sonst stünde nach jedem RAMpe-Neubau das alte Datum drin),
    sonst datei_beispiel. #}
{%- set ru = werte.get("rampe_url") or "" -%}
{%- set rd = ru.rsplit("/", 1)[-1] -%}
{%- set db = rd if "." in rd else werte.datei_beispiel -%}
{{ n }}. **Datei mit curl hochladen.** Öffne ein Terminal (unter Windows die
   **PowerShell**), wechsle in den Ordner mit der Datei und gib ein:

   Linux und macOS:

   ```sh
   curl -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o /dev/null -F "firmware=@{{ db }};type=application/octet-stream" http://{{ werte.recovery_ip }}{{ werte.upload_pfad }}
   ```

   Windows (PowerShell):

   ```
   curl.exe -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o antwort.bin -F "firmware=@{{ db }};type=application/octet-stream" http://{{ werte.recovery_ip }}{{ werte.upload_pfad }}
   ```

   Den echten Dateinamen statt `{{ db }}` einsetzen. Unter
   Windows `curl.exe` genau so ausschreiben; `antwort.bin` nimmt nur die
   Antwort des Routers auf und kann danach weg. Mehr unter
   [curl benutzen](grundlagen/curl.md).

{{ n + 1 }}. **Warten.** curl zeigt beim Hochladen eine Fortschrittsanzeige. Bei 100 %
   ist die Datei drüben, das dauert meist nur Sekunden. Danach schreibt die
   Recovery sie in den Speicher{% if werte.get("led_schreibt") %}; dabei {{ werte.led_schreibt }}{% endif %}.
   Bis zum Neustart vergehen meist {{ werte.dauer_neustart }}
   {%- if werte.dauer_lang %}, es kann aber auch {{ werte.dauer_lang }} dauern{% endif %}.
   **Strom nicht ziehen.**
   Oft kommt curl danach nicht von selbst zurück, obwohl alles geklappt hat.
   Dann beende es mit **Strg+C** (am Mac ctrl+C), aber erst, wenn der Router
   neu startet{% if werte.get("led_start") %} (beim Neustart {{ werte.led_start }}){% endif %}.
   Wartest du stattdessen, kommt curl nach einiger Zeit (bei uns gut 10
   Minuten) von selbst zurück, meist mit "Recv failure: Connection timed
   out". Das ist in Ordnung.
   {%- if werte.datei_art == "rampe" %} Entscheidend ist die letzte Zeile, sie
   zeigt, wie viel ankam. Geklappt hat es bei **{{ werte.rampe_bytes }} Bytes**.
   Steht da 0, kam nichts an (siehe "Wenn etwas schiefgeht").
   {%- endif %}
{%- endmacro %}
{%- set w = werte -%}
{%- set browser = w.browser_upload or "Chrome oder Chromium" -%}
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
- zum Hochladen den Browser **{{ browser }}**
  {%- if w.browser_nicht %} ({{ w.browser_nicht }} geht hier nicht){% endif %}

WLAN am Rechner schaltest du für die Installation am besten aus, damit er
wirklich über das Kabel spricht.

## Schritte

1. **Dateien bereitlegen.** Lade
   {%- if w.datei_art == "rampe" %} die RAMpe-Datei und das sysupgrade-Image
   {%- else %} das factory-Image{% endif %} herunter und leg {% if w.datei_art == "rampe" %}sie{% else %}es{% endif %} in einen
   Ordner, den du wiederfindest, zum Beispiel "Downloads".

2. **Feste Adresse am Rechner.** Stell den Netzwerkanschluss deines Rechners
   auf die feste Adresse `{{ w.rechner_ip }}` mit der Netzmaske
   `255.255.255.0`. Ein Gateway brauchst du nicht. Wie das geht, steht unter
   [Feste IP-Adresse einstellen](grundlagen/feste-ip.md).

3. **Kabel stecken.** Verbinde den Rechner mit dem Router
   {%- if w.anschluss %}, und zwar mit {{ w.anschluss }}{% endif %}.
   {%- if w.anschluss_warnung %} **{{ w.anschluss_warnung }}**{% endif %}
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

5. **Recovery-Seite öffnen.**
   {%- if w.recovery_wartezeit %} Warte {{ w.recovery_wartezeit }}.{% endif %}
   Öffne in {{ browser }} `http://{{ w.recovery_ip }}`.
   {%- if w.seitentitel %} Es erscheint eine schlichte Seite
   "{{ w.seitentitel }}".{% else %} Es erscheint die Recovery-Seite von D-Link.{% endif %}
   {%- if w.herstellerseite_gleiche_ip %}
   Kommt stattdessen eine aufwendigere Seite, die nach einem Passwort fragt,
   ist das die normale D-Link-Firmware, nicht die Recovery: zurück zu
   Schritt 4.
   {%- endif %}
   Kommt gar nichts, prüf die feste Adresse (Schritt 2) und das Kabel
   (Schritt 3). Ein `ping` hilft hier nicht, die Recovery antwortet nicht
   darauf.
   {%- if b.get("recovery-seite") %}

   ![Die Recovery-Seite im Browser: Überschrift, Feld für die Datei, Knopf {% if w.upload_knopf %}"{{ w.upload_knopf }}"{% else %}zum Hochladen{% endif %}]({{ b["recovery-seite"] }})
   {%- endif %}

6. **Datei im Browser hochladen.** Klick auf "Datei auswählen", wähl
   {%- if w.datei_art == "rampe" %} die RAMpe-Datei `{{ w.rampe_datei }}`
   {%- else %} das factory-Image{% endif %} und klick
   {%- if w.upload_knopf %} "{{ w.upload_knopf }}"{% else %} den Knopf daneben{% endif %}.
   {%- if b.get("recovery-datei-gewaehlt") %}

   ![Die Recovery-Seite mit gewählter Datei, daneben der Knopf {% if w.upload_knopf %}"{{ w.upload_knopf }}"{% else %}zum Hochladen{% endif %}]({{ b["recovery-datei-gewaehlt"] }})
   {% endif %}
   Die Seite zeigt jetzt
   {%- if w.meldung_laeuft %} "{{ w.meldung_laeuft }}" mit einer Prozentzahl{% else %} den Fortschritt in Prozent{% endif %}.
   {%- if w.upload_langsam %} Das Hochladen geht langsam.{% endif %} Lass die Seite in Ruhe, bis
   {%- if w.meldung_fertig %} "{{ w.meldung_fertig }}"{% else %} die Erfolgsmeldung{% endif %} erscheint.
   {%- if b.get("recovery-upload") %}

   ![Die Recovery-Seite während des Hochladens, mit Prozentanzeige]({{ b["recovery-upload"] }})
   {%- endif %}

7. **Warten.** Danach schreibt die Recovery die Datei in den Speicher
   {%- if w.get("led_schreibt") %}; dabei {{ w.led_schreibt }}{% endif %}, und
   der Router startet neu{% if w.get("led_start") %} (beim Neustart {{ w.led_start }}){% endif %}.
   **Strom nicht ziehen.** Die Erfolgsmeldung allein heißt noch nicht,
   dass es geklappt hat.
   {%- if b.get("recovery-fertig") %}

   ![Die Recovery-Seite nach dem Hochladen, mit Erfolgsmeldung]({{ b["recovery-fertig"] }})
   {% endif %}
   Nicht geklappt hat es, wenn

   - gar nichts passiert: Der Router bleibt in der Recovery, die LED blinkt
     weiter wie in Schritt 4, oder
   - der Router mit der normalen D-Link-Firmware startet
     {%- if w.led_herstellerfirmware %} ({{ w.led_herstellerfirmware }}){% endif %}.

   Dann ist die Datei nicht angekommen. Das ist harmlos: noch einmal ab
   Schritt 4 mit {{ browser }}. Klappt es auch dann nicht, nimm den Notweg
   weiter unten ("Notweg: Hochladen mit curl").
{%- if w.datei_art == "rampe" %}

8. **Die RAMpe.** Nach dem Neustart {{ w.led_rampe }}. Stell den Rechner
   wieder auf "automatisch" (DHCP) und öffne
   `http://{{ w.rampe_ip }}`. Die RAMpe leitet von selbst auf ihre Seite
   "Firmware aktualisieren" weiter. Kommt stattdessen "Not Found", hat sich der Browser eine Weiterleitung von früher gemerkt, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Kommt gar nichts, siehe [Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md).
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
    unter `http://192.168.1.1` oder gleich im Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Wie es weitergeht,
    beschreibt deine Community.
{%- else %}

8. **Fertig.** Nach dem Neustart startet die Freifunk-Firmware deiner
   Community: je nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Wie es weitergeht, beschreibt
   deine Community.
{%- endif %}

## Woran du erkennst, dass es geklappt hat
{% if w.datei_art == "rampe" %}
- Nach dem Neustart {{ w.led_rampe }}, und `http://{{ w.rampe_ip }}` zeigt
  die Seite "Firmware aktualisieren".
{%- else %}
- Nach dem Neustart meldet sich die Freifunk-Firmware.
{%- endif %}
- Die Erfolgsmeldung der D-Link-Seite zählt nicht, sie erscheint immer.

## Wenn etwas schiefgeht

- **Der Router bleibt in der Recovery (die LED blinkt weiter wie in
  Schritt 4), oder er startet mit der normalen D-Link-Firmware
  {%- if w.led_herstellerfirmware %} ({{ w.led_herstellerfirmware }}){% endif %}.**
  Dann ist die Datei nicht angekommen.
  {%- if w.browser_nicht %} Mit {{ w.browser_nicht }} passiert das immer.{% endif %}
  Noch einmal ab Schritt 4 mit {{ browser }}, sonst den Notweg mit curl
  (unten). Im Notweg ist die häufigste Ursache ein Tippfehler im
  Dateinamen.
- **Im Notweg: curl meldet "Failed to connect", HTTP 000 und 0 Bytes.** Die Recovery war
  nicht erreichbar. Prüf die feste Adresse (Schritt 2) und das Kabel (Schritt 3), dann
  Router noch einmal in die Recovery bringen (Schritt 4).
- **Im Notweg: curl steht bei 100 % und kommt nicht zurück, oder meldet nach langer
  Zeit "Recv failure: Connection timed out".** Das ist normal: Der Router hat
  neu gestartet, ohne curl Bescheid zu geben. curl darf mit Strg+C beendet
  werden, sobald der Router neu startet.
- **Im Notweg: Aus der WSL unter Windows kommt keine Verbindung zustande.** Nimm curl.exe
  direkt in Windows, nicht in der WSL.
{{ zusatz.fehler }}

## Notweg: Hochladen mit curl

Nur wenn das Hochladen im Browser nicht klappt. Du brauchst dafür das
Programm **curl**. Unter Linux und macOS ist es meist schon da, unter
Windows 10 und 11 heißt es `curl.exe` und ist eingebaut
([curl benutzen](grundlagen/curl.md)).

1. **Router wieder in die Recovery bringen** wie in Schritt 4 und 5, aber
   dort nichts hochladen.
{{ curl_schritte(2) }}

Danach weiter mit Schritt {% if w.datei_art == "rampe" %}8{% else %}8 ("Fertig"){% endif %} oben.
  {%- if b.get("curl-ausgabe") %}

![curl in der PowerShell: oben ein Fehlversuch mit "Failed to connect" und 0 Bytes, unten ein vollständiger Upload mit 50.00M bei 100 %]({{ b["curl-ausgabe"] }})
  {%- endif %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
