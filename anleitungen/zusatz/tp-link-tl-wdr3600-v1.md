## Vorher prüfen

- **Herstellerfirmware:** Version 3.14.3 (Build 151104) sperrt fremde
  Firmware. OpenWrt empfiehlt, vorher die TP-Link-Firmware 3.13.33 (130617)
  einzuspielen.
- **Dateiname:** Die Oberfläche ist hier besonders wählerisch: Sie meldet
  "firmware path too long" bei zu langen **und** zu kurzen Namen. Laut
  OpenWrt nimmt sie den Namen `wdr4300v1_en_3_14_3_up_boot(150518).bin` an.
  Ob es genau dieser sein muss, ist nicht geklärt.
- Der TL-WDR4300 sieht ähnlich aus, braucht aber ein eigenes Image.
