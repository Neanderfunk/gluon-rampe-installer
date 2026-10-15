---
gluon_name: extreme-networks-ws-ap3825i
modell: Extreme Networks WS-AP3825i
anzeige: Extreme Networks WS-AP3825i
familie: seriell-tftp
gluon_broken: false
sprache: de
level: L6
level_text: Serielles Kabel
risiko: normal
status: ungeprüft
grundlagen: [feste-ip, serielle-konsole, ssh-scp, tftp-server]
daten_stand: 555d2189
vorlage_stand: 4935d8a7
---

# Extreme Networks WS-AP3825i: Freifunk-Firmware installieren

> **Bei uns in der Praxis erprobt.** Wir haben Geräte dieses Typs schon so
> umgestellt, nur noch nicht mit der aktuellen Version der
> Freifunk-Firmware.
> Wir haben rund ein Dutzend dieser Geräte auf diesem Weg umgestellt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Extreme%20Networks%20WS-AP3825i)

> **Achtung:** Das Schreiben der Freifunk-Firmware und der erste Start danach dauern bei
> diesem Gerät **sehr lange, länger, als es sich gut anfühlt**. Bei uns waren
> es einmal etwa 11 Minuten, bis er wieder unter `192.168.1.1` antwortete, und
> die Konsole blieb dabei lange stumm. So war es bei jedem der rund zwölf
> Geräte, die wir umgestellt haben. **Nicht den Strom ziehen**, auch wenn
> scheinbar nichts passiert.

Dieses Gerät nimmt keine fremde Firmware über seine Weboberfläche an. Der
Weg führt über die **serielle Konsole**, also ein Kabel, über das du den
Bootloader des Geräts direkt bedienst. Er hat zwei Etappen:

1. **OpenWrt starten.** Du stellst den Bootloader so ein, dass er ein
   kleines OpenWrt per TFTP von deinem Rechner holt und startet. Es läuft
   nur im Arbeitsspeicher.
2. **Die Freifunk-Firmware aufspielen.** Aus diesem OpenWrt heraus
   installierst du die Freifunk-Firmware deiner Community.

Dafür brauchst du drei Werkzeuge, die auf eigenen Seiten erklärt sind:
[Serielle Konsole benutzen](grundlagen/serielle-konsole.md),
[TFTP-Server einrichten](grundlagen/tftp-server.md) und
[SSH und scp benutzen](grundlagen/ssh-scp.md). Rechne beim ersten Mal mit
einer Stunde.

## Was du brauchst

- das Gerät mit Stromversorgung (Netzteil oder PoE-Injektor), einen Rechner
  mit Netzwerkanschluss und ein Netzwerkkabel
- ein **Cisco-Konsolenkabel**: RJ45-Stecker auf der einen Seite, USB (oder
  die alte 9-polige serielle Buchse plus USB-Adapter) auf der anderen. Die
  Konsolenbuchse sitzt neben der Buchse für das 12-V-Netzteil. Ein einfacher USB-Seriell-Adapter für 3,3 V
  passt hier **nicht**: Die Buchse arbeitet mit den höheren Spannungen der
  alten seriellen Schnittstelle (RS-232).
- ein Terminalprogramm, einen TFTP-Server und `ssh`/`scp` (siehe die drei
  Seiten oben)
