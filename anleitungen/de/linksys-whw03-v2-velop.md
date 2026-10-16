---
gluon_name: linksys-whw03-v2-velop
modell: Linksys WHW03 v2 (Velop)
anzeige: Linksys WHW03 v2 (Velop)
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: ungeprüft
grundlagen: []
daten_stand: 7e377f68
vorlage_stand: bfd04827
---

# Linksys WHW03 v2 (Velop): Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Linksys%20WHW03%20v2%20%28Velop%29)

Beim Linksys WHW03 v2 (Velop) geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Linksys WHW03 v2 (Velop), und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "Linksys WHW03 v2 (Velop)", bevor du anfängst.

## Vorher prüfen

WHW03 v2 und [WHW03 v1](linksys-whw03-velop.md) brauchen je ihr eigenes
Image. Hochgeladen wird im Support-Modus unter `http://192.168.1.1/ca`,
Bereich "Connectivity". Laut OpenWrt gehen auch
`https://192.168.1.1/fwupdate.html` oder `http://10.65.1.1/ca`. Nicht
eingerichtete Geräte haben das Passwort `admin`.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.1.1/ca`.
   Melde dich an: mit dem Admin-Passwort (bei nicht eingerichteten Geräten `admin`).

4. **Firmware-Update aufrufen.** Geh zu **Connectivity**.

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

## Zurück zur Linksys-Firmware

Dreimal hintereinander einschalten und nach etwa 2 Sekunden wieder
ausschalten. Dann startet die vorherige Firmware.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit 9e4ede83 (Schritte (Normalweg), Adressen, Programm, Zugang, Datei, Rückweg zur Herstellerfirmware)
- geprüft: Commit 9e4ede83/c9048755 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Wiki toh:linksys:whw03_v2 (Adressen, Zugang)
- Geräteeintrag: OpenWrt 9e4ede8344d60d4837e047e9275c21fd2a8f130b
