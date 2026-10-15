---
gluon_name: tp-link-archer-c6-v2-eu-ru-jp
modell: TP-Link Archer C6 v2 (EU/RU/JP)
anzeige: TP-Link Archer C6 v2 (EU/RU/JP)
familie: k0-webui
gluon_broken: false
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [feste-ip, tftp-server]
daten_stand: 37aa5ed
vorlage_stand: bfd0482
---

# TP-Link Archer C6 v2 (EU/RU/JP): Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Ob die TP-Link-Oberfläche die Datei annimmt, hängt von der Version der Herstellerfirmware ab; mit 1.3.3 oder 1.3.7 sollte es am ehesten gehen.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20Archer%20C6%20v2%20%28EU/RU/JP%29)

Beim TP-Link Archer C6 v2 (EU/RU/JP) geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link Archer C6 v2 (EU/RU/JP), und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link Archer C6 v2 (EU/RU/JP)", bevor du anfängst.

## Vorher prüfen

- **Region:** Nur Geräte für EU, RU oder JP (auch der baugleiche Archer A6
  v2). Die Variante für die USA und Taiwan ist innen anders und braucht ein
  Image, das es für Gluon nicht gibt. Die Region steht auf dem Aufkleber.
- **Herstellerfirmware:** Ob die Oberfläche das Image annimmt, hängt von
  ihrer Version ab. 1.2.0 und 1.2.1 lehnen es mit "invalid type" ab. Mit
  1.3.3 und 1.3.7 hat es laut OpenWrt geklappt. Die Version siehst du in der
  Oberfläche, meist auf der Seite für das Firmware-Update.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser die Adresse der Oberfläche (sie steht meist auf dem Aufkleber unter dem Gerät).
   Melde dich mit den Zugangsdaten vom Aufkleber an, oder leg beim ersten
   Aufruf ein Passwort fest.

4. **Firmware-Update aufrufen.** Such den Menüpunkt für das Firmware-Update. Er heißt je nach
   Hersteller etwa "Firmware Upgrade", "Firmware-Update" oder "Firmware
   aktualisieren" und liegt oft unter "System", "System Tools" oder
   "Verwaltung".

5. **Hochladen.** Wähl das factory-Image aus, starte das Update und
   bestätige die Rückfragen.

6. **Warten.** Das Gerät schreibt die Firmware und startet neu. Das dauert
   einige Minuten.
   **Nicht ausschalten, Strom nicht ziehen und die Seite nicht neu laden.**
   Manche Geräte löschen zuerst den ganzen Speicher; ein Abbruch in dieser
   Zeit kann sie unbrauchbar machen.

7. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Wie es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- Das Gerät startet nach einigen Minuten von selbst neu.
- Die Herstelleroberfläche ist weg. Stattdessen meldet sich die
  Freifunk-Firmware, oft zuerst mit der Einrichtungsseite unter
  `http://192.168.1.1`.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Häufige Gründe: Das Image ist für
  eine andere Hardware-Version oder Region (Aufkleber prüfen), der Dateiname
  ist zu lang (kurz umbenennen, z. B. in `factory.bin`), oder die
  Herstellerfirmware ist zu neu und sperrt fremde Firmware (siehe "Vorher
  prüfen", falls vorhanden).
- **Nach dem Neustart ist unter `http://192.168.1.1` nichts.** Stell den
  Rechner auf "automatisch" und zieh das Kabel kurz ab und wieder an. Je nach
  Community startet die Firmware auch gleich im Betrieb ohne
  Einrichtungsseite.

## Notfall: Firmware per TFTP

Startet das Gerät nicht mehr richtig, etwa nach einem abgebrochenen Update
oder weil es in einer Startschleife hängt, kann es sich eine Firmware selbst
von deinem Rechner holen. Dafür brauchst du einen
TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)) und eine
feste Adresse am Rechner ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

1. Leg das factory-Image unter dem Namen `ArcherC6v2_tp_recovery.bin` in den
   Ordner des TFTP-Servers. Genau dieser Name, Groß- und Kleinschreibung
   zählt.
2. Stell deinen Rechner fest auf `192.168.0.66`, Netzmaske
   `255.255.255.0`, und starte den TFTP-Server.
3. Kabel an eine LAN-Buchse, Strom aus. Drück die Reset-Taste, halte sie
   gedrückt und schalte den Strom ein. Halte sie gedrückt:
   bis die WPS-LED leuchtet.
4. Warten, etwa 150 Sekunden. Das Gerät
   schreibt die Datei und startet neu.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg), Bedingung an die Herstellerfirmware)
- geprüft (Weg ab Werk, Schritte (Normalweg), Programm, Datei, Notweg, Quelle (OpenWrt-Commit))
- geprüft: Commit d03aae1a (Notweg)
- geprüft: Wiki toh:tp-link:archer_c6_v2 (Bedingung an die Herstellerfirmware)
- geprüft: tplink-safeloader ARCHER-C6-V2 / -US, Commit d03aae1a; Gluon targets/ath79-generic (Schritte (Normalweg), Typenschild/Verwechslung)
- Geräteeintrag: d03aae1a09fce5a5d5747855bc07ee1f54388e03 [geprüft]
