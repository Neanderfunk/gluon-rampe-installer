---
thema: image-schreiben
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# Image auf einen Datenträger schreiben

Bei Raspberry Pi, NanoPi und x86-Rechnern gibt es keine Firmware, die man
hochlädt. Die Freifunk-Firmware wird stattdessen als fertiges Abbild
("Image") auf den Datenträger geschrieben, von dem das Gerät startet: eine
microSD-Karte, eine Festplatte, eine SSD oder einen USB-Stick.

## Worauf es ankommt

- Die Firmware kommt als `.img.gz`, also gepackt. Auf den Datenträger muss
  das **ausgepackte, rohe `.img`**.
- Es wird auf den **ganzen Datenträger** geschrieben, nicht in eine Partition
  und nicht als Datei in ein Dateisystem. Was vorher darauf war, ist danach
  weg.
- Das Image ist nur gut 100 MB groß. Der Rest des Datenträgers bleibt
  ungenutzt; jede Karte ab etwa 256 MB reicht.

Es gibt grafische Programme, die das erledigen, für Windows, macOS und Linux;
einige können `.img.gz` sogar direkt schreiben. Deren Bedienung erklären wir
hier nicht. Wichtig ist nur: Sie müssen das rohe Image auf den ganzen
Datenträger schreiben.

## Linux im Terminal (Referenz)

1. **Datenträger finden.** Vorher und nachher, mit eingesteckter Karte bzw.
   angeschlossenem Stick:

   ```sh
   lsblk
   ```

   Der neu aufgetauchte Eintrag ist es, zum Beispiel `sdb` (ganzer
   Datenträger) mit `sdb1` (Partition darauf). Hier heißt er im Folgenden
   `/dev/sdX`. **Doppelt prüfen:** Ein Tippfehler überschreibt die falsche
   Platte.

2. **Partitionen aushängen,** falls das System sie automatisch eingebunden
   hat:

   ```sh
   sudo umount /dev/sdX?*
   ```

3. **Image auspacken.**

   ```sh
   gunzip -k gluon-…img.gz
   ```

   Meldet `gunzip` "trailing garbage ignored", ist das in Ordnung: Hinter
   den gepackten Daten hängen bei manchen Images Zusatzangaben, das
   ausgepackte `.img` ist trotzdem vollständig.

4. **Schreiben.**

   ```sh
   sudo dd if=gluon-…img of=/dev/sdX bs=4M conv=fsync status=progress
   sync
   ```

   Das dauert Sekunden bis etwa eine Minute. Danach den Datenträger
   abziehen.

## macOS im Terminal

Wie unter Linux, nur heißt der Datenträger `/dev/diskN` (zu finden mit
`diskutil list`), ausgehängt wird er mit `diskutil unmountDisk /dev/diskN`,
und bei `dd` nimmt man `of=/dev/rdiskN bs=4m`.
