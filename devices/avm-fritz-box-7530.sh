# AVM FRITZ!Box 7530 (ipq40xx-generic, IPQ4019, 256 MB RAM, 128 MB NAND), dazu
# Alias avm-fritz-box-7520 (Gluon: aliases = {'avm-fritz-box-7520'}; gleiches
# OpenWrt-Profil avm_fritzbox-7530, aber EIGENER U-Boot uboot-fritz7520.bin)
#
# TEILWEISE. Weg laut OpenWrt 95b0c07a618fe5fd93a26931152ced483bba143b
# [geprueft]:
#  1. Rechner 192.168.178.10/24 an einen LAN-Port, Strom an, sobald Link:
#       ./eva_ramboot.py --offset 0x85000000 192.168.178.1 uboot-fritz7530.bin
#     (eva_ramboot.py aus OpenWrt scripts/flashing; 7520: uboot-fritz7520.bin)
#  2. Rechner auf 192.168.1.70/24, TFTP-Server mit dem RAMpe-initramfs als
#     FRITZ7530.bin; der OpenWrt-U-Boot holt es und startet es (bis 2 min).
#  3. Danach die RAMpe unter http://192.168.1.1. Vor dem sysupgrade verlangt
#     der Commit:
#       mtd write /path/to/uboot-fritz7530.bin uboot0
#       mtd write /path/to/uboot-fritz7530.bin uboot1
#       ubirmvol /dev/ubi0 --name=avm_filesys_0
#       ubirmvol /dev/ubi0 --name=avm_filesys_1
#     -> Vorbereitungsskript der RAMpe (siehe unten), dann Community-sysupgrade.
# EVA-FTP und TFTP bleiben beim Nutzer.
# 7520: TFTP-Dateiname laut Inventar offen ([abgeleitet] FRITZ7530.bin, weil
# derselbe U-Boot-Quelltext; nicht belegt).
#
# U-Boot im RAMpe-Image: die u-boot-fritz*-Pakete lassen sich in Gluon nicht
# je Geraet waehlen ("symbol value 'm' invalid", Bau-Log 15.10.2026; die .bin
# fehlte im cpio [geprueft]). Deshalb package/gluon-rampe-uboot-fritz: legt
# uboot-fritz7530.bin und uboot-fritz7520.bin nach /lib/gluon-rampe/uboot/.
#
# 7520 oder 7530? Ein Image, ein board_name avm,fritzbox-7530. Das
# Vorbereitungsskript waehlt den U-Boot nach der HWRevision aus dem TFFS
# (236 = 7530, 247 = 7520, wie im Devicetree der beiden U-Boots
# [geprueft: chunkeey/FritzBox-4040-UBOOT @9d89013f]); sonst Abbruch ohne
# Schreiben.
#
# Image: rohes initramfs openwrt-ipq40xx-generic-avm_fritzbox-7530-initramfs-uImage.itb
# (Device/FitImageLzma) [geprueft: generic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]; als extra_images.
# Target-Configs: TARGET_ROOTFS_INITRAMFS [geprueft: Gluon aus].
# Groesse: TFTP in den RAM; OpenWrt-24.10.8-initramfs 8274508 Byte
# [geprueft]. uboot0/uboot1 je 0x400000 [geprueft: DTS]. RAM 256 MB.
#
# Vorbereitung vor dem sysupgrade: overlay/lib/gluon-rampe/prepare/
# avm_fritzbox-7530.sh (mtd write uboot0/uboot1, ubirmvol avm_filesys_0/1 wie
# im Commit), aufgerufen vom RAMpe-Controller upgrade.lua in Schritt 3.
# sysupgrade -T hat fuer avm,fritzbox-7530 keine Sonderpruefung, der Lauf
# direkt vor sysupgrade reicht [geprueft: platform.sh].
# Ungetestet am Geraet.
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic avm-fritz-box-7530 -initramfs-uImage -initramfs-uImage .itb
ensure_site_packages avm-fritz-box-7530 gluon-rampe-uboot-fritz7530
