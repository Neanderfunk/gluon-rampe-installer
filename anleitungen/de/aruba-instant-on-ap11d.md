---
gluon_name: aruba-instant-on-ap11d
modell: Aruba Instant On AP11D (Alias von aruba-ap-303h)
anzeige: Aruba Instant On AP11D
familie: aruba-apboot
gluon_broken: false
sprache: de
level: L6
level_text: Serielles Kabel
risiko: normal
status: ungeprüft
rampe_image: gluon-rampe-20261115-aruba-ap-303h-initramfs-uImage.itb
grundlagen: [browser-https, browser-not-found, feste-ip, router-antwortet-nicht, serielle-konsole, ssh-scp, tftp-server]
daten_stand: 7ef99fa21
vorlage_stand: 84f780274
---

# Aruba Instant On AP11D: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Aruba%20Instant%20On%20AP11D)

Aruba-Access-Points nehmen eine fremde Firmware nicht über ihre
Weboberfläche an. Der Weg führt über die **serielle Konsole**, also ein
Kabel, über das du den Bootloader des Geräts (bei Aruba heißt er "APBoot")
direkt bedienst. Das Gehäuse musst du dafür nicht öffnen.

Der Weg hat zwei Etappen:

1. **Die RAMpe starten.** Du stellst den Bootloader so ein, dass er die
   **Gluon-RAMpe** per TFTP von deinem Rechner holt und startet: eine kleine
   Firmware, die nur eins kann, die Freifunk-Firmware deiner Community
   annehmen. Sie läuft nur im Arbeitsspeicher.
2. **Die Freifunk-Firmware aufspielen.** Auf der Seite der RAMpe lädst du
   sie im Browser hoch. Den Speicher bereitet die RAMpe dabei selbst vor.

Dafür brauchst du zwei Werkzeuge, die auf eigenen Seiten erklärt sind:
[Serielle Konsole benutzen](grundlagen/serielle-konsole.md) und
[TFTP-Server einrichten](grundlagen/tftp-server.md). Rechne beim ersten Mal
mit einer Stunde, ohne das Kabel zu bauen.

## Was du brauchst

- den Access Point mit Stromversorgung (Netzteil oder PoE-Injektor), einen
  Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- einen **USB-Seriell-Adapter für 3,3 V** und ein **selbst gebautes
  Konsolenkabel** (siehe unten). Die Entwickler von OpenWrt berichten, dass
  billige Adapter hier nicht funktioniert haben.
