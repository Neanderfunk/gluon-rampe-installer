# Xiaomi Redmi Router AC2100 (ramips-mt7621, NAND)
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
# Dass eine RAMpe aus dem Flash im Config-Mode startet, ist am D-Link M60 A1
# belegt (13.10.2026, dessen -squashfs-recovery liegt ebenfalls im Flash)
# [geprueft, adorfer]. Dieses Format selbst ist ungetestet.
ensure_extra_image ramips-mt7621 xiaomi-redmi-router-ac2100 -squashfs-kernel1 -kernel1 .bin
ensure_extra_image ramips-mt7621 xiaomi-redmi-router-ac2100 -squashfs-rootfs0 -rootfs0 .bin
