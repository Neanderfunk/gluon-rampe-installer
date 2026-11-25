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
rampe_image: gluon-rampe-20261115-extreme-networks-ws-ap3825i-initramfs-kernel.bin
grundlagen: [browser-https, browser-not-found, feste-ip, router-antwortet-nicht, serielle-konsole, ssh-scp, tftp-server]
daten_stand: cfa733f38
vorlage_stand: ae4d4370f
---

# Extreme Networks WS-AP3825i: Freifunk-Firmware installieren

> Schreib uns, ob es geklappt hat. Und wenn es irgendwo hakt: Melde dich,
> wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Extreme%20Networks%20WS-AP3825i)

> **Achtung:** Das Schreiben der Freifunk-Firmware und der erste Start danach dauern bei
> diesem Gerät **sehr lange, länger, als es sich gut anfühlt**. Es kann etwa
> 11 Minuten dauern, bis er wieder unter `192.168.1.1` antwortet, und die
> Konsole bleibt dabei lange stumm. **Nicht den Strom ziehen**, auch wenn
> scheinbar nichts passiert.

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
  Konsolenbuchse sitzt neben der Buchse für das 12-V-Netzteil. Ein einfacher USB-Seriell-Adapter für 3,3 V
  passt hier **nicht**: Die Buchse arbeitet mit den höheren Spannungen der
  alten seriellen Schnittstelle (RS-232).
- ein Terminalprogramm und einen TFTP-Server (siehe die zwei Seiten oben)
- diese Dateien:
  1. die RAMpe für den Extreme Networks WS-AP3825i:
     [gluon-rampe-20261115-extreme-networks-ws-ap3825i-initramfs-kernel.bin](https://firmware.neanderfunk.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261115-extreme-networks-ws-ap3825i-initramfs-kernel.bin).
     Leg sie in den Ordner deines TFTP-Servers und benenn sie dort genau in
     **`ws-ap3825i-initramfs.bin`** um.
  2. die Freifunk-Firmware deiner Community für den Extreme Networks WS-AP3825i, und zwar
     das **sysupgrade**-Image.

## Vorher prüfen

- Die WS-AP3825i hat dasselbe Gehäuse wie die Enterasys WS-AP3725i und die
  Adtran BSAP-2030. Ob die dieselbe Firmware vertragen, ist nicht geklärt.
  Nimm diese Anleitung nur für eine WS-AP3825i (Typenschild).

## Schritte

### Die RAMpe starten

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

6. **Bootloader einstellen und die RAMpe laden.** Gib
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
   die RAMpe; das Terminal zeigt viele Zeilen. Warte, bis
   `Please press Enter to activate this console.` erscheint.

   Ab jetzt startet das Gerät nicht mehr die Herstellerfirmware.

### Freifunk-Firmware aufspielen

7. **Rechner vorbereiten.** Steck das Netzwerkkabel jetzt in die Buchse
   **LAN1**. Die feste Adresse `192.168.1.66` passt auch für die
   RAMpe unter `192.168.1.1`.

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

10. **Warten.** Das Gerät schreibt die Freifunk-Firmware und startet neu. Das dauert bei diesem Gerät sehr lange, oft zehn Minuten und mehr, und die Konsole bleibt dabei lange stumm (siehe Achtung oben).
    **Strom nicht ziehen.** Laut OpenWrt-Wiki blinkt die Power-LED, solange er beschäftigt ist, und leuchtet dauerhaft, wenn er fertig ist.

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
  `192.168.1.66`, die Firewall deines Rechners und den Dateinamen
  `ws-ap3825i-initramfs.bin`, und ob das Kabel in LAN2 steckt.
- **In Schritt 8 antwortet nichts.** Warte noch eine Minute, die RAMpe
  braucht etwas. Prüf, ob das Kabel jetzt in LAN1
  steckt.
- **Nach Schritt 10 meldet sich lange nichts.** Weiter warten und nicht den
  Strom ziehen. Erst wenn nach einer halben Stunde noch nichts kommt, schreib
  uns, am besten mit der Mitschrift des Terminals.
- **Statt `Boot (PRI)->` erscheint eine Eingabe wie `/flash/home/admin`,
  oder `setenv` ist unbekannt.** Dann bist du nicht im Bootloader, sondern
  schon in der Herstellerfirmware. Strom ziehen, Schritt 5 wiederholen und
  Enter drücken, sobald `Scanning JFFS2 FS:` erscheint.
- **Der Start bleibt mit `ft_fixup_l2cache: FDT_ERR_NOTFOUND` stehen.** Das
  OpenWrt-initramfs ist zu neu. Nimm genau die Version 22.03.0 von oben.

## Anderer Weg: über OpenWrt

Statt der RAMpe startet der Bootloader in Schritt 6 auch OpenWrt:
[openwrt-22.03.0-mpc85xx-p1020-extreme-networks_ws-ap3825i-initramfs-kernel.bin](https://archive.openwrt.org/releases/22.03.0/targets/mpc85xx/p1020/openwrt-22.03.0-mpc85xx-p1020-extreme-networks_ws-ap3825i-initramfs-kernel.bin), ebenfalls unter dem Namen
`ws-ap3825i-initramfs.bin` in den TFTP-Ordner. Bewusst die alte Version 22.03.0: Mit neueren bleibt das Gerät beim Start mit der Meldung `ft_fixup_l2cache: FDT_ERR_NOTFOUND` hängen. Die Freifunk-Firmware, die du danach aufspielst, ist trotzdem aktuell.
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

Zurück zur Herstellerfirmware geht nur mit einer Sicherung der Partition "firmware", die du vor Schritt 7 aus OpenWrt heraus gemacht hast. Das beschreiben wir hier nicht.
