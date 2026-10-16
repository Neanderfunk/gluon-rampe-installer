---
gluon_name: ubiquiti-unifi-ac-lite
modell: Ubiquiti UniFi AC Lite
anzeige: Ubiquiti UniFi AC Lite
familie: ubiquiti-unifi-ssh
gluon_broken: false
sprache: de
level: L4
level_text: Netzwerkwerkzeuge
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, schreibschutz, ssh-scp, tftp-client]
daten_stand: 6c52e41c
vorlage_stand: 883c350d
---

# Ubiquiti UniFi AC Lite: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Den Ablauf haben wir vom UniFi Swiss Army Knife Ultra übernommen, der dieselbe Technik hat. Im Freifunk-Forum gibt es Erfolgsberichte für den AC Lite.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Ubiquiti%20UniFi%20AC%20Lite)

Die UniFi-Geräte von Ubiquiti haben keine Oberfläche, über die man fremde
Firmware hochladen kann. Man meldet sich stattdessen per **SSH** auf dem
Gerät an, kopiert die Freifunk-Firmware hinüber und schreibt sie mit ein paar
Befehlen selbst in den Speicher. Das ist nicht schwer, aber die Befehle
müssen genau stimmen. Wenn du noch nie mit SSH gearbeitet hast, lies vorher
[SSH und scp benutzen](grundlagen/ssh-scp.md).

## Was du brauchst

- das Gerät mit PoE-Injektor oder einem PoE-Switch
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Ubiquiti UniFi AC Lite, und zwar das
  **sysupgrade**-Image
- `ssh` und `scp`. Unter Linux, macOS und Windows 10/11 sind sie eingebaut
  ([SSH und scp benutzen](grundlagen/ssh-scp.md)).

Das Gerät muss im **Werkszustand** sein. Ist es in einem UniFi-Controller
angemeldet, gelten dort andere Zugangsdaten. Setz es dann vorher auf
Werkseinstellungen zurück oder entferne es im Controller.

## Vorher prüfen

AC Lite, AC LR und AC Mesh sind innen gleich, haben aber verschiedene
Antennen und brauchen je ihr **eigenes** Image. Lies den Aufkleber genau.

Für diese Geräte gibt es zwei Wege:

- **Weg a (Schritte oben):** Die Freifunk-Firmware wird mit `dd` direkt in
  den Speicher geschrieben. Das geht laut Freifunk-Forum auch mit aktueller
  Ubiquiti-Firmware (gezeigt mit 6.2.35, bestätigt Ende 2023). Das ist der
  Weg für die meisten Geräte.
- **Weg b (unten):** Erst zurück auf die alte Ubiquiti-Firmware 3.7.58, dann
  mit `mtd` schreiben. Das ging früher überall, scheitert aber laut Forum,
  sobald Ubiquiti-Firmware 4.3 oder neuer drauf ist: Ubiquiti sperrt das
  Zurückgehen.

Welche Version auf dem Gerät läuft, siehst du nach dem Anmelden in Schritt 5
an der Eingabezeile, zum Beispiel `UAP-AC-Lite-BZ.6.2.35#`.

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
   scp -O firmware.bin ubnt@192.168.1.20:/tmp/firmware.bin
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

   **Wichtig ist die Zeile mit `/proc/ubnthal/.uf`.** Sie hebt den
   Schreibschutz auf, mit dem Ubiquiti den Speicher sperrt. Ohne sie laufen
   die Schreibbefehle scheinbar fehlerfrei durch, aber es wird nichts
   geschrieben, und nach dem Neustart ist wieder die Ubiquiti-Firmware da.
   Mehr dazu unter [Schreibschutz im Flash](grundlagen/schreibschutz.md).

   ```
   cat /proc/mtd
   ```

   **Prüfen:** Weiter nur, wenn in der Ausgabe kernel0 bei mtd2, kernel1 bei mtd3 und bs bei mtd4 steht. Sonst hier aufhören.

   ```
   echo "5edfacbf" > /proc/ubnthal/.uf
   cat /sys/class/mtd/mtd2/flags
   cat /sys/class/mtd/mtd3/flags
   ```

   **Prüfen:** Weiter nur, wenn jetzt beide Male 0xc00 ausgegeben wird (vor dem Aufheben stand dort 0x800). Sonst hier aufhören.

   ```
   dd if=/tmp/firmware.bin of=/dev/mtdblock2
   dd if=/tmp/firmware.bin of=/dev/mtdblock3
   dd if=/dev/zero bs=1 count=1 of=/dev/mtd4
   reboot
   ```

   Ein Tippfehler an dieser Stelle kann das Gerät unbrauchbar machen. Meldet
   ein Befehl einen Fehler, mach **nicht** weiter, sondern melde dich bei
   deiner Community oder bei uns.

7. **Warten.** Das Gerät startet mit der Freifunk-Firmware neu. Der erste
   Start dauert etwa 2 Minuten.
   **Strom nicht ziehen.**

8. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md). Wie
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
- **Nach dem Neustart läuft wieder die Ubiquiti-Firmware.** Dann hat das
  Aufheben des Schreibschutzes nicht gegriffen, die Befehle melden das nicht.
  Setz das Gerät auf Werkseinstellungen zurück und mach alles noch einmal;
  im Forum hat genau das geholfen.
  Siehe [Schreibschutz im Flash](grundlagen/schreibschutz.md).

