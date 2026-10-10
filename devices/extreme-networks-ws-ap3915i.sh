# Extreme Networks WS-AP3915i (ipq40xx-generic, IPQ4029, 512 MB RAM)
#
# TEILWEISE: serielle Konsole bleibt (RJ45, Cisco-Kabel, 115200 8N1).
# Weg laut OpenWrt e16a0e7e8876df0a92ec4779fe766de1a943307a [geprueft]:
# Autoboot mit "s" abbrechen, Login admin / new2day, dann
#   setenv ramboot_openwrt "setenv serverip 192.168.1.66;
#     setenv ipaddr 192.168.1.1; tftpboot 0x86000000 openwrt-3915.bin;
#     bootm"
#   setenv boot_openwrt "sf probe;
#     sf read 0x88000000 0x280000 0xc00000; bootm 0x88000000"
#   setenv bootcmd "run boot_openwrt"
#   saveenv
#   run ramboot_openwrt
# TFTP-Server 192.168.1.66, Datei openwrt-3915.bin = RAMpe-initramfs
# umbenannt. Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade.
#
# Image: rohes initramfs openwrt-ipq40xx-generic-extreme-networks_ws-ap3915i-initramfs-uImage.itb
# (Device/FitImage, gzip) [geprueft: generic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]; als extra_images.
# Target-Configs: TARGET_ROOTFS_INITRAMFS [geprueft: Gluon aus].
# Groesse: TFTP nach 0x86000000 in den RAM, keine Flash-Grenze fuer die
# RAMpe; OpenWrt-24.10.8-initramfs 10160932 Byte [geprueft]. (IMAGE_SIZE
# 30080k und "sf read ... 0xc00000" = 12 MiB Kernel gelten fuer das
# Community-sysupgrade, nicht fuer die RAMpe [abgeleitet].) RAM 512 MB.
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic extreme-networks-ws-ap3915i -initramfs-uImage -initramfs-uImage .itb
