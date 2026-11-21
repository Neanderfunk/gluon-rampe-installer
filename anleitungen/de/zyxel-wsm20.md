---
gluon_name: zyxel-wsm20
modell: ZyXEL WSM20 (Multy M1)
anzeige: ZyXEL WSM20 (Multy M1)
familie: sonderweg-zyxel-wsm20
gluon_broken: false
sprache: de
level: L1
level_text: Zwei Schritte im Browser
risiko: normal
status: erprobt
erprobt_am: 2026-09-19
erprobt_mit: Gluon 2023.2.6 (26091920sta) über das OpenWrt-initramfs
rampe_image: gluon-rampe-20261115-zyxel-wsm20-initramfs-kernel.bin
grundlagen: [browser-https, browser-not-found, router-antwortet-nicht]
daten_stand: 3512b4651
vorlage_stand: ae198bf8f
---

# ZyXEL WSM20 (Multy M1): Freifunk-Firmware installieren

> **Am Gerät erprobt** am 19.09.2026 mit `Gluon 2023.2.6 (26091920sta) über das OpenWrt-initramfs`. Das aktuelle Image ist neuer und in dieser Form
> noch nicht am Gerät gelaufen.
>
> Schreib uns, ob es geklappt hat. Und wenn es irgendwo hakt: Melde dich,
> wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20ZyXEL%20WSM20%20%28Multy%20M1%29)

Die Firmware von Zyxel hat eine versteckte Seite, über die sich eine andere
Firmware hochladen lässt. Darüber kommt zuerst die **Gluon-RAMpe** in den Arbeitsspeicher: eine kleine
Firmware, die nur eins kann, die Freifunk-Firmware deiner Community
annehmen. Du
brauchst nur einen Browser, aber etwas Geduld: Die versteckte Seite ist
manchmal zickig.

Ein Konto in der Zyxel-Cloud brauchst du dafür nicht.

## Was du brauchst

- den Multy M1 mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die RAMpe für den WSM20 (nur für den Arbeitsspeicher):
  [gluon-rampe-20261115-zyxel-wsm20-initramfs-kernel.bin](https://firmware.neanderfunk.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261115-zyxel-wsm20-initramfs-kernel.bin)
- die Freifunk-Firmware deiner Community für dieses Gerät, und zwar das
  **sysupgrade**-Image

## Schritte

### Teil 1: Die RAMpe in den Arbeitsspeicher

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

4. **RAMpe hochladen.** Die RAMpe-Datei wählen und mit "OK" bestätigen.
   Die Seite zeigt erst den Fortschritt in Prozent und zählt dann 150
   Sekunden herunter. Danach startet die RAMpe im Arbeitsspeicher.

### Teil 2: Freifunk-Firmware

5. **Die RAMpe-Seite öffnen.** Öffne `http://192.168.1.1`. Die RAMpe
    leitet von selbst auf ihre Seite "Firmware aktualisieren" weiter. Kommt
    stattdessen "Not Found", hat sich der Browser eine Weiterleitung von
    früher gemerkt, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
    Kommt gar nichts, siehe [Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md).
    Zeigt der Browser eine Warnung vor einem unsicheren Zertifikat, hat er
    von sich aus `https://` vor die Adresse gesetzt, siehe
    [Browser macht https daraus](grundlagen/browser-https.md).
    Die RAMpe läuft nur im Arbeitsspeicher. Startet das Gerät zwischendurch
    neu oder fehlt der Strom, ist sie weg: dann noch einmal ab Schritt 2.

    ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"](../bilder/allgemein/rampe-seite.png)

6. **Freifunk-Firmware hochladen.** Wähl das **sysupgrade**-Image
    deiner Community aus und klick "Datei hochladen". Die RAMpe zeigt die
    Prüfsumme (SHA256) der Datei. Vergleich sie mit der Prüfsumme, die deine
    Community zur Datei angibt. Stimmt sie, klick "Fortfahren".

    ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"](../bilder/allgemein/rampe-pruefsumme.png)

    Danach erscheint der Hinweis, dass die Firmware jetzt geschrieben wird.
    Jetzt den Strom nicht unterbrechen.

    ![Hinweis der RAMpe: Die Firmware wird jetzt aktualisiert, Stromversorgung nicht unterbrechen](../bilder/allgemein/rampe-flash-laeuft.png)

7. **Warten,** etwa 2 Minuten, Strom nicht ziehen.

8. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   (die LED blinkt dann langsam weiß) oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- Nach Teil 1 zeigt `http://192.168.1.1` die RAMpe-Seite "Firmware
  aktualisieren".
- Nach Teil 2 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Upgrade-Seite bleibt ausgegraut.** 1 bis 2 Minuten warten; das ist
  normal.
- **Der Browser springt auf die Einrichtungsseite von Zyxel.** Zurück
  springen oder die Adresse in einem neuen Tab öffnen.
- **Die LED leuchtet dauerhaft rot.** Werkseinstellungen wie in Schritt 2.

## Anderer Weg: über OpenWrt

Statt der RAMpe nimmt die versteckte Seite in Schritt 4 auch OpenWrt für den
Arbeitsspeicher:
[openwrt-24.10.8-ramips-mt7621-zyxel_wsm20-initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-zyxel_wsm20-initramfs-kernel.bin). Danach unter
`http://192.168.1.1` bei "Login" klicken (ein Passwort gibt es noch nicht),
**System → Backup / Flash Firmware**, ganz unten "Flash image…", das
sysupgrade-Image wählen, "Upload", den Haken bei **"Keep settings and retain
the current configuration" entfernen** und **"Continue"**.

## Herkunft der Angaben

Diese Anleitung folgt in weiten Teilen der
[Anleitung von Freifunk Aachen](https://freifunk-aachen.de/2024/01/04/installationsanleitung-zyxel-wsm20/)
(Stefan Limbach, 2024).

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Gluon-RAMpe passt)
- abgeleitet: Freifunk Aachen 04.01.2024, FAQ: rote LED = eingerichtet und ohne Internet (Schritte (Normalweg))
- abgeleitet: Freifunk Aachen, FAQ: rote LED = eingerichtet und ohne Internet (Anschluss)
- geprüft: Commit (Bedingung an die Herstellerfirmware)
- geprüft: Commit 28df7f7 (Programm)
- geprüft: Commit 28df7f7, Wiki toh:zyxel:wsm20 (Adressen)
- geprüft: Freifunk Aachen 04.01.2024 (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Anschluss, Adressen, Zugang, Datei, Dauer, Fehlerbild)
- geprüft: Freifunk Aachen 04.01.2024 + Wiki toh:zyxel:wsm20; Neanderfunk-Notiz, adorfer 15.10.2026: nach dieser Anleitung installiert, läuft als Testknoten in 21_dias (dias-d41ad11183d0, Gluon 2023.2.6, Karte 15.10.2026) (Bedingung an die Herstellerfirmware)
- geprüft: Freifunk Aachen 04.01.2024, Wiki toh:zyxel:wsm20; Neanderfunk-Notiz, adorfer 15.10.2026: nach dieser Anleitung installiert, läuft als Testknoten in 21_dias (dias-d41ad11183d0, Gluon 2023.2.6, Karte 15.10.2026) (Weg ab Werk)
- geprüft: Freifunk Aachen 04.01.2024; Neanderfunk-Notiz, adorfer: Wartezeit auf der Upgrade-Seite am Gerät so erlebt (Schritte (Normalweg))
- Geräteeintrag: 28df7f7ff251d8684caa60f07ed0ba0c4a8e71f4