- ein Terminalprogramm und einen TFTP-Server (siehe die zwei Seiten oben)
- diese Dateien:
  1. die RAMpe für dein Gerät:
     [gluon-rampe-20261115-aruba-ap-303h-initramfs-uImage.itb](https://firmware.neanderfunk.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261115-aruba-ap-303h-initramfs-uImage.itb).
     Leg sie in den Ordner deines TFTP-Servers und benenn sie dort genau in
     **`ipq40xx.ari`** um.
  2. die Freifunk-Firmware deiner Community für den Aruba Instant On AP11D, und zwar
     das **sysupgrade**-Image.

## Vorher prüfen

- Der Instant On AP11D ist technisch ein Aruba AP-303H. Die
  Freifunk-Firmware ist für beide dieselbe; manche Communities bieten sie nur
  unter dem Namen AP-303H an.
- Nicht verwechseln mit dem [Instant On AP11](aruba-instant-on-ap11.md) ohne
  "D", dem Gerät für Decke oder Wand mit einer Netzwerkbuchse. Der braucht
  andere Dateien.
- Wir vermuten, dass neuere AP11D denselben gesperrten Bootloader haben wie
  neuere Instant On AP11. Rückmeldungen dazu haben wir noch keine. Kommt in
  Schritt 7 `Unknown command 'bootm'`, schreib uns bitte, damit wir es
  belegen können. Der ältere Bootloader von der AP11-Seite passt **nicht**
  zum AP11D.

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
   `ipq40xx.ari` liegt
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an die Buchse **E0** des Access Points.
   Nur über diese Buchse holt er sich die Dateien. Sie sitzt auf der Rückseite neben „PT“. Die Buchse „E0/PT“ unten ist nur das andere Ende der Durchreiche PT; darüber erreichst du das Gerät nicht.
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

### Die RAMpe starten

6. **Bootloader einstellen.** Gib diese Befehle ein, jede Zeile einzeln, und
    warte nach jeder Zeile auf `apboot>`:

    ```
    setenv bootargs_openwrt "setenv bootargs console=ttyMSM0,9600n8"
    setenv nandboot_openwrt "run bootargs_openwrt; ubi part aos1; ubi read 0x85000000 kernel; set fdt_high 0x87000000; bootm 0x85000000"
    setenv ramboot_openwrt "run bootargs_openwrt; setenv ipaddr 192.168.1.105; setenv serverip 192.168.1.75; netget; set fdt_high 0x87000000; bootm"
    setenv bootcmd "run nandboot_openwrt"
    saveenv
    ```

    **Prüfen:** Gib `printenv ramboot_openwrt` ein. Die Ausgabe muss genau
    der dritten Zeile oben entsprechen. Sonst diese Zeile noch einmal
    eingeben und wieder `saveenv`.

    Damit startet der Access Point ab jetzt nicht mehr die
    Aruba-Firmware. Die Aruba-Firmware bleibt im Speicher, siehe "Zurück zur
    Aruba-Firmware".

7. **Die RAMpe laden.** Gib ein:

    ```
    run ramboot_openwrt
    ```

    Der Access Point holt `ipq40xx.ari` von deinem Rechner. Danach erscheint
    `Invalid image format version`, das ist normal. Kurz darauf startet
    die RAMpe, das Terminal zeigt viele Zeilen. Warte, bis
    `Please press Enter to activate this console.` erscheint.

    **Kommt stattdessen `Unknown command 'bootm'`**, lies unter "Wenn etwas
    schiefgeht" weiter.

### Freifunk-Firmware aufspielen

8. **Rechner vorbereiten.** Steck das Netzwerkkabel jetzt in die Buchse
    **E1, E2 oder E3**. Unter der RAMpe ist E0
    der Internet-Anschluss und nicht erreichbar. Die feste Adresse
    `192.168.1.75` passt auch für die RAMpe unter `192.168.1.1`.

9. **Die RAMpe-Seite öffnen.** Öffne `http://192.168.1.1`. Die RAMpe
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

10. **Freifunk-Firmware hochladen.** Wähl das **sysupgrade**-Image
    deiner Community aus und klick "Datei hochladen". Die RAMpe zeigt die
    Prüfsumme (SHA256) der Datei. Vergleich sie mit der Prüfsumme, die deine
    Community zur Datei angibt. Stimmt sie, klick "Fortfahren".

    ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"](../bilder/allgemein/rampe-pruefsumme.png)

    Danach erscheint der Hinweis, dass die Firmware jetzt geschrieben wird.
    Jetzt den Strom nicht unterbrechen.

    ![Hinweis der RAMpe: Die Firmware wird jetzt aktualisiert, Stromversorgung nicht unterbrechen](../bilder/allgemein/rampe-flash-laeuft.png)

    Vor dem Schreiben bereitet die RAMpe den Speicher vor. Klappt das nicht,
    schreibt sie nichts und zeigt ein Protokoll an, siehe "Wenn etwas
    schiefgeht".

11. **Fertig.** Einige Minuten warten, Strom nicht ziehen. Im
    Konsolen-Terminal siehst du den Neustart. Stell den Rechner wieder auf
    "automatisch". Danach startet die Freifunk-Firmware deiner Community: je
    nach Community zuerst mit einer Einrichtungsseite unter
    `http://192.168.1.1` oder gleich im Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 5 erscheint `apboot>`.
- In Schritt 7 zeigt der Bootloader, dass er die Datei geholt hat
  (`Bytes transferred = …`), und die RAMpe startet.
- In Schritt 9 zeigt `http://192.168.1.1` die RAMpe-Seite
  "Firmware aktualisieren".
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
  und den Dateinamen, und ob das Kabel in E0 steckt.
- **In Schritt 7 kommt `Unknown command 'bootm'`.** Dann hat dein Gerät vermutlich einen neueren Bootloader, aus
  dem der Hersteller Befehle entfernt hat, die OpenWrt braucht. Einen
  passenden älteren Bootloader für den Aruba Instant On AP11D haben wir noch nicht.
  Bitte schreib uns, damit wir es klären können. **Schreib auf keinen Fall
  den Bootloader eines anderen Modells auf dein Gerät**, auch nicht den von
  der Seite eines ähnlichen Geräts: Es könnte danach nicht mehr starten.
  Willst du an dieser Stelle aufhören, stell im Bootloader den Start der
  Aruba-Firmware wieder her, wie unter "Zurück zur Aruba-Firmware"
  beschrieben.
- **In Schritt 9 antwortet nichts.** Warte noch eine Minute,
  die RAMpe braucht etwas. Prüf, ob das Kabel jetzt in E1, E2 oder E3
  steckt.
- **Die RAMpe meldet beim Vorbereiten des Speichers einen Fehler** und
  zeigt ein Protokoll. Dann hat sie nichts geschrieben. Nicht weitermachen,
  sondern das Protokoll abschreiben (oder die Mitschrift des Terminals
  nehmen) und uns schreiben.

## Anderer Weg: über OpenWrt

Statt der RAMpe startet der Bootloader in Schritt 7 auch OpenWrt:
[openwrt-24.10.8-ipq40xx-generic-aruba_ap-303h-initramfs-uImage.itb](https://downloads.openwrt.org/releases/24.10.8/targets/ipq40xx/generic/openwrt-24.10.8-ipq40xx-generic-aruba_ap-303h-initramfs-uImage.itb), SHA256 `70aebd60b9d1c666656ed89c7a81f53ead246ed96ecbd94551226a0c8f0a785e`,
ebenfalls als `ipq40xx.ari` in den TFTP-Ordner. Den Speicher bereitest du
dann selbst vor ([SSH und scp benutzen](grundlagen/ssh-scp.md)): das
sysupgrade-Image in `gluon.bin` umbenennen, Rechner wie in Schritt
8 vorbereiten, dann

```
scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
ssh root@192.168.1.1
```

und auf dem Access Point, Zeile für Zeile (prüf vorher mit
`grep ubi /proc/mtd`, dass die Ausgabe mit
`mtd16:` beginnt und auf `"ubi"` endet):

```
ubidetach -p /dev/mtd16
ubiformat /dev/mtd16
sysupgrade -n /tmp/gluon.bin
```

## Zurück zur Aruba-Firmware

Die Aruba-Firmware bleibt bei diesem Weg im Speicher. Um sie wieder zu
starten, halt den Bootloader an (Schritt 5) und gib ein:

```
setenv bootcmd "boot"
saveenv
```

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Weg ab Werk, Schritte (Normalweg), Gehäuse öffnen, Typenschild/Verwechslung)
- abgeleitet: Wiki toh/aruba/ap-303h 'same platform' (Schritte (Normalweg), Anschluss, Adressen, Programm, Zugang, Datei)
- abgeleitet: Wiki-Bootlog AP11, Neanderfunk-Notiz (Schritte (Normalweg), Bedingung an die Herstellerfirmware)
- abgeleitet: gleiche Plattform (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Gluon-Alias, Wiki toh:aruba:ap-303h (Typenschild/Verwechslung)
- geprüft: HPE AP11D Installation Guide, Abb. 2/3 und Abschnitt Ethernet Ports, https://arubanetworking.hpe.com/techdocs/hardware/instantonaps/ap11d/Aruba_AP11D_Installation_Guide_EN.pdf (Anschluss)
- Geräteeintrag: OpenWrt c6e972c8772a628a1a2f2e5590d7c6f4acef9ab0
