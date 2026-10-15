{#-
Vorlage tplink-eap-ssh (TP-Link EAP225-Outdoor v1/v3, EAP225-Wall v2,
EAP613 v1, EAP615-Wall v1): Per SSH an der TP-Link-Firmware anmelden,
`cliclientd stopcs` ausführen, dann das factory-Image über die
Weboberfläche hochladen.

Weg: OpenWrt-Commits 4f86edf (EAP225-Outdoor v1, Firmware ab v1.6.0,
getestet v1.7.0), 7e4de89 (EAP225-Outdoor v3), c9f51a9 (EAP225-Wall v2,
getestet 1.20.0), 11588c5 (EAP613 v1: SSH in der Weboberfläche einschalten,
Dateinamen ggf. auf factory.bin kürzen), a1b8a4d (EAP615-Wall v1).
Adresse 192.168.0.254 und admin/admin: TP-Link-Werkszustand ohne DHCP
(abgeleitet, nicht in den Commits). Den kurzen Dateinamen nimmt die Vorlage
für alle Geräte, das schadet nicht.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken), alle optional:
    stock_min            Mindestversion der TP-Link-Firmware, z. B. "1.6.0"
    stock_getestet       Version, mit der OpenWrt es ausprobiert hat
    strom                Stromversorgung, wenn nicht nur PoE, z. B. "über PoE
                         oder ein 12-V-Netzteil"
    sicherheit, sicherheit_hinweis   siehe _status.md
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Die Weboberfläche von TP-Link nimmt die Freifunk-Firmware an, aber erst,
nachdem du per SSH einen einzigen Befehl auf dem Gerät ausgeführt hast. Der
Weg hat also drei kurze Teile: SSH einschalten, den Befehl ausführen, die
Firmware hochladen. Rechne mit einer halben Stunde.

## Was du brauchst

- den Access Point und Strom
  {%- if w.get("strom") %} {{ w.get("strom") }}{% else %} über PoE, also
  einen PoE-Injektor oder PoE-Switch{% endif %}
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- `ssh` ([SSH und scp benutzen](grundlagen/ssh-scp.md))
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **factory**-Image. Benenn es in **`factory.bin`** um. Manche dieser Geräte
  lehnen lange Dateinamen ab.
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Rechner anschließen.** Stell deinen Rechner auf die feste Adresse
   `192.168.0.10`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Verbinde ihn
   mit dem Access Point (bei PoE: mit dem LAN-Anschluss des Injektors) und
   schalte den Access Point ein. Warte zwei Minuten.

2. **Weboberfläche öffnen.** Öffne `http://192.168.0.254` und melde dich an.
   Im Werkszustand heißt der Benutzer `admin` mit Passwort `admin`; danach
   verlangt das Gerät einen neuen Benutzernamen und ein neues Passwort.
   Merk sie dir.
   {%- if w.get("stock_min") %}

   **Prüfen:** Die TP-Link-Firmware muss mindestens Version
   **{{ w.get("stock_min") }}** sein
   {%- if w.get("stock_getestet") %} (OpenWrt hat es mit
   {{ w.get("stock_getestet") }} ausprobiert){% endif %}. Ist sie älter, spiel
   zuerst über dieselbe Oberfläche eine neuere TP-Link-Firmware ein
   (Download bei TP-Link für genau dein Modell und deine Hardware-Version).
   {%- endif %}

3. **SSH einschalten.** Such in der Weboberfläche den Punkt für SSH (je nach
   Firmware unter "Management" oder "System") und schalte SSH ein.
   Speichern.

4. **Den Befehl ausführen.** Im Terminal auf deinem Rechner, mit dem
   Benutzernamen aus Schritt 2 statt `admin`:

   ```
   ssh admin@192.168.0.254
   ```

   Meldet `ssh` "no matching host key type found" oder etwas Ähnliches,
   siehe [SSH und scp benutzen](grundlagen/ssh-scp.md). Auf dem Gerät gibst
   du dann ein:

   ```
   cliclientd stopcs
   ```

   Danach mit `exit` abmelden. Ohne diesen Befehl lehnt die Weboberfläche
   die Freifunk-Firmware ab.

5. **Freifunk-Firmware hochladen.** Geh in der Weboberfläche zum
   Firmware-Update, wähl `factory.bin` aus und starte das Update. Der Access
   Point schreibt die Freifunk-Firmware und startet neu, einige Minuten.
   **Strom nicht ziehen.**

6. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet
   die Freifunk-Firmware deiner Community: je nach Community zuerst mit
   einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im
   Betrieb.

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 nimmt das Gerät die SSH-Anmeldung an.
- In Schritt 5 nimmt die Weboberfläche `factory.bin` an und zeigt den
  Fortschritt.
- Nach Schritt 6 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **`http://192.168.0.254` antwortet nicht.** Prüf die feste Adresse am
  Rechner und ob der Access Point Strom hat. Wurde er schon einmal in ein
  Netz mit DHCP eingebunden, hat er dort vielleicht eine andere Adresse
  bekommen. Dann setz ihn auf Werkseinstellungen zurück (Reset-Taste, wie
  in der Anleitung von TP-Link beschrieben).
- **Die Weboberfläche lehnt `factory.bin` ab.** Lief Schritt 4 wirklich
  durch? Nach einem Neustart des Geräts musst du ihn vermutlich
  wiederholen.
  {%- if w.get("stock_min") %} Prüf auch die Version der TP-Link-Firmware
  (Schritt 2).{% endif %}
- **Nach dem Update startet nichts mehr.** Zurück geht es bei diesen Geräten
  nur noch über die serielle Konsole im Gehäuse, und dafür muss man löten.
  Schreib uns.
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

## Zurück zur TP-Link-Firmware

Einen einfachen Weg zurück gibt es nicht. Laut OpenWrt geht es nur über die
serielle Konsole, für die man im Gehäuse an Lötpunkte muss.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
