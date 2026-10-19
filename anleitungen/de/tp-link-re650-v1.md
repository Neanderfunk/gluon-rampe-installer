---
gluon_name: tp-link-re650-v1
modell: TP-Link RE650 v1
anzeige: TP-Link RE650 v1
familie: k0-webui
gluon_broken: false
sprache: de
level: L3
level_text: Feste Adresse am Rechner
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht]
daten_stand: d44f4bc8
vorlage_stand: 33a38da8
---

# TP-Link RE650 v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20RE650%20v1)

Beim TP-Link RE650 v1 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link RE650 v1, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link RE650 v1", bevor du anfängst.

## Vorher prüfen

RE500 v1 und RE650 v1 haben die gleiche Technik, brauchen aber je ihr
eigenes Image. Der **RE650 v2 geht nicht** (zu wenig Speicher). Auf dem
Aufkleber steht "1.0" bzw. "2.0".

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Stell deinen Rechner auf die feste Adresse `192.168.0.10` mit der
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.0.254`.
   Melde dich mit den Zugangsdaten vom Aufkleber an, oder leg beim ersten
   Aufruf ein Passwort fest.

4. **Firmware-Update aufrufen.** Such den Menüpunkt für das Firmware-Update. Er heißt je nach
   Hersteller etwa "Firmware Upgrade", "Firmware-Update" oder "Firmware
   aktualisieren" und liegt oft unter "System", "System Tools" oder
   "Verwaltung".

5. **Hochladen.** Wähl das factory-Image aus, starte das Update und
   bestätige die Rückfragen.

6. **Warten.** Das Gerät schreibt die Firmware und startet neu. Das dauert
   etwa zweieinhalb Minuten.
   **Nicht ausschalten, Strom nicht ziehen und die Seite nicht neu laden.**
   Manche Geräte löschen zuerst den ganzen Speicher; ein Abbruch in dieser
   Zeit kann sie unbrauchbar machen.

7. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Stell den Rechner vorher wieder auf "automatisch".
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

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- geprüft (Weg ab Werk, Schritte (Normalweg), Datei)
- geprüft: Commit ba0f4f0c/8c51ddef (Schritte (Normalweg), Typenschild/Verwechslung, Rückweg zur Herstellerfirmware)
- geprüft: Wiki toh:tp-link:re650_v1 (Schritte (Normalweg), Adressen, Programm, Dauer)
- geprüft: Wiki toh:tp-link:re650_v1; "nicht unterstützt" abgeleitet, im Rohtext nicht gefunden (Typenschild/Verwechslung)
- Geräteeintrag: 8c51ddeff0876b439ac35a3f492ab719085bfb9c
