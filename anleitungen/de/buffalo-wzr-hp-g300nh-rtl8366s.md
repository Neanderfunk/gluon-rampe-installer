---
gluon_name: buffalo-wzr-hp-g300nh-rtl8366s
modell: Buffalo WZR-HP-G300NH (RTL8366S switch)
anzeige: Buffalo WZR-HP-G300NH (RTL8366S switch)
familie: k0-webui
gluon_broken: false
sprache: de
level: L0.1
risiko: normal
status: ungeprüft
grundlagen: []
daten_stand: 3b96298
vorlage_stand: bfd0482
---

# Buffalo WZR-HP-G300NH (RTL8366S switch): Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Buffalo%20WZR-HP-G300NH%20%28RTL8366S%20switch%29)

Beim Buffalo WZR-HP-G300NH (RTL8366S switch) geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Buffalo WZR-HP-G300NH (RTL8366S switch), und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "Buffalo WZR-HP-G300NH (RTL8366S switch)", bevor du anfängst.

## Vorher prüfen

Den WZR-HP-G300NH gibt es mit zwei verschiedenen Netzwerkchips (RTL8366S und
RTL8366RB). Die Freifunk-Firmware gibt es **nur für die S-Variante**; mit der
falschen startet das Gerät ohne Netzwerk. Die Variante steht nicht als Text
auf dem Aufkleber. Einen Hinweis gibt der Modellcode (vier oder fünf Zeichen)
oben rechts auf dem Aufkleber mit dem WLAN-Namen; laut der Tabelle im
OpenWrt-Wiki:

- RTL8366S: A0A0, A0A1, A0A3, A0D0, A2F0B, B0B0, B0B0G, B0C0
- RTL8366RB: A0F0B, A1A3, A2A0

Ein Forenbeitrag ordnet A0D0 und B0C0 dagegen der RB-Variante zu. Bei diesen
beiden Codes also besonders vorsichtig sein.

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an eine LAN-Buchse des
   Geräts (nicht WAN oder Internet).
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.

3. **Oberfläche öffnen.** Öffne im Browser `http://192.168.11.1`.
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

## Notfall für Erfahrene: TFTP im Bootloader

Laut OpenWrt nimmt der Bootloader beim Einschalten ein tftp-Image an. Rechner
fest auf `192.168.11.2`, angeschlossen über einen Switch an der LAN-Buchse
neben WAN. Vor dem Einschalten:

```
arp -s 192.168.11.1 02:AA:BB:CC:DD:1A
curl -T <tftp-Image> tftp://192.168.11.1
```

Während das Image geschrieben wird, blinkt die Diag-LED eine Weile.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- abgeleitet: Suchergebnis (Typenschild/Verwechslung)
- geprüft (Weg ab Werk, Schritte (Normalweg), Datei, Notweg, Quelle (OpenWrt-Commit))
- geprüft: Commit bc356de2 (Notweg)
- geprüft: Commit bc356de2; Gluon targets/ath79-generic (Typenschild/Verwechslung)
- geprüft: Feld uebertragung (Schritte (Normalweg), Adressen, Programm)
- geprüft: Wiki toh:buffalo:wzr-hp-g300h (Schritte (Normalweg), Warnung, Typenschild/Verwechslung)
- Geräteeintrag: bc356de2850f14629cb1301be719772fa1212e72 [geprüft]
