# GL.iNet GL-XE300 (ath79-nand, QCA9531, 128 MB RAM, NAND)
#
# Dauerhafte RAMpe statt OpenWrt-Zwischenschritt: Gluon baut kein factory.img
# (factory = false) [geprueft].
# Weg: U-Boot-Rescue, Reset und Power gleichzeitig halten, bis die LAN-LED
# 5x blinkt, http://192.168.1.1, factory-Image hochladen [geprueft: Inventar].
# Danach Config-Mode der RAMpe, Community-sysupgrade hochladen [abgeleitet].
# Image: IMAGE/factory.img := append-kernel | pad-to KERNEL_SIZE | append-ubi
# (ath79/image/nand.mk, Device/glinet_gl-xe300, Pin 5204715d14207efa956553d9d7079f6fa1aaea40) [geprueft].
# Config-Mode beim Start: Gluons normales Verhalten fuer ein unkonfiguriertes
# Geraet; die RAMpe hat keinen Wizard, der "configured" setzt, also nach jedem
# Neustart wieder [abgeleitet]. Der D-Link M60 belegt das NICHT (dessen
# recovery.bin enthaelt das initramfs, die RAMpe laeuft dort im RAM).
# Ungetestet.
ensure_extra_image ath79-nand gl.inet-gl-xe300 -squashfs-factory -factory .img
