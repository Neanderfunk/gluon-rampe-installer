## Vorher prüfen

GL-AR300M (mit zusätzlichem NAND-Speicher), GL-AR300M16 (nur 16 MB NOR) und
GL-AR300M-Lite (nur ein Netzwerkanschluss) brauchen je ihr eigenes Image.

Noch Ende 2024 wurden AR300M mit einem alten Bootloader verkauft, der neue
Images ablehnen kann. Laut OpenWrt lässt er sich über
`http://192.168.1.1/uboot.html` im Notfall-Modus aktualisieren.

Statt über den Notfall-Modus geht es laut OpenWrt auch aus der GL.iNet-Firmware
heraus per SSH mit `sysupgrade --force`.
