## Vorher prüfen

- **Herstellerfirmware:** Bei uns hat die TP-Link-Firmware 3.14.3
  (Build 150518) das factory-Image direkt angenommen. Laut OpenWrt sperrt
  der spätere Build 151104 fremde Firmware. Lehnt die Oberfläche das Image
  ab, spiel zuerst über TFTP die Version 150518 ein (unten, "Zurück zur
  TP-Link-Firmware").
- **Dateiname:** Nimm die Datei mit ihrem Originalnamen, umbenennen ist
  nicht nötig. Hast du sie mehrfach heruntergeladen und heißt sie jetzt
  `…(1).bin` oder `…[1].bin`, benenne sie zurück. Bei zu langem Namen meldet
  die Oberfläche "Please choose a file to upgrade!". Bei uns ging ein Name
  mit 54 Zeichen, einer mit 68 nicht.
- Der TL-WDR4300 sieht ähnlich aus, braucht aber ein eigenes Image.

## Wenn etwas schiefgeht

- **"Error code: 18005 … the version of the upgraded file was
  incorrect".** Das ist das sysupgrade-Image. Die TP-Link-Oberfläche
  braucht das factory-Image.
- **"Please choose a file to upgrade!"** Der Dateiname ist zu lang, siehe
  "Vorher prüfen".

## Zurück zur TP-Link-Firmware

Über den Notfall per TFTP (oben) nimmt der WDR3600 auch die Firmware von
TP-Link wieder an, allerdings nur ohne ihren Bootloader-Teil am Anfang. So
bereitest du die Datei vor:

1. Lade
   [TL-WDR3600_V1_150518.zip](https://static.tp-link.com/res/down/soft/TL-WDR3600_V1_150518.zip)
   bei TP-Link herunter und pack sie aus. Darin liegt
   `wdr3600v1_en_3_14_3_up_boot(150518).bin`.
2. Schneide die ersten 131.584 Bytes ab (257 mal 512) und speichere den
   Rest als `wdr3600v1_tp_recovery.bin`. Öffne dazu ein Terminal in dem
   Ordner:

   - Linux und macOS:

     ```
     dd if='wdr3600v1_en_3_14_3_up_boot(150518).bin' of=wdr3600v1_tp_recovery.bin bs=512 skip=257
     ```

   - Windows (PowerShell oder Eingabeaufforderung) mit **Python 3**
     (<https://www.python.org/downloads/>), geht auch unter Linux und macOS
     mit `python3` statt `py`:

     ```
     py -c "open('wdr3600v1_tp_recovery.bin','wb').write(open('wdr3600v1_en_3_14_3_up_boot(150518).bin','rb').read()[131584:])"
     ```

   **Prüfen:** `wdr3600v1_tp_recovery.bin` ist genau **8.060.928 Bytes**
   groß.
3. Weiter wie oben unter "Notfall: Firmware per TFTP". Danach ist die
   TP-Link-Oberfläche unter `http://192.168.0.1` erreichbar (Benutzer
   `admin`, Passwort `admin`).
