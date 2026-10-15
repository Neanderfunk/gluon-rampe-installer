---
gluon_name: tp-link-archer-ax23-v1
modell: "TP-Link Archer AX23 v1 (Gluon: broken)"
anzeige: TP-Link Archer AX23 v1
familie: k0-webui
gluon_broken: true
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [curl]
daten_stand: 440a725
vorlage_stand: bfd0482
---

# TP-Link Archer AX23 v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
> Die Freifunk-Firmware für dieses Gerät gilt bei Gluon als nicht ausreichend
> getestet ("broken"); nicht jede Community bietet sie an.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20Archer%20AX23%20v1)

Beim TP-Link Archer AX23 v1 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link Archer AX23 v1, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link Archer AX23 v1", bevor du anfängst.

## Vorher prüfen

Hardware-Version 1.0, 1.2 und 1.20 sind gleich, auch der "AX1800" mit
Hardware 1.20 läuft. Der **Archer AX23 v2 geht nicht**, er hat einen ganz
anderen Chip.

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

## Notfall: Web-Recovery

Der AX23 hat eine Notfall-Seite, die das factory-Image annimmt: Strom aus,
Reset-Taste gedrückt halten, Strom ein, halten, bis die orange WAN-LED
leuchtet. Dann mit fester Adresse im Netz 192.168.0.x die Seite
`http://192.168.0.1` öffnen und das factory-Image hochladen. Laut OpenWrt
geht der Upload auch mit curl ([curl benutzen](grundlagen/curl.md)):

```
curl -F firmware=@factory.bin http://192.168.0.1/f2.htm
```

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk, Schritte (Normalweg), Notweg)
- geprüft: Commit 7dceef5e (Notweg)
- geprüft: Wiki toh:tp-link:archer_ax23_v1 (Schritte (Normalweg), Adressen, Programm, Datei, Typenschild/Verwechslung, Notweg)
- geprüft: tplink-safeloader ARCHER-AX23-V1 (Typenschild/Verwechslung)
- Geräteeintrag: 7dceef5ee554ec4ab5d2dd2ff999f4a60bf2e0f4
