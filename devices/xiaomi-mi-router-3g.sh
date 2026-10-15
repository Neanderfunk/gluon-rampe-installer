# Xiaomi Mi Router 3G (ramips-mt7621, NAND)
#
# Dauerhafte RAMpe statt OpenWrt-Zwischenschritt: Der Weg ab Werk schreibt
# OpenWrt-kernel1.bin und rootfs0.bin in den Flash; Gluon baut beide nicht
# (factory = false) [geprueft: Inventar]. Mit diesem Rezept entstehen sie als
# RAMpe; danach Config-Mode der RAMpe, Community-sysupgrade hochladen
# [abgeleitet]. Wie man auf der Stock-Firmware an eine Shell kommt, steht
# nur im Inventar, nicht hier.
# Image: Device/xiaomi_nand_separate (ramips/image/mt7621.mk, Pin 5204715d14207efa956553d9d7079f6fa1aaea40):
# IMAGES += kernel1.bin rootfs0.bin, IMAGE/kernel1.bin := append-kernel,
# IMAGE/rootfs0.bin := append-ubi | check-size [geprueft].
# Config-Mode beim Start: Gluons normales Verhalten fuer ein unkonfiguriertes
# Geraet; die RAMpe hat keinen Wizard, der "configured" setzt, also nach jedem
# Neustart wieder [abgeleitet]. Der D-Link M60 belegt das NICHT (dessen
# recovery.bin enthaelt das initramfs, die RAMpe laeuft dort im RAM).
# Ungetestet.
ensure_extra_image ramips-mt7621 xiaomi-mi-router-3g -squashfs-kernel1 -kernel1 .bin
ensure_extra_image ramips-mt7621 xiaomi-mi-router-3g -squashfs-rootfs0 -rootfs0 .bin
