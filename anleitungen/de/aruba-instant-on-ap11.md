---
gluon_name: aruba-instant-on-ap11
modell: Aruba Instant On AP11 (Alias von aruba-ap-303)
anzeige: Aruba Instant On AP11
familie: aruba-apboot
gluon_broken: false
sprache: de
level: L6
level_text: Serielles Kabel
risiko: bootloader
status: ungeprüft
grundlagen: [feste-ip, serielle-konsole, ssh-scp, tftp-server]
daten_stand: 071c7876
vorlage_stand: 565e8935
---

# Aruba Instant On AP11: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
> Den Schritt mit dem älteren Bootloader beschreibt Freifunk Darmstadt; die Datei dafür stellen wir bereit.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Aruba%20Instant%20On%20AP11)

> **Achtung, Bootloader:** Bei diesem Gerät wird der Bootloader verändert,
> also das kleine Programm, das vor jeder Firmware startet. Geht dabei etwas
> schief, etwa durch einen Stromausfall oder eine falsche Datei, startet das
> Gerät womöglich nicht mehr. Ohne Flash-Programmer gibt es dann meist kein
> Zurück. Lies die Anleitung vorher einmal ganz durch und halte dich genau an
> die Befehle.

Aruba-Access-Points nehmen eine fremde Firmware nicht über ihre
Weboberfläche an. Der Weg führt über die **serielle Konsole**, also ein
Kabel, über das du den Bootloader des Geräts (bei Aruba heißt er "APBoot")
direkt bedienst. Das Gehäuse musst du dafür nicht öffnen.

Der Weg hat drei Etappen:

1. **Älteren Bootloader aufspielen.** Praktisch alle Geräte dieses Typs
   haben inzwischen einen Bootloader, aus dem der Hersteller Befehle
   entfernt hat, die OpenWrt braucht. Du ersetzt ihn zuerst durch eine
   ältere Fassung. Das ist der heikelste Teil; lies ihn vorher einmal ganz
   durch.
2. **OpenWrt starten.** Du stellst den Bootloader so ein, dass er ein
   kleines OpenWrt per TFTP von deinem Rechner holt und startet. Es läuft
   nur im Arbeitsspeicher.
3. **Die Freifunk-Firmware aufspielen.** Aus diesem OpenWrt heraus bereitest
   du den Speicher vor und installierst die Freifunk-Firmware deiner
   Community.

Dafür brauchst du drei Werkzeuge, die auf eigenen Seiten erklärt sind:
[Serielle Konsole benutzen](grundlagen/serielle-konsole.md),
[TFTP-Server einrichten](grundlagen/tftp-server.md) und
[SSH und scp benutzen](grundlagen/ssh-scp.md). Rechne beim ersten Mal mit
einer Stunde, ohne das Kabel zu bauen.

## Was du brauchst

- den Access Point mit Stromversorgung (Netzteil oder PoE-Injektor), einen
  Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- einen **USB-Seriell-Adapter für 3,3 V** und ein **selbst gebautes
  Konsolenkabel** (siehe unten). Die Entwickler von OpenWrt berichten, dass
  billige Adapter hier nicht funktioniert haben.
- ein Terminalprogramm, einen TFTP-Server und `ssh`/`scp` (siehe die drei
  Seiten oben)
