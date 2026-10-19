{#-
Vorlage sonderweg-mercusys-mr90x-v1 (Mercusys MR90X v1, HW 1.0 und 1.2).
Auftrag adorfer über Supernode 2026-10. ENTWURF Content, Formulierungen erst
nach der Validierung durch Buildsystem festzurren.

Quelle: OpenWrt-Wiki toh:mercusys:mr90x_v1, Abschnitt "Installation", Reiter
"Stock bootloader" (SSH Port 20001 mit Web-Passwort, telnetd über
/etc/hotplug.d/iface/65-iptv und den Schalter "IPTV/VLAN Enable", volles
busybox für ubiupdatevol, initramfs ins UBI-Volume "kernel", fw_setenv,
sysupgrade -n), dazu "Notes" (alte ssh-Algorithmen), "Debricking"/"Return to
stock" (Reset beim Einschalten etwa 10 s, Web-Recovery unter 192.168.1.1) und
"Serial" (R3 und R6 fehlen auf der Platine).
Sicherungen boot (mtd0) und tp_data (mtd5) sowie der Ordner /tp_data
(MT7986_EEPROM.bin, default-mac): Pflicht laut adorfer; Befehle aus dem Wiki,
Reiter "Installation U-Boot layout", Schritt 11. Partitionsliste laut Wiki:
2M(boot),1M(u-boot-env),50M(ubi0),50M(ubi1),8M(userconfig),4M(tp_data).
scp: Das Wiki schreibt "scp -p 20001", richtig ist -P (großes P).
Dateien (adorfer, über Buildsystem): busybox und initramfs als eine ZIP auf
unserem Server (other/dump), Prüfung wie beim AP11 "lässt sich ohne Fehler
auspacken"; Inhalt busybox-aarch64 (BusyBox 1.36.1 statisch, Arch Linux ARM
busybox-1.36.1-4), OpenWrt-initramfs 24.10.8 unverändert, SHA256SUMS,
QUELLEN.txt.
[abgeleitet, bei der Validierung prüfen]: "nimmt fremde Firmware weder über
die Oberfläche noch über den Notfall-Modus an" (Wiki nennt nur OEM-Firmware
für die Web-Recovery); sed-Befehl in Schritt 5 statt
Bearbeiten mit WinSCP; feste Adresse 192.168.1.2 für die Web-Recovery (Wiki
nennt keine); /etc beschreibbar (Wiki: Datei mit WinSCP bearbeiten).

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    zip_url              Download der Installationsdateien als ZIP von unserem
                         Server (adorfer: busybox und initramfs liegen bei uns)
    initramfs_datei      Name des OpenWrt-initramfs in der ZIP (Stock-Aufteilung,
                         nicht "-ubi-")

  optional
    zip_datei            Name der ZIP (leer = Dateiname aus zip_url)
    busybox_datei        Name des busybox in der ZIP (leer = busybox-aarch64)
    stock_ip             Adresse der Mercusys-Oberfläche (leer = 192.168.1.1)
    kernel_groesse       Größe des neuen UBI-Volumes (leer = 9MiB)
    rueckweg_url         Download-Seite der Mercusys-Firmware
    dauer                Zeitbedarf, z. B. "etwa eine Stunde"
    sicherheit, sicherheit_hinweis   siehe _status.md
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set ip = w.get("stock_ip") or "192.168.1.1" -%}
{%- set kg = w.get("kernel_groesse") or "9MiB" -%}
{%- set zd = w.get("zip_datei") or w.zip_url.rsplit("/", 1)[-1] -%}
{%- set bb = w.get("busybox_datei") or "busybox-aarch64" -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Der {{ modell }} nimmt fremde Firmware weder über seine Oberfläche noch über
einen einfachen Notfall-Modus an. Der Weg führt über eine Hintertür in der
Mercusys-Firmware auf die Kommandozeile, von dort kommt ein kleines OpenWrt
auf den Router und darüber die Freifunk-Firmware. Das ist etwas für Leute,
die mit SSH, scp und einer Shell umgehen können
([SSH und scp benutzen](grundlagen/ssh-scp.md)).
{%- if w.get("dauer") %} Rechne mit {{ w.dauer }}.{% endif %}

> **Erst sichern, dann ändern.** Bevor du irgendetwas veränderst, sicherst
> du in Schritt 4 die Bereiche `boot` und `tp_data` und den Ordner
> `/tp_data`. Darin stecken unter anderem die MAC-Adresse und die
> Funk-Kalibrierung des Geräts. Ohne diese Sicherungen gibt es keinen
> Rückweg, wenn etwas schiefgeht. Die serielle Konsole hilft dann auch
> nicht ohne Weiteres: Sie ist erst nutzbar, wenn man auf der Platine
> fehlende Widerstände bestückt oder Lötbrücken setzt.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- auf dem Rechner `ssh`, `scp` und `telnet` (unter Windows ist `telnet`
  ein optionales Feature, alternativ PuTTY)
- das Passwort der Mercusys-Oberfläche (beim ersten Aufruf legst du es fest)
- die Installationsdateien als ZIP: [{{ zd }}]({{ w.zip_url }}). Pack sie
  aus. Kommt dabei keine Fehlermeldung, sind die Dateien heil. Darin liegen
  ein vollständiges busybox (`{{ bb }}`; das busybox der
  Mercusys-Firmware kann einen nötigen Befehl nicht), OpenWrt als
  Zwischenstufe (`{{ w.initramfs_datei }}`), Prüfsummen und Hinweise zu den
  Quelltexten.
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

### Teil 1: Zugang und Sicherungen

1. **Verbinden.** Steck das Kabel vom Rechner in die Buchse **LAN1**. Der
   Rechner bleibt auf "automatisch". Öffne `http://{{ ip }}` und leg das
   Passwort für die Oberfläche fest, falls noch keins gesetzt ist.

2. **Per SSH anmelden.** Benutzer `root`, Port `20001`, Passwort wie in
   der Oberfläche:

   ```
   ssh -p 20001 -o HostKeyAlgorithms=+ssh-rsa root@{{ ip }}
   ```

   Es erscheint eine Shell mit `root@Akronite`.

3. **Startbereich prüfen.**

   ```
   fw_printenv | grep tp_boot_idx
   ```

   Steht dort `tp_boot_idx=1`, spiel zuerst über die Oberfläche die
   Mercusys-Firmware noch einmal ein und fang bei Schritt 2 wieder an.
   Sonst weiter.

4. **Sichern.** Noch in der SSH-Shell:

   ```
   cat /dev/mtd0 > /tmp/boot.bin
   cat /dev/mtd5 > /tmp/tp_data.bin
   chmod 666 /tp_data/MT7986_EEPROM.bin /tp_data/default-mac
   ```

   Dann auf deinem Rechner, in einem zweiten Terminal:

   ```
   mkdir mr90x-sicherung
   scp -O -P 20001 -o HostKeyAlgorithms=+ssh-rsa root@{{ ip }}:/tmp/boot.bin mr90x-sicherung/
   scp -O -P 20001 -o HostKeyAlgorithms=+ssh-rsa root@{{ ip }}:/tmp/tp_data.bin mr90x-sicherung/
   scp -O -P 20001 -o HostKeyAlgorithms=+ssh-rsa -r root@{{ ip }}:/tp_data mr90x-sicherung/
   ```

   scp fragt jedes Mal nach dem Passwort.

   **Prüfen:** `boot.bin` ist 2 MiB groß (2.097.152 Bytes), `tp_data.bin`
   4 MiB (4.194.304 Bytes), und im Ordner `tp_data` liegen
   `MT7986_EEPROM.bin` und `default-mac`. Leg die Sicherung an einen
   sicheren Ort. Ohne sie nicht weitermachen.

### Teil 2: Telnet über die IPTV-Einstellung

5. **Telnet vorbereiten.** Die Datei `/etc/hotplug.d/iface/65-iptv`
   bekommt direkt nach der ersten Zeile (`#!/bin/sh`) die Zeile
   `telnetd -l /bin/login.sh`. In der SSH-Shell:

   ```
   sed -i '1a telnetd -l /bin/login.sh' /etc/hotplug.d/iface/65-iptv
   head -n 3 /etc/hotplug.d/iface/65-iptv
   ```

   Die Ausgabe zeigt oben `#!/bin/sh`, darunter die neue Zeile. Wer lieber
   mit WinSCP arbeitet, kann die Datei auch dort bearbeiten.

6. **Auslösen.** Schalte in der Mercusys-Oberfläche die Einstellung
   **"IPTV/VLAN Enable"** um und speichere. Prüf in der SSH-Shell, ob jetzt
   ein Telnet-Dienst läuft:

   ```
   netstat -ltunp | grep 23
   ```

7. **Per Telnet anmelden.** Auf deinem Rechner:

   ```
   telnet {{ ip }}
   ```

   Ohne Benutzer und Passwort erscheint `root@Akronite:/#`. Die weiteren
   Befehle tippst du in diese Telnet-Shell.

### Teil 3: OpenWrt als Zwischenstufe

8. **Dateien auf den Router.** Auf deinem Rechner, im ausgepackten Ordner:

   ```
   scp -O -P 20001 -o HostKeyAlgorithms=+ssh-rsa {{ bb }} {{ w.initramfs_datei }} root@{{ ip }}:/tmp/
   ```

   In der Telnet-Shell:

   ```
   cd /tmp
   chmod a+x {{ bb }}
   du -h {{ w.initramfs_datei }}
   ```

   Die Größe muss kleiner sein als {{ kg }}.

9. **OpenWrt schreiben.** Ab hier ist die Mercusys-Firmware weg. Der
   Notfall-Modus des Bootloaders bleibt aber erhalten (siehe "Zurück zur
   Mercusys-Firmware").

   ```
   ubirmvol /dev/ubi0 -N kernel
   ubimkvol /dev/ubi0 -n 1 -N kernel -s {{ kg }}
   ./{{ bb }} ubiupdatevol /dev/ubi0_1 /tmp/{{ w.initramfs_datei }}
   reboot
   ```

10. **OpenWrt-Einstellungen setzen.** Nach dem Neustart läuft OpenWrt unter
    `192.168.1.1`, der Rechner bleibt auf "automatisch". Melde dich an,
    jetzt auf dem normalen Port und ohne Passwort:

    ```
    ssh root@192.168.1.1
    ```

    Dann genau diese Befehle:

    ```
    fw_setenv baudrate 115200
    fw_setenv bootargs "ubi.mtd=ubi0 console=ttyS0,115200n1 loglevel=8 earlycon=uart8250,mmio32,0x11002000 init=/etc/preinit"
    fw_setenv fdtcontroladdr 5ffc0e70
    fw_setenv ipaddr 192.168.1.1
    fw_setenv loadaddr 0x46000000
    fw_setenv mtdids "spi-nand0=spi-nand0"
    fw_setenv mtdparts "spi-nand0:2M(boot),1M(u-boot-env),50M(ubi0),50M(ubi1),8M(userconfig),4M(tp_data)"
    fw_setenv netmask 255.255.255.0
    fw_setenv serverip 192.168.1.2
    fw_setenv stderr serial@11002000
    fw_setenv stdin serial@11002000
    fw_setenv stdout serial@11002000
    fw_setenv tp_boot_idx 0
    ```

### Teil 4: Freifunk-Firmware

11. **Freifunk-Firmware aufspielen.** Auf deinem Rechner:

    ```
    scp -O <sysupgrade-image> root@192.168.1.1:/tmp/sysupgrade.bin
    ```

    Dann auf dem Router:

    ```
    sysupgrade -n /tmp/sysupgrade.bin
    ```

    Der Router schreibt die Firmware und startet neu, einige Minuten.
    **Strom nicht ziehen.**

12. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je
    nach Community zuerst mit einer Einrichtungsseite unter
    `http://192.168.1.1` oder gleich im Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- Nach Schritt 4 liegen `boot.bin`, `tp_data.bin` und der Ordner `tp_data`
  in der richtigen Größe auf deinem Rechner.
- Nach Schritt 9 meldet sich unter `192.168.1.1` OpenWrt.
- Nach Schritt 11 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **ssh meldet "no matching host key type found".** Der Router kennt nur
  alte Verfahren. Die Option `-o HostKeyAlgorithms=+ssh-rsa` muss dabei
  sein. Manche Linux-Systeme lehnen zusätzlich SHA-1 ab; dann hilft der
  Hinweis im Abschnitt "Notes" des OpenWrt-Wikis.
- **scp meldet "sftp-server: not found" o. ä.** Das `-O` fehlt.
- **Nach dem Umschalten von "IPTV/VLAN Enable" läuft kein Telnet.** Prüf,
  ob die Zeile in `65-iptv` direkt unter `#!/bin/sh` steht, und schalte die
  Einstellung noch einmal um.
- **Nach Schritt 9 startet der Router nicht.** Über den Notfall-Modus
  zurück zur Mercusys-Firmware (unten) und von vorn.
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

## Zurück zur Mercusys-Firmware

Der Bootloader von Mercusys bleibt bei diesem Weg unangetastet, sein
Notfall-Modus also auch:

1. Rechner fest auf `192.168.1.2`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)), Kabel an LAN1.
2. Reset-Taste drücken, Strom einstecken, nach etwa 10 Sekunden loslassen.
3. Im Browser `http://192.168.1.1` öffnen und die Mercusys-Firmware
   hochladen{% if w.get("rueckweg_url") %} ([Download bei Mercusys]({{ w.rueckweg_url }})){% endif %}.

Stimmen danach MAC-Adresse oder Funk nicht, schreibst du `tp_data` aus
deiner Sicherung zurück. Wie das geht, beschreibt das OpenWrt-Wiki im
Abschnitt "Return to stock".

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
