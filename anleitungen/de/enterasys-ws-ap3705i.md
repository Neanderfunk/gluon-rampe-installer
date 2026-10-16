---
gluon_name: enterasys-ws-ap3705i
modell: Enterasys WS-AP3705i
anzeige: Enterasys WS-AP3705i
familie: seriell-tftp
gluon_broken: false
sprache: de
level: L6
level_text: Serielles Kabel
risiko: normal
status: ungeprüft
grundlagen: [feste-ip, serielle-konsole, ssh-scp, tftp-server]
daten_stand: 7e377f68
vorlage_stand: 4935d8a7
---

# Enterasys WS-AP3705i: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Enterasys%20WS-AP3705i)

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
  Konsolenbuchse ist
  eine RJ45-Buchse. Ein einfacher USB-Seriell-Adapter für 3,3 V
  passt hier **nicht**: Die Buchse arbeitet mit den höheren Spannungen der
  alten seriellen Schnittstelle (RS-232).
- ein Terminalprogramm, einen TFTP-Server und `ssh`/`scp` (siehe die drei
  Seiten oben)
- diese Dateien:
  1. das OpenWrt-initramfs:
     [openwrt-24.10.8-ath79-generic-enterasys_ws-ap3705i-initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-enterasys_ws-ap3705i-initramfs-kernel.bin).
     Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
     **`1401A8C0.img`** um.
  2. die Freifunk-Firmware deiner Community für den Enterasys WS-AP3705i, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.

## Schritte

### OpenWrt starten

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.66`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht das Gerät den TFTP-Server.

2. **TFTP-Server starten.** Starte den TFTP-Server mit dem Ordner, in dem
   `1401A8C0.img` liegt
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an die Netzwerkbuchse des Geräts.
   Das Konsolenkabel an die Konsole, das andere Ende an den Rechner. Strom
   noch nicht anschließen.

4. **Terminal öffnen.** Starte das Terminalprogramm mit **115200**
   Baud, 8N1, ohne Flusssteuerung
   ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).

5. **Bootloader anhalten.** Schließ jetzt den Strom an. Sobald die Aufforderung erscheint, brich den Start mit Enter ab; dafür ist nur eine Sekunde Zeit, drück am besten schon beim Einschalten immer wieder Enter. Melde dich mit **admin / new2day** an
   (Benutzer / Passwort).
   **Prüfen:** Es erscheint die Eingabeaufforderung des Bootloaders. Sonst Strom
   ziehen und noch einmal.

6. **Bootloader einstellen und OpenWrt laden.** Gib
   diese Befehle ein, jede Zeile einzeln. Warte nach jeder Zeile, bis die
   Eingabeaufforderung wieder erscheint; `saveenv` kann ein paar Sekunden brauchen, dabei
   **nicht den Strom ziehen**:

   ```
   setenv boot_openwrt 'setenv bootargs; bootm 0xbf230000'
   setenv ramboot_openwrt 'setenv serverip 192.168.1.66; tftpboot 0x85000000; bootm'
   setenv bootcmd 'run boot_openwrt'
   saveenv
   run ramboot_openwrt
   ```

   Die Befehle holen `1401A8C0.img` von deinem Rechner und starten
   OpenWrt; das Terminal zeigt viele Zeilen. Warte, bis
   `Please press Enter to activate this console.` erscheint.

   Ab jetzt startet das Gerät OpenWrt statt der Herstellerfirmware.

### Freifunk-Firmware aufspielen

7. **Freifunk-Firmware kopieren.**
   Öffne ein zweites Terminal im Ordner mit `gluon.bin` und gib ein:

   ```
   scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
   ssh root@192.168.1.1 "sysupgrade -n /tmp/gluon.bin"
   ```

   Ein Passwort gibt es nicht. Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS
   CHANGED", siehe [SSH und scp benutzen](grundlagen/ssh-scp.md). Nach dem
   zweiten Befehl bricht die Verbindung ab, oft mit einer Meldung wie
   `Command failed: … (Connection failed)`. Das ist harmlos.

8. **Warten.** Das Gerät schreibt die Freifunk-Firmware und startet neu.
   **Strom nicht ziehen.**

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
  `1401A8C0.img`.
- **In Schritt 7 antwortet nichts.** Warte noch eine Minute, OpenWrt
  braucht etwas.
- **Nach Schritt 8 meldet sich lange nichts.** Weiter warten und nicht den
  Strom ziehen. Erst wenn nach einer halben Stunde noch nichts kommt, schreib
  uns, am besten mit der Mitschrift des Terminals.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- geprüft (Weg ab Werk, Schritte (Normalweg), Anschluss, Datei, Quelle (OpenWrt-Commit))
- geprüft: Commit (Schritte (Normalweg), Anschluss, Programm, Zugang)
- geprüft: Commit ebddc5f (Schritte (Normalweg), Taste und Zeitpunkt, Zugang)
- geprüft: Commit; Hex-Deutung abgeleitet (Schritte (Normalweg), Adressen, Datei)
- geprüft: OpenWrt-Commit ebddc5f, am 15.10.2026 nachgelesen (Programm)
- Geräteeintrag: ebddc5f984a240980303aed68524eb615484eef8 [geprüft]
