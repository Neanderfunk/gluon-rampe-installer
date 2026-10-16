{#-
Vorlage avm-eva-ramboot (AVM lantiq: Gluon-RAMpe per EVA in den
Arbeitsspeicher laden, dort das Community-sysupgrade hochladen). Entwurf
Content, 15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz, herkunft, broken.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    rampe_url            Direktlink auf die RAMpe (…-initramfs-kernel.bin)
    rampe_datei          Dateiname dazu

  optional
    rechner_ip           feste Adresse des Rechners (leer = 192.168.178.10)
    ersatz_ip            Adresse, unter der die Box sonst antworten kann (169.254.120.1)
    led_rampe            ganzer Satz, woran man die laufende RAMpe erkennt
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set rip = w.rechner_ip if w.rechner_ip else "192.168.178.10" -%}
{%- set eva = "https://raw.githubusercontent.com/openwrt/openwrt/a1ea57bd050c172fdc2b851824ebd9782aafb055/scripts/flashing/eva_ramboot.py" -%}
# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Der Bootloader von AVM nimmt in den ersten Sekunden nach dem Einschalten
Verbindungen per FTP an ([Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md)).
Darüber kommt zuerst die **Gluon-RAMpe** in den Arbeitsspeicher: eine kleine
Firmware, die nur eins kann, nämlich die Freifunk-Firmware deiner Community
annehmen. Die lädst du dann im Browser hoch.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel; ein einfacher Switch dazwischen hilft beim Timing
- Python 3 und das kleine Programm
  [eva_ramboot.py]({{ eva }}) von OpenWrt
- die RAMpe für dieses Gerät:
  [{{ w.rampe_datei }}]({{ w.rampe_url }})
- die Freifunk-Firmware deiner Community für dieses Gerät, und zwar das
  **sysupgrade**-Image
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Rechner vorbereiten.** Feste Adresse `{{ rip }}`, Netzmaske
   `255.255.255.0` ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
   WLAN am Rechner aus. Leg eva_ramboot.py und die RAMpe in einen Ordner und
   öffne dort ein Terminal.

2. **Verbinden.** Kabel vom Rechner an eine LAN-Buchse der Box, wenn
   vorhanden über einen einfachen Switch.

3. **Den richtigen Firmware-Speicher wählen.** Die Box hat zwei Speicher für
   die Firmware. Damit die Freifunk-Firmware später auch startet, muss der
   erste gewählt sein. Strom an der Box ziehen, wieder einstecken und
   **sofort**:

   ```
   python3 -c "from ftplib import FTP; f=FTP('192.168.178.1','adam2','adam2'); print(f.sendcmd('SETENV linux_fs_start 0'))"
   ```

   Kommt eine Fehlermeldung, war das Zeitfenster vorbei: Strom ziehen und
   noch einmal. Geklappt hat es, wenn eine Antwort mit `200` kommt.

4. **RAMpe laden.** Strom an der Box noch einmal ziehen, wieder einstecken
   und nach wenigen Sekunden:

   ```
   python3 eva_ramboot.py 192.168.178.1 {{ w.rampe_datei }}
   ```

   Das Programm zeigt, was es mit der Box bespricht, und endet von selbst.
   Kommt eine Fehlermeldung, Strom ziehen und noch einmal.

5. **Die RAMpe.** Die Box startet jetzt die RAMpe aus dem Arbeitsspeicher.
   {%- if w.led_rampe %} {{ w.led_rampe }}{% endif %} Stell den Rechner auf
   "automatisch" und öffne nach etwa einer Minute
   `http://192.168.1.1/cgi-bin/config`. Es erscheint die Seite "Firmware
   aktualisieren". Kommt "Not Found", hat sich der Browser eine Seite von
   früher gemerkt: Tipp die Adresse vollständig ein, mit `/cgi-bin/config` am
   Ende.
   {%- if b.get("rampe-seite") %}

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"]({{ b["rampe-seite"] }})
   {%- endif %}

   Die RAMpe läuft nur im Arbeitsspeicher. Geht der Strom aus, ist sie weg:
   dann wieder ab Schritt 4.

6. **Freifunk-Firmware hochladen.** Wähl das sysupgrade-Image deiner
   Community und klick "Datei hochladen". Die RAMpe zeigt die Prüfsumme
   (SHA256); vergleich sie mit der Angabe deiner Community und klick
   "Fortfahren".
   {%- if b.get("rampe-pruefsumme") %}

   ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"]({{ b["rampe-pruefsumme"] }})
   {%- endif %}

7. **Fertig.** Die Box schreibt die Firmware und startet neu, **Strom nicht
   ziehen**. Der erste Start kann etwas länger dauern. Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- Schritt 3 antwortet mit `200`.
- Nach Schritt 4 erscheint unter `http://192.168.1.1` die Seite der RAMpe.
- Nach Schritt 7 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Box antwortet nicht.** Das Zeitfenster ist kurz. Einen einfachen
  Switch zwischen Box und Rechner stecken, WLAN am Rechner aus, und noch
  einmal.
{%- if w.ersatz_ip %}
- **Die Box antwortet nicht unter `192.168.178.1`.** Nach einem
  Firmware-Update oder einer Wiederherstellung hört sie manchmal auf
  `{{ w.ersatz_ip }}`. Dann diese Adresse in den Befehlen verwenden und den
  Rechner auf eine Adresse im selben Netz stellen.
{%- endif %}
- **Nach Schritt 7 startet wieder FRITZ!OS.** Dann stand der
  Firmware-Speicher noch auf dem zweiten. Schritt 3 wiederholen, dann ab
  Schritt 4 noch einmal.
- **Unter `http://192.168.1.1` kommt eine Zertifikatswarnung.** Siehe
  [Browser macht https daraus](grundlagen/browser-https.md).
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
