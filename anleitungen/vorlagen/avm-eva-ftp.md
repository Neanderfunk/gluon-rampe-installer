{#-
Vorlage avm-eva-ftp (AVM: Gluon-Image per EVA-FTP direkt in den Speicher,
mit fritzflash.py oder von Hand). Entwurf Content, 15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz, herkunft, broken.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken), alle optional:
    datei_art            "sysupgrade" (Vorgabe) oder "bootloader" (4040: Gluon-…-bootloader.bin)
    rechner_ip           feste Adresse des Rechners (leer = 192.168.178.2)
    ftp_befehle          Liste: wenn gesetzt, ist der Weg von Hand per FTP der
                         Hauptweg (z. B. 3370 mit zwei Dateien), fritzflash.py entfällt;
                         Zeilen mit "# " werden zu "Prüfen:"-Sätzen wie bei UniFi
    led_schreiben        ganzer Satz, was die LEDs beim Schreiben/fertig zeigen
    ersatz_ip            Adresse, unter der die Box sonst antworten kann (z. B. 169.254.157.1)
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set art = w.datei_art if w.datei_art else "sysupgrade" -%}
{%- set rip = w.rechner_ip if w.rechner_ip else "192.168.178.2" -%}
# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

AVM-Geräte haben einen Bootloader, der in den ersten Sekunden nach dem
Einschalten Verbindungen per FTP annimmt. Darüber kommt die
Freifunk-Firmware direkt in den Speicher. Eine Taste brauchst du nicht, nur
das richtige Timing. Wie der Bootloader funktioniert, steht unter
[Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md).

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel; ein einfacher Switch dazwischen hilft beim Timing
{%- if w.ftp_befehle %}
- einen Rechner mit Linux oder macOS (für `ftp`)
{%- else %}
- Python 3 und das Programm
  [fritzflash.py](https://github.com/freifunk-darmstadt/fritz-tools)
{%- endif %}
{%- set eva = w.ftp_befehle and (w.ftp_befehle | join(" ")).find("-eva-kernel") >= 0 %}
- die Freifunk-Firmware deiner Community für dieses Gerät,
  {%- if art == "bootloader" %} und zwar das Image mit **„-bootloader.bin“**
  am Ende, nicht das sysupgrade. Im Firmware-Selector wählst du dafür unter
  "Wähle Deine Installationsart" den Knopf **Bootloader-Image**.
  {%- elif eva %} und zwar zwei Dateien, die in Schritt 4 genannt sind. Im
  Firmware-Selector findest du sie unter "Wähle Deine Installationsart": die
  Datei auf `-eva-kernel.bin` beim Knopf **Bootloader-Kernel-Image**, die
  Datei auf `-eva-filesystem.bin` beim Knopf **Bootloader-Root-Image**.
  {%- elif w.ftp_befehle %} die Dateien, die in Schritt 4 genannt sind
  {%- else %} und zwar das **sysupgrade**-Image. Das ist hier richtig, auch
  für die erste Installation.{% endif %}
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Rechner vorbereiten.** Feste Adresse `{{ rip }}`, Netzmaske
   `255.255.255.0`, Gateway `192.168.178.1`, kein DNS
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). WLAN am Rechner
   aus.

2. **Verbinden.** Kabel vom Rechner an die **gelbe LAN-Buchse** der Box
   (wenn vorhanden über einen einfachen Switch). Die Box bleibt vorerst aus
   bzw. läuft noch, das ist egal.
{%- if w.ftp_befehle %}

3. **Box einschalten und sofort verbinden.** Strom ziehen, wieder einstecken
   und sofort:

   ```
   ftp 192.168.178.1
   ```

   Benutzer `adam2`, Passwort `adam2`. Klappt es nicht innerhalb weniger
   Sekunden, Strom ziehen und noch einmal.

4. **Befehle eingeben,** einzeln und genau so:
{%- set ns = namespace(block=[]) %}
{%- for z in w.ftp_befehle %}
{%- if z.startswith("# ") %}
{%- if ns.block %}

   ```
{%- for y in ns.block %}
   {{ y }}
{%- endfor %}
   ```
{%- set ns.block = [] %}
{%- endif %}

   **Prüfen:** {{ z[2:] }} Sonst hier aufhören.
{%- else %}
{%- set ns.block = ns.block + [z] %}
{%- endif %}
{%- endfor %}
{%- if ns.block %}

   ```
{%- for y in ns.block %}
   {{ y }}
{%- endfor %}
   ```
{%- endif %}

5. **Warten,** bis der letzte Befehl durch ist.{% if w.led_schreiben %} {{ w.led_schreiben }}{% endif %}
   Startet die Box nicht von selbst neu: Strom aus und wieder an.
{%- else %}

3. **fritzflash.py starten.** Leg das Image in denselben Ordner wie
   fritzflash.py und starte im Terminal:

   ```
   python3 fritzflash.py --image <Freifunk-Image>
   ```

4. **Box neu starten, wenn das Programm es sagt.** Enter drücken, dann den
   Strom an der Box ziehen und wieder einstecken. fritzflash.py sucht die Box
   und schreibt die Firmware.

5. **Warten.** Während des Schreibens leuchtet die rote Info-LED. Das ist
   normal. **Strom nicht ziehen.** Das dauert bis zu 2 Minuten.
   {%- if w.led_schreiben %} {{ w.led_schreiben }}{% endif %}
   Danach startet die Box neu.
{%- endif %}

6. **Fertig.** Stell den Rechner wieder auf "automatisch". Nach 2 bis 5
   Minuten startet die Freifunk-Firmware deiner Community: je nach Community
   zuerst mit einer Einrichtungsseite unter `http://192.168.1.1` oder gleich
   im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- {% if w.ftp_befehle %}Die Befehle laufen ohne Fehlermeldung durch.{% else %}fritzflash.py meldet am Ende, dass das Schreiben geklappt hat.{% endif %}
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Box antwortet nicht.** Das Zeitfenster ist kurz. Einen einfachen
  Switch zwischen Box und Rechner stecken, WLAN am Rechner aus, und noch
  einmal: Strom ziehen, einstecken, sofort verbinden.
{%- if w.ersatz_ip %}
- **Die Box antwortet unter einer anderen Adresse.** Manche Geräte hören im
  Bootloader auf `{{ w.ersatz_ip }}` statt `192.168.178.1`.
{%- endif %}
{{ zusatz.fehler }}

## Zurück zu FRITZ!OS

AVM hat für jedes Gerät ein Wiederherstellungs-Programm (für Windows), das
die Original-Firmware zurückspielt. Es liegt auf dem Download-Server von AVM
im Ordner des Geräts unter "recover". Geräte von Providern (zum Beispiel
1&1) verweigern das eventuell; dann vorher per FTP
`quote UNSETENV provider` ([Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md)).

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
