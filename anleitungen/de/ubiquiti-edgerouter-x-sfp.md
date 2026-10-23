---
gluon_name: ubiquiti-edgerouter-x-sfp
modell: Ubiquiti EdgeRouter X-SFP
anzeige: Ubiquiti EdgeRouter X-SFP
familie: ubiquiti-edgerouter
gluon_broken: false
sprache: de
level: L4
level_text: Network-Tools
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht, ssh-scp]
daten_stand: adb37d3f
vorlage_stand: 33a38da8
---

# Ubiquiti EdgeRouter X-SFP: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Ubiquiti%20EdgeRouter%20X-SFP)

Diese Anleitung ist für einen Ubiquiti EdgeRouter X-SFP, auf dem noch die Firmware von
Ubiquiti läuft (EdgeOS), und der neu mit Freifunk anfangen soll.

Der Weg hat drei Etappen, weil es keine Abkürzung gibt:

1. **Aus EdgeOS heraus ein altes OpenWrt aufspielen.** EdgeOS nimmt nur
   Dateien in einem bestimmten Format an, und die gibt es nur für ältere
   OpenWrt-Versionen.
2. **Auf das neue Speicherlayout umstellen.** Die Firmware ab Gluon 2025.1
   (Linux 6.6) ist zu groß für den alten Platz im Speicher. Ein Skript teilt
   den Speicher neu ein und spielt dabei OpenWrt 24.10 auf.
3. **Die Freifunk-Firmware aufspielen**, ganz normal über die
   Weboberfläche von OpenWrt.

