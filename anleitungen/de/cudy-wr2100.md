---
gluon_name: cudy-wr2100
modell: Cudy WR2100
anzeige: Cudy WR2100
familie: cudy-zwischenfirmware
gluon_broken: false
sprache: de
level: L1
level_text: Zwei Schritte im Browser
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht, tftp-server]
daten_stand: 367dd1b3
vorlage_stand: bf452817
---

# Cudy WR2100: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Cudy%20WR2100)

Router von Cudy nehmen ab Werk nur Firmware an, die Cudy selbst
unterschrieben hat. Deshalb geht es in zwei Schritten: Zuerst kommt eine
**Zwischenfirmware von Cudy** auf den Router, ein OpenWrt, das Cudy
unterschrieben hat. Darüber spielst du dann die **Freifunk-Firmware** deiner
Community ein. Beides geht im Browser, du brauchst kein Zusatzprogramm.

## Was du brauchst

- den Router und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die **Zwischenfirmware von Cudy** für genau dieses Modell:
  [Zwischenfirmware für den Cudy WR2100 aus unserem Spiegel](https://firmware.ffnef.de/other/cudy-mirror-20261022/zwischenfirmware/cudy-wr2100.bin), Datei `cudy-wr2100.bin`
- die Freifunk-Firmware deiner Community für den Cudy WR2100, und zwar das
  **sysupgrade**-Image, nicht "factory". Das ist bei Cudy richtig, auch wenn
  es die erste Installation ist.

Modell und Version stehen auf dem Aufkleber unter dem Gerät. Vergleich sie
genau mit "Cudy WR2100", bevor du anfängst.

## Schritte

### Teil 1: Zwischenfirmware von Cudy

1. **Dateien bereitlegen.** Lade die Zwischenfirmware und das
   sysupgrade-Image herunter und leg sie in einen Ordner, den du
   wiederfindest.

2. **Verbinden.** Versorg den Router mit Strom und steck den Rechner per
   Kabel an eine **LAN**-Buchse. Der Rechner holt sich seine
   Adresse automatisch, so wie er normalerweise eingestellt ist.

3. **Cudy-Oberfläche öffnen.** Öffne im Browser `http://192.168.10.1`.
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
   002345fcc699c7b5a99b8fdb99dd6719
   ```

   Stimmt sie, klick auf **Fortfahren**.

6. **Warten.** Die Oberfläche zeigt "System - Firmware wird installiert…".
   Die LEDs zeigen erst ein Lauflicht (bis etwa eine halbe Minute), dann
   blinken oder flackern sie kurz, dann startet der Router einmal neu. Bei
   uns dauerte das weniger als eine Minute. **Strom nicht ziehen.**

### Teil 2: Freifunk-Firmware

7. **OpenWrt-Oberfläche öffnen.**
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
    wieder einige Minuten, Strom nicht ziehen. Danach startet die
    Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
    Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Wie
    es weitergeht, beschreibt deine Community.

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
- **Nach Schritt 6 antwortet `http://192.168.1.1` nicht.** Steck das Kabel in
  eine andere Buchse. Bei manchen Modellen tauschen LAN und WAN nach dem
  Wechsel auf OpenWrt die Rolle.
- **Unter `http://192.168.10.1` kommt keine Cudy-Seite, sondern schon
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

1. Lade die Cudy-Firmware für dein Modell von der
   [Download-Seite von Cudy](https://www.cudy.com/pages/download-center/wr2100-1-0) herunter, und zwar
   die oberste, also neueste Version.
   Kommt sie als ZIP-Archiv, pack es aus: Darin liegt die `.bin`-Datei,
   manchmal zusätzlich eine `md5.txt`. Die `.bin`-Datei heißt bei Cudy oft
   "…-sysupgrade.bin". Das ist trotzdem die Cudy-Firmware, nicht die
   Freifunk-Firmware. Benenn sie in `recovery.bin` um (genau so) und leg sie
   in den Ordner des TFTP-Servers.
2. Stell deinen Rechner fest auf `192.168.1.88`, Netzmaske `255.255.255.0`,
   und starte den TFTP-Server.
3. Steck das Kabel an eine
   LAN-Buchse. Der Router hat noch keinen Strom.
4. Drück die Reset-Taste (versenkt, mit einer Büroklammer) und halte sie
   gedrückt, steck den Strom ein und halte
   weiter,
   bis **alle LEDs einmal kurz aufleuchten**, etwa eine halbe Sekunde lang.
   Dann loslassen. Hältst du weiter, fängt der Router etwa alle 20 Sekunden
   von vorn an. Im TFTP-Server siehst du, dass `recovery.bin` abgeholt wird.
   Klappt es mit der Reset-Taste nicht, versuch es genauso mit der
   WPS-Taste. Bei einem unserer Geräte ging es zuerst nur damit.
5. Warten: Das Schreiben dauert ein paar Minuten. Die LEDs können dabei
   flackern, und die Netzwerkverbindung geht zwischendurch weg und wieder an.
   **Strom nicht ziehen.** Der Router ist fertig, wenn die **System-LED ruhig
   leuchtet** (steckt ein Kabel in der WAN-Buchse, leuchtet zusätzlich
   "Internet"). Danach den
   Rechner wieder auf "automatisch" stellen; die Cudy-Oberfläche ist unter
   `http://192.168.10.1` erreichbar.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Router ist in beiden Firmwares DHCP-Server (Schritte (Normalweg), Anschluss, Adressen, Programm)
- abgeleitet: so am WR3000H 16.10.2026; die Cudy-FAQ (schnelles/langsames Blinken) stimmte dort nicht (Rückweg zur Herstellerfirmware)
- abgeleitet: sysupgrade schreibt den Flash (Schritte (Normalweg), Dauer)
- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit (Rückweg zur Herstellerfirmware)
- geprüft: Cudy-FAQ "OpenWrt Software Download" (Bedingung an die Herstellerfirmware)
- geprüft: Neanderfunk-Notiz (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Datei, Dauer, Fehlerbild)
- geprüft: Neanderfunk-Notiz, Commit WR3000E/M3000 v2 (Schritte (Normalweg), Sichtbare Zeichen, Zugang)
- geprüft: Spiegel firmware.ffnef.de/other/cudy-mirror-20261022, geholt 22.10.2026, MD5 geprüft (Datei)
- Geräteeintrag: 3501db9b9b4a71ae52c539b46af817783c327866
