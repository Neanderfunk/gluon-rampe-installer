---
gluon_name: zyxel-nwa50ax
modell: ZyXEL NWA50AX (Alias NWA90AX)
anzeige: ZyXEL NWA50AX / NWA90AX
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
level_text: Hochladen, richtige Datei wählen
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found]
daten_stand: 1d8a57e2
vorlage_stand: 883c350d
---

# ZyXEL NWA50AX / NWA90AX: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20ZyXEL%20NWA50AX%20/%20NWA90AX)

Beim ZyXEL NWA50AX / NWA90AX geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den ZyXEL NWA50AX / NWA90AX, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "ZyXEL NWA50AX / NWA90AX", bevor du anfängst.

## Vorher prüfen

Der NWA50AX ist ein anderes Gerät als der [NWA50AX Pro](zyxel-nwa50ax-pro.md), mit eigenem Image.

**Zwei Firmware-Speicher:** Diese Geräte haben zwei Plätze für die Firmware.
Die Freifunk-Firmware läuft nur vom ersten. Damit die Zyxel-Oberfläche sie
dorthin schreibt, muss vorher der zweite aktiv sein. Startet die
Freifunk-Firmware nur einmal und danach wieder die Zyxel-Firmware, war das
nicht so: dann zuerst ein beliebiges Zyxel-Update einspielen und noch einmal
von vorn.

**Gebrauchte Geräte und die Zyxel-Cloud (Nebula):** War das Gerät beim
Vorbesitz in der Zyxel-Cloud "Nebula" angemeldet, holt es sich nach einem
Werksreset innerhalb von etwa 30 Minuten wieder die Cloud-Einstellungen, und
die Oberfläche verlangt das Nebula-Passwort ("This device is managed by
Nebula"). Herauslösen lässt es sich, indem man es mit einem anderen
Nebula-Konto übernimmt (force adopt, QR-Code in der Nebula-App) und dort
wieder abmeldet. Das haben wir nicht selbst ausprobiert. In einem Forumsfall
half stattdessen: Werksreset und sofort die Nebula-Erkennung mit dem
Zyxel-Werkzeug ZON abschalten.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser die Adresse der Oberfläche (sie steht meist auf dem Aufkleber unter dem Gerät).
   Melde dich an: Benutzer `admin`, Passwort `1234`.

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
- **"ULCGI unable to parse CGI query".** Der Dateiname ist zu lang. Benenne
  die Datei kurz um, zum Beispiel in `factory.bin`.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Forum-Zusammenfassung: community.zyxel.com/en/discussion/29636 (Bedingung an die Herstellerfirmware)
- abgeleitet: adorfer, Hörensagen; Ablauf Unregister: mysupport.zyxel.com/hc/en-us/articles/360006459099, nicht gelesen (Bedingung an die Herstellerfirmware)
- geprüft (Weg ab Werk, Schritte (Normalweg), Programm, Datei)
- geprüft: Commit a0b7fef0/f0445746 (Schritte (Normalweg), Typenschild/Verwechslung, Bedingung an die Herstellerfirmware, Fehlerbild)
- geprüft: Wiki toh:zyxel:nwa50ax (Schritte (Normalweg), Sichtbare Zeichen, Zugang, Fehlerbild)
- Geräteeintrag: a0b7fef0ffe4cd9cca39a652a37e4f3ce8f0a681
