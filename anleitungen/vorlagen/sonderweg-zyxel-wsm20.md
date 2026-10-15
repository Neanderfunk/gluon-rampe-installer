{#-
Vorlage sonderweg-zyxel-wsm20 (nur Zyxel Multy M1 / WSM20): versteckte
Upgrade-Seite der Zyxel-Firmware nimmt ein initramfs, danach sysupgrade
über LuCI. Entwurf Content, 15.10.2026. Quellen: Freifunk Aachen
(Stefan Limbach, 04.01.2024, im Original gelesen 15.10.2026), OpenWrt-Commit
28df7f7, OpenWrt-Wiki toh:zyxel:wsm20; adorfer hat so ein Gerät installiert.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz, herkunft, broken.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    openwrt_datei        Dateiname des OpenWrt-initramfs-kernel für den WSM20
    openwrt_url          Download-Adresse dazu

  RAMpe als zweiter Weg (siehe _rampe.md, alles optional)
    rampe_url            Direktlink auf die RAMpe
    rampe_datei          Dateiname dazu
    rampe_weg            ganzer Satz, wie die RAMpe statt OpenWrt aufs Gerät kommt
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Die Firmware von Zyxel hat eine versteckte Seite, über die sich eine andere
Firmware hochladen lässt. Darüber kommt zuerst OpenWrt in den
Arbeitsspeicher, und von dort aus spielst du die Freifunk-Firmware ein. Du
brauchst nur einen Browser, aber etwas Geduld: Die versteckte Seite ist
manchmal zickig.

Ein Konto in der Zyxel-Cloud brauchst du dafür nicht.

## Was du brauchst

- den Multy M1 mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- OpenWrt für den WSM20 (nur für den Arbeitsspeicher):
  [{{ w.openwrt_datei }}]({{ w.openwrt_url }})
- die Freifunk-Firmware deiner Community für dieses Gerät, und zwar das
  **sysupgrade**-Image
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

### Teil 1: OpenWrt in den Arbeitsspeicher

1. **Verbinden.** Steck das Kabel vom Rechner in die Buchse **LAN1** des
   WSM20. Kein Internet-Anschluss, nur der Rechner. Der Rechner holt sich
   seine Adresse automatisch.

2. **Einschalten und auf die LED achten.** Strom an. Die LED leuchtet erst
   türkis, blinkt dann türkis und schließlich grün, jeweils etwa zweimal pro
   Sekunde. Dann ist das Gerät bereit.
   Leuchtet sie stattdessen **dauerhaft rot**, war das Gerät schon
   eingerichtet und meldet nur, dass es kein Internet hat. Dann erst auf
   Werkseinstellungen zurücksetzen: im laufenden Betrieb die Reset-Taste
   hinten etwa 5 Sekunden drücken, bis die LED die Farbe wechselt (gelb) und
   blinkt. Nach dem Neustart kommt die Folge türkis, türkis blinkend, grün
   blinkend.

3. **Die versteckte Seite öffnen.** Im Browser:

   ```
   http://192.168.212.1/gui/#/main/debug/firmwareupgrade
   ```

   **Geduld:** Anfangs ist die Seite oft ausgegraut, manchmal mit einer
   Ladeanimation. Nach 1 bis 2 Minuten lässt sich "Upload File" anklicken.
   Landest du stattdessen auf der Einrichtungsseite von Zyxel: zurück
   springen oder die Adresse in einem neuen Tab öffnen, bis die Upgrade-Seite
   kommt.

4. **OpenWrt hochladen.** Die OpenWrt-Datei wählen und mit "OK" bestätigen.
   Die Seite zeigt erst den Fortschritt in Prozent und zählt dann 150
   Sekunden herunter. Leuchtet die LED danach **dauerhaft weiß**, läuft
   OpenWrt im Arbeitsspeicher.

### Teil 2: Freifunk-Firmware

5. **OpenWrt-Oberfläche öffnen.** `http://192.168.1.1`. Kommt nichts, das
   Kabel kurz ziehen und wieder stecken, damit der Rechner eine neue Adresse
   bekommt. Auf "Login" klicken, ein Passwort gibt es noch nicht.

6. **Hochladen.** **System → Backup / Flash Firmware**, ganz unten "Flash
   image…", das sysupgrade-Image deiner Community wählen, "Upload". Den Haken
   bei **"Keep settings and retain the current configuration" entfernen**.
   Das ist wichtig. Dann **"Continue"**.

7. **Warten,** etwa 2 Minuten, Strom nicht ziehen. Die LED leuchtet
   zwischendurch türkis und blinkt beim Schreiben weiß.

8. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   (die LED blinkt dann langsam weiß) oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- Nach Teil 1 leuchtet die LED dauerhaft weiß, und unter
  `http://192.168.1.1` meldet sich OpenWrt.
- Nach Teil 2 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Upgrade-Seite bleibt ausgegraut.** 1 bis 2 Minuten warten; das ist
  normal.
- **Der Browser springt auf die Einrichtungsseite von Zyxel.** Zurück
  springen oder die Adresse in einem neuen Tab öffnen.
- **Die LED leuchtet dauerhaft rot.** Werkseinstellungen wie in Schritt 2.
{{ zusatz.fehler }}

{% include "_rampe.md" %}

{{ zusatz.text }}

## Herkunft der Angaben

Diese Anleitung folgt in weiten Teilen der
[Anleitung von Freifunk Aachen](https://freifunk-aachen.de/2024/01/04/installationsanleitung-zyxel-wsm20/)
(Stefan Limbach, 2024).

{{ herkunft }}
