{#-
Vorlage avm-eva-uboot (FRITZ!Box 7520/7530, FRITZ!Repeater 1200/3000):
OpenWrt-U-Boot per EVA in den RAM, RAMpe per TFTP, auf der RAMpe-Seite
Vorbereitung (U-Boot in den Flash, FRITZ!OS entfernen) und sysupgrade.
Entwurf Content, 15.10.2026, nach Angaben Buildsystem (RAMpe 5b99784 ff.).

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz, herkunft, broken.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    uboot_datei          Dateiname des OpenWrt-U-Boot, z. B. uboot-fritz7530.bin
    uboot_url            Direktlink darauf
    tftp_name            Name, unter dem der TFTP-Server die RAMpe anbietet, z. B. FRITZ7530.bin
    rampe_url            Direktlink auf die RAMpe (…-initramfs-uImage.itb)
    rampe_datei          Dateiname dazu
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set eva = "https://raw.githubusercontent.com/openwrt/openwrt/a1ea57bd050c172fdc2b851824ebd9782aafb055/scripts/flashing/eva_ramboot.py" -%}
# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

> **Danach ist FRITZ!OS weg.** Bei diesem Gerät ersetzt die Installation den
> Bootloader und entfernt die Firmware von AVM. Zurück geht es danach nur
> noch mit dem Wiederherstellungs-Programm von AVM (siehe unten).

Bei diesem Gerät geht es in drei Etappen, alle vom Rechner aus und ohne das
Gerät zu öffnen:

1. Über den Bootloader von AVM kommt ein neuer Bootloader (U-Boot) in den
   Arbeitsspeicher ([Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md)).
2. Der holt sich per TFTP die **Gluon-RAMpe**: eine kleine Firmware, die nur
   eins kann, nämlich die Freifunk-Firmware deiner Community annehmen.
3. Auf der Seite der RAMpe lädst du die Freifunk-Firmware hoch. Die RAMpe
   bereitet den Speicher vor und schreibt dann die Freifunk-Firmware.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- Python 3 und das kleine Programm [eva_ramboot.py]({{ eva }}) von OpenWrt
- einen TFTP-Server auf dem Rechner ([TFTP-Server einrichten](grundlagen/tftp-server.md))
- den Bootloader für dieses Gerät: [{{ w.uboot_datei }}]({{ w.uboot_url }})
- die RAMpe für dieses Gerät: [{{ w.rampe_datei }}]({{ w.rampe_url }})
- die Freifunk-Firmware deiner Community für dieses Gerät, und zwar das
  **sysupgrade**-Image
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Dateien bereitlegen.** eva_ramboot.py und `{{ w.uboot_datei }}` in einen
   Ordner, dort ein Terminal öffnen. Die RAMpe in den Ordner des
   TFTP-Servers legen und **genau in `{{ w.tftp_name }}` umbenennen**.

2. **Rechner vorbereiten.** Feste Adresse `192.168.178.10`, Netzmaske
   `255.255.255.0` ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
   WLAN am Rechner aus. Kabel an eine LAN-Buchse des Geräts.

3. **Bootloader laden.** Strom an das Gerät, und sobald der Rechner eine
   Netzwerkverbindung anzeigt:

   ```
   python3 eva_ramboot.py --offset 0x85000000 192.168.178.1 {{ w.uboot_datei }}
   ```

   Kommt eine Fehlermeldung, war das Zeitfenster vorbei: Strom ziehen und
   noch einmal.

4. **RAMpe per TFTP.** Stell den Rechner jetzt um auf die feste Adresse
   `192.168.1.70`, Netzmaske `255.255.255.0`, und starte den TFTP-Server.
   Der neue Bootloader fragt alle 5 Sekunden nach `{{ w.tftp_name }}`; der
   TFTP-Server zeigt, wenn die Datei abgeholt wird. Danach startet die RAMpe
   aus dem Arbeitsspeicher. Das dauert bis zu 2 Minuten.

5. **Die Seite der RAMpe.** Öffne `http://192.168.1.1/cgi-bin/config` (der
   Rechner kann auf `192.168.1.70` bleiben). Kommt "Not Found", hat sich der
   Browser eine Seite von früher gemerkt: Tipp die Adresse vollständig ein,
   mit `/cgi-bin/config` am Ende. Hilft das nicht, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Die Seite weist darauf hin, dass sie bei diesem
   Gerät den Speicher vorbereitet, den neuen Bootloader dauerhaft schreibt
   und die Firmware von AVM entfernt.
   {%- if b.get("rampe-seite") %}

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"]({{ b["rampe-seite"] }})
   {%- endif %}

6. **Freifunk-Firmware hochladen.** Wähl das sysupgrade-Image deiner
   Community und klick "Datei hochladen". Die RAMpe zeigt die Prüfsumme
   (SHA256); vergleich sie mit der Angabe deiner Community und klick
   "Fortfahren".
   {%- if b.get("rampe-pruefsumme") %}

   ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"]({{ b["rampe-pruefsumme"] }})
   {%- endif %}

7. **Warten.** Die RAMpe schreibt zuerst den Bootloader, entfernt die
   Firmware von AVM und schreibt dann die Freifunk-Firmware. **Strom nicht
   ziehen.**

8. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

Tipp für Linux: Mit `ip addr add` kannst du dem Netzwerkanschluss beide
Adressen gleichzeitig geben (`192.168.178.10/24` und `192.168.1.70/24`);
dann entfällt das Umstellen in Schritt 4.

## Woran du erkennst, dass es geklappt hat

- eva_ramboot.py endet ohne Fehlermeldung.
- Der TFTP-Server zeigt, dass `{{ w.tftp_name }}` abgeholt wurde.
- Unter `http://192.168.1.1` erscheint die Seite der RAMpe.
- Nach Schritt 7 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **eva_ramboot.py bekommt keine Verbindung.** Das Zeitfenster ist kurz.
  Strom ziehen, einstecken, sofort noch einmal. Ein einfacher Switch zwischen
  Gerät und Rechner hilft. Laut OpenWrt nehmen manche Geräte beim Start auch
  `192.168.1.1` statt `192.168.178.1`.
- **Der TFTP-Server meldet keine Anfrage.** Prüf die Adresse
  `192.168.1.70`, die Firewall und den Dateinamen `{{ w.tftp_name }}` (genau
  so, Groß- und Kleinschreibung zählt).
- **Die RAMpe meldet "Die Vorbereitung dieses Geräts ist fehlgeschlagen. Die
  Freifunk-Firmware wurde nicht aufgespielt."** Dann wurde nichts
  geschrieben. Schick uns bitte das Protokoll, das darunter steht, an
  [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de).
- **Nach einem Abbruch startet das Gerät mit dem neuen Bootloader, aber ohne
  Freifunk-Firmware.** Dann einfach ab Schritt 4 noch einmal: Der neue
  Bootloader fragt beim Start wieder per TFTP nach der RAMpe.
{{ zusatz.fehler }}

## Zurück zu FRITZ!OS

Der Bootloader von AVM selbst bleibt unberührt. Mit dem
Wiederherstellungs-Programm von AVM (für Windows; auf dem Download-Server von
AVM im Ordner des Geräts unter "recover") lässt sich FRITZ!OS zurückspielen.
Laut OpenWrt hilft im Notfall die Version FRITZ!OS 7.21.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