- diese Dateien:
  1. das OpenWrt-initramfs für dein Gerät:
     [openwrt-24.10.8-ipq40xx-generic-aruba_ap-303-initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-303-initramfs-uImage.itb), SHA256
     `5d65d93c796b5dd10e42a65269dadb7905dca0b42c0fd60251431392b53ac56e`.
     Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
     **`ipq40xx.ari`** um.
  2. die Freifunk-Firmware deiner Community für den Aruba Instant On AP11, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.
  3. den älteren Bootloader als ZIP-Archiv:
     [ap303-loader-2.5.0.2.zip](https://download.ffnef.de/other/dump/ap303-loader-2.5.0.2.zip). Pack es aus. Kommt dabei
     keine Fehlermeldung, ist die Datei heil. Leg `ap303-loader-2.5.0.2.bin` aus
     dem Archiv ebenfalls in den Ordner deines TFTP-Servers, unter genau
     diesem Namen.

## Vorher prüfen

- Der Instant On AP11 ist technisch ein Aruba AP-303. Die Freifunk-Firmware
  ist für beide dieselbe; manche Communities bieten sie nur unter dem Namen
  AP-303 an.
- Nicht verwechseln mit dem [Instant On AP11D](aruba-instant-on-ap11d.md),
  dem Tischgerät mit mehreren Netzwerkbuchsen. Der braucht andere Dateien.
- Praktisch alle AP11 haben inzwischen den neueren Bootloader
  (`APBoot 2.6.…`). Deshalb beginnt diese Anleitung damit, den älteren
  aufzuspielen. Lies den Teil "Älteren Bootloader aufspielen" vorher einmal
  ganz durch.

## Das Konsolenkabel bauen

**Steck nie ein normales USB-Kabel in die Buchse "Console".** Aruba hat dort
keinen USB-Anschluss eingebaut, sondern legt die seriellen Leitungen auf die
Kontakte der Micro-USB-Buchse. Du baust dir das Kabel aus einem alten
Micro-USB-Kabel: Schneid das große USB-Ende ab und isolier die vier Adern ab.

| Ader im Micro-USB-Kabel | meist diese Farbe | an den Adapter |
|---|---|---|
| VCC | rot | **nicht anschließen**, einzeln isolieren |
| D+ | grün | RX |
| D− | weiß | TX |
| GND | schwarz | GND |

Laut OpenWrt liegt auf D+ der Sendekontakt (TX) und auf D− der
Empfangskontakt (RX) des Access Points. Deshalb kommt D+ an RX und D− an TX
des Adapters. Die Farben stimmen bei den meisten Kabeln, aber nicht bei
allen. Erscheint später kein Text im Terminal, tausch grün und weiß. Es gibt
auch fertige Kabel, die ausdrücklich für Aruba-Access-Points verkauft
werden.

## Schritte

### Vorbereitung

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.75`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Access Point den TFTP-Server.

2. **TFTP-Server starten.** Starte den TFTP-Server mit dem Ordner, in dem
   `ipq40xx.ari` und `ap303-loader-2.5.0.2.bin` liegen
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an die Netzwerkbuchse des Access Points.
   Das Konsolenkabel an die Konsolenbuchse, das andere Ende an den Rechner.
   Strom noch nicht anschließen.

4. **Terminal öffnen.** Starte das Terminalprogramm mit **9600** Baud, 8N1,
   ohne Flusssteuerung
   ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).

5. **Bootloader anhalten.** Schließ jetzt den Strom an. Im Terminal erscheint
   der Start des Bootloaders. Die erste Zeile beginnt mit `APBoot` und
   nennt die Version, merk sie dir. Sobald `Hit <Enter> to stop autoboot`
   erscheint, drück Enter. Das Zeitfenster ist nur etwa zwei Sekunden lang;
   drück am besten schon beim Einschalten immer wieder Enter. **Prüfen:** Es
   erscheint die Eingabeaufforderung `apboot>`. Sonst Strom ziehen und noch
   einmal.

   Steht in der ersten Zeile schon `APBoot 2.5.0.2`, ist der ältere
   Bootloader bereits drauf, etwa bei einem Gerät aus zweiter Hand. Dann
   überspring den nächsten Teil und mach mit Schritt 9 weiter.

### Älteren Bootloader aufspielen

> **Warnung:** Hier überschreibst du den Bootloader des Geräts. Geht dabei
> etwas schief, zum Beispiel eine falsche Datei, ein Tippfehler in den
> Adressen oder ein Stromausfall mittendrin, startet das Gerät nicht mehr.
> Dann hilft nur noch ein Programmiergerät für den Speicherchip. Mach das
> nur bei dem Gerät, für das diese Anleitung gilt, und halte dich genau an
> die Befehle.

Praktisch alle Geräte dieses Typs haben inzwischen einen neueren Bootloader
(zum Beispiel `APBoot 2.6.2.9`), aus dem der Hersteller Befehle entfernt
hat, die OpenWrt braucht. Du ersetzt ihn durch die ältere Fassung
`APBoot 2.5.0.2` aus einem älteren Gerät desselben Typs. Freifunk Darmstadt
hat diesen Weg ausprobiert. Überschrieben wird nur der Bereich des
Bootloaders, nicht der Rest des Speichers.

6. **Datei laden.** Gib im Terminal bei `apboot>` ein (eine Zeile):

   ```
   setenv ipaddr 192.168.1.105; setenv serverip 192.168.1.75; netget 0x84000000 ap303-loader-2.5.0.2.bin
   ```

   **Prüfen:** Es erscheint `Bytes transferred = 983040 (f0000 hex)`. Die
   Meldung `Invalid image format version` danach ist hier normal. Steht
   dort eine andere Zahl oder ein Fehler, **hier aufhören** und auf keinen
   Fall Schritt 7 eingeben.

7. **Bootloader schreiben.** Gib ein (eine Zeile, genau so):

   ```
   sf probe; sf protect off; sf erase 0xf0000 0xf0000; sf write 0x84000000 0xf0000 0xf0000
   ```

   Strom nicht ziehen. Warte, bis wieder `apboot>` erscheint. Meldet der
   Bootloader `Unknown command 'sf'`, gib zuerst `diag` ein und dann die
   Zeile noch einmal.

8. **Neu starten.** Gib `reset` ein. **Prüfen:** Die erste Zeile lautet
   jetzt `APBoot 2.5.0.2`. Halt den Bootloader wie in Schritt 5 wieder an,
   bis `apboot>` erscheint.

### OpenWrt starten

9. **Bootloader einstellen.** Gib diese Befehle ein, jede Zeile einzeln, und
    warte nach jeder Zeile auf `apboot>`:

    ```
    setenv bootargs_openwrt "setenv bootargs console=ttyMSM1,9600n8"
    setenv nandboot_openwrt "run bootargs_openwrt; ubi part aos1; ubi read 0x85000000 kernel; set fdt_high 0x87000000; bootm 0x85000000"
    setenv ramboot_openwrt "run bootargs_openwrt; setenv ipaddr 192.168.1.105; setenv serverip 192.168.1.75; netget; set fdt_high 0x87000000; bootm"
    setenv bootcmd "run nandboot_openwrt"
    saveenv
    ```

    **Prüfen:** Gib `printenv ramboot_openwrt` ein. Die Ausgabe muss genau
    der dritten Zeile oben entsprechen. Sonst diese Zeile noch einmal
    eingeben und wieder `saveenv`.

    Damit startet der Access Point ab jetzt OpenWrt statt der
    Aruba-Firmware. Die Aruba-Firmware bleibt im Speicher, siehe "Zurück zur
    Aruba-Firmware".

10. **OpenWrt laden.** Gib ein:

    ```
    run ramboot_openwrt
    ```

    Der Access Point holt `ipq40xx.ari` von deinem Rechner. Danach erscheint
    `Invalid image format version`, das ist normal. Kurz darauf startet
    OpenWrt, das Terminal zeigt viele Zeilen. Warte, bis
    `Please press Enter to activate this console.` erscheint.

    **Kommt stattdessen `Unknown command 'bootm'`**, lies unter "Wenn etwas
    schiefgeht" weiter.

### Freifunk-Firmware aufspielen

11. **Anmelden.**
    Öffne ein zweites Terminal im Ordner mit `gluon.bin` und gib ein:

    ```
    scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
    ssh root@192.168.1.1
    ```

    Ein Passwort gibt es nicht. Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS
    CHANGED", siehe [SSH und scp benutzen](grundlagen/ssh-scp.md).

12. **Speicher prüfen.** Auf dem Access Point:

    ```
    grep ubi /proc/mtd
    ```

    **Prüfen:** Die Ausgabe beginnt mit
    `mtd1:` und endet mit `"ubi"`. Sonst hier
    aufhören und uns schreiben.

13. **Speicher vorbereiten und Freifunk-Firmware schreiben.** Gib ein, Zeile
    für Zeile:

    ```
    ubidetach -p /dev/mtd1
    ubiformat /dev/mtd1
    sysupgrade -n /tmp/gluon.bin
    ```

    Meldet `ubidetach` einen Fehler, ist das kein Problem, solange
    `ubiformat` danach ohne Fehler durchläuft. Fragt `ubiformat` nach, mit
    `y` bestätigen. Nach `sysupgrade` bricht die Verbindung ab.

14. **Fertig.** Einige Minuten warten, Strom nicht ziehen. Im
    Konsolen-Terminal siehst du den Neustart. Stell den Rechner wieder auf
    "automatisch". Danach startet die Freifunk-Firmware deiner Community: je
    nach Community zuerst mit einer Einrichtungsseite unter
    `http://192.168.1.1` oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- In Schritt 5 erscheint `apboot>`.
- In Schritt 6 kommt `Bytes transferred = 983040 (f0000 hex)`, und nach
  Schritt 8 lautet die erste Zeile `APBoot 2.5.0.2`.
- In Schritt 10 zeigt der Bootloader, dass er die Datei geholt hat
  (`Bytes transferred = …`), und OpenWrt startet.
- In Schritt 12 zeigt `grep` die Partition `"ubi"`.
- Nach Schritt 14 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Im Terminal erscheint nichts.** Prüf Baudrate (9600), GND und die
  Leitungen. TX und RX tauschen
  ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).
