---
gluon_name: zyxel-nbg6617
modell: Zyxel NBG6617
familie: k0-webui
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [tftp-server]
daten_stand: fbe5766
vorlage_stand: aa479e3
---

> **Noch nicht am Gerät erprobt.** Diese Anleitung ist aus Quellen
> zusammengestellt, aber noch niemand hat sie an einem Zyxel NBG6617 Schritt
> für Schritt nachvollzogen. Wenn du es tust: Schreib uns an
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de), ob es geklappt hat.

# Zyxel NBG6617: Freifunk-Firmware installieren

Beim Zyxel NBG6617 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Zyxel NBG6617, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "Zyxel NBG6617", bevor du anfängst.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.1.1`.
   Melde dich an: Passwort `1234`.

4. **Firmware-Update aufrufen.** Geh zu **Expert Mode → Maintenance → Firmware Upgrade**.

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

## Zurück zur Zyxel-Firmware

Per TFTP: Rechner fest auf `192.168.1.99` an LAN, die Zyxel-Firmware
(V1.00(ABCT.X).bin) als `ras.bin` im TFTP-Server
([TFTP-Server einrichten](grundlagen/tftp-server.md)), WPS-Taste beim
Einschalten 30 Sekunden halten, dann lange warten. Fertig, wenn die
Power-LED langsam und USB- und WPS-LED schnell blinken; dann neu starten.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- geprüft (Weg ab Werk, Schritte (Normalweg), Datei, Notweg)
- geprüft: Commit 82618062 (Schritte (Normalweg), Sichtbare Zeichen, Adressen, Programm, Zugang, Rückweg zur Herstellerfirmware)
- geprüft: Wiki toh:zyxel:nbg6617 (Adressen)
- Geräteeintrag: OpenWrt 82618062cf7ed6b40d2c52c6f6b96364888ffda6
