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
rampe_image: gluon-rampe-20261015-zyxel-wsm20-initramfs-kernel.bin
grundlagen: [browser-https]
daten_stand: af10b830
vorlage_stand: 79f8a174
---

# ZyXEL WSM20 (Multy M1): Freifunk-Firmware installieren

> **Am Gerät erprobt** am 19.09.2026 mit `Gluon 2023.2.6 (26091920sta) über das OpenWrt-initramfs`.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20ZyXEL%20WSM20%20%28Multy%20M1%29)

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
  [openwrt-24.10.8-ramips-mt7621-zyxel_wsm20-initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-zyxel_wsm20-initramfs-kernel.bin)
- die Freifunk-Firmware deiner Community für dieses Gerät, und zwar das
  **sysupgrade**-Image

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

## Anderer Weg: mit der Gluon-RAMpe (ungetestet)

Statt erst OpenWrt und dann die Freifunk-Firmware aufzuspielen, geht es auch
mit der **Gluon-RAMpe**: einer kleinen Firmware, die nur eins kann, nämlich
die Freifunk-Firmware deiner Community annehmen. Das spart die
OpenWrt-Etappe. Für den ZyXEL WSM20 (Multy M1) ist dieser Weg **noch von niemandem
ausprobiert**; die RAMpe selbst läuft auf anderen Geräten.

1. Lade die RAMpe für den ZyXEL WSM20 (Multy M1) herunter:
   [gluon-rampe-20261015-zyxel-wsm20-initramfs-kernel.bin](https://download.ffnef.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261015-zyxel-wsm20-initramfs-kernel.bin).
2. Lade in Schritt 4 statt der OpenWrt-Datei die RAMpe hoch; Teil 2 entfällt dann.
3. Nach dem Neustart öffne `http://192.168.1.1/cgi-bin/config`. Es erscheint
   die Seite "Firmware aktualisieren" der RAMpe. Kommt "Not Found", hat sich
   der Browser eine Seite von früher gemerkt: Tipp die Adresse vollständig
   ein, mit `/cgi-bin/config` am Ende. Startet der Router zwischendurch neu,
   einfach die Seite wieder aufrufen.

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"](../bilder/allgemein/rampe-seite.png)
4. Wähl das **sysupgrade**-Image deiner Community und klick "Datei
   hochladen". Die RAMpe zeigt die Prüfsumme (SHA256); vergleich sie mit der
   Angabe deiner Community und klick "Fortfahren".
5. Nach wenigen Minuten startet die Freifunk-Firmware.

Zeigt der Browser beim Aufruf eine Warnung vor dem Zertifikat, siehe
[Browser macht https daraus](grundlagen/browser-https.md).

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