- **Text erscheint, aber Enter wirkt nicht.** Der Konsolenanschluss der
  Aruba-Geräte ist wählerisch. Mit manchen Adaptern kann man mitlesen, aber
  nichts eingeben. Versuch einen anderen Adapter.
- **Eine Datei kommt nicht an** (der Bootloader wiederholt es oder bricht
  ab). Prüf die feste Adresse `192.168.1.75`, die Firewall deines Rechners
  und den Dateinamen.
- **In Schritt 10 kommt `Unknown command 'bootm'`.** Dann läuft noch der neuere Bootloader. Prüf beim
  Einschalten die erste Zeile: Sie muss `APBoot 2.5.0.2` lauten. Sonst den
  Teil "Älteren Bootloader aufspielen" wiederholen.
  Willst du an dieser Stelle aufhören, stell im Bootloader den Start der
  Aruba-Firmware wieder her, wie unter "Zurück zur Aruba-Firmware"
  beschrieben.
- **In Schritt 11 antwortet nichts.** Warte noch eine Minute,
  OpenWrt braucht etwas.
- **`ubiformat` meldet einen Fehler.** Nicht weitermachen, sondern die
  Ausgabe abschreiben (oder die Mitschrift des Terminals nehmen) und uns
  schreiben.

## Zurück zur Aruba-Firmware

