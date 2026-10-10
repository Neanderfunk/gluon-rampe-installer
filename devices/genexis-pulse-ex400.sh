# Genexis / Inteno Pulse EX400 (ramips-mt7621, 256 MB RAM, 256 MB NAND)
#
# Einspielen ueber die Stock-Web-UI oder die U-Boot-Recovery: Reset beim
# Einschalten halten, bis die Update-LED gruen leuchtet, Webserver
# http://192.168.1.1 (Port 80), das RAMpe-Image ...-factory.bin hochladen.
# Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade hochladen.
# Quelle: OpenWrt dd0c2839a81bb3c5067be99b02ec5c0adff93ac6 ("With the vendor
# web UI, or from the U-Boot recovery UI, install the OpenWrt factory image")
# [geprueft].
#
# Image: IMAGE factory.bin (mt7621.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055, Device/genexis_pulse-ex400/common):
# append-image-stage initramfs-kernel.bin | inteno-bootfs |
# inteno-y3-header EX400 | append-md5sum-ascii-salted, nur mit
# CONFIG_TARGET_ROOTFS_INITRAMFS [geprueft]. Das Geraet setzt
# DEVICE_IMG_NAME = $(DEVICE_IMG_PREFIX)-$(2), also OHNE Dateisystem im Namen:
# openwrt-ramips-mt7621-genexis_pulse-ex400-factory.bin (darum hat Gluon dort
# sysupgrade = '-sysupgrade') [geprueft]. extra_images deshalb mit
# '-factory', nicht '-squashfs-factory'.
#
# Groesse, ACHTUNG: inteno-bootfs baut ein UBIFS mit MKUBIFS_OPTS
# --leb-size=124KiB --max-leb-cnt=96, also hoechstens ~11.6 MiB fuer
# Kernel+DTB [abgeleitet aus mt7621.mk]. OpenWrt-24.10.8-factory.bin hat
# 9270304 Byte [geprueft]. Ist das RAMpe-initramfs zu gross, scheitert
# mkfs.ubifs, das Image fehlt, und Gluons copy_output bricht ab
# [abgeleitet]. IMAGE_SIZE 117m betrifft nur das sysupgrade.
# Kompression: ramips-Default LZMA [geprueft], keine eigene Zeile.
# RAM 256 MB [Commit].
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_target_config ramips-mt7621 TARGET_ROOTFS_INITRAMFS
ensure_extra_image ramips-mt7621 genexis-pulse-ex400 -factory -factory .bin
