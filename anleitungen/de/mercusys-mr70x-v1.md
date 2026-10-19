---
gluon_name: mercusys-mr70x-v1
modell: Mercusys MR70X v1
anzeige: Mercusys MR70X v1
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: erprobt
erprobt_am: 2026-10-17
erprobt_mit: Gluon 2025.1 (26100702bro), factory über die Mercusys-Oberfläche 1.0.11 (Hardware V1.20)
grundlagen: [browser-not-found, router-antwortet-nicht]
daten_stand: 25f2bbde
vorlage_stand: 33a38da8
---

# Mercusys MR70X v1: Freifunk-Firmware installieren

> **Am Gerät erprobt** am 17.10.2026 mit `Gluon 2025.1 (26100702bro), factory über die Mercusys-Oberfläche 1.0.11 (Hardware V1.20)`.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Mercusys%20MR70X%20v1)

> **Achtung:** Einen einfachen Weg zurück zur Mercusys-Firmware gibt es nach der
> Installation nicht.
> Sobald einmal OpenWrt oder die Freifunk-Firmware auf dem MR70X war, nimmt
> seine Notfall-Seite (Reset-Taste beim Einstecken) keine Mercusys-Firmware
> mehr an. Sie meldet trotzdem jedes Mal Erfolg.

Beim Mercusys MR70X v1 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Mercusys MR70X v1, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "Mercusys MR70X v1", bevor du anfängst.

## Vorher prüfen

- Das Image passt zum MR70X und zum baugleichen MR1800X mit Hardware 1 (auf
  dem Aufkleber "1.0" oder "1.20"; mit 1.20 lief die Freifunk-Firmware bei
  uns). Die Oberfläche nennt sich dabei "MR70X v1.0", auch bei 1.20 auf dem
  Aufkleber. Für Hardware 2 gilt diese Anleitung nicht.
- Beim ersten Aufruf verlangt die Oberfläche ein eigenes Passwort ("Create
  an administrator password"). Die Schnelleinrichtung danach oben rechts
  verlassen und mit "EXIT" bestätigen ("Your settings will not be saved").
- Kommt stattdessen "Log In with Local Password" und du kennst das Passwort
  nicht, stecken noch Einstellungen eines Vorbesitzers drin. Dann halte die
  Reset-Taste im laufenden Betrieb etwa 10 Sekunden gedrückt, das setzt ihn
  zurück. Nicht beim Einstecken drücken, das startet die Notfall-Seite.
- Meldet die Oberfläche nach dem Anmelden "Firmware Update Available", klick
  "NOT NOW". Das Update von Mercusys brauchst du nicht.

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

4. **Firmware-Update aufrufen.** Geh zu **Advanced → System → Firmware Update → Local Update**.

5. **Hochladen.** Wähl das factory-Image aus, starte das Update und
   bestätige die Rückfragen. Danach zeigt der Browser „Uploading...“. Das
   ist normal.

6. **Warten.** Das Gerät schreibt die Firmware und startet neu. Das dauert
   einige Minuten; beim ersten Start der Freifunk-Firmware startet der Router nach etwa 70 Sekunden noch einmal von selbst neu.
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
- **Der Router startet nur noch die Notfall-Seite** ("System error. The
  router cannot start up normally …"), auch nach erneutem Hochladen. Dann
  hat der Bootloader im Speicher eine Markierung gelöscht, ohne die er keine
  Firmware mehr startet. Warum, wissen wir nicht. Über die Notfall-Seite
  lässt sich das nicht beheben, ihre Erfolgsmeldung gilt nicht. Es geht nur
  noch mit einer seriellen Konsole bei geöffnetem Gehäuse, also etwas für
  Erfahrene (beschrieben im OpenWrt-Forum,
  [Thema 160069](https://forum.openwrt.org/t/160069)).

## Zurück zur Mercusys-Firmware

Nach der Installation geht das nicht mehr über die Notfall-Seite (siehe
"Achtung" oben). Zurück geht es dann nur noch mit einer seriellen Konsole
bei geöffnetem Gehäuse. Das haben wir ausprobiert, es ist aber nichts für
Endnutzer (Hintergrund im OpenWrt-Forum,
[Thema 160069](https://forum.openwrt.org/t/160069)).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg), Rückweg zur Herstellerfirmware)
- geprüft (Weg ab Werk, Schritte (Normalweg), Programm, Datei)
- geprüft: Commit 47de2c68 (Rückweg zur Herstellerfirmware)
- geprüft: Test Neanderfunk 17.10.2026 (Weg ab Werk, Typenschild/Verwechslung, Fehlerbild, Notweg, Rückweg zur Herstellerfirmware)
- geprüft: tplink-safeloader MR70X (Schritte (Normalweg), Typenschild/Verwechslung)
- Geräteeintrag: 47de2c686291e69afc9f443e27e1dfd11ed5fbe7