Die Aruba-Firmware bleibt bei diesem Weg im Speicher. Um sie wieder zu
starten, halt den Bootloader an (Schritt 5) und gib ein:

```
setenv bootcmd "boot"
saveenv
```

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Typenschild/Verwechslung)
- abgeleitet: Alias, gleiche Platine (Gehäuse öffnen)
- geprüft: Datei und ZIP geladen 15.10.2026, SHA256 gleich der im Freifunk-Darmstadt-Wiki Aruba AP11 (github freifunk-darmstadt/projects, getestet mit APBoot 2.6.2.9) für apboot-unlocked.bin (Werkzeug/Spezial)
- geprüft: Forum t/22653 #28 (adorfer, 03.04.2023, Abzüge) (Stock-Teile)
- geprüft: Forum t/22653 #29 (blocktrron, 14.06.2024) (Programm)
- geprüft: Freifunk-Darmstadt-Wiki Aruba AP11 (github freifunk-darmstadt/projects, getestet mit APBoot 2.6.2.9); Adressen dort .6/.66, in der Anleitung .105/.75 (Programm)
- geprüft: Gluon-Alias, Wiki toh:aruba:ap-303 (Typenschild/Verwechslung)
- geprüft: Neanderfunk-Notiz zum AP11, 2024 (Weg ab Werk)
- geprüft: Neanderfunk-Notiz, adorfer 15.10.2026 (Abzüge 2021/2023); Freifunk-Darmstadt-Wiki Aruba AP11 (github freifunk-darmstadt/projects, getestet mit APBoot 2.6.2.9); APBoot-Version in ap303-loader-2.5.0.2.bin per strings geprüft (Sichtbare Zeichen)
- geprüft: Neanderfunk-Notiz; Sc4ndium90-README (Bedingung an die Herstellerfirmware)
- geprüft: OpenWrt-Commit 102c8c5 (AP-303) (Programm)
- geprüft: Sc4ndium90-README (Programm)
- geprüft: Wiki toh:aruba:ap-303 (Sichtbare Zeichen)
- geprüft: Wiki toh:aruba:ap-303h, Rohtext 15.10.2026 (Programm)
- geprüft: github Sc4ndium90/aruba-ap11-openwrt, Wiki toh:aruba:ap-303 (Taste und Zeitpunkt)
- Geräteeintrag: Notiz ap11.md (2024); OpenWrt 102c8c55f217606cdbdc9a449667e034676b3e75