Du arbeitest dabei mit SSH und scp im Terminal. Wenn das neu für dich ist,
lies vorher [SSH und scp benutzen](grundlagen/ssh-scp.md). Rechne mit einer
Stunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- `ssh` und `scp` ([SSH und scp benutzen](grundlagen/ssh-scp.md))
- diese vier Dateien, alle in einem Ordner:
  1. das OpenWrt-factory-Image für EdgeOS:
     [openwrt-ramips-mt7621-ubnt_edgerouter-x-initramfs-factory.tar](https://raw.githubusercontent.com/stman/OpenWRT-19.07.2-factory-tar-file-for-Ubiquiti-EdgeRouter-x/de2ade9e0c5356af31e5ae0ff011fd22525e8342/Version%2022.03/openwrt-ramips-mt7621-ubnt_edgerouter-x-initramfs-factory.tar)
     (3.010.560 Bytes), SHA256
     `8f6f370dd7a8bc3e702fba607f175ac5b892a6d8cc852faa94fa73b0f8eccb42`.
     Es stammt nicht von OpenWrt selbst, sondern von einem Nutzer, der es
     gebaut hat, weil OpenWrt für diesen Router keine solche Datei mehr
     erzeugt; das OpenWrt-Wiki verweist darauf.
  2. die beiden Umstellungs-Skripte
     [ubnt_erx_migrate.sh](https://raw.githubusercontent.com/darkxst/erx-migration/d29f71a94ec3fadd1f31bee2b39536f395ee9aa5/ubnt_erx_migrate.sh) und
     [ubnt_erx_stage2.sh](https://raw.githubusercontent.com/darkxst/erx-migration/d29f71a94ec3fadd1f31bee2b39536f395ee9aa5/ubnt_erx_stage2.sh), genau unter
     diesen Namen
  3. OpenWrt 24.10 für dein Modell:
     [openwrt-24.10.8-ramips-mt7621-ubnt_edgerouter-x-sfp-squashfs-sysupgrade.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-ubnt_edgerouter-x-sfp-squashfs-sysupgrade.bin), SHA256
     `6cc7cf45dad3ee1f2dfe6440ed032d8647d782630ed381eb4622fab3ff879e21`
  4. die Freifunk-Firmware deiner Community für den Ubiquiti EdgeRouter X-SFP, und zwar
     das **sysupgrade**-Image

## Vorher prüfen

- Diese Anleitung ist für den **EdgeRouter X-SFP** (mit SFP-Anschluss). Für
  den [EdgeRouter X](ubiquiti-edgerouter-x.md) ohne SFP gibt es eigene
  Dateien.
- Das factory-Image aus Teil 1 gibt es nur für den EdgeRouter X. Laut
  OpenWrt-Wiki läuft es auch auf dem X-SFP; in Teil 1 läuft auf deinem
  Router also kurz das OpenWrt des Schwestergeräts. **Wichtig ist, dass du in
  Teil 2 die OpenWrt-Datei für den X-SFP nimmst** (mit `-sfp` im Namen),
  sonst passt danach die Freifunk-Firmware nicht.
- Bei manchen Communities trägt die Freifunk-Firmware für dieses Gerät einen
  Zusatz im Namen, bei Neanderfunk zum Beispiel
  `…-ubiquiti-edgerouter-x-sfp-ka-sysupgrade.bin`. Das `ka` steht für das
  neue Speicherlayout und ist hier genau richtig.

## Empfohlen: EdgeOS und Bootloader vorher aktualisieren

OpenWrt empfiehlt, vor allem anderen die neueste EdgeOS-Version 2.x und das
Bootloader-Update von Ubiquiti einzuspielen. Der neue Bootloader hat einen
Notfall-Modus, der über die Reset-Taste erreichbar ist; ohne ihn bleibt im
Notfall nur die serielle Konsole. Wie es geht, beschreibt Ubiquiti:
[EdgeOS herunterladen](https://www.ui.com/download/software/er-x),
[Bootloader aktualisieren](https://help.ui.com/hc/en-us/articles/360009932554-EdgeRouter-How-to-Update-the-Bootloader).

## Schritte

### Teil 1: OpenWrt aus EdgeOS heraus aufspielen

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.10`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

2. **Kabel an eth0.** Steck das Kabel vom Rechner in die Buchse **eth0**
   des Routers und schalte ihn ein. Warte, bis er gestartet ist (etwa eine
   Minute).

3. **factory-Image einspielen.** Öffne ein Terminal im Ordner mit den
   Dateien:

   ```
   scp -O openwrt-ramips-mt7621-ubnt_edgerouter-x-initramfs-factory.tar ubnt@192.168.1.1:/tmp/
   ssh ubnt@192.168.1.1
   ```

   Das Passwort ist jeweils `ubnt` (sofern es niemand geändert hat). Auf dem
   Router dann:

   ```
   add system image /tmp/openwrt-ramips-mt7621-ubnt_edgerouter-x-initramfs-factory.tar
   reboot
   ```

   Die Meldung `line 509: [: too many arguments` dabei ist harmlos; am Ende
   muss `Upgrade completed` stehen. `reboot` fragt eventuell nach: mit `y`
   bestätigen.

   Statt mit `scp` und `ssh` geht das auch in der Weboberfläche von EdgeOS
   (`https://192.168.1.1`): unten links auf **System**, dann bei "Upgrade
   System Image" die Datei hochladen.

4. **Kabel an eth1.** Nach dem Neustart läuft OpenWrt, und das antwortet
   **nicht mehr an eth0, sondern an eth1**. Steck das Kabel um und warte etwa
   eine Minute. Dann:

   ```
   ssh root@192.168.1.1
   ```

   Ein Passwort gibt es nicht. Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS
   CHANGED", ist das hier richtig so, siehe
   [SSH und scp benutzen](grundlagen/ssh-scp.md). Mit `exit` wieder
   abmelden.

### Teil 2: Auf das neue Speicherlayout umstellen

5. **Dateien hinüberkopieren.** Im Terminal auf deinem Rechner:

   ```
   scp -O ubnt_erx_migrate.sh ubnt_erx_stage2.sh root@192.168.1.1:/tmp/
   scp -O openwrt-24.10.8-ramips-mt7621-ubnt_edgerouter-x-sfp-squashfs-sysupgrade.bin root@192.168.1.1:/tmp/sysupgrade.img
   ```

   Die OpenWrt-Datei heißt auf dem Router `sysupgrade.img`. Unter diesem
   Namen findet das Skript sie und lädt nichts aus dem Internet nach.

6. **Umstellen.** Melde dich an und starte das Skript:

   ```
   ssh root@192.168.1.1
   cd /tmp
   chmod +x ubnt_erx_migrate.sh
   ./ubnt_erx_migrate.sh
   ```

   Es meldet `Found local /tmp/sysupgrade.img... Skipping download step.` und
   fragt `Do you want to proceed with the migration? (y/n)`: `y` eintippen,
   Enter. Danach bricht die Verbindung ab. Der Router schreibt Kernel und
   System neu und startet neu. **Einige Minuten warten, Strom nicht
   ziehen.**

7. **Prüfen.** Melde dich wieder an (`ssh root@192.168.1.1`, kein Passwort)
   und gib ein:

   ```
   cat /proc/mtd
   ```

   **Prüfen:** In der Ausgabe muss eine Zeile `mtd3: 00600000 00020000
   "kernel"` stehen, und es darf kein `kernel1` und `kernel2` mehr geben.
   Dann ist das neue Layout drin. Sonst hier aufhören und melden.

### Teil 3: Freifunk-Firmware aufspielen

8. **Weboberfläche öffnen.** Öffne im Browser `http://192.168.1.1`. Es
   erscheint die Anmeldung von OpenWrt. Das Passwort-Feld bleibt leer.

9. **Freifunk-Firmware hochladen.** Geh zu **System → Backup / Flash
   Firmware**, ganz unten "Flash image…", und wähl das sysupgrade-Image
   deiner Community aus. Im folgenden Fenster den Haken bei **"Keep
   settings"** (Einstellungen beibehalten) **entfernen**, dann
   **Continue**.

10. **Fertig.** Der Router schreibt die Freifunk-Firmware und startet neu,
    einige Minuten, Strom nicht ziehen. Stell den Rechner wieder auf
    "automatisch". Danach startet die Freifunk-Firmware deiner Community: je
    nach Community zuerst mit einer Einrichtungsseite unter
    `http://192.168.1.1` oder gleich im Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 endet EdgeOS mit `Upgrade completed`.
- In Schritt 4 meldet sich OpenWrt an **eth1**.
- In Schritt 7 zeigt `cat /proc/mtd` eine Partition `kernel` mit `00600000`.
- Nach Schritt 10 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **In Schritt 4 antwortet nichts.** Das Kabel steckt noch an eth0. OpenWrt
  ist an **eth1** erreichbar.
- **`scp` meldet einen Fehler.** Das `-O` fehlt, oder der Router hat kein
  `scp`. Dann geht es auch so, zum Beispiel für die OpenWrt-Datei:
  `ssh root@192.168.1.1 "cat > /tmp/sysupgrade.img" < openwrt-24.10.8-ramips-mt7621-ubnt_edgerouter-x-sfp-squashfs-sysupgrade.bin`
  (in der Eingabeaufforderung "cmd", nicht in der PowerShell).
- **Das Skript meldet "Incompatible board".** Dann läuft auf dem Router
  nicht das OpenWrt aus Teil 1. Zurück zu Schritt 3.
- **Das Skript meldet "Invalid image file".** Die Datei `/tmp/sysupgrade.img`
  ist nicht vollständig angekommen. Schritt 5 wiederholen.
- **EdgeOS lehnt das factory-Image ab** ("invalid firmware"). Das OpenWrt-Wiki
  nennt dafür einen Umweg über ältere EdgeOS-Versionen:
  <https://openwrt.org/toh/ubiquiti/edgerouter_x_er-x_ka>.
- **Der Router startet nach Schritt 6 nicht wieder.** Nicht wild
  ausprobieren. Mit aktualisiertem Bootloader (siehe oben) gibt es den
  Notfall-Modus über die Reset-Taste, sonst nur die serielle Konsole
  (57600 Baud). Frag deine Community oder uns.

## Zurück zur Ubiquiti-Firmware

Ubiquiti beschreibt, wie EdgeOS wieder aufgespielt wird:
<https://help.ui.com/hc/en-us/articles/360019289113>.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Wiki-Rohtext: toh:ubiquiti:edgerouter_x_er-x_ka, 15.10.2026 (Weg ab Werk)
- abgeleitet (Gluon-RAMpe passt)
- abgeleitet: Wiki (Schritte (Normalweg), Anschluss, Adressen, Zugang, Datei, Bedingung an die Herstellerfirmware, Rückweg zur Herstellerfirmware)
- abgeleitet: Wiki toh/ubiquiti/edgerouter_x_er-x_ka (Schritte (Normalweg), Taste und Zeitpunkt, Anschluss, Adressen, Programm, Zugang)
- abgeleitet: Wiki, Einzelbericht (Fehlerbild)
- abgeleitet: Wiki; vgl. Bestand werkzeug (Schritte (Normalweg), Programm, Datei)
- abgeleitet: das ER-X-factory der 22.03-Zwischenstufe läuft laut Wiki auch auf dem X-SFP; für den Weg über darkxst übertragen (Weg ab Werk)
- geprüft: Commit 9715beb (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Commit, mk, Wiki toh:ubiquiti:edgerouter_x_er-x_ka (Weg ab Werk, Schritte (Normalweg), Datei, Notweg)
- geprüft: OpenWrt 24.10.8 sha256sums für das sysupgrade, am 15.10.2026 abgeglichen (Weg ab Werk)
- geprüft: darkxst/erx-migration README und ubnt_erx_migrate.sh, Commit d29f71a: eine vorher abgelegte /tmp/sysupgrade.img überspringt den Download, Board edgerouter-x oder -x-sfp erlaubt (Weg ab Werk)
- geprüft: stman OpenWrt-22.03-initramfs-factory.tar, Commit de2ade9, SHA256 gegen sha256sums (Weg ab Werk)
- Geräteeintrag: 9715beb04c74a918697945b3e2d23a139bd04b70