## Zurück zur Ubiquiti-Firmware

UniFi-Geräte haben einen TFTP-Notfall-Modus. Strom aus, Reset-Taste drücken
und halten, Strom ein. Halte sie gedrückt:
etwa 15 Sekunden, bis die LED weiß, blau und aus wechselt. Dann schickst du die Original-Firmware von Ubiquiti per
TFTP an `192.168.1.20`, wie unter
[TFTP-Client benutzen](grundlagen/tftp-client.md) beschrieben.

## Weg b: erst zurück auf Ubiquiti-Firmware 3.7.58

Nur, wenn auf dem Gerät noch eine Ubiquiti-Firmware **älter als 4.3** läuft.

1. Lade die alte Firmware direkt bei Ubiquiti herunter:
   [BZ.qca956x.v3.7.58.6385.170508.0957.bin](https://dl.ui.com/unifi/firmware/U7PG2/3.7.58.6385/BZ.qca956x.v3.7.58.6385.170508.0957.bin)
   (7.764.011 Bytes). Prüfsumme (SHA256):

   ```
   cfe2e639c430d1a849c2892effb84157e82ea9cb08d174547c1e001d4d4388a8
   ```

   Benenne sie in `fwupdate.bin` um.
2. Rechner, Kabel und feste Adresse wie in Schritt 2 und 3 oben. Dann:

   ```
   scp -O fwupdate.bin ubnt@192.168.1.20:/tmp/fwupdate.bin
   ssh ubnt@192.168.1.20
   ```

3. Auf dem Gerät:

   ```
   syswrapper.sh upgrade2 &
   ```

   Das Gerät schreibt die alte Firmware und startet neu; die
   SSH-Verbindung bricht dabei ab. Warte einige Minuten.
4. Kopier die Freifunk-Firmware wie in Schritt 4 oben nach
   `/tmp/firmware.bin` und melde dich wie in Schritt 5 an. Die Eingabezeile
   zeigt jetzt `BZ.v3.7.58#`.
5. Statt der Befehle aus Schritt 6:

   ```
   mtd write /tmp/firmware.bin kernel0
   mtd write /tmp/firmware.bin kernel1
   dd if=/dev/zero bs=1 count=1 of=/dev/mtd$(cat /proc/mtd|grep bs|cut -c4)
   reboot
   ```

   Danach startet die Freifunk-Firmware.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Forum: forum.freifunk.net/t/13863 #134 (adorfer, 2018, AC Lite und AC Mesh, Downgrade 3.7.58 per syswrapper.sh upgrade2, dann mtd) (Notweg)
- Forum: forum.freifunk.net/t/23422 #10 (blocktrron, 2022, AC Lite 6.2.35, dd-Weg, am 15.10.2026 am Beitrag gegengelesen), #24 (2023: "funktioniert noch auf aktueller Firmware"), #26 (nach Werksreset ok); #8/#3: Downgrade unter 4.3.31 scheitert (Weg ab Werk)
- abgeleitet (Dauer, Quelle (OpenWrt-Commit))
- abgeleitet: Ablauf aus UK-Ultra-Commit bf94e0a, gleiche ubnt_unifiac-Basis; Commit des Geräts ohne Anleitung (Weg ab Werk, Schritte (Normalweg))
- abgeleitet: Commits nennen 'factory defaults' (Schritte (Normalweg), Bedingung an die Herstellerfirmware)
- abgeleitet: Wiki (Bedingung an die Herstellerfirmware, Dauer)
- abgeleitet: Wiki toh/ubiquiti/unifiac (Schritte (Normalweg), Sichtbare Zeichen, Bedingung an die Herstellerfirmware, Rückweg zur Herstellerfirmware)
- abgeleitet: ar71xx-Commit 43a7a1a nennt AC Mesh = Hardwarekopie AC Lite, 128 MiB (RAM)
- geprüft: Commit bf94e0a (Schritte (Normalweg), Programm)
- geprüft: Commits (Datei)
- geprüft: Commits 07c1ddf, 4456dd4 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Commits, z. B. 4c8446b 'On factory defaults, user and password is ubnt at 192.168.1.20/24' (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Commits; IP-Beispiel .10 abgeleitet: Wiki toh/ubiquiti/unifiac (Schritte (Normalweg), Anschluss, Adressen, Programm, Zugang)
- geprüft: dl.ui.com/unifi/firmware/U7PG2/3.7.58.6385/BZ.qca956x.v3.7.58.6385.170508.0957.bin, HTTP 200, 7.764.011 Bytes, SHA256 cfe2e639c430d1a849c2892effb84157e82ea9cb08d174547c1e001d4d4388a8, abgerufen 15.10.2026 (Notweg)
- geprüft: forum.freifunk.net/t/23422 #10 zeigt für mtd2 und mtd3 die Flags 0x800 vor und 0xc00 nach dem Aufheben des Schreibschutzes (AC Lite 6.2.35) (Weg ab Werk)
- Geräteeintrag: cad843e1f57790a08dd4804011b6cd3a4796786b (ohne Anleitung); 56fddc2577baf194d1e9a7b37d454d12ff9fb469 (Umbenennung) [abgeleitet]
