---
gluon_name: enterasys-ws-ap3710i
modell: Enterasys WS-AP3710i
anzeige: Enterasys WS-AP3710i
familie: seriell-tftp
gluon_broken: false
sprache: de
level: L6
level_text: Serielles Kabel
risiko: normal
status: ungeprüft
rampe_image: gluon-rampe-20261115-enterasys-ws-ap3710i-initramfs-kernel.bin
grundlagen: [browser-https, browser-not-found, feste-ip, router-antwortet-nicht, serielle-konsole, ssh-scp, tftp-server]
daten_stand: 7ef99fa21
vorlage_stand: 9a02820db
---

# Enterasys WS-AP3710i: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Enterasys%20WS-AP3710i)

Dieses Gerät nimmt keine fremde Firmware über seine Weboberfläche an. Der
Weg führt über die **serielle Konsole**, also ein Kabel, über das du den
Bootloader des Geräts direkt bedienst. Er hat zwei Etappen:

1. **Die RAMpe starten.** Du stellst den Bootloader so ein, dass er die
   **Gluon-RAMpe** per TFTP von deinem Rechner holt und startet: eine kleine
   Firmware, die nur eins kann, die Freifunk-Firmware deiner Community
   annehmen. Sie läuft nur im Arbeitsspeicher.
2. **Die Freifunk-Firmware aufspielen.** Auf der Seite der RAMpe lädst du
   im Browser die Freifunk-Firmware deiner Community hoch.

Dafür brauchst du zwei Werkzeuge, die auf eigenen Seiten erklärt sind:
[Serielle Konsole benutzen](grundlagen/serielle-konsole.md) und
[TFTP-Server einrichten](grundlagen/tftp-server.md). Rechne beim ersten Mal
mit einer Stunde.

## Was du brauchst

- das Gerät mit Stromversorgung (Netzteil oder PoE-Injektor), einen Rechner
  mit Netzwerkanschluss und ein Netzwerkkabel
- ein **Cisco-Konsolenkabel**: RJ45-Stecker auf der einen Seite, USB (oder
  die alte 9-polige serielle Buchse plus USB-Adapter) auf der anderen. Die
  Konsolenbuchse sitzt neben der Netzwerkbuchse. Ein einfacher USB-Seriell-Adapter für 3,3 V
  passt hier **nicht**: Die Buchse arbeitet mit den höheren Spannungen der
  alten seriellen Schnittstelle (RS-232).
- ein Terminalprogramm und einen TFTP-Server (siehe die zwei Seiten oben)
- diese Dateien:
  1. die RAMpe für den Enterasys WS-AP3710i:
     [gluon-rampe-20261115-enterasys-ws-ap3710i-initramfs-kernel.bin](https://firmware.neanderfunk.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261115-enterasys-ws-ap3710i-initramfs-kernel.bin).
     Leg sie in den Ordner deines TFTP-Servers und benenn sie dort genau in
     **`01C8A8C0.img`** um.
  2. die Freifunk-Firmware deiner Community für den Enterasys WS-AP3710i, und zwar
     das **sysupgrade**-Image.

## Schritte

### Die RAMpe starten

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.200.200`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht das Gerät den TFTP-Server.

2. **TFTP-Server starten.** Starte den TFTP-Server mit dem Ordner, in dem
   `01C8A8C0.img` liegt
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an die Netzwerkbuchse des Geräts.
   Das Konsolenkabel an die Konsole, das andere Ende an den Rechner. Strom
   noch nicht anschließen.

4. **Terminal öffnen.** Starte das Terminalprogramm mit **115200**
   Baud, 8N1, ohne Flusssteuerung
   ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).

5. **Bootloader anhalten.** Schließ jetzt den Strom an. Drück Enter, sobald die Aufforderung erscheint, den automatischen Start abzubrechen. Melde dich mit **admin / new2day** an
   (Benutzer / Passwort).
   **Prüfen:** Es erscheint die Eingabeaufforderung des Bootloaders. Sonst Strom
   ziehen und noch einmal.

6. **Bootloader einstellen und die RAMpe laden.** Gib
   diese Befehle ein, jede Zeile einzeln. Warte nach jeder Zeile, bis die
   Eingabeaufforderung wieder erscheint; `saveenv` kann ein paar Sekunden brauchen, dabei
   **nicht den Strom ziehen**:

   ```
   setenv boot_openwrt "setenv bootargs; cp.b 0xee000000 0x1000000 0x1000000; bootm 0x1000000"
   setenv bootcmd "run boot_openwrt"
   saveenv
   tftpboot 0x1000000 192.168.200.200:01C8A8C0.img; bootm
   ```

   Die Befehle holen `01C8A8C0.img` von deinem Rechner und starten
   die RAMpe; das Terminal zeigt viele Zeilen. Warte, bis
   `Please press Enter to activate this console.` erscheint.

   Ab jetzt startet das Gerät nicht mehr die Herstellerfirmware.

### Freifunk-Firmware aufspielen

7. **Rechner vorbereiten.** Die RAMpe antwortet
   unter `192.168.1.1`. Stell deinen Rechner deshalb jetzt auf die feste
   Adresse `192.168.1.10` um, Netzmaske `255.255.255.0`.

8. **Die RAMpe-Seite öffnen.** Öffne `http://192.168.1.1`. Die RAMpe
    leitet von selbst auf ihre Seite "Firmware aktualisieren" weiter. Kommt
    stattdessen "Not Found", hat sich der Browser eine Weiterleitung von
    früher gemerkt, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
    Kommt gar nichts, siehe [Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md).
    Zeigt der Browser eine Warnung vor einem unsicheren Zertifikat, hat er
    von sich aus `https://` vor die Adresse gesetzt, siehe
    [Browser macht https daraus](grundlagen/browser-https.md).
    Die RAMpe läuft nur im Arbeitsspeicher. Startet das Gerät zwischendurch
    neu oder fehlt der Strom, ist sie weg: dann noch einmal ab Schritt 5.

    ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"](../bilder/allgemein/rampe-seite.png)

9. **Freifunk-Firmware hochladen.** Wähl das **sysupgrade**-Image
    deiner Community aus und klick "Datei hochladen". Die RAMpe zeigt die
    Prüfsumme (SHA256) der Datei. Vergleich sie mit der Prüfsumme, die deine
    Community zur Datei angibt. Stimmt sie, klick "Fortfahren".

    ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"](../bilder/allgemein/rampe-pruefsumme.png)

    Danach erscheint der Hinweis, dass die Firmware jetzt geschrieben wird.
    Jetzt den Strom nicht unterbrechen.

    ![Hinweis der RAMpe: Die Firmware wird jetzt aktualisiert, Stromversorgung nicht unterbrechen](../bilder/allgemein/rampe-flash-laeuft.png)

10. **Warten.** Das Gerät schreibt die Freifunk-Firmware und startet neu.
    **Strom nicht ziehen.**

11. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet
    die Freifunk-Firmware deiner Community: je nach Community zuerst mit
    einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im
    Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 5 erscheint die Eingabeaufforderung des Bootloaders.
- In Schritt 6 holt der Bootloader die Datei, und die RAMpe startet.
- In Schritt 8 zeigt `http://192.168.1.1` die RAMpe-Seite "Firmware
  aktualisieren".
- Nach Schritt 10 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Im Terminal erscheint nichts oder nur wirre Zeichen.** Prüf die
  Geschwindigkeit (115200) und das Kabel
  ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).
