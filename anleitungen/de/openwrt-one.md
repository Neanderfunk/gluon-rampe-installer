---
gluon_name: openwrt-one
modell: OpenWrt One
anzeige: OpenWrt One
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
risiko: normal
status: ungeprüft
grundlagen: []
daten_stand: 3b96298
vorlage_stand: bfd0482
---

# OpenWrt One: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20OpenWrt%20One)

Beim OpenWrt One geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den OpenWrt One, und zwar das
  **sysupgrade**-Image

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "OpenWrt One", bevor du anfängst.

## Vorher prüfen

Der OpenWrt One kommt ab Werk schon mit OpenWrt. Die "Herstelleroberfläche"
ist hier also die Weboberfläche von OpenWrt (LuCI), und du brauchst das
**sysupgrade**-Image (Endung `.itb`), kein factory-Image.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.1.1`.
   Melde dich mit den Zugangsdaten vom Aufkleber an, oder leg beim ersten
   Aufruf ein Passwort fest.

4. **Firmware-Update aufrufen.** Geh zu **System → Backup / Flash Firmware**.

5. **Hochladen.** Wähl das sysupgrade-Image aus, starte das Update und
   bestätige die Rückfragen. Bietet die Seite an, die Einstellungen
   zu behalten ("Keep settings"), **entfern diesen Haken**.

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

## Zurück

Der OpenWrt One hat zwei Notfall-Wege: per USB (FAT32-Stick, Reset-Taste
hinten beim Einschalten halten) und über den zweiten Bootloader (Schalter
auf NOR, vorderen Taster beim Einschalten halten). Einzelheiten stehen im
OpenWrt-Wiki: <https://openwrt.org/toh/openwrt/one>.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- abgeleitet: Image-Rezept, Commit ohne Installationsabschnitt (Weg ab Werk, Schritte (Normalweg), Programm, Datei, Notweg)
- geprüft: Wiki toh:openwrt:one (Schritte (Normalweg), Taste und Zeitpunkt, Bedingung an die Herstellerfirmware, Rückweg zur Herstellerfirmware)
- Geräteeintrag: OpenWrt 797904b3cb4a5c575641c19e7f3989926e4c7902
