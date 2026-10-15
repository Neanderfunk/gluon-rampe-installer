{#-
Vorlage aruba-apboot (Aruba AP-303, AP-303H, AP-365 und die Instant-On-
Varianten AP11, AP11D, AP17): über die serielle Konsole im Bootloader APBoot
das OpenWrt-initramfs per TFTP starten, dann UBI neu formatieren und das
Gluon-sysupgrade per sysupgrade -n schreiben.

Weg: OpenWrt-Commits 102c8c5 (AP-303), c6e972c (AP-303H), 300b7fe (AP-365),
alle David Bauer; OpenWrt-Wiki toh:aruba:ap-303 (nandboot mit
"set fdt_high 0x87000000" wie beim AP-303H, "Invalid image format version"
harmlos, billige Adapter versagten), toh:aruba:ap-303h (wählerischer
Konsolenanschluss).

Abschnitt "älteren Bootloader aufspielen" (nur mit bootm_weg = "apboot",
gedacht für den AP11): Freifunk-Darmstadt-Wiki "Aruba AP11" (blocktrron, APBoot
2.6.2.9 getestet). Die Adressen sind dort 192.168.1.6/.66, hier an den
übrigen Weg angeglichen (192.168.1.105/.75). Die Datei (APBoot 2.5.0.2) stellt
Neanderfunk selbst bereit (Auftrag adorfer 15.10.2026); ihre SHA256 ist die,
die das Darmstädter Wiki für apboot-unlocked.bin nennt. Wunsch adorfer: im
Abschnitt zur Datei keinen Herstellernamen nennen.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    initramfs_datei      Dateiname des OpenWrt-initramfs (…-initramfs-uImage.itb)
    initramfs_url        Download-Adresse dieser Datei
    tty                  Konsole für OpenWrt: "ttyMSM1" (AP-303, AP-365) oder
                         "ttyMSM0" (AP-303H)
    mtd                  UBI-Partition für ubiformat: "/dev/mtd1" (AP-303, AP-365)
                         oder "/dev/mtd16" (AP-303H)

  optional
    initramfs_sha256     SHA256 des initramfs (aus sha256sums von OpenWrt)
    konsole              "uart" (Vorgabe: serielle Leitungen auf der
                         Micro-USB-Buchse "Console", eigenes Kabel), "usb"
                         (echter USB-Anschluss, AP-365) oder "unklar"
    tftp_buchse          Buchse für TFTP, z. B. "E0" (AP-303H); ohne Wert "die
                         Netzwerkbuchse"
    ssh_buchse           Buchse für scp/ssh, wenn sie anders ist, z. B. "E1, E2
                         oder E3" (AP-303H)
    bootm_weg            "apboot": Abschnitt "älteren Bootloader aufspielen"
                         zeigen (nur AP11)
    apboot_datei, apboot_url, apboot_sha256
                         bei bootm_weg nötig: der ältere Bootloader
                         (ap303-loader-2.5.0.2.bin, 983.040 Bytes,
                         SHA256 69e45b04…98a5)
    apboot_sha256_url    optional: Prüfsummendatei daneben (nur Dateiname
                         darin, für sha256sum -c)
    bootm_hinweis        ganze Sätze statt des Standardtexts, wenn "Unknown
                         command 'bootm'" kommt und es keinen bootm_weg gibt.
                         Der Standardtext verweist bewusst auf keine andere
                         Seite: Der Bootloader des AP11 passt nicht auf
                         AP11D (Plattform AP-303H) und AP17 (AP-365).
    sicherheit, sicherheit_hinweis   siehe _status.md
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set konsole = w.get("konsole") or "uart" -%}
{%- set tftp_buchse = w.get("tftp_buchse") -%}
{%- set ssh_buchse = w.get("ssh_buchse") -%}
{%- set apboot = w.get("bootm_weg") == "apboot" and w.get("apboot_url") -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

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
{%- if konsole == "usb" %}
- ein USB-Kabel für die USB-Buchse des Geräts. Sie ist beim {{ modell }}
  ein echter USB-Anschluss mit eingebautem Seriell-Wandler (CP2101). Ein
  Adapter ist also nicht nötig, unter Windows eventuell aber der
  CP210x-Treiber des Herstellers Silicon Labs.
{%- elif konsole == "unklar" %}
- einen Zugang zur seriellen Konsole. **Wir wissen nicht sicher**, ob die
  USB-Buchse des {{ modell }} ein echter USB-Anschluss ist (wie beim
  Aruba AP-365) oder nur die seriellen Leitungen trägt (wie beim AP-303).
  Steck kein normales USB-Kabel ein, solange das nicht geklärt ist, und
  schreib uns vorher. Wir finden es mit dir heraus.
{%- else %}
- einen **USB-Seriell-Adapter für 3,3 V** und ein **selbst gebautes
  Konsolenkabel** (siehe unten). Die Entwickler von OpenWrt berichten, dass
  billige Adapter hier nicht funktioniert haben.
{%- endif %}
- ein Terminalprogramm, einen TFTP-Server und `ssh`/`scp` (siehe die drei
  Seiten oben)
- diese Dateien:
  1. das OpenWrt-initramfs für dein Gerät:
     [{{ w.initramfs_datei }}]({{ w.initramfs_url }})
     {%- if w.get("initramfs_sha256") %}, SHA256
     `{{ w.initramfs_sha256 }}`{% endif %}.
     Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
     **`ipq40xx.ari`** um.
  2. die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.
{%- if apboot %}
  3. nur wenn dein Gerät den neueren Bootloader hat (siehe "Älteren
     Bootloader aufspielen" unten): den älteren Bootloader
     [{{ w.apboot_datei }}]({{ w.apboot_url }}), SHA256
     `{{ w.apboot_sha256 }}`. Leg ihn ebenfalls in den Ordner deines
     TFTP-Servers, unter genau diesem Namen.
{%- endif %}
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}
{%- if konsole == "uart" %}

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
{%- endif %}

## Schritte

### Teil 1: OpenWrt starten

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.75`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Access Point den TFTP-Server.

2. **TFTP-Server starten.** Starte den TFTP-Server mit dem Ordner, in dem
   `ipq40xx.ari` liegt ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an
   {%- if tftp_buchse %} die Buchse **{{ tftp_buchse }}** des Access Points.
   Nur über diese Buchse holt er sich die Datei.
   {%- else %} die Netzwerkbuchse des Access Points.{% endif %}
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

6. **Bootloader einstellen.** Gib diese Befehle ein, jede Zeile einzeln, und
   warte nach jeder Zeile auf `apboot>`:

   ```
   setenv bootargs_openwrt "setenv bootargs console={{ w.tty }},9600n8"
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

   **Kommt stattdessen `Unknown command 'bootm'`**, hat dein Gerät einen
   neueren Bootloader. Lies dann unter "Wenn etwas schiefgeht" weiter.

### Teil 2: Freifunk-Firmware aufspielen

8. **Anmelden.**
   {%- if ssh_buchse %} Steck das Netzwerkkabel jetzt in die Buchse
   **{{ ssh_buchse }}**. Unter OpenWrt ist {{ tftp_buchse or "die bisherige Buchse" }}
   der Internet-Anschluss und nicht erreichbar.{% endif %}
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
   `{{ w.mtd | replace("/dev/", "") }}:` und endet mit `"ubi"`. Sonst hier
   aufhören und uns schreiben.

10. **Speicher vorbereiten und Freifunk-Firmware schreiben.** Gib ein, Zeile
    für Zeile:

    ```
    ubidetach -p {{ w.mtd }}
    ubiformat {{ w.mtd }}
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
- **In Schritt 7 kommt die Datei nicht an** (der Bootloader wiederholt es
  oder bricht ab). Prüf die feste Adresse `192.168.1.75`, die Firewall
  deines Rechners und den Dateinamen `ipq40xx.ari`
  {%- if tftp_buchse %}, und ob das Kabel in {{ tftp_buchse }} steckt{% endif %}.
- **In Schritt 7 kommt `Unknown command 'bootm'`.**
  {%- if apboot %} Dann hat dein Gerät den neueren Bootloader (meist
  `APBoot 2.6.…` in der ersten Zeile). Weiter geht es nur mit dem Abschnitt
  "Älteren Bootloader aufspielen" weiter unten. **Lies dort zuerst die
  Warnung.**
  {%- elif w.get("bootm_hinweis") %} {{ w.get("bootm_hinweis") }}
  {%- else %} Dann hat dein Gerät vermutlich einen neueren Bootloader, aus
  dem der Hersteller Befehle entfernt hat, die OpenWrt braucht. Einen
  passenden älteren Bootloader für den {{ modell }} haben wir noch nicht.
  Bitte schreib uns, damit wir es klären können. **Schreib auf keinen Fall
  den Bootloader eines anderen Modells auf dein Gerät**, auch nicht den von
  der Seite eines ähnlichen Geräts: Es könnte danach nicht mehr starten.
  {%- endif %}
  Willst du an dieser Stelle aufhören, stell im Bootloader den Start der
  Aruba-Firmware wieder her, wie unter "Zurück zur Aruba-Firmware"
  beschrieben.
- **In Schritt 8 antwortet nichts.** Warte noch eine Minute, OpenWrt
  braucht etwas.
  {%- if ssh_buchse %} Prüf, ob das Kabel jetzt in {{ ssh_buchse }}
  steckt.{% endif %}
- **`ubiformat` meldet einen Fehler.** Nicht weitermachen, sondern die
  Ausgabe abschreiben (oder die Mitschrift des Terminals nehmen) und uns
  schreiben.
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}
{%- if apboot %}

## Älteren Bootloader aufspielen

> **Warnung:** Hier überschreibst du den Bootloader des Geräts. Geht dabei
> etwas schief, zum Beispiel eine falsche Datei, ein Tippfehler in den
> Adressen oder ein Stromausfall mittendrin, startet das Gerät nicht mehr.
> Dann hilft nur noch ein Programmiergerät für den Speicherchip. Mach das
> nur, wenn in Schritt 7 `Unknown command 'bootm'` kam, und nur bei dem
> Gerät, für das diese Anleitung gilt.

Neuere Geräte haben einen Bootloader, aus dem der Hersteller Befehle
entfernt hat (Freifunk Darmstadt hat den Weg mit `APBoot 2.6.2.9`
ausprobiert). Du ersetzt ihn durch die ältere Fassung `APBoot 2.5.0.2` aus
einem älteren Gerät desselben Typs. Überschrieben wird nur der Bereich des
Bootloaders, nicht der Rest des Speichers.

1. **Datei holen und prüfen.** Lade
   [{{ w.apboot_datei }}]({{ w.apboot_url }}) herunter
   (983.040 Bytes). Prüf die SHA256: unter Linux `sha256sum {{ w.apboot_datei }}`,
   unter macOS `shasum -a 256 {{ w.apboot_datei }}`, in der Windows-PowerShell
   `Get-FileHash {{ w.apboot_datei }}`. Das Ergebnis muss genau so lauten
   (Groß- und Kleinschreibung spielt keine Rolle):

   ```
   {{ w.apboot_sha256 }}
   ```

   {%- if w.get("apboot_sha256_url") %}

   Unter Linux geht es auch in einem Schritt: Lade die
   [Prüfsummendatei]({{ w.get("apboot_sha256_url") }}) in denselben Ordner
   und gib `sha256sum -c {{ w.get("apboot_sha256_url").split("/")[-1] }}`
   ein. Es muss `OK` erscheinen.
   {%- endif %}

   Stimmt die Summe nicht, hier aufhören. Leg die Datei in den Ordner des
   TFTP-Servers, neben `ipq40xx.ari`.

2. **Bootloader anhalten.** Strom ziehen und wieder anschließen, wie in
   Schritt 5 bis `apboot>`.

3. **Datei laden.** Gib ein (eine Zeile):

   ```
   setenv ipaddr 192.168.1.105; setenv serverip 192.168.1.75; netget 0x84000000 {{ w.apboot_datei }}
   ```

   **Prüfen:** Es erscheint `Bytes transferred = 983040 (f0000 hex)`. Die
   Meldung `Invalid image format version` danach ist auch hier normal.
   Steht dort eine andere Zahl oder ein Fehler, **hier aufhören** und auf
   keinen Fall Schritt 4 eingeben.

4. **Bootloader schreiben.** Gib ein (eine Zeile, genau so):

   ```
   sf probe; sf protect off; sf erase 0xf0000 0xf0000; sf write 0x84000000 0xf0000 0xf0000
   ```

   Strom nicht ziehen. Warte, bis wieder `apboot>` erscheint. Meldet der
   Bootloader `Unknown command 'sf'`, gib zuerst `diag` ein und dann die
   Zeile noch einmal.

5. **Neu starten.** Gib `reset` ein. **Prüfen:** Die erste Zeile lautet
   jetzt `APBoot 2.5.0.2`. Dann weiter mit Schritt 5 oben. Gib dabei auch
   die Befehle aus Schritt 6 noch einmal ein.
{%- endif %}

## Zurück zur Aruba-Firmware

Die Aruba-Firmware bleibt bei diesem Weg im Speicher. Um sie wieder zu
starten, halt den Bootloader an (Schritt 5) und gib ein:

```
setenv bootcmd "boot"
saveenv
```

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
