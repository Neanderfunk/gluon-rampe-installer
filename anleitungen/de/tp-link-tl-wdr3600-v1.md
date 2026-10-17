---
gluon_name: tp-link-tl-wdr3600-v1
modell: TP-Link TL-WDR3600 v1
anzeige: TP-Link TL-WDR3600 v1
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: erprobt
erprobt_am: 2026-10-16
erprobt_mit: Gluon 2025.1 (26100702bro) per TFTP mit dem factory-Image; über die TP-Link-Oberfläche 3.14.3 Build 150518 mit Gluon 2023.2.6 (factory, Originalname)
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht, tftp-server]
daten_stand: fdaf35ba
vorlage_stand: 33a38da8
---

# TP-Link TL-WDR3600 v1: Freifunk-Firmware installieren

> **Am Gerät erprobt** am 16.10.2026 mit `Gluon 2025.1 (26100702bro) per TFTP mit dem factory-Image; über die TP-Link-Oberfläche 3.14.3 Build 150518 mit Gluon 2023.2.6 (factory, Originalname)`.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20TL-WDR3600%20v1)

Beim TP-Link TL-WDR3600 v1 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link TL-WDR3600 v1, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade" (nicht umbenennen)

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link TL-WDR3600 v1", bevor du anfängst.

## Vorher prüfen

- **Herstellerfirmware:** Bei uns hat die TP-Link-Firmware 3.14.3
  (Build 150518) das factory-Image direkt angenommen. Laut OpenWrt sperrt
  der spätere Build 151104 fremde Firmware. Lehnt die Oberfläche das Image
  ab, nimm den Weg per TFTP (unten unter "Notfall"): Der WDR3600 holt sich
  das factory-Image dann selbst, ganz ohne die TP-Link-Oberfläche. Den
  TFTP-Weg hat aber nicht jeder WDR3600: Ein Gerät Ver 1.1 mit PCT-Zeichen
  (russische Zulassung) und blauen LEDs holte sich bei uns keine Datei, eins
  mit grünen LEDs schon.
- **Dateiname:** Nimm die Datei mit ihrem Originalnamen, umbenennen ist
  nicht nötig. Hast du sie mehrfach heruntergeladen und heißt sie jetzt
  `…(1).bin` oder `…[1].bin`, benenne sie zurück. Bei zu langem Namen meldet
  die Oberfläche "Please choose a file to upgrade!". Bei uns ging ein Name
  mit 54 Zeichen, einer mit 68 nicht.
- Der TL-WDR4300 sieht ähnlich aus, braucht aber ein eigenes Image.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.0.1`.
   Melde dich an: Benutzer `admin`, Passwort `admin`.

4. **Firmware-Update aufrufen.** Such den Menüpunkt für das Firmware-Update. Er heißt je nach
   Hersteller etwa "Firmware Upgrade", "Firmware-Update" oder "Firmware
   aktualisieren" und liegt oft unter "System", "System Tools" oder
   "Verwaltung".

5. **Hochladen.** Wähl das factory-Image aus, starte das Update und
   bestätige die Rückfragen.

6. **Warten.** Das Gerät schreibt die Firmware und startet neu. Das dauert
   etwa zwei bis drei Minuten.
   **Nicht ausschalten, Strom nicht ziehen und die Seite nicht neu laden.**
   Manche Geräte löschen zuerst den ganzen Speicher; ein Abbruch in dieser
   Zeit kann sie unbrauchbar machen.

7. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
   Wie es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- Das Gerät startet nach einigen Minuten von selbst neu.
- Die Herstelleroberfläche ist weg. Stattdessen meldet sich die
  Freifunk-Firmware, oft zuerst mit der Einrichtungsseite unter
  `http://192.168.1.1`.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Häufige Gründe: Das Image ist für
  eine andere Hardware-Version oder Region (Aufkleber prüfen), es ist das sysupgrade- statt des factory-Images, der Dateiname
  ist zu lang (kurz umbenennen, z. B. in `factory.bin`), oder die
  Herstellerfirmware ist zu neu und sperrt fremde Firmware (siehe "Vorher
  prüfen", falls vorhanden).
- **Nach dem Neustart ist unter `http://192.168.1.1` nichts.** Stell den
  Rechner auf "automatisch" und zieh das Kabel kurz ab und wieder an
  ([Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md)).
  Je nach Community startet die Firmware auch gleich im Betrieb ohne
  Einrichtungsseite.
- **"Error code: 18005 … the version of the upgraded file was
  incorrect".** Das ist das sysupgrade-Image. Die TP-Link-Oberfläche
  braucht das factory-Image.
- **"Please choose a file to upgrade!"** Der Dateiname ist zu lang, siehe
  "Vorher prüfen".

## Notfall: Firmware per TFTP

Startet das Gerät nicht mehr richtig, etwa nach einem abgebrochenen Update
oder weil es in einer Startschleife hängt, kann es sich eine Firmware selbst
von deinem Rechner holen. Dafür brauchst du einen
TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)) und eine
feste Adresse am Rechner ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

