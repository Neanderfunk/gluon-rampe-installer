---
gluon_name: tp-link-tl-wdr3600-v1
modell: TP-Link TL-WDR3600 v1
anzeige: TP-Link TL-WDR3600 v1
familie: k0-webui
gluon_broken: false
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: []
daten_stand: 154f6f8
vorlage_stand: bfd0482
---

# TP-Link TL-WDR3600 v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
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
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link TL-WDR3600 v1", bevor du anfängst.

## Vorher prüfen

- **Herstellerfirmware:** Version 3.14.3 (Build 151104) sperrt fremde
  Firmware. OpenWrt empfiehlt, vorher die TP-Link-Firmware 3.13.33 (130617)
  einzuspielen.
- **Dateiname:** Die Oberfläche ist hier besonders wählerisch: Sie meldet
  "firmware path too long" bei zu langen **und** zu kurzen Namen. Laut
  OpenWrt nimmt sie den Namen `wdr4300v1_en_3_14_3_up_boot(150518).bin` an.
  Ob es genau dieser sein muss, ist nicht geklärt.
- Der TL-WDR4300 sieht ähnlich aus, braucht aber ein eigenes Image.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter. Benenne es danach in `wdr4300v1_en_3_14_3_up_boot(150518).bin` um, genau
   so. Die Oberfläche lehnt den langen Originalnamen sonst ab. Achtung:
   Windows blendet Dateiendungen gern aus; schalte sie im Explorer unter
   "Ansicht" ein, damit nicht `wdr4300v1_en_3_14_3_up_boot(150518).bin.bin` daraus wird.

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

- abgeleitet (Quelle (OpenWrt-Commit))
- abgeleitet: Commit ohne Anleitung (Weg ab Werk)
- abgeleitet: Wiki-Zusammenfassung, im Rohtext toh:tp-link:tl-wdr4300_v1 nicht gefunden (Schritte (Normalweg), Dauer)
- abgeleitet: offen (Datei)
- geprüft: OpenWrt generic-tp-link.mk (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: WDR3600-Seite verweist darauf, Wiki toh:tp-link:tl-wdr4300_v1 (Schritte (Normalweg), Adressen, Programm, Zugang)
- geprüft: Wiki toh:tp-link:tl-wdr3600_v1 (Typenschild/Verwechslung)
- geprüft: tl-wdr3600_v1, Wiki toh:tp-link:tl-wdr4300_v1 (Schritte (Normalweg), Datei, Fehlerbild)
- geprüft: tl-wdr3600_v1, Wiki toh:tp-link:tl-wdr4300_v1, toh:tp-link:tl-wdr3600_v1 (Bedingung an die Herstellerfirmware)
- Geräteeintrag: a7e1e919afa9659f66dada5e69d1b162f447ced7 (ohne Anleitung) [abgeleitet]
