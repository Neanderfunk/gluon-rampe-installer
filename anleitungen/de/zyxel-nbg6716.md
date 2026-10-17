---
gluon_name: zyxel-nbg6716
modell: Zyxel NBG6716
anzeige: Zyxel NBG6716
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, router-antwortet-nicht, tftp-server]
daten_stand: 53055667
vorlage_stand: 33a38da8
---

# Zyxel NBG6716: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> OpenWrt beschreibt nicht, wie die Datei aus der Zyxel-Firmware heraus auf das Gerät kommt; den Weg über die Zyxel-Oberfläche haben wir angenommen.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Zyxel%20NBG6716)

Beim Zyxel NBG6716 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Zyxel NBG6716, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "Zyxel NBG6716", bevor du anfängst.

## Vorher prüfen

Den NBG6716 gibt es mit verschieden großem Speicher; von außen sieht man das
nicht, die Freifunk-Firmware nutzt in jedem Fall nur 128 MB. Der EMG2926
(Videotron) ist baugleich, lehnt NBG6716-Images aber ab.

Wie die Installation aus der Zyxel-Firmware heraus geht, beschreibt OpenWrt
nicht; diese Anleitung geht vom üblichen Weg über die Weboberfläche aus.

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
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
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
  Rechner auf "automatisch" und zieh das Kabel kurz ab und wieder an
  ([Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md)).
  Je nach Community startet die Firmware auch gleich im Betrieb ohne
  Einrichtungsseite.

## Zurück zur Zyxel-Firmware

Per TFTP: Rechner fest auf `192.168.1.33`, die Zyxel-Firmware als `ras.bin`
im TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)),
WPS-Taste beim Einschalten halten. Das Schreiben dauert etwa 10 Sekunden,
danach blinken Power- und Key-LED schnell.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg), Übertragung, Quelle (OpenWrt-Commit))
- abgeleitet: Web-UI (Weg ab Werk, Schritte (Normalweg), Programm, Datei)
- geprüft: Commit 99835e09 (Typenschild/Verwechslung)
- geprüft: Wiki toh:zyxel:nbg6716 (Schritte (Normalweg), Rückweg zur Herstellerfirmware)
- geprüft: Wiki toh:zyxel:nbg6716; "von außen nicht unterscheidbar" im Rohtext nicht gefunden (Typenschild/Verwechslung)
- Geräteeintrag: 99835e09992bb411519fda1f8d16a6d07df7f598 [abgeleitet]
