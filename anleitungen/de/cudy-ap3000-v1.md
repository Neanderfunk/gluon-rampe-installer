---
gluon_name: cudy-ap3000-v1
modell: Cudy AP3000 v1
anzeige: Cudy AP3000 v1
familie: cudy-zwischenfirmware
gluon_broken: false
sprache: de
level: L3
level_text: Feste Adresse am Rechner
risiko: normal
status: erprobt
erprobt_am: 2026-10-17
erprobt_mit: Gluon 2025.1 (26100702bro), Zwischenfirmware aus unserem Spiegel, vorher Cudy-Firmware 2.4.4
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht, tftp-server]
daten_stand: 2e1c85fd
vorlage_stand: 33a38da8
---

# Cudy AP3000 v1: Freifunk-Firmware installieren

> **Am Gerät erprobt** am 17.10.2026 mit `Gluon 2025.1 (26100702bro), Zwischenfirmware aus unserem Spiegel, vorher Cudy-Firmware 2.4.4`.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Cudy%20AP3000%20v1)

Router von Cudy nehmen ab Werk nur Firmware an, die Cudy selbst
unterschrieben hat. Deshalb geht es in zwei Schritten: Zuerst kommt eine
**Zwischenfirmware von Cudy** auf den Router, ein OpenWrt, das Cudy
unterschrieben hat. Darüber spielst du dann die **Freifunk-Firmware** deiner
Community ein. Beides geht im Browser, du brauchst kein Zusatzprogramm.

> **Nicht ins Heimnetz.** Häng den Cudy AP3000 v1 zum Einrichten direkt an
> deinen Rechner, nicht an deinen Router zu Hause. Startet nach dem
> Einspielen die Einrichtungsseite der Freifunk-Firmware, verteilt er selbst
> Adressen und stört damit deinen Router. Erst wenn die Freifunk-Firmware
> eingerichtet ist, kommt er an deinen Router.

## Was du brauchst