- **In Schritt 6 kommt die Datei nicht an.** Prüf die feste Adresse
  `192.168.200.200`, die Firewall deines Rechners und den Dateinamen
  `01C8A8C0.img`.
- **In Schritt 8 antwortet nichts.** Warte noch eine Minute, die RAMpe
  braucht etwas.
- **Nach Schritt 10 meldet sich lange nichts.** Weiter warten und nicht den
  Strom ziehen. Erst wenn nach einer halben Stunde noch nichts kommt, schreib
  uns, am besten mit der Mitschrift des Terminals.

## Anderer Weg: über OpenWrt

Statt der RAMpe startet der Bootloader in Schritt 6 auch OpenWrt:
[openwrt-24.10.8-mpc85xx-p1020-enterasys_ws-ap3710i-initramfs-kernel.bin](https://downloads.openwrt.org/releases/24.10.8/targets/mpc85xx/p1020/openwrt-24.10.8-mpc85xx-p1020-enterasys_ws-ap3710i-initramfs-kernel.bin), ebenfalls unter dem Namen
`01C8A8C0.img` in den TFTP-Ordner.
Danach kommt die Freifunk-Firmware per scp und ssh statt über den Browser
([SSH und scp benutzen](grundlagen/ssh-scp.md)): das sysupgrade-Image in
`gluon.bin` umbenennen, Rechner wie in Schritt 7 vorbereiten, dann

```
scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
ssh root@192.168.1.1 "sysupgrade -n /tmp/gluon.bin"
```

Ein Passwort gibt es nicht. Nach dem zweiten Befehl bricht die Verbindung
ab, das ist harmlos.

## Zurück zur Herstellerfirmware

Zurück zur Herstellerfirmware geht nur mit einer Sicherung der Partition "firmware", die du vor Schritt 7 aus OpenWrt heraus gemacht hast; der alte Startbefehl steht im Bootloader in der Variable boot_flash. Das beschreiben wir hier nicht.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: TFTP-Weg (Anschluss)
- geprüft (Weg ab Werk, Schritte (Normalweg), Datei)
- geprüft: Commit (Schritte (Normalweg), Anschluss, Adressen, Programm, Zugang, Datei, Rückweg zur Herstellerfirmware)
- geprüft: Commit 16b01fb (Schritte (Normalweg), Taste und Zeitpunkt, Zugang)
- geprüft: OpenWrt-Commit 16b01fb, am 15.10.2026 nachgelesen (Programm)
- geprüft: Wiki toh:enterasys:ws-ap3710i (Fehlerbild)
- geprüft: github grische/extremeflash, Wiki toh:enterasys:ws-ap3710i (Notweg)
- Geräteeintrag: 16b01fb1b9c99513c318109bef96a1a3545c57a0
