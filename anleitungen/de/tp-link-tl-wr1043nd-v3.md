---
gluon_name: tp-link-tl-wr1043nd-v3
modell: TP-Link TL-WR1043N/ND v3
anzeige: TP-Link TL-WR1043N/ND v3
familie: k0-webui
gluon_broken: false
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: []
daten_stand: lokal
vorlage_stand: 393f161
---

# TP-Link TL-WR1043N/ND v3: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20TL-WR1043N/ND%20v3)

Beim TP-Link TL-WR1043N/ND v3 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link TL-WR1043N/ND v3, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link TL-WR1043N/ND v3", bevor du anfängst.

## Vorher prüfen

TL-WR1043N/ND v2, v3, v4 und der TL-WR1043N v5 brauchen je ihr eigenes
Image, auch wenn sich manche sehr ähnlich sind. Prüf die Version auf dem
Aufkleber: Diese Anleitung ist für die **v3**.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.0.1` oder `http://192.168.1.1`.
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
- **Die Seite fragt immer wieder "Please choose a file to upgrade".** Der
  Dateiname ist zu lang. Benenne die Datei um, z. B. in `firmware.bin`.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg), Quelle (OpenWrt-Commit))
- abgeleitet: Commit ohne Anleitung (Weg ab Werk, Schritte (Normalweg), Datei)
- geprüft: OpenWrt generic-tp-link.mk, Hardware-ID 0x10430002/0x10430003 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Wiki toh:tp-link:tl-wr1043nd (Schritte (Normalweg), Programm, Typenschild/Verwechslung, Fehlerbild)
- geprüft: Wiki toh:tp-link:tl-wr1043nd, korrigiert (Adressen)
- Geräteeintrag: b1a173d7c396c0a9e6bb0078a1a061eb9fdd0316 (ohne Anleitung) [abgeleitet]
