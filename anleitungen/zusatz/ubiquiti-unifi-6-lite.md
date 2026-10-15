## Vorher prüfen

- Nur der **U6 Lite**. U6 IW, U6 Mesh, U6 Extender und die frühe U6 LR-EA
  sind technisch verwandt, brauchen aber eigene Images.
- Ab Ubiquiti-Firmware **6.5** muss das Gerät laut OpenWrt erst auf
  Version **6.0.14** zurück. Das geht per TFTP (siehe unten) oder auf dem
  Gerät mit `fwupdate.real -m <Datei>`.
