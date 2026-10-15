---
gluon_name: tp-link-archer-c6-v3
modell: TP-Link Archer C6 v3 (Gluon: broken)
familie: k0-webui
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: []
daten_stand: 0a4f2b3
vorlage_stand: aa479e3
---

> **Noch nicht am Gerät erprobt.** Diese Anleitung ist aus Quellen
> zusammengestellt, aber noch niemand hat sie an einem TP-Link Archer C6 v3 (Gluon: broken) Schritt
> für Schritt nachvollzogen. Wenn du es tust: Schreib uns an
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de), ob es geklappt hat.

# TP-Link Archer C6 v3 (Gluon: broken): Freifunk-Firmware installieren

Beim TP-Link Archer C6 v3 (Gluon: broken) geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link Archer C6 v3 (Gluon: broken), und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link Archer C6 v3 (Gluon: broken)", bevor du anfängst.

## Vorher prüfen

Der Archer C6 v3 ist baugleich mit dem Archer A6 v3. Der Nachfolger
**Archer C6 v4 sieht außen gleich aus, geht aber nicht** (andere CPU, zu
wenig Speicher). Der Archer C6 v2 ist ebenfalls ein anderes Gerät. Prüf die
Version auf dem Aufkleber.

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

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit d22fb7f4 (Schritte (Normalweg), Programm, Datei)
- geprüft: Commit d22fb7f4; tplink-safeloader ARCHER-C6-V3 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Wiki toh:tp-link:archer_c6_v3 (Schritte (Normalweg), Typenschild/Verwechslung)
- Geräteeintrag: d22fb7f4fd833c420bc2ab34384862da0a6688b5
