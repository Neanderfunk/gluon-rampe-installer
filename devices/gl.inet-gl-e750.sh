# GL.iNet GL-E750 (ath79-nand, QCA9531, 128 MB RAM, NAND)
#
# Dauerhafte RAMpe statt OpenWrt-Zwischenschritt: Gluon baut fuer das Geraet
# kein factory.img (factory = false), der Weg ab Werk braucht aber eins.
# Weg: U-Boot-Web (GL.iNet-Debrick-Anleitung); mit GL-Firmware 3.100 nur so,
# weil deren sysupgrade den groesseren Kernel zerstoert [geprueft: Inventar].
# Die U-Boot-Web-Oberflaeche nimmt das NAND-factory.img (Kernel + UBI)
# [abgeleitet: Inventar]. Danach startet die RAMpe aus dem Flash; ohne
# Konfiguration geht Gluon beim ersten Start in den Config-Mode (90_setup_mode),
# dort die RAMpe-Upload-Seite, Community-sysupgrade hochladen [abgeleitet].
# Image: IMAGE/factory.img := append-kernel | pad-to KERNEL_SIZE | append-ubi
# (ath79/image/nand.mk, Device/glinet_gl-e750, OpenWrt am Gluon-v2025.1.3-Pin
# 5204715d14207efa956553d9d7079f6fa1aaea40) [geprueft], also openwrt-ath79-nand-glinet_gl-e750-squashfs-factory.img.
# Gluon v2025.1.3: broken = true ("the display is not showing status and there
# are no LEDs"), factory = false [geprueft]; fuer die RAMpe ohne Belang.
# Dass eine RAMpe aus dem Flash im Config-Mode startet, ist am D-Link M60 A1
# belegt (13.10.2026, dessen -squashfs-recovery liegt ebenfalls im Flash)
# [geprueft, adorfer]. Dieses Format selbst ist ungetestet.
ensure_device_option ath79-nand gl.inet-gl-e750 broken false
ensure_extra_image ath79-nand gl.inet-gl-e750 -squashfs-factory -factory .img