1. Leg das factory-Image der Freifunk-Firmware (für den Weg zurück zu TP-Link stattdessen die TP-Link-Firmware ohne ihren Bootloader-Teil, siehe unten unter „Zurück zur TP-Link-Firmware“) unter dem Namen `wdr3600v1_tp_recovery.bin` in den
   Ordner des TFTP-Servers. Genau dieser Name, Groß- und Kleinschreibung
   zählt.
2. Stell deinen Rechner fest auf `192.168.0.66`, Netzmaske
   `255.255.255.0`, und starte den TFTP-Server.
   Am Rechner darf nur diese eine Adresse eingestellt sein, sonst antwortet der TFTP-Server von einer anderen Adresse, und der Router nimmt die Datei nicht. Nicht jeder WDR3600 hat diesen Weg, siehe „Vorher prüfen“.
3. Kabel an eine LAN-Buchse, Strom aus. Drück die Reset-Taste, halte sie
   gedrückt und schalte den Strom ein. Halte sie gedrückt:
   bis der TFTP-Server
   zeigt, dass die Datei abgeholt wird.
4. Warten, einige Minuten (mit der TP-Link-Firmware etwa 6 Minuten). Das Gerät
   schreibt die Datei und startet neu.

## Zurück zur TP-Link-Firmware

Über den Notfall per TFTP (oben) nimmt der WDR3600 auch die Firmware von
TP-Link wieder an, allerdings nur ohne ihren Bootloader-Teil am Anfang und
nur, wenn er den TFTP-Weg hat (siehe "Vorher prüfen"). So
bereitest du die Datei vor:

1. Lade
   [TL-WDR3600_V1_150518.zip](https://static.tp-link.com/res/down/soft/TL-WDR3600_V1_150518.zip)
   bei TP-Link herunter und pack sie aus. Darin liegt
   `wdr3600v1_en_3_14_3_up_boot(150518).bin`.
2. Schneide die ersten 131.584 Bytes ab (257 mal 512) und speichere den
   Rest als `wdr3600v1_tp_recovery.bin`. Öffne dazu ein Terminal in dem
   Ordner:

   - Linux und macOS:

     ```
     dd if='wdr3600v1_en_3_14_3_up_boot(150518).bin' of=wdr3600v1_tp_recovery.bin bs=512 skip=257
     ```

   - Windows (PowerShell oder Eingabeaufforderung) mit **Python 3**
     (<https://www.python.org/downloads/>), geht auch unter Linux und macOS
     mit `python3` statt `py`:

     ```
     py -c "open('wdr3600v1_tp_recovery.bin','wb').write(open('wdr3600v1_en_3_14_3_up_boot(150518).bin','rb').read()[131584:])"
     ```

   **Prüfen:** `wdr3600v1_tp_recovery.bin` ist genau **8.060.928 Bytes**
   groß.
3. Weiter wie oben unter "Notfall: Firmware per TFTP". Danach ist die
   TP-Link-Oberfläche unter `http://192.168.0.1` erreichbar (Benutzer
   `admin`, Passwort `admin`).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Quelle (OpenWrt-Commit))
- abgeleitet: Wiki-Zusammenfassung, im Rohtext toh:tp-link:tl-wdr4300_v1 nicht gefunden (Schritte (Normalweg), Dauer)
- geprüft: OpenWrt generic-tp-link.mk (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Test Neanderfunk 16.10.2026 (Weg ab Werk, Schritte (Normalweg), Datei, Bedingung an die Herstellerfirmware, Fehlerbild, Notweg)
- geprüft: Test Neanderfunk 16.10.2026, zweites Gerät (Typenschild/Verwechslung, Notweg)
- geprüft: WDR3600-Seite verweist darauf, Wiki toh:tp-link:tl-wdr4300_v1 (Schritte (Normalweg), Adressen, Programm, Zugang)
- geprüft: Wiki toh:tp-link:tl-wdr3600_v1 (Typenschild/Verwechslung)
- geprüft: tl-wdr3600_v1, Wiki toh:tp-link:tl-wdr4300_v1 (Schritte (Normalweg), Fehlerbild)
- Geräteeintrag: a7e1e919afa9659f66dada5e69d1b162f447ced7 (ohne Anleitung) [abgeleitet]
