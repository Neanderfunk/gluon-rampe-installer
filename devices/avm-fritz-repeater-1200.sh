# AVM FRITZ!Repeater 1200 (ipq40xx-generic, IPQ4019, 256 MB RAM, 128 MB NAND)
#
# TEILWEISE. Weg laut OpenWrt 7f187229a8e9b7966248b1e024217e07a9fc3e50
# [geprueft]:
#  1. Rechner 192.168.178.10/24, Strom an, sobald Link:
#       ./eva_ramboot.py --offset 0x85000000 192.168.178.1 uboot-fritz1200.bin
#  2. Rechner auf 192.168.1.70/24, TFTP-Server mit dem RAMpe-initramfs als
#     FRITZ1200.bin.
#  3. RAMpe unter http://192.168.1.1. Commit vor dem sysupgrade:
#       mtd write /path/to/uboot-fritz1200.bin uboot0
#       mtd write /path/to/uboot-fritz1200.bin uboot1
#       ubirmvol /dev/ubi0 --name=avm_filesys_0
#       ubirmvol /dev/ubi0 --name=avm_filesys_1
#     -> Vorbereitungsskript, dann Community-sysupgrade.
#
# U-Boot im RAMpe-Image: Paket u-boot-fritz1200 (BUILD_DEVICES
# avm_fritzrepeater-1200) legt /uboot-fritz1200.bin ab [geprueft: Makefile,
# u-boot.mk]; Uebernahme ins initramfs [abgeleitet], im Bau pruefen.
#
# Image: rohes initramfs openwrt-ipq40xx-generic-avm_fritzrepeater-1200-initramfs-uImage.itb
# (Device/FitImageLzma) [geprueft: generic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]; als extra_images.
# Target-Configs: TARGET_ROOTFS_INITRAMFS [geprueft: Gluon aus].
# Groesse: TFTP in den RAM, Vorlage OpenWrt 24.10.8 nicht gemessen. RAM 256 MB.
#
# Vorbereitungsskript (Vorschlag, overlay/lib/gluon-rampe/prepare/avm_fritzrepeater-1200.sh):
#   ub=/uboot-fritz1200.bin
#   [ -s "$ub" ] || exit 1
#   mtd write "$ub" uboot0
#   mtd write "$ub" uboot1
#   ubirmvol /dev/ubi0 --name=avm_filesys_0
#   ubirmvol /dev/ubi0 --name=avm_filesys_1
# Ungetestet. Braucht ensure_site_packages (Vorschlag lib.sh/build.sh).
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic avm-fritz-repeater-1200 -initramfs-uImage -initramfs-uImage .itb
ensure_site_packages avm-fritz-repeater-1200 u-boot-fritz1200
