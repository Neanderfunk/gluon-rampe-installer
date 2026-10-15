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
    luci_buchse          Buchse für Schritt 7, z. B. "den Port „1Gbps LAN“"
    force_upgrade        true: LuCI braucht laut OpenWrt "Force upgrade"
    rueckweg_buchse      Buchse für die Recovery, leer = "eine LAN-Buchse"
    rueckweg_halten      z. B. "mindestens 8 Sekunden"
    rueckweg_quelle      woher die Cudy-Firmware kommt, leer = Cudys Download-Seite
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
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

### Teil 1: Zwischenfirmware von Cudy

1. **Dateien bereitlegen.** Lade die Zwischenfirmware und das
   sysupgrade-Image herunter und leg sie in einen Ordner, den du
   wiederfindest.

2. **Verbinden.** Versorg den Router mit Strom und steck den Rechner per
   Kabel an eine **LAN**-Buchse. Der Rechner holt sich seine Adresse
   automatisch, so wie er normalerweise eingestellt ist.

3. **Cudy-Oberfläche öffnen.** Öffne im Browser `http://{{ w.cudy_ip }}` und
   melde dich mit dem Passwort `admin` an. Beim ersten Mal fragt der Router
   einige Einstellungen ab: alles mit "Weiter" bestätigen, am Ende
   speichern.

4. **Zwischenfirmware hochladen.** Geh zu **Erweiterte Einstellungen →
   System → Firmware** und wähl die Zwischenfirmware aus. Die Bezeichnungen
   können je nach Modell und Alter der Cudy-Firmware etwas anders heißen.
   {%- if b.get("cudy-firmware-seite") %}

   ![Die Firmware-Seite der Cudy-Oberfläche]({{ b["cudy-firmware-seite"] }})
   {%- endif %}

5. **Prüfsumme vergleichen.** Nach dem Hochladen zeigt der Router eine
   MD5-Prüfsumme.
   {%- if w.zwischen_md5 %} Sie muss genau so aussehen:

   ```
   {{ w.zwischen_md5 }}
   ```

   Stimmt sie, klick auf **Fortfahren**.
   {%- else %} Vergleich sie mit der Prüfsumme, die an der Download-Stelle
   steht. Stimmt sie, klick auf **Fortfahren**.
   {%- endif %}

6. **Warten.** Der Router schreibt die Zwischenfirmware und startet neu. Das
   dauert einige Minuten. **Strom nicht ziehen.**

### Teil 2: Freifunk-Firmware

7. **OpenWrt-Oberfläche öffnen.**
   {%- if w.luci_buchse %} Steck das Kabel jetzt an {{ w.luci_buchse }}.{% endif %}
   Öffne `http://192.168.1.1`. Es erscheint die Anmeldung von OpenWrt
   ("LuCI"). Das Passwort-Feld bleibt leer, einfach anmelden.

8. **Freifunk-Firmware auswählen.** Geh zu **System → Backup / Firmware
   Update** (englisch "Backup / Flash Firmware"). Ganz unten unter "Firmware
   aktualisieren" (englisch "Flash image…") wählst du das sysupgrade-Image
   deiner Community aus.

9. **Einstellungen nicht behalten.** Bevor es losgeht, zeigt OpenWrt ein
   Fenster mit einem Haken bei **"Einstellungen beibehalten"** (englisch
   "Keep settings"). **Entfern diesen Haken.** Es darf kein Haken mehr
   gesetzt sein.
   {%- if w.force_upgrade %}
   Meldet OpenWrt, dass das Image nicht zum Gerät passt, obwohl du sicher die
   Datei für den {{ modell }} hast, setz zusätzlich den Haken bei
   "Upgrade erzwingen" (englisch "Force upgrade"). Bei diesem Modell ist das
   laut OpenWrt nötig, weil die Zwischenfirmware das Gerät anders benennt.
   {%- endif %}
   Dann **Fortfahren**.

10. **Fertig.** Der Router schreibt die Freifunk-Firmware und startet neu,
    wieder einige Minuten, Strom nicht ziehen. Danach startet die
    Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
    Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb. Wie
    es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- Nach Schritt 5 stimmt die Prüfsumme genau.
- Nach Schritt 6 zeigt `http://192.168.1.1` die Anmeldung von OpenWrt.
- Nach Schritt 10 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Prüfsumme stimmt nicht.** Nicht fortfahren. Lad die Datei neu herunter
  und prüf, ob es die für dein Modell und deine Version ist.
- **Die Cudy-Oberfläche nimmt die Datei nicht an.** Meist ist es die
  Zwischenfirmware eines anderen Modells oder einer anderen Version. Vergleich
  noch einmal mit dem Aufkleber.
- **Nach Schritt 6 antwortet `http://192.168.1.1` nicht.** Steck das Kabel in
  eine andere Buchse. Bei manchen Modellen tauschen LAN und WAN nach dem
  Wechsel auf OpenWrt die Rolle.
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

1. Lade die Cudy-Firmware für dein Modell
   {%- if w.rueckweg_quelle %} {{ w.rueckweg_quelle }}{% else %} von der
   Download-Seite von Cudy{% endif %} herunter, benenne sie in
   `recovery.bin` um (genau so) und leg sie in den Ordner des TFTP-Servers.
2. Stell deinen Rechner fest auf `192.168.1.88`, Netzmaske `255.255.255.0`,
   und starte den TFTP-Server.
3. Steck das Kabel an
   {%- if w.rueckweg_buchse %} {{ w.rueckweg_buchse }}{% else %} eine
   LAN-Buchse{% endif %}. Der Router hat noch keinen Strom.
4. Drück die Reset-Taste und halte sie gedrückt, steck den Strom ein und halte
   weiter{% if w.rueckweg_halten %} ({{ w.rueckweg_halten }}){% endif %}, bis
   alle LEDs schnell blinken oder der TFTP-Server den Download zeigt. Dann
   loslassen.
5. Blinken die LEDs langsam, ist der Router fertig. Danach den Rechner wieder
   auf "automatisch" stellen; die Cudy-Oberfläche ist unter
   `http://{{ w.cudy_ip }}` erreichbar.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
