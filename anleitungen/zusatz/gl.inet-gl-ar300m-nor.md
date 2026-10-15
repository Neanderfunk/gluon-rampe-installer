## Vorher prüfen

GL-AR300M (mit zusätzlichem NAND-Speicher), GL-AR300M16 (nur 16 MB NOR) und
GL-AR300M-Lite (nur ein Netzwerkanschluss) brauchen je ihr eigenes Image.

Noch Ende 2024 wurden AR300M mit einem alten Bootloader verkauft, der neue
Images ablehnen kann. Laut OpenWrt lässt er sich über
`http://192.168.1.1/uboot.html` im Notfall-Modus aktualisieren.

Die Freifunk-Firmware kommt hier in den NOR-Speicher. Der Bootloader fällt nach
drei misslungenen Starts aus dem NAND-Speicher von selbst auf NOR zurück.
