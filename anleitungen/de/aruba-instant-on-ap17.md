---
gluon_name: aruba-instant-on-ap17
modell: Aruba Instant On AP17 (Alias von aruba-ap-365)
anzeige: Aruba Instant On AP17
familie: aruba-apboot
gluon_broken: false
sprache: de
level: L6
level_text: Serielles Kabel
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, serielle-konsole, ssh-scp, tftp-server]
daten_stand: f73c9aa2
vorlage_stand: 883c350d
---

# Aruba Instant On AP17: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Aruba%20Instant%20On%20AP17)

Aruba-Access-Points nehmen eine fremde Firmware nicht über ihre
Weboberfläche an. Der Weg führt über die **serielle Konsole**, also ein
Kabel, über das du den Bootloader des Geräts (bei Aruba heißt er "APBoot")
direkt bedienst. Das Gehäuse musst du dafür nicht öffnen.

Der Weg hat zwei Etappen:

1. **OpenWrt starten.** Du stellst den Bootloader so ein, dass er ein
   kleines OpenWrt per TFTP von deinem Rechner holt und startet. Es läuft
   nur im Arbeitsspeicher.
2. **Die Freifunk-Firmware aufspielen.** Aus diesem OpenWrt heraus bereitest
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
- einen Zugang zur seriellen Konsole. **Wir wissen nicht sicher**, ob die
  USB-Buchse des Aruba Instant On AP17 ein echter USB-Anschluss ist (wie beim
  Aruba AP-365) oder nur die seriellen Leitungen trägt (wie beim AP-303).
  Steck kein normales USB-Kabel ein, solange das nicht geklärt ist, und
  schreib uns vorher. Wir finden es mit dir heraus.
- ein Terminalprogramm, einen TFTP-Server und `ssh`/`scp` (siehe die drei
  Seiten oben)
- diese Dateien:
  1. das OpenWrt-initramfs für dein Gerät:
     [openwrt-24.10.8-ipq40xx-generic-aruba_ap-365-initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-365-initramfs-uImage.itb), SHA256
     `9dbf7ed4b826d75d4d6893c52d3d5e925b2331c91a33b9842a3d1f7c03a12d83`.
     Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
     **`ipq40xx.ari`** um.
  2. die Freifunk-Firmware deiner Community für den Aruba Instant On AP17, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.

## Vorher prüfen

- Der Instant On AP17 ist technisch ein Aruba AP-365 für draußen. Die
  Freifunk-Firmware ist für beide dieselbe; manche Communities bieten sie nur
  unter dem Namen AP-365 an.
- Wir vermuten, dass neuere AP17 denselben gesperrten Bootloader haben wie
  neuere Instant On AP11. Rückmeldungen dazu haben wir noch keine. Kommt in
  Schritt 7 `Unknown command 'bootm'`, schreib uns bitte, damit wir es
  belegen können. Der ältere Bootloader von der AP11-Seite passt **nicht**
  zum AP17.

## Schritte

### Vorbereitung

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.75`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Access Point den TFTP-Server.

2. **TFTP-Server starten.** Starte den TFTP-Server mit dem Ordner, in dem
   `ipq40xx.ari` liegt
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

### OpenWrt starten

6. **Bootloader einstellen.** Gib diese Befehle ein, jede Zeile einzeln, und
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

7. **OpenWrt laden.** Gib ein:

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

8. **Anmelden.**
    Öffne ein zweites Terminal im Ordner mit `gluon.bin` und gib ein:

    ```
    scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
    ssh root@192.168.1.1
    ```

    Ein Passwort gibt es nicht. Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS
    CHANGED", siehe [SSH und scp benutzen](grundlagen/ssh-scp.md).

9. **Speicher prüfen.** Auf dem Access Point:

    ```
    grep ubi /proc/mtd
    ```

    **Prüfen:** Die Ausgabe beginnt mit
    `mtd1:` und endet mit `"ubi"`. Sonst hier
    aufhören und uns schreiben.

10. **Speicher vorbereiten und Freifunk-Firmware schreiben.** Gib ein, Zeile
    für Zeile:

    ```
    ubidetach -p /dev/mtd1
    ubiformat /dev/mtd1
    sysupgrade -n /tmp/gluon.bin
    ```

    Meldet `ubidetach` einen Fehler, ist das kein Problem, solange
    `ubiformat` danach ohne Fehler durchläuft. Fragt `ubiformat` nach, mit
    `y` bestätigen. Nach `sysupgrade` bricht die Verbindung ab.

11. **Fertig.** Einige Minuten warten, Strom nicht ziehen. Im
    Konsolen-Terminal siehst du den Neustart. Stell den Rechner wieder auf
    "automatisch". Danach startet die Freifunk-Firmware deiner Community: je
    nach Community zuerst mit einer Einrichtungsseite unter
    `http://192.168.1.1` oder gleich im Betrieb.
    Kommt dort "Not Found", siehe [Der Browser zeigt
    "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 5 erscheint `apboot>`.
- In Schritt 7 zeigt der Bootloader, dass er die Datei geholt hat
  (`Bytes transferred = …`), und OpenWrt startet.
- In Schritt 9 zeigt `grep` die Partition `"ubi"`.
- Nach Schritt 11 meldet sich die Freifunk-Firmware.

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
- **In Schritt 7 kommt `Unknown command 'bootm'`.** Dann hat dein Gerät vermutlich einen neueren Bootloader, aus
  dem der Hersteller Befehle entfernt hat, die OpenWrt braucht. Einen
  passenden älteren Bootloader für den Aruba Instant On AP17 haben wir noch nicht.
  Bitte schreib uns, damit wir es klären können. **Schreib auf keinen Fall
  den Bootloader eines anderen Modells auf dein Gerät**, auch nicht den von
  der Seite eines ähnlichen Geräts: Es könnte danach nicht mehr starten.
  Willst du an dieser Stelle aufhören, stell im Bootloader den Start der
  Aruba-Firmware wieder her, wie unter "Zurück zur Aruba-Firmware"
  beschrieben.
- **In Schritt 8 antwortet nichts.** Warte noch eine Minute,
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

- abgeleitet (Weg ab Werk, Schritte (Normalweg), Gehäuse öffnen)
- abgeleitet: Analogie AP11 (Bedingung an die Herstellerfirmware)
- abgeleitet: Wiki toh/aruba/ap-365 'same platform' (Schritte (Normalweg), Adressen, Programm, Zugang, Datei)
- abgeleitet: Wiki toh/aruba/ap-365 'same platform'; ob die USB-Buchse beim AP17 auch echtes USB ist, ist nicht belegt (Schritte (Normalweg), Anschluss)
- abgeleitet: gleiche Plattform (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Gluon-Alias, Wiki toh:aruba:ap-365 (Typenschild/Verwechslung)
- Geräteeintrag: OpenWrt 300b7fe85a743ab0e039457a5a551819b49450da
