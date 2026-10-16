---
gluon_name: tp-link-re200-v3
modell: TP-Link RE200 v3
anzeige: TP-Link RE200 v3
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found]
daten_stand: 7e0c7878
vorlage_stand: dd72aaab
---

# TP-Link RE200 v3: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20RE200%20v3)

Beim TP-Link RE200 v3 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link RE200 v3, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link RE200 v3", bevor du anfängst.

## Vorher prüfen

- RE200 v2, v3 und v4 brauchen je ihr eigenes Image; diese Anleitung ist für
  die **v3**. Der **RE200 v5 geht nicht**.
- **Herstellerfirmware:** Version neuer als 1.1.0 lehnt die Freifunk-Firmware
  ab. Spiel vorher die TP-Link-Firmware 1.1.0 ein; laut OpenWrt gibt es sie
  auf der EU-Seite von TP-Link, nicht auf der US-Seite.
- Der RE200 hat **keinen Notfall-Weg**. Geht beim Hochladen etwas schief,
  hilft nur noch die serielle Konsole, und dafür muss das verschweißte
  Gehäuse auf. Also: Datei und Version genau prüfen, und während der
  Installation den Stecker in Ruhe lassen.

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
   bis zu 20 Minuten.
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
  eine andere Hardware-Version oder Region (Aufkleber prüfen), es ist das sysupgrade- statt des factory-Images, der Dateiname
  ist zu lang (kurz umbenennen, z. B. in `factory.bin`), oder die
  Herstellerfirmware ist zu neu und sperrt fremde Firmware (siehe "Vorher
  prüfen", falls vorhanden).
- **Nach dem Neustart ist unter `http://192.168.1.1` nichts.** Stell den
  Rechner auf "automatisch" und zieh das Kabel kurz ab und wieder an. Je nach
  Community startet die Firmware auch gleich im Betrieb ohne
  Einrichtungsseite.

## Notfall

Der RE200 hat keinen Notfall-Weg ohne Öffnen des Gehäuses.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: getrennte Gluon-Geräte; OpenWrt-Commits (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft (Weg ab Werk, Schritte (Normalweg), Programm, Datei)
- geprüft: Commit 6d6f36ae/009e62c9/33b76d66 (Warnung)
- geprüft: Wiki toh:tp-link:re200 (Schritte (Normalweg), Typenschild/Verwechslung, Bedingung an die Herstellerfirmware)
- nicht ausstecken abgeleitet; geprüft: Wiki toh:tp-link:re200 (Schritte (Normalweg), Dauer)
- Geräteeintrag: 009e62c92c35142c5be3b375d6c393e63d2d27eb
