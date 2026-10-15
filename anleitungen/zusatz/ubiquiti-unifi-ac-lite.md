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

## Wenn etwas schiefgeht

- **Nach dem Neustart läuft wieder die Ubiquiti-Firmware.** Dann hat das
  Aufheben des Schreibschutzes nicht gegriffen, die Befehle melden das nicht.
  Setz das Gerät auf Werkseinstellungen zurück und mach alles noch einmal;
  im Forum hat genau das geholfen.

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