- diese Dateien:
  1. das OpenWrt-initramfs:
     [openwrt-22.03.0-mpc85xx-p1020-extreme-networks_ws-ap3825i-initramfs-kernel.bin](https://archive.openwrt.org/releases/22.03.0/targets/mpc85xx/p1020/openwrt-22.03.0-mpc85xx-p1020-extreme-networks_ws-ap3825i-initramfs-kernel.bin). Bewusst die alte Version 22.03.0: Mit neueren bleibt das Gerät beim Start mit der Meldung `ft_fixup_l2cache: FDT_ERR_NOTFOUND` hängen. Die Freifunk-Firmware, die du danach aufspielst, ist trotzdem aktuell.
     Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
     **`ws-ap3825i-initramfs.bin`** um.
  2. die Freifunk-Firmware deiner Community für den Extreme Networks WS-AP3825i, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.

## Vorher prüfen

- Die WS-AP3825i hat dasselbe Gehäuse wie die Enterasys WS-AP3725i und die
  Adtran BSAP-2030. Ob die dieselbe Firmware vertragen, ist nicht geklärt.
  Nimm diese Anleitung nur für eine WS-AP3825i (Typenschild).

## Schritte

### OpenWrt starten

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.66`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht das Gerät den TFTP-Server.

2. **TFTP-Server starten.** Starte den TFTP-Server mit dem Ordner, in dem
   `ws-ap3825i-initramfs.bin` liegt
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an die Buchse **LAN2**.
   Das Konsolenkabel an die Konsole, das andere Ende an den Rechner. Strom
   noch nicht anschließen.

4. **Terminal öffnen.** Starte das Terminalprogramm mit **115200**
   Baud, 8N1, ohne Flusssteuerung
   ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).

5. **Bootloader anhalten.** Schließ jetzt den Strom an. Sobald im Terminal `Scanning JFFS2 FS:` erscheint, drück einmal Enter und warte, bis der Bootloader nach den Zugangsdaten fragt. Melde dich mit **admin / new2day** an
   (Benutzer / Passwort). Gehen sie nicht, lass das Gerät normal starten und halt dann die Reset-Taste mindestens 5 Sekunden gedrückt; das setzt die Herstellerfirmware auf Werkseinstellungen zurück.
   **Prüfen:** Es erscheint die Eingabeaufforderung des Bootloaders `Boot (PRI)->`. Sonst Strom
   ziehen und noch einmal.

6. **Bootloader einstellen und OpenWrt laden.** Gib
   diese Befehle ein, jede Zeile einzeln. Warte nach jeder Zeile, bis die
   Eingabeaufforderung wieder erscheint; `saveenv` kann ein paar Sekunden brauchen, dabei
   **nicht den Strom ziehen**:

   ```
   setenv ramboot_openwrt "setenv ipaddr 192.168.1.22; setenv serverip 192.168.1.66; tftpboot 0x2000000 ws-ap3825i-initramfs.bin; interrupts off; bootm start 0x2000000; bootm loados; fdt resize; fdt boardsetup; fdt resize; fdt boardsetup; fdt chosen; fdt resize; fdt chosen; bootm prep; bootm go;"
   setenv boot_openwrt "cp.b 0xEC000000 0x2000000 0x2000000; interrupts off; bootm start 0x2000000; bootm loados; fdt resize; fdt boardsetup; fdt resize; fdt boardsetup; fdt chosen; fdt resize; fdt chosen; bootm prep; bootm go;"
   setenv bootcmd "run boot_openwrt";
   saveenv
   run ramboot_openwrt
   ```

   Die Befehle holen `ws-ap3825i-initramfs.bin` von deinem Rechner und starten
   OpenWrt; das Terminal zeigt viele Zeilen. Warte, bis
   `Please press Enter to activate this console.` erscheint.

   Ab jetzt startet das Gerät OpenWrt statt der Herstellerfirmware.

### Freifunk-Firmware aufspielen

7. **Freifunk-Firmware kopieren.** Steck das Netzwerkkabel jetzt in die Buchse
   **LAN1**.
   Öffne ein zweites Terminal im Ordner mit `gluon.bin` und gib ein:

   ```
   scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
   ssh root@192.168.1.1 "sysupgrade -n /tmp/gluon.bin"
   ```

   Ein Passwort gibt es nicht. Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS
   CHANGED", siehe [SSH und scp benutzen](grundlagen/ssh-scp.md). Nach dem
   zweiten Befehl bricht die Verbindung ab, oft mit einer Meldung wie
   `Command failed: … (Connection failed)`. Das ist harmlos.

8. **Warten.** Das Gerät schreibt die Freifunk-Firmware und startet neu. Das dauert bei diesem Gerät sehr lange, oft zehn Minuten und mehr, und die Konsole bleibt dabei lange stumm (siehe Achtung oben).
   **Strom nicht ziehen.** Laut OpenWrt-Wiki blinkt die Power-LED, solange er beschäftigt ist, und leuchtet dauerhaft, wenn er fertig ist.

9. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet
   die Freifunk-Firmware deiner Community: je nach Community zuerst mit
   einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im
   Betrieb.

## Woran du erkennst, dass es geklappt hat

- In Schritt 5 erscheint die Eingabeaufforderung des Bootloaders.
- In Schritt 6 holt der Bootloader die Datei, und OpenWrt startet.
- Nach Schritt 8 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Im Terminal erscheint nichts oder nur wirre Zeichen.** Prüf die
  Geschwindigkeit (115200) und das Kabel
  ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).
- **In Schritt 6 kommt die Datei nicht an.** Prüf die feste Adresse
  `192.168.1.66`, die Firewall deines Rechners und den Dateinamen
  `ws-ap3825i-initramfs.bin`, und ob das Kabel in LAN2 steckt.
- **In Schritt 7 antwortet nichts.** Warte noch eine Minute, OpenWrt
  braucht etwas. Prüf, ob das Kabel jetzt in LAN1
  steckt.
- **Nach Schritt 8 meldet sich lange nichts.** Weiter warten und nicht den
  Strom ziehen. Erst wenn nach einer halben Stunde noch nichts kommt, schreib
  uns, am besten mit der Mitschrift des Terminals.
- **Statt `Boot (PRI)->` erscheint eine Eingabe wie `/flash/home/admin`,
  oder `setenv` ist unbekannt.** Dann bist du nicht im Bootloader, sondern
  schon in der Herstellerfirmware. Strom ziehen, Schritt 5 wiederholen und
  Enter drücken, sobald `Scanning JFFS2 FS:` erscheint.
- **Der Start bleibt mit `ft_fixup_l2cache: FDT_ERR_NOTFOUND` stehen.** Das
  OpenWrt-initramfs ist zu neu. Nimm genau die Version 22.03.0 von oben.

## Zurück zur Herstellerfirmware

Zurück zur Herstellerfirmware geht nur mit einer Sicherung der Partition "firmware", die du vor Schritt 7 aus OpenWrt heraus gemacht hast. Das beschreiben wir hier nicht.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- geprüft (Weg ab Werk, Schritte (Normalweg), Programm, Datei, Dauer)
- geprüft, Wiki toh:extreme_networks:ws-ap3825i (Schritte (Normalweg))
- geprüft: Commit (Schritte (Normalweg), Anschluss, Zugang, Typenschild/Verwechslung, Rückweg zur Herstellerfirmware)
- geprüft: Commit 7e61482 (Schritte (Normalweg), Taste und Zeitpunkt, Zugang)
- geprüft: Commit, Wiki toh:extreme_networks:ws-ap3825i (Schritte (Normalweg), Adressen, Programm)
- geprüft: Neanderfunk-Notiz (Dauer)
- geprüft: OpenWrt-Issue 17152 (Gluon-RAMpe passt)
- geprüft: OpenWrt-Issue 17152 (offen): adorfer 29.03.2025 "broken in 24.x and 23, tested with 4 devices … 22.03.0 works", jensgraef 15.05.2025 "sysupgrade of openwrt-24.10 without any problems", jbusuttil 03.09.2026 22.03.0, dann sysupgrade; Datei archive.openwrt.org 22.03.0, SHA256 fc9a27d9… laut sha256sums, 6.879.964 Byte (Bedingung an die Herstellerfirmware)
- geprüft: Wiki toh:extreme_networks:ws-ap3825i (Schritte (Normalweg), Anschluss, Datei, Dauer, Fehlerbild)
- geprüft: Wiki toh:extreme_networks:ws-ap3825i, Titel (Typenschild/Verwechslung)
- geprüft: forum.darmstadt.freifunk.net t/923 #1 (TomH, 30.04.2022), am 15.10.2026 gelesen: 192.168.1.66/.22, ws-ap3825i-initramfs.bin, Prompt 'Boot (PRI)->', Anhalten bei 'Scanning JFFS2 FS:' (Weg ab Werk)
- geprüft: forum.darmstadt.freifunk.net t/923 #4, #7 (Notweg)
- geprüft: forum.darmstadt.freifunk.net t/923 #8 (Notweg)
- geprüft: laut Commit sind die LEDs unter OpenWrt sonst ohne Funktion, Wiki toh:extreme_networks:ws-ap3825i (Sichtbare Zeichen)
- Geräteeintrag: 7e614820a89208c4e91a3a5f9de07a5402accdaa
