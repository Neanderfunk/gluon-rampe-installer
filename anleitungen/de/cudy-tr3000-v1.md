---
gluon_name: cudy-tr3000-v1
modell: Cudy TR3000 v1 (128 MB Flash)
anzeige: Cudy TR3000 v1 (128 MB Flash)
familie: cudy-zwischenfirmware
gluon_broken: false
sprache: de
level: L1
level_text: Zwei Schritte im Browser
risiko: normal
status: ungeprüft
grundlagen: [feste-ip, tftp-server]
daten_stand: 8a173cbb
vorlage_stand: 393f1614
---

# Cudy TR3000 v1 (128 MB Flash): Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Cudy%20TR3000%20v1%20%28128%20MB%20Flash%29)

Router von Cudy nehmen ab Werk nur Firmware an, die Cudy selbst
unterschrieben hat. Deshalb geht es in zwei Schritten: Zuerst kommt eine
**Zwischenfirmware von Cudy** auf den Router, ein OpenWrt, das Cudy
unterschrieben hat. Darüber spielst du dann die **Freifunk-Firmware** deiner
Community ein. Beides geht im Browser, du brauchst kein Zusatzprogramm.

## Was du brauchst

- den Router und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die **Zwischenfirmware von Cudy** für genau dieses Modell:
  [Zwischenfirmware für den Cudy TR3000 v1 (128 MB Flash) aus unserem Spiegel](https://firmware.ffnef.de/other/cudy-mirror-20261015/zwischenfirmware/cudy-tr3000.bin), Datei `cudy-tr3000.bin`
- die Freifunk-Firmware deiner Community für den Cudy TR3000 v1 (128 MB Flash), und zwar das
  **sysupgrade**-Image, nicht "factory". Das ist bei Cudy richtig, auch wenn
  es die erste Installation ist.

Modell und Version stehen auf dem Aufkleber unter dem Gerät. Vergleich sie
genau mit "Cudy TR3000 v1 (128 MB Flash)", bevor du anfängst.

## Vorher prüfen

Diese Anleitung gilt für den **normalen TR3000 v1**. Es gibt auch einen
[TR3000 mit 256 MB Speicher](cudy-tr3000-256mb-v1.md) (Cudy nennt ihn
"TR3000-256MB"). Der braucht eine andere Zwischenfirmware und eine andere
Freifunk-Firmware. Schau auf das Typenschild oder den Karton: Steht dort
"256MB", nimm die andere Anleitung.

## Schritte

### Teil 1: Zwischenfirmware von Cudy

1. **Dateien bereitlegen.** Lade die Zwischenfirmware und das
   sysupgrade-Image herunter und leg sie in einen Ordner, den du
   wiederfindest.

2. **Verbinden.** Versorg den Router mit Strom und steck den Rechner per
   Kabel an eine **LAN**-Buchse. Der Rechner holt sich seine Adresse
   automatisch, so wie er normalerweise eingestellt ist.

3. **Cudy-Oberfläche öffnen.** Öffne im Browser `http://192.168.10.1` und
   melde dich mit dem Passwort `admin` an. Beim ersten Mal fragt der Router
   einige Einstellungen ab: alles mit "Weiter" bestätigen, am Ende
   speichern.

4. **Zwischenfirmware hochladen.** Geh zu **Erweiterte Einstellungen →
   System → Firmware** und wähl die Zwischenfirmware aus. Die Bezeichnungen
   können je nach Modell und Alter der Cudy-Firmware etwas anders heißen.

5. **Prüfsumme vergleichen.** Nach dem Hochladen zeigt der Router eine
   MD5-Prüfsumme. Sie muss genau so aussehen:

   ```
   4551e961e22c0dafab13f5251d64d042
   ```

   Stimmt sie, klick auf **Fortfahren**.

6. **Warten.** Der Router schreibt die Zwischenfirmware und startet neu. Das
   dauert einige Minuten. **Strom nicht ziehen.**

### Teil 2: Freifunk-Firmware

7. **OpenWrt-Oberfläche öffnen.**
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
   Download-Seite von Cudy herunter, benenne sie in
   `recovery.bin` um (genau so) und leg sie in den Ordner des TFTP-Servers.
2. Stell deinen Rechner fest auf `192.168.1.88`, Netzmaske `255.255.255.0`,
   und starte den TFTP-Server.
3. Steck das Kabel an eine
   LAN-Buchse. Der Router hat noch keinen Strom.
4. Drück die Reset-Taste und halte sie gedrückt, steck den Strom ein und halte
   weiter (mindestens 5 Sekunden), bis
   alle LEDs schnell blinken oder der TFTP-Server den Download zeigt. Dann
   loslassen.
5. Blinken die LEDs langsam, ist der Router fertig. Danach den Rechner wieder
   auf "automatisch" stellen; die Cudy-Oberfläche ist unter
   `http://192.168.10.1` erreichbar.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Zwang: abgeleitet; geprüft: Wiki toh:cudy:tr3000 (Datei)
- abgeleitet: Wiki (Typenschild/Verwechslung)
- abgeleitet: sysupgrade schreibt den Flash (Schritte (Normalweg))
- geprüft (Notweg)
- geprüft: Commit (Anschluss, Adressen, Programm, Zugang, Notweg)
- geprüft: Commit 63b8d98, Wiki toh:cudy:tr3000 (Taste und Zeitpunkt, Sichtbare Zeichen, Zugang, Notweg)
- geprüft: Commit; Zwang: abgeleitet (Notweg)
- geprüft: Spiegel firmware.ffnef.de/other/cudy-mirror-20261015 (Cudys Drive-Ordner, geholt 15.10.2026; MD5 geprüft) (Schritte (Normalweg))
- geprüft: Spiegel firmware.ffnef.de/other/cudy-mirror-20261015 (Cudys Drive-Ordner, geholt 15.10.2026; MD5 geprüft); Ablauf forum.darmstadt.freifunk.net t/1010 #1 (TomH, 09.04.2025, am 15.10.2026 gelesen) (Schritte (Normalweg))
- geprüft: Wiki toh:cudy:tr3000 (Anschluss, Typenschild/Verwechslung, Dauer, Notweg, Rückweg zur Herstellerfirmware)
- geprüft: forum.darmstadt.freifunk.net t/1010 #1 (TomH, 09.04.2025, am 15.10.2026 gelesen) (Schritte (Normalweg))
- geprüft: forum.darmstadt.freifunk.net t/1010 #1 (TomH, 09.04.2025, am 15.10.2026 gelesen), mit älterer Fassung MD5 b8333d8e…; Spiegel firmware.ffnef.de/other/cudy-mirror-20261015 (Cudys Drive-Ordner, geholt 15.10.2026; MD5 geprüft) (Weg ab Werk)
- Geräteeintrag: OpenWrt 63b8d98dd0d2f7797ea5b5f25978590982bbbb5d
