# Aruba AP-303 (ipq40xx-generic, IPQ4029, 512 MB RAM), dazu Alias
# aruba-instant-on-ap11 (Gluon: aliases = {'aruba-instant-on-ap11'}; ein Image
# fuer beide, kein eigenes Rezept: build.sh kennt nur Geraete-, keine Aliasnamen)
#
# TEILWEISE. Weg laut OpenWrt 102c8c55f217606cdbdc9a449667e034676b3e75
# [geprueft]: TFTP-Server 192.168.1.75/24 am Ethernet-Port, RAMpe-initramfs
# als ipq40xx.ari ablegen; serielle Konsole (Micro-USB-Buchse als UART-Stecker,
# 9600 8N1), Autoboot mit Enter abbrechen, dann
#   setenv bootargs_openwrt "setenv bootargs console=ttyMSM1,9600n8"
#   setenv nandboot_openwrt "run bootargs_openwrt; ubi part aos1;
#     ubi read 0x85000000 kernel; bootm 0x85000000"
#   setenv ramboot_openwrt "run bootargs_openwrt;
#     setenv ipaddr 192.168.1.105; setenv serverip 192.168.1.75;
#     netget; set fdt_high 0x87000000; bootm"
#   setenv bootcmd "run nandboot_openwrt"
#   saveenv
#   run ramboot_openwrt
# Danach die RAMpe unter http://192.168.1.1. Vor dem sysupgrade verlangt der
# Commit
#   ubidetach -p /dev/mtd1
#   ubiformat /dev/mtd1
# Das uebernimmt das Vorbereitungsskript der RAMpe (siehe unten), dann
# Community-sysupgrade hochladen.
# Beim AP11 ist das apboot-Environment gesperrt (Neanderfunk-Notiz 2024, K5):
# vorher entsperrtes apboot per netget/sf write, bleibt seriell.
#
# ".ari" ist hier nur der Dateiname: der Commit nimmt "the OpenWrt initramfs
# image" und benennt es um [geprueft]. Kein Aruba-Header (anders als AP-32x).
# Image: rohes initramfs openwrt-ipq40xx-generic-aruba_ap-303-initramfs-uImage.itb
# (Device/FitImageLzma, KERNEL_SUFFIX -uImage.itb) [geprueft: generic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]. build.sh sucht nur
# *-initramfs-kernel.bin, deshalb als extra_images.
# Target-Configs: TARGET_ROOTFS_INITRAMFS (Gluon: aus) [geprueft].
# Kompression: Kconfig-Default NONE; ipq40xx hat kein separate_ramdisk, das
# initramfs steckt im Kernel und wird mit ihm per lzma im FIT gepackt
# [geprueft: Makefile/FEATURES]. Keine eigene Zeile noetig.
# Groesse: TFTP in den RAM; OpenWrt-24.10.8-initramfs 7467896 Byte [geprueft].
# RAM 512 MB [Inventar].
#
# Vorbereitungsskript (Vorschlag, overlay/lib/gluon-rampe/prepare/aruba_ap-303.sh):
#   mtd=$(find_mtd_index ubi)        # Label "ubi" = aos1 [geprueft: DTS glenmorangie.dtsi]
#   ubidetach -p /dev/mtd$mtd || true
#   ubiformat /dev/mtd$mtd -y
# (-y statt Rueckfrage [abgeleitet]; ubi-utils sind im Image, base-files
# +NAND_SUPPORT:ubi-utils, ipq40xx/generic FEATURES nand [geprueft]).
# Ungetestet.
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic aruba-ap-303 -initramfs-uImage -initramfs-uImage .itb
