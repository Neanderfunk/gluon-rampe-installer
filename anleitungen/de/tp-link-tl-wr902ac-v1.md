---
gluon_name: tp-link-tl-wr902ac-v1
modell: TP-Link TL-WR902AC v1 (broken)
familie: k0-webui
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [feste-ip, tftp-server]
daten_stand: 0d84d1c
vorlage_stand: 47c7bb2
---

> **Noch nicht am Gerät erprobt.** Diese Anleitung ist aus Quellen
> zusammengestellt, aber noch niemand hat sie an einem TP-Link TL-WR902AC v1 (broken) Schritt
> für Schritt nachvollzogen. Wenn du es tust: Schreib uns an
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de), ob es geklappt hat.

# TP-Link TL-WR902AC v1 (broken): Freifunk-Firmware installieren

Beim TP-Link TL-WR902AC v1 (broken) geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link TL-WR902AC v1 (broken), und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link TL-WR902AC v1 (broken)", bevor du anfängst.

## Vorher prüfen

Der TL-WR902AC sieht fast aus wie der TL-MR3020, ist aber ein anderes Gerät.
Das Image passt nur zu Geräten für EU und USA.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter. Benenne es danach in `update.bin` um, genau
   so. Die Oberfläche lehnt den langen Originalnamen sonst ab. Achtung:
   Windows blendet Dateiendungen gern aus; schalte sie im Explorer unter
   "Ansicht" ein, damit nicht `update.bin.bin` daraus wird.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser die Adresse der Oberfläche. Sie steht meist
   auf dem Aufkleber unter dem Gerät. Melde dich mit
   den Zugangsdaten vom Aufkleber an, oder leg beim ersten Aufruf ein
   Passwort fest.

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

Startet das Gerät nach einem abgebrochenen Update nicht mehr, kann es sich
eine Firmware selbst von deinem Rechner holen. Dafür brauchst du einen
TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)) und eine
feste Adresse am Rechner ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

1. Leg das factory-Image unter dem Namen `wr902acv1_un_tp_recovery.bin` in den
   Ordner des TFTP-Servers. Genau dieser Name, Groß- und Kleinschreibung
   zählt.
2. Stell deinen Rechner fest auf `192.168.0.66`, Netzmaske
   `255.255.255.0`, und starte den TFTP-Server.
3. Kabel an eine LAN-Buchse, Strom aus. Drück die Reset-Taste, halte sie
   gedrückt und schalte den Strom ein. Halte sie gedrückt:
   bis die WPS-LED leuchtet.
4. Warten. Das Gerät
   schreibt die Datei und startet neu.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk, Schritte (Normalweg), Programm, Notweg, Quelle (OpenWrt-Commit))
- geprüft: Commit 60de1fdb (Schritte (Normalweg), Typenschild/Verwechslung, Notweg, Rückweg zur Herstellerfirmware)
- geprüft: Wiki toh:tp-link:tl-wr902ac_v1 (Schritte (Normalweg), Datei)
- geprüft: tplink-safeloader TL-WR902AC-V1 (Schritte (Normalweg), Typenschild/Verwechslung)
- Geräteeintrag: 60de1fdbb4492b5270edf49d634979c0cfd1e743 [geprüft]
