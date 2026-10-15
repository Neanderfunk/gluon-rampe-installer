---
gluon_name: sophos-ap15
modell: Sophos AP15 (broken)
anzeige: Sophos AP15
familie: seriell-tftp
gluon_broken: true
sprache: de
level: L7
risiko: normal
status: ungeprüft
grundlagen: [feste-ip, serielle-konsole, ssh-scp, tftp-server]
daten_stand: 3b96298
vorlage_stand: 4935d8a
---

# Sophos AP15: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
> Die Freifunk-Firmware für dieses Gerät gilt bei Gluon als nicht ausreichend
> getestet ("broken"); nicht jede Community bietet sie an.
> Laut OpenWrt an zwei Geräten ausprobiert.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Sophos%20AP15)

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
- einen **USB-Seriell-Adapter für 3,3 V** und kurze Steckkabel. Die
  Konsole liegt auf Stiften im Gehäuse (auf der Platine (Gehäuse öffnen)); du
  musst das Gerät also öffnen.
- ein Terminalprogramm, einen TFTP-Server und `ssh`/`scp` (siehe die drei
  Seiten oben)
- diese Dateien:
  1. das OpenWrt-initramfs:
     [openwrt-24.10.8-ath79-generic-sophos_ap15-initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/generic/openwrt-24.10.8-ath79-generic-sophos_ap15-initramfs-kernel.bin).
     Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
     **`boot.bin`** um.
  2. die Freifunk-Firmware deiner Community für den Sophos AP15, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.

## Vorher prüfen

Der AP15 hat keine Taste und keine Konsolenbuchse außen. Der AP15**C** hat
beides und braucht eine andere Freifunk-Firmware, siehe die
[Anleitung für den AP15C](sophos-ap15c.md). Schau auf das Typenschild.

## Schritte

### OpenWrt starten

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.99.8`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht das Gerät den TFTP-Server.

2. **TFTP-Server starten.** Starte den TFTP-Server mit dem Ordner, in dem
   `boot.bin` liegt
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an die Netzwerkbuchse des Geräts.
   Das Konsolenkabel an die Konsole, das andere Ende an den Rechner. Strom
   noch nicht anschließen.

4. **Terminal öffnen.** Starte das Terminalprogramm mit **115200**
   Baud, 8N1, ohne Flusssteuerung
   ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).

5. **Bootloader anhalten.** Schließ jetzt den Strom an. Sobald die Aufforderung erscheint, den automatischen Start abzubrechen, drück eine Taste.
   **Prüfen:** Es erscheint die Eingabeaufforderung des Bootloaders `ath>`. Sonst Strom
   ziehen und noch einmal.

6. **OpenWrt laden.** Gib
   diese Befehle ein, jede Zeile einzeln. Warte nach jeder Zeile, bis die
   Eingabeaufforderung wieder erscheint:

   ```
   tftpboot 0x81000000 boot.bin
   bootm 0x81000000
   ```

   Die Befehle holen `boot.bin` von deinem Rechner und starten
   OpenWrt; das Terminal zeigt viele Zeilen. Warte, bis
   `Please press Enter to activate this console.` erscheint.

### Freifunk-Firmware aufspielen

7. **Freifunk-Firmware kopieren.** OpenWrt antwortet
   unter `192.168.1.1`. Stell deinen Rechner deshalb jetzt auf die feste
   Adresse `192.168.1.10` um, Netzmaske `255.255.255.0`.
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
  `192.168.99.8`, die Firewall deines Rechners und den Dateinamen
  `boot.bin`.
- **In Schritt 7 antwortet nichts.** Warte noch eine Minute, OpenWrt
  braucht etwas.
- **Nach Schritt 8 meldet sich lange nichts.** Weiter warten und nicht den
  Strom ziehen. Erst wenn nach einer halben Stunde noch nichts kommt, schreib
  uns, am besten mit der Mitschrift des Terminals.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Netz 192.168.1.0/24 (Schritte (Normalweg))
- geprüft (Weg ab Werk, Schritte (Normalweg), Anschluss, Quelle (OpenWrt-Commit))
- geprüft: Commit (Schritte (Normalweg), Adressen, Programm, Datei, Typenschild/Verwechslung)
- geprüft: Commit 0dc5821 (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Zugang)
- geprüft: Commit; Wiki-Zusammenfassung: Pegel laut ToH (Schritte (Normalweg), Anschluss, Zugang)
- geprüft: Gluon-Target ath79-generic (Typenschild/Verwechslung)
- ungeprüft im Commit (Weg ab Werk, Notweg)
- Geräteeintrag: 0dc58214896aacf67a3759495d70e2b4e9c160d8 (Einführung, Anleitung); fc31261c3307458e38c9a676211a25c99c044ece (DTS-Umbenennung) [geprüft]
