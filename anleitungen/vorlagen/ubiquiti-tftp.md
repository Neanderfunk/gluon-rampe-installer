{#-
Vorlage ubiquiti-tftp (Ubiquiti-TFTP-Recovery: Reset beim Einschalten, das
Gerät wird zum TFTP-Server, das factory-Image wird per TFTP hochgeladen).
Entwurf Content, 15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    geraet_ip            Adresse des Geräts im TFTP-Modus, z. B. 192.168.1.20
    rechner_ip           feste Adresse für den Rechner, z. B. 192.168.1.21
    taste                nach "Halte sie gedrückt:", z. B. "bis die Signal-LEDs
                         abwechselnd blinken (erst LED 1 und 3, dann LED 2 und 4);
                         das kann bis zu 25 Sekunden dauern" oder "10 Sekunden"

  optional (leer = Satz entfällt bzw. allgemeiner Satz)
    taste_ort            wo die Reset-Taste ist, z. B. "am Gerät oder am PoE-Netzteil"
    kabel_am_geraet      true: zum Einschalten das Kabel am Gerät abziehen und
                         wieder einstecken (statt den Injektor aus- und einzustecken)
    led_schreiben        was die LEDs beim Schreiben tun, z. B. "laufen die
                         Signal-LEDs der Reihe nach durch"
    dauer                z. B. "etwa 2 Minuten" (leer = "einige Minuten")
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- if status == "ungeprüft" %}
> **Noch nicht am Gerät erprobt.** Diese Anleitung ist aus Quellen
> zusammengestellt, aber noch niemand hat sie an einem {{ modell }} Schritt
> für Schritt nachvollzogen. Wenn du es tust: Schreib uns an
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de), ob es geklappt hat.
{%- else %}
> **Am Gerät erprobt** am {{ erprobt_am }} mit `{{ erprobt_mit }}`.
{%- endif %}

# {{ modell }}: Freifunk-Firmware installieren

Ubiquiti-Geräte haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, wartet das Gerät darauf, dass ihm jemand eine
Firmware per **TFTP** schickt. Genau darüber kommt die Freifunk-Firmware
drauf. Du brauchst dafür ein kleines Programm auf dem Rechner, den
TFTP-Client ([TFTP-Client benutzen](grundlagen/tftp-client.md)), und eine
feste Adresse am Rechner.

## Was du brauchst

- das Gerät mit seinem PoE-Netzteil (PoE-Injektor)
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- eine Büroklammer für die Reset-Taste
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"
- einen TFTP-Client ([TFTP-Client benutzen](grundlagen/tftp-client.md))
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter und benenne es in
   einen kurzen Namen um, zum Beispiel `factory.bin`. Einen bestimmten Namen
   verlangt das Gerät nicht, ein kurzer erspart aber Tippfehler.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf die feste Adresse
   `{{ w.rechner_ip }}` mit der Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Nicht
   `{{ w.geraet_ip }}`, die braucht das Gerät.

3. **Verbinden.** Steck das Kabel vom Rechner an die Buchse **LAN** des
   PoE-Injektors. Die Buchse **PoE** des Injektors geht zum Gerät.

4. **Gerät in den TFTP-Modus bringen.**
   {%- if w.kabel_am_geraet %} Zieh das Kabel am Gerät ab. Drück mit der
   Büroklammer die Reset-Taste{% if w.taste_ort %} ({{ w.taste_ort }}){% endif %}
   und halte sie gedrückt. Steck das Kabel wieder ein.
   {%- else %} Zieh den Injektor aus der Steckdose. Drück mit der Büroklammer
   die Reset-Taste{% if w.taste_ort %} ({{ w.taste_ort }}){% endif %} und
   halte sie gedrückt. Steck den Injektor wieder ein.
   {%- endif %}
   Halte die Taste weiter gedrückt: {{ w.taste }}. Dann loslassen.

5. **Firmware schicken.** Öffne ein Terminal im Ordner mit der Datei und
   schick sie an das Gerät.

   Linux und macOS:

   ```
   tftp {{ w.geraet_ip }}
   binary
   put factory.bin
   quit
   ```

   Windows (Eingabeaufforderung "cmd", TFTP-Client muss eingeschaltet sein):

   ```
   tftp -i {{ w.geraet_ip }} PUT factory.bin
   ```

   Die Übertragung dauert nur Sekunden.

6. **Warten.** Das Gerät schreibt die Firmware und startet neu
   {%- if w.led_schreiben %}; dabei {{ w.led_schreiben }}{% endif %}. Das
   dauert {% if w.dauer %}{{ w.dauer }}{% else %}einige Minuten{% endif %}.
   **Strom nicht ziehen, solange die LEDs laufen.**

7. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb. Wie
   es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 zeigen die LEDs, dass der TFTP-Modus erreicht ist.
- Der TFTP-Client meldet die Übertragung ohne Fehler.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Der TFTP-Client meldet eine Zeitüberschreitung.** Das Gerät war nicht im
  TFTP-Modus oder die Adresse am Rechner stimmt nicht. Prüf Schritt 2 und
  bring das Gerät noch einmal in den TFTP-Modus. Unter Windows kann auch die
  Firewall stören.
- **Das Gerät nimmt die Datei an, startet aber wieder mit der alten
  Firmware.** Vermutlich passt das Image nicht zur Hardware (siehe "Vorher
  prüfen"), oder die Herstellerfirmware ist zu neu.
{{ zusatz.fehler }}

## Zurück zur Ubiquiti-Firmware

Derselbe Weg geht auch rückwärts: Gerät wie in Schritt 4 in den TFTP-Modus
bringen und statt der Freifunk-Firmware die Original-Firmware von Ubiquiti
schicken, möglichst genau die Version, die vorher drauf war.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
