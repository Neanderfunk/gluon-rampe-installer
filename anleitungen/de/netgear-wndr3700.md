---
gluon_name: netgear-wndr3700
modell: NETGEAR WNDR3700 v1
anzeige: NETGEAR WNDR3700 v1
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found]
daten_stand: d343091b
vorlage_stand: 883c350d
---

# NETGEAR WNDR3700 v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20NETGEAR%20WNDR3700%20v1)

Beim NETGEAR WNDR3700 v1 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den NETGEAR WNDR3700 v1, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "NETGEAR WNDR3700 v1", bevor du anfängst.

## Vorher prüfen

WNDR3700 v1, WNDR3700 v2, WNDR3800, WNDR3800CH und WNDRMAC v2 sind eine
Gerätefamilie, aber jedes Modell braucht sein **eigenes** Image. Der
WNDR3700 v3 geht nicht (anderer Chip), der WNDR3700 v4 ist ein anderes
Gerät mit eigenem Image.

**v1 oder v2?** Auf dem Aufkleber sind die beiden oft nicht zu
unterscheiden. Hinweise laut OpenWrt: Auf dem Karton steht bei der v2
"(WNDR3700v2)" unter "Package Contents"; die Netgear-Oberfläche zeigt die
Hardware-Version unter "Maintenance" bzw. "Router Status"; Herstellerfirmware
1.0.4.x und höher gehört zur v1, 1.0.1.x und älter zur v2.

Außerhalb Nordamerikas warnt die Netgear-Oberfläche womöglich, das Image
gebe sich als Nordamerika-Version aus. Laut OpenWrt kannst du das
ignorieren.

Geräte mit nordamerikanischer Netgear-Firmware nehmen das Freifunk-Image
womöglich nicht an; dafür gäbe es ein eigenes Image, das Gluon nicht baut.

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
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).
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

- abgeleitet (Schritte (Normalweg), Übertragung, Quelle (OpenWrt-Commit))
- abgeleitet: Commit ohne Anleitung (Weg ab Werk, Schritte (Normalweg), Programm, Datei)
- geprüft: OpenWrt generic.mk IMAGE/factory-NA.img, Gluon targets/ath79-generic; Folge abgeleitet (Typenschild/Verwechslung)
- geprüft: OpenWrt generic.mk/nand.mk (Typenschild/Verwechslung)
- geprüft: Wiki toh:netgear:wndr3700 (Schritte (Normalweg), Sichtbare Zeichen, Typenschild/Verwechslung)
- Geräteeintrag: 4dc7cb792a8e34b6ad97c7b8058c70311a06bd38 [abgeleitet]
