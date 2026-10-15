---
gluon_name: tp-link-archer-c5-v1
modell: TP-Link Archer C5 v1
familie: k0-webui
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: []
daten_stand: 5e09bfd
vorlage_stand: 7deda71
---

> **Noch nicht am Gerät erprobt.** Diese Anleitung ist aus Quellen
> zusammengestellt, aber noch niemand hat sie an einem TP-Link Archer C5 v1 Schritt
> für Schritt nachvollzogen. Wenn du es tust: Schreib uns an
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de), ob es geklappt hat.

# TP-Link Archer C5 v1: Freifunk-Firmware installieren

Beim TP-Link Archer C5 v1 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link Archer C5 v1, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link Archer C5 v1", bevor du anfängst.

## Vorher prüfen

Nur der Archer C5 **v1** (drei Antennen innen, drei außen). Spätere C5-Versionen
sind andere Geräte.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter. Benenne es danach in `factory.bin` um, genau
   so. Die Oberfläche lehnt den langen Originalnamen sonst ab. Achtung:
   Windows blendet Dateiendungen gern aus; schalte sie im Explorer unter
   "Ansicht" ein, damit nicht `factory.bin.bin` daraus wird.

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

- Rest abgeleitet; geprüft: Wiki toh:tp-link:archer-c5-c7-wdr7500 (Schritte (Normalweg), Typenschild/Verwechslung)
- abgeleitet (Schritte (Normalweg), Quelle (OpenWrt-Commit))
- abgeleitet: Commit ohne Anleitung (Weg ab Werk)
- geprüft: Wiki toh:tp-link:archer-c5-c7-wdr7500 (Schritte (Normalweg), Adressen, Programm, Zugang, Datei)
- geprüft: Wiki toh:tp-link:archer-c5-c7-wdr7500, Abschnitt TFTP Recovery (Schritte (Normalweg), Warnung, Dauer)
- Geräteeintrag: 438605454980ee815a506a9a2a4a3532ab378922 (ohne Anleitung, Wiki-Verweis) [abgeleitet]
