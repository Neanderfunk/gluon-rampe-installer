# Zyxel WSM20 / Multy M1 (ramips-mt7621, 256 MB RAM, 128 MB NAND)
#
# Einspielen ueber die versteckte Upgrade-Seite der Stock-Web-UI. Das Geraet
# muss vorher in der Zyxel-Cloud registriert sein. Dann
# https://192.168.212.1/gui/#/main/debug/firmwareupgrade oeffnen und das rohe
# RAMpe-initramfs (out/gluon-rampe-<Datum>-zyxel-wsm20-initramfs-kernel.bin)
# hochladen. Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade
# hochladen. Laut Commit setzt das sysupgrade die Boot-Nummer auf die erste
# Partition, falls das initramfs in RAS2 landete.
# Quelle: OpenWrt 28df7f7ff251d8684caa60f07ed0ba0c4a8e71f4 [geprueft].
#
# Image: das rohe initramfs IST das Hersteller-Image: KERNEL_INITRAMFS :=
# kernel-bin | lzma | fit lzma ... | znet-header V1.00(ABZF.0)C0
# (mt7621.mk am Pin a1ea57bd050c172fdc2b851824ebd9782aafb055) [geprueft].
# Dateiname openwrt-ramips-mt7621-zyxel_wsm20-initramfs-kernel.bin; build.sh
# sammelt ihn schon ein, kein extra_images noetig.
# Groesse: Firmware-Slots je 0x2800000 = 40 MiB; OpenWrts "kernel" darin ist
# 8 MiB (KERNEL_SIZE 8192k gilt aber nur fuer das sysupgrade) [geprueft: DTS,
# mk]. OpenWrt-24.10.8-initramfs 7657036 Byte [geprueft]. Ob der Stock-U-Boot
# mehr als 8 MiB Kernel liest: offen; das RAMpe-initramfs nach dem Bau gegen
# 8 MiB pruefen. RAM 256 MB.
# Kompression: ramips-Default LZMA [geprueft].
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_target_config ramips-mt7621 TARGET_ROOTFS_INITRAMFS
