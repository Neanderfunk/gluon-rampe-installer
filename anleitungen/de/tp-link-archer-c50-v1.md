---
gluon_name: tp-link-archer-c50-v1
modell: TP-Link Archer C50 v1
anzeige: TP-Link Archer C50 v1
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: ungeprüft
grundlagen: []
daten_stand: 9936ce50
vorlage_stand: bfd04827
---

# TP-Link Archer C50 v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20Archer%20C50%20v1)

Beim TP-Link Archer C50 v1 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link Archer C50 v1, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade" (mit „-eu“ bzw. „-us“ im Namen, passend zur Region auf dem Aufkleber)

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link Archer C50 v1", bevor du anfängst.

## Vorher prüfen

- **Wichtig:** Läuft auf einem EU-Gerät die Herstellerfirmware **160411**,
  spiel zuerst eine ältere TP-Link-Firmware ein. Sonst wird der Router laut
  OpenWrt unbrauchbar.
- **Region:** Gluon baut das factory-Image getrennt für EU und USA ("-eu"
  bzw. "-us" im Namen). Nimm die Variante, die zu deinem Gerät passt. Nicht
  jede Community baut beide.
- Nur der Archer C50 **v1**. Die C50 v3, v4 und v6 sind andere Geräte mit
  eigenen Images.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.0.1`.
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
- abgeleitet: Gluon baut factory; Wiki nennt TFTP-Recovery wie TL-WDR4300 (Weg ab Werk, Schritte (Normalweg), Notweg)
- geprüft: Gluon targets/ramips-mt7620, ramips-mt76x8 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Wiki toh:tp-link:archer-c50 (Schritte (Normalweg), Warnung, Adressen, Programm, Bedingung an die Herstellerfirmware)
- geprüft: templates/common/site.mk, Gluon targets/ramips-mt7620; Folge abgeleitet (Schritte (Normalweg), Datei, Typenschild/Verwechslung)
- Geräteeintrag: 1c00c09eb6af88a0a96451f8da6108171c46a42d (ohne Installationstext)
