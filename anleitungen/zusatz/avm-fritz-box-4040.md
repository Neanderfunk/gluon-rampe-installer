## Vorher prüfen

- Die 4040 braucht ein eigenes Image: das mit **„-bootloader.bin“** am Ende.
  Es enthält einen neuen Bootloader und die Freifunk-Firmware zusammen. Das
  normale sysupgrade geht hier nicht. Nicht mit der
  [4020](avm-fritz-box-4020.md) verwechseln.
- Laut OpenWrt muss FRITZ!OS auf der 4040 vorher **einmal eingerichtet**
  worden sein (im Browser unter `http://192.168.178.1`: Sprache, Land, erste
  Anmeldung). Sonst nimmt der Bootloader keine FTP-Verbindung an.

Das Hochladen kann bei der 4040 erst bis zu 2 Minuten nach dem Start
beginnen; insgesamt dauert es 2 Minuten und mehr. Geduld haben.
