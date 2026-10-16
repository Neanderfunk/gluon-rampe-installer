---
gluon_name: zyxel-nwa50ax-pro
modell: Zyxel NWA50AX Pro
anzeige: Zyxel NWA50AX Pro
familie: k0-webui
gluon_broken: false
sprache: de
level: L3
level_text: Feste Adresse am Rechner
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip]
daten_stand: 9d9d8227
vorlage_stand: dd72aaab
---

# Zyxel NWA50AX Pro: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Zyxel%20NWA50AX%20Pro)

Beim Zyxel NWA50AX Pro geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Zyxel NWA50AX Pro, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "Zyxel NWA50AX Pro", bevor du anfängst.

## Vorher prüfen

Der NWA50AX Pro ist ein anderes Gerät als der [NWA50AX](zyxel-nwa50ax.md), mit eigenem Image. Laut OpenWrt scheitert die Installation, wenn die Zyxel-Firmware vorher eine ungerade Zahl von Malen aktualisiert wurde; dann einmal ein Zyxel-Update einspielen.

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
   Stell deinen Rechner auf die feste Adresse `192.168.1.10` mit der
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

3. **Oberfläche öffnen.** Öffne im Browser `192.168.1.2`.
   Melde dich an: Benutzer `admin`, Passwort vom Aufkleber hinten oder `1234`.

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
   "Not Found"](grundlagen/browser-not-found.md). Stell den Rechner vorher wieder auf "automatisch".
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
- **Fehler beim Hochladen.** Dateinamen kürzen, zum Beispiel in
  `factory.bin`.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Forum-Zusammenfassung: community.zyxel.com/en/discussion/29636 (Bedingung an die Herstellerfirmware)
- abgeleitet (Schritte (Normalweg))
- abgeleitet: Rechner fest auf 192.168.1.10, wenn kein DHCP; die Quelle nennt nur das Gerät unter 192.168.1.2 (Adressen)
- abgeleitet: adorfer, Hörensagen; Ablauf Unregister: mysupport.zyxel.com/hc/en-us/articles/360006459099, nicht gelesen (Bedingung an die Herstellerfirmware)
- geprüft (Weg ab Werk, Schritte (Normalweg), Programm, Datei)
- geprüft: Commit a0b7fef0/f0445746 (Schritte (Normalweg), Bedingung an die Herstellerfirmware, Fehlerbild)
- geprüft: Commit f0445746; Feld modell (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Wiki toh:zyxel:nwa50ax_pro (Schritte (Normalweg), Adressen, Zugang, Bedingung an die Herstellerfirmware, Fehlerbild)
- Geräteeintrag: OpenWrt f0445746f6fd96fc7c5394b238153bd2ff22bc5b
