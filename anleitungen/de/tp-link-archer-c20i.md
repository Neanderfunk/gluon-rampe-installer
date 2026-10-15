---
gluon_name: tp-link-archer-c20i
modell: TP-Link Archer C20i
anzeige: TP-Link Archer C20i
familie: k0-webui
gluon_broken: false
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [feste-ip, tftp-server]
daten_stand: a602f5a
vorlage_stand: bfd0482
---

# TP-Link Archer C20i: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Die Gefahr aus Build 151014 kennen wir aus eigener Erfahrung; den Weg aus Build 140709 haben wir nicht selbst nachvollzogen.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20Archer%20C20i)

> **Achtung:** Läuft auf dem Router die TP-Link-Firmware **Build 151014** (die neueste),
> **nicht** direkt die Freifunk-Firmware hochladen. Der Router hängt danach in
> einer Startschleife und lässt sich nur noch über den TFTP-Notfall-Weg
> retten. Spiel zuerst die ältere TP-Link-Firmware **Build 140709** ein, erst
> dann die Freifunk-Firmware. Das wissen wir aus eigener Erfahrung.

Beim TP-Link Archer C20i geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und sein Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den TP-Link Archer C20i, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link Archer C20i", bevor du anfängst.

## Vorher prüfen

**Firmware-Version nachsehen:** Die TP-Link-Oberfläche zeigt sie auf der
Statusseite ("Firmware Version", mit "Build …" am Ende). Steht dort
**151014**: zuerst über dieselbe Seite für das Firmware-Update die
TP-Link-Firmware **Build 140709** einspielen, den Neustart abwarten und erst
dann mit Schritt 1 anfangen.

Nicht verwechseln mit dem Archer C20 v1 oder dem Archer C2, das sind andere
Geräte.

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

## Notfall: Firmware per TFTP

Startet das Gerät nicht mehr richtig, etwa nach einem abgebrochenen Update
oder weil es in einer Startschleife hängt, kann es sich eine Firmware selbst
von deinem Rechner holen. Dafür brauchst du einen
TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)) und eine
feste Adresse am Rechner ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

1. Leg die TP-Link-Firmware ohne ihren ersten 512-Byte-Block (siehe „Die Rettungsdatei vorbereiten“) unter dem Namen `ArcherC20iV1_tp_recovery.bin` in den
   Ordner des TFTP-Servers. Genau dieser Name, Groß- und Kleinschreibung
   zählt.
2. Stell deinen Rechner fest auf `192.168.0.66`, Netzmaske
   `255.255.255.0`, und starte den TFTP-Server.
3. Kabel an eine LAN-Buchse, Strom aus. Drück die Reset-Taste, halte sie
   gedrückt und schalte den Strom ein. Halte sie gedrückt:
   bis der TFTP-Server
   zeigt, dass die Datei abgeholt wird.
4. Warten. Das Gerät
   schreibt die Datei und startet neu.

## Die Rettungsdatei vorbereiten

Für den TFTP-Notfall-Weg (oben) braucht der C20i die **TP-Link-Firmware ohne
ihren ersten 512-Byte-Block**, umbenannt in `ArcherC20iV1_tp_recovery.bin`.
So haben wir unseren C20i aus der Startschleife geholt. Unter Linux oder
macOS im Ordner mit der TP-Link-Datei:

```sh
dd if=<TP-Link-Firmware>.bin of=ArcherC20iV1_tp_recovery.bin bs=512 skip=1
```

Die fertige Datei war bei uns 8.126.464 Bytes groß. Danach läuft wieder die
TP-Link-Firmware; dann wie oben erst Build 140709, dann die
Freifunk-Firmware.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- abgeleitet: Gluon baut factory; Wiki nennt nur TFTP-Recovery mit ArcherC20iV1_tp_recovery.bin von 192.168.0.66 (Weg ab Werk, Schritte (Normalweg), Programm, Datei)
- geprüft: Gluon targets/ramips-mt7620, Wiki toh:tp-link:archer_c20i (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Neanderfunk-Notiz, adorfer 15.10.2026, am Gerät 06.10.2026: TP-Link-Firmware ohne ersten 512-Byte-Sektor (dd), als ArcherC20iV1_tp_recovery.bin per Tftpd64, Gerät aus der Startschleife geholt (Notweg)
- geprüft: Neanderfunk-Notiz, adorfer 15.10.2026, am Gerät: aus Build 151014 geflasht -> Startschleife, Rettung nur per TFTP (Warnung, Bedingung an die Herstellerfirmware)
- geprüft: Wiki toh:tp-link:archer_c20i (Schritte (Normalweg), Warnung, Bedingung an die Herstellerfirmware)
- geprüft: Wiki toh:tp-link:archer_c20i (Dateiname, Server-IP) (Notweg)
- Geräteeintrag: 48d8bc4f971ad7795e3162134759caa37900138f (ohne Installationstext)