- den Router und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die **Zwischenfirmware von Cudy** für genau dieses Modell:
  [Zwischenfirmware für den Cudy AP3000 v1 aus unserem Spiegel](https://firmware.ffnef.de/other/cudy-mirror-20261022/zwischenfirmware/cudy-ap3000.bin), Datei `cudy-ap3000.bin`
- die Freifunk-Firmware deiner Community für den Cudy AP3000 v1, und zwar das
  **sysupgrade**-Image, nicht "factory". Das ist bei Cudy richtig, auch wenn
  es die erste Installation ist.

Modell und Version stehen auf dem Aufkleber unter dem Gerät. Vergleich sie
genau mit "Cudy AP3000 v1", bevor du anfängst.

## Vorher prüfen

**Weg zurück offenhalten:** Den Notfall-Weg zurück zur Cudy-Firmware (unten)
hat der Cudy AP3000 v1 laut OpenWrt erst ab Cudy-Firmware
**2.4.7**; ältere Bootloader holen sich keine Datei.
Welche Version läuft, zeigt die Cudy-Oberfläche. Ist sie älter, spiel
zuerst die neueste Cudy-Firmware ein (Download wie unten unter "Zurück zur
Cudy-Firmware"), an derselben Stelle wie in Schritt 4 die Zwischenfirmware.
Warte den Neustart ab und mach dann mit Schritt 4 weiter. Ob der Notfall-Weg
danach auch unter der Freifunk-Firmware erhalten bleibt, haben wir noch
nicht geprüft.

Nicht verwechseln mit dem AP3000 Outdoor oder dem AP3000 Wall, die haben je
ihre eigene Zwischenfirmware. Die Zwischenfirmware für den AP3000 v1 hat Cudy
nicht öffentlich abgelegt; die Datei bei uns stammt direkt vom Cudy-Support.

## Schritte

### Teil 1: Zwischenfirmware von Cudy

1. **Dateien bereitlegen.** Lade die Zwischenfirmware und das
   sysupgrade-Image herunter und leg sie in einen Ordner, den du
   wiederfindest.

2. **Verbinden.** Versorg den Router mit Strom und steck den Rechner per
   Kabel an seine einzige Netzwerkbuchse. Der Cudy AP3000 v1 vergibt selbst keine
   Adressen. Stell deinen Rechner deshalb fest auf `192.168.10.100`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Nach dem Einschalten braucht er
   etwa eine Minute, bis er unter seiner Adresse antwortet.

3. **Cudy-Oberfläche öffnen.** Öffne im Browser `http://192.168.10.254`.
   Ab Werk verlangt die Oberfläche zuerst ein **eigenes Admin-Passwort**
   (mindestens 8 Zeichen). Denk dir eins aus und merk es dir. Ältere
   Cudy-Firmware fragt stattdessen nach dem Passwort `admin`. Danach startet
   der Assistent "Schnelleinrichtung": Den kannst du mit **"« Beenden"**
   überspringen (bei manchen Versionen heißt der Knopf "« Ausfahrt").

4. **Zwischenfirmware hochladen.** Geh zum Reiter **"Allgemeine
   Einstellungen"**, klick in der Symbolspalte links ganz unten auf
   **"Firmware"** und im Abschnitt **"Lokales Update"** auf
   **"Durchsuchen …"**. Wähl dort die Zwischenfirmware aus. Gibt es den
   Reiter nicht, such oben **Erweiterte Einstellungen** und links den
   Eintrag **Firmware** (bei älterer Cudy-Firmware unter **System**).

5. **Prüfsumme vergleichen.** Nach dem Hochladen zeigt der Router im
   Fenster "Lokales Update" eine MD5-Prüfsumme und die Größe. Sie muss genau so aussehen:

   ```
   7023a3bd44e4ae0bf09de4ed9cb44335
   ```

   Stimmt sie, klick auf **Fortfahren**.

6. **Warten.** Die Oberfläche zeigt "System - Firmware wird installiert…".
   Die LED wechselt erst zwischen Rot, Grün, Blau und Orange, blinkt dann schnell in mehreren Farben und leuchtet am Ende dauerhaft violett-weiß. Bei
   uns dauerte das weniger als eine Minute. **Strom nicht ziehen.**

### Teil 2: Freifunk-Firmware

7. **OpenWrt-Oberfläche öffnen.** Stell den Rechner jetzt fest auf
   `192.168.1.100`, Netzmaske `255.255.255.0`.
   Öffne `http://192.168.1.1`. Es erscheint die Anmeldung von OpenWrt
   ("LuCI"). Das Passwort-Feld bleibt leer, einfach anmelden.

8. **Freifunk-Firmware hochladen.** Geh zu **System → Backup / Firmware
   Update** (englisch "Backup / Flash Firmware"). Klick ganz unten auf
   **"Firmware aktualisieren…"** (englisch "Flash image…"). Es erscheint das
   Fenster "Datei wird hochgeladen…": Wähl dort das sysupgrade-Image deiner
   Community aus und klick auf **"Hochladen"**.

9. **Einstellungen nicht behalten.** Danach zeigt OpenWrt das Fenster
   "Image schreiben?" (englisch "Flash image?"). Dort ist der Haken bei **"Einstellungen beibehalten und die
   aktuelle Konfiguration sichern"** (englisch "Keep settings …") schon
   gesetzt. **Entfern diesen Haken.** Die beiden Haken darunter sind schon
   aus. Es darf kein Haken mehr gesetzt sein.
   Dann **Fortfahren**.

10. **Fertig.** Der Router schreibt die Freifunk-Firmware und startet neu,
    wieder einige Minuten, Strom nicht ziehen. Stell den Rechner wieder auf
    "automatisch". Danach startet die
    Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
    Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Wie
    es weitergeht, beschreibt deine Community. Im Betrieb ist die einzige
    Netzwerkbuchse des Cudy AP3000 v1 sein Anschluss ans Internet: Verbinde
    sie erst nach der Einrichtung mit deinem Router zu Hause.

## Woran du erkennst, dass es geklappt hat

- Nach Schritt 5 stimmt die Prüfsumme genau.
- Nach Schritt 6 zeigt `http://192.168.1.1` die Anmeldung von OpenWrt.
- Nach Schritt 10 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Prüfsumme stimmt nicht.** Nicht fortfahren. Lad die Datei neu herunter
  und prüf, ob es die für dein Modell und deine Version ist.
- **Die Cudy-Oberfläche meldet "Datei ist nicht verfügbar. Bitte versuchen
  Sie es erneut."** Die Meldung führt in die Irre: Gemeint ist, dass die
  Datei nicht von Cudy unterschrieben ist. Es ist also die falsche Datei,
  etwa schon die Freifunk-Firmware oder die Zwischenfirmware eines anderen
  Modells. Nicht noch einmal versuchen, sondern die Zwischenfirmware für
  genau dieses Modell nehmen (Aufkleber vergleichen).
- **OpenWrt meldet "not supported by this image" oder "Überprüfung der
  Abbilddatei fehlgeschlagen"** (in Schritt 9, mit einem Haken "Erzwinge
  Upgrade"). Dann ist es das Image für ein anderes Modell. **"Erzwinge
  Upgrade" nie anhaken**, sondern **"Abbrechen"** und das richtige Image
  holen.
- **Unter `http://192.168.10.254` kommt keine Cudy-Seite, sondern schon
  OpenWrt.** Dann ist die Zwischenfirmware vermutlich schon drauf: weiter bei
  Schritt 7. Läuft dort eine ganz andere Firmware, geht die Zwischenfirmware
  nicht mehr. Cudy nimmt sie nur an, solange die Original-Oberfläche läuft.
  Dann zuerst zurück zur Cudy-Firmware (unten).

## Zurück zur Cudy-Firmware

Wenn der Router nicht mehr richtig startet oder du wieder die
Original-Firmware willst, hat Cudy einen Notfall-Weg. Er braucht etwas
Werkzeug: einen TFTP-Server auf deinem Rechner
([TFTP-Server einrichten](grundlagen/tftp-server.md)) und eine feste
Adresse am Rechner ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
Beim Cudy AP3000 v1 geht das nur, wenn vorher mindestens Cudy-Firmware
2.4.7 lief (siehe "Vorher prüfen"). Mit einem älteren
Bootloader holt er sich keine Datei, dann gibt es keinen einfachen Weg
zurück.

1. Lade die Cudy-Firmware für dein Modell von der
   [Download-Seite von Cudy](https://www.cudy.com/pages/download-center/ap3000-1-0) herunter, und zwar
   die oberste, also neueste Version.
   Kommt sie als ZIP-Archiv, pack es aus: Darin liegt die `.bin`-Datei,
   manchmal zusätzlich eine `md5.txt`. Die `.bin`-Datei heißt bei Cudy oft
   "…-sysupgrade.bin". Das ist trotzdem die Cudy-Firmware, nicht die
   Freifunk-Firmware. Benenn sie in `recovery.bin` um (genau so) und leg sie
   in den Ordner des TFTP-Servers.
2. Stell deinen Rechner fest auf `192.168.1.88`, Netzmaske `255.255.255.0`,
   und starte den TFTP-Server.
3. Steck das Kabel an seine einzige Netzwerkbuchse. Der Router hat noch keinen Strom.
4. Drück die Reset-Taste (versenkt, mit einer Büroklammer) und halte sie
   gedrückt, steck den Strom ein und halte
   weiter, bis die LED abwechselnd orange und rot blinkt. Dann loslassen. Im TFTP-Server siehst du, dass `recovery.bin` abgeholt wird.
5. Warten: Das Schreiben dauert ein paar Minuten. Die LEDs können dabei
   flackern, und die Netzwerkverbindung geht zwischendurch weg und wieder an.
   **Strom nicht ziehen.** Danach den Rechner fest auf
   `192.168.10.100` stellen wie in Schritt 2; die Cudy-Oberfläche ist
   unter `http://192.168.10.254` erreichbar, nach dem Neustart braucht er dafür wieder
   etwa eine Minute.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Gluon-Setup-Mode, wie Gluon 2025.1 die einzige Buchse im Setup-Mode belegt, ist am Gerät nicht gemessen (Warnung)
- abgeleitet: Router ist in beiden Firmwares DHCP-Server (Schritte (Normalweg), Programm)
- abgeleitet: ob die Zwischenfirmware DHCP vergibt, offen; am Testplatz war 192.168.1.88 fest eingestellt (Adressen)
- abgeleitet: sysupgrade schreibt den Flash (Schritte (Normalweg), Dauer)
- geprüft: Commit-Texte (Gluon-RAMpe passt)
- geprüft: Commit/Neanderfunk-Notiz (Weg ab Werk, Schritte (Normalweg))
- geprüft: Cudy-FAQ "OpenWrt Software Download" (Bedingung an die Herstellerfirmware)
- geprüft: Mitschnitt Test Neanderfunk 17.10.2026 (Adressen, Fehlerbild)
- geprüft: Neanderfunk-Notiz (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Datei, Dauer)
- geprüft: Neanderfunk-Notiz, Commit WR3000E/M3000 v2 (Schritte (Normalweg), Sichtbare Zeichen, Zugang)
- geprüft: Spiegel-Ordner (Typenschild/Verwechslung)
- geprüft: Test Neanderfunk 17.10.2026 (Sichtbare Zeichen, Anschluss, Rückweg zur Herstellerfirmware)
- geprüft: Wiki toh:cudy:ap3000_v1 (Rückweg zur Herstellerfirmware)
- Geräteeintrag: OpenWrt 6dacba30a75b0ac8a65115f78808a97abbb34939
