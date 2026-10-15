---
gluon_name: ubiquiti-unifi-6-lite
modell: Ubiquiti UniFi 6 Lite
anzeige: Ubiquiti UniFi 6 Lite
familie: ubiquiti-unifi-ssh
gluon_broken: false
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [feste-ip, ssh-scp, tftp-client]
daten_stand: ebc2777
vorlage_stand: 393f161
---

# Ubiquiti UniFi 6 Lite: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Ubiquiti%20UniFi%206%20Lite)

Die UniFi-Geräte von Ubiquiti haben keine Oberfläche, über die man fremde
Firmware hochladen kann. Man meldet sich stattdessen per **SSH** auf dem
Gerät an, kopiert die Freifunk-Firmware hinüber und schreibt sie mit ein paar
Befehlen selbst in den Speicher. Das ist nicht schwer, aber die Befehle
müssen genau stimmen. Wenn du noch nie mit SSH gearbeitet hast, lies vorher
[SSH und scp benutzen](grundlagen/ssh-scp.md).

## Was du brauchst

- das Gerät mit PoE-Injektor oder einem PoE-Switch
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Ubiquiti UniFi 6 Lite, und zwar das
  **sysupgrade**-Image
- `ssh` und `scp`. Unter Linux, macOS und Windows 10/11 sind sie eingebaut
  ([SSH und scp benutzen](grundlagen/ssh-scp.md)).

Das Gerät muss im **Werkszustand** sein. Ist es in einem UniFi-Controller
angemeldet, gelten dort andere Zugangsdaten. Setz es dann vorher auf
Werkseinstellungen zurück oder entferne es im Controller.

## Vorher prüfen

- Nur der **U6 Lite**. U6 IW, U6 Mesh, U6 Extender und die frühe U6 LR-EA
  sind technisch verwandt, brauchen aber eigene Images.
- Ab Ubiquiti-Firmware **6.5** muss das Gerät laut OpenWrt erst auf
  Version **6.0.14** zurück. Das geht per TFTP (siehe unten) oder auf dem
  Gerät mit `fwupdate.real -m <Datei>`.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter und
   benenne es in `firmware.bin` um. Das erspart Tippfehler in den Befehlen.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf die feste Adresse
   `192.168.1.2` mit der Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

3. **Verbinden.** Steck das Kabel vom Rechner an die Buchse **LAN** des
   PoE-Injektors (oder an den PoE-Switch, an dem das Gerät hängt) und warte,
   bis das Gerät gestartet ist. Das dauert etwa eine Minute.

4. **Firmware hinüberkopieren.** Öffne ein Terminal im Ordner mit der Datei
   und gib ein:

   ```
   scp -O firmware.bin ubnt@192.168.1.20:/tmp/openwrt.bin
   ```

   Das Passwort ist `ubnt`. Beim ersten Mal fragt `scp`, ob du dem Gerät
   vertraust: mit `yes` bestätigen.

5. **Anmelden.**

   ```
   ssh ubnt@192.168.1.20
   ```

   Passwort wieder `ubnt`. Du bist jetzt auf dem Gerät angemeldet.

6. **Firmware schreiben.** Gib diese Befehle **einzeln und genau so** ein,
   jeweils mit Enter. Am besten kopierst du sie Zeile für Zeile.

   ```
   fw_setenv devmode TRUE
   fw_setenv boot_openwrt "fdt addr \$(fdtcontroladdr); fdt rm /signature; bootubnt"
   fw_setenv bootcmd "run boot_openwrt"
   cat /proc/mtd
   ```

   **Prüfen:** Weiter nur, wenn in der Ausgabe bs bei mtd4, kernel0 bei mtd6 und kernel1 bei mtd7 steht. Sonst hier aufhören.

   ```
   dd if=/dev/zero bs=1 count=1 of=/dev/mtdblock4
   dd if=/tmp/openwrt.bin of=/dev/mtdblock6
   dd if=/tmp/openwrt.bin of=/dev/mtdblock7
   reboot
   ```

   Ein Tippfehler an dieser Stelle kann das Gerät unbrauchbar machen. Meldet
   ein Befehl einen Fehler, mach **nicht** weiter, sondern melde dich bei
   deiner Community oder bei uns.

7. **Warten.** Das Gerät startet mit der Freifunk-Firmware neu. Der erste
   Start dauert einige Minuten.
   **Strom nicht ziehen.**

8. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb. Wie
   es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- `scp` kopiert die Datei ohne Fehlermeldung.
- Keiner der Befehle in Schritt 6 meldet einen Fehler.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **`ssh` oder `scp` meldet "Connection refused" oder "Permission denied".**
  Das Gerät ist nicht im Werkszustand, oder es ist noch nicht fertig
  gestartet. Zurücksetzen und noch einmal.
- **`scp` meldet einen Fehler wie "subsystem request failed".** Das `-O` fehlt
  im Befehl.
- **"no matching host key type found".** Dein SSH ist neuer als das Gerät.
  Häng an `ssh` und `scp` noch `-o HostKeyAlgorithms=+ssh-rsa` an, siehe
  [SSH und scp benutzen](grundlagen/ssh-scp.md).
- **"REMOTE HOST IDENTIFICATION HAS CHANGED".** Du hast schon einmal ein
  anderes Gerät unter derselben Adresse benutzt. Siehe
  [SSH und scp benutzen](grundlagen/ssh-scp.md).

## Zurück zur Ubiquiti-Firmware

UniFi-Geräte haben einen TFTP-Notfall-Modus. Strom aus, Reset-Taste drücken
und halten, Strom ein. Halte sie gedrückt:
bis die LED ihr Muster
wechselt. Dann schickst du die Original-Firmware von Ubiquiti per
TFTP an `192.168.1.20`, wie unter
[TFTP-Client benutzen](grundlagen/tftp-client.md) beschrieben.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Commits nennen 'factory defaults' (Schritte (Normalweg), Bedingung an die Herstellerfirmware)
- abgeleitet: Wiki toh/ubiquiti/unifi_6_lite (Schritte (Normalweg), Bedingung an die Herstellerfirmware, Rückweg zur Herstellerfirmware)
- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit bf94e0a (Schritte (Normalweg), Programm)
- geprüft: Commit fb4d7a9 (Programm)
- geprüft: Commit fb4d7a9, FIT-Konfigurationen (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Commits (Datei)
- geprüft: Commits, z. B. 4c8446b 'On factory defaults, user and password is ubnt at 192.168.1.20/24' (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Commits; IP-Beispiel .10 abgeleitet: Wiki toh/ubiquiti/unifiac (Schritte (Normalweg), Anschluss, Adressen, Programm, Zugang)
- Geräteeintrag: fb4d7a9680117a00721936c98ce41eeb2dea95c9
