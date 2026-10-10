# ASUS Lyra MAP-AC2200 (ipq40xx-generic, IPQ4019, 256 MB RAM)
#
# Einspielen per SSH in die Stock-Firmware (Zugang wie Web-UI): das
# RAMpe-initramfs nach /tmp kopieren, dann
#   mtd-write -d linux -i <rampe>-initramfs-uImage.itb
# Strom aus/an. Danach die RAMpe unter http://192.168.1.1 (LAN = Port neben
# der Strombuchse), Community-sysupgrade hochladen.
# Quelle: OpenWrt 9ad3967f140bd6d08796f1ec151b753186b3eb44 [geprueft].
# Der SSH-Schritt bleibt beim Nutzer.
#
# Image: rohes initramfs openwrt-ipq40xx-generic-asus_map-ac2200-initramfs-uImage.itb
# (Device/FitImageLzma) [geprueft: generic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]; als extra_images, weil build.sh
# nur *-initramfs-kernel.bin sucht.
# Target-Configs: TARGET_ROOTFS_INITRAMFS (Gluon: aus) [geprueft];
# Kompression wie aruba-ap-303.sh (keine eigene Zeile).
# Groesse: kein IMAGE_SIZE fuer das Geraet; OpenWrt-24.10.8-initramfs
# 8677256 Byte [geprueft]. Wie gross "linux" fuer mtd-write sein darf: offen
# (die verwandten RT-AC42U/RT-AC58U haben IMAGE_SIZE 20439364 [geprueft],
# fuer die Lyra steht nichts im mk). RAM 256 MB.
# Vorbereitungsskript: keins noetig (sysupgrade -T hat fuer asus,map-ac2200
# keine Sonderpruefung, platform.sh nand_do_upgrade mit CI_KERNPART=linux
# [geprueft]).
# Ungetestet.
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic asus-lyra-map-ac2200 -initramfs-uImage -initramfs-uImage .itb
