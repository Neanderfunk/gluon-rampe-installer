# Extreme Networks AP3935i/e (ipq806x-generic, IPQ8068, ~1 GB RAM, 512 MB NAND)
#
# TEILWEISE: serielle Konsole bleibt (RJ45 Cisco-Kabel oder 4-Pin-Leiste,
# 115200 8N1). Weg laut OpenWrt 3aef61060e3f51aa43fe494d5ff173e81dd43003
# [geprueft]: TFTP-Server an LAN1, Boot mit beliebiger Taste anhalten, Login
# admin / new2day, dann
#   set serverip 192.168.1.2
#   set ipaddr 192.168.1.101
#   set bootcmd 'ping 192.168.1.1; run boot_flash'
#   saveenv
#   tftpboot 0x42000000 <rampe>-initramfs-uImage
#   bootm 0x42000000
# In OpenWrt (und der RAMpe) ist LAN1 = LAN, LAN2 = WAN [Commit]; die
# RAMpe-Seite liegt auf LAN [geprueft: gluon-setup-mode 320-setup-ifname].
# Danach Community-sysupgrade hochladen (Gluon: '-squashfs-nand-sysupgrade').
#
# Image: rohes initramfs openwrt-ipq806x-generic-extreme_ap3935-initramfs-uImage
# (ohne Endung; Device/extreme_ap3935: KERNEL = kernel-bin | append-dtb |
# uImage none | append-uImage-fakehdr filesystem, KERNEL_SUFFIX -uImage,
# KERNEL_INITRAMFS = $(KERNEL)) [geprueft: ipq806x image/Makefile und
# generic.mk am Pin a1ea57bd050c172fdc2b851824ebd9782aafb055]. Als
# extra_images mit leerer Endung.
# Target-Configs: TARGET_ROOTFS_INITRAMFS [geprueft: Gluon aus]. Kompression:
# Kconfig-Default NONE, kein separate_ramdisk; das initramfs steckt im zImage
# [geprueft: Makefile/FEATURES].
# Groesse: TFTP in den RAM; OpenWrt-24.10.8-initramfs 7448539 Byte
# [geprueft]. KERNEL_SIZE 14400k gilt fuer das sysupgrade. Ladeadresse
# 0x42000000, KERNEL_LOADADDR 0x41408000 (uImage none, bootm verschiebt
# nach unten) [geprueft: mk]; ob ein groesseres initramfs dabei kollidiert:
# offen, mit OpenWrts eigenem initramfs funktioniert es laut Commit.
# RAM: memory reg 0x41400000 Laenge 0x3ec00000 (~1004 MiB) [geprueft: DTS].
# QCA9990: kein 802.11s (Gluon-Kommentar in targets/ipq806x-generic).
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_target_config ipq806x-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq806x-generic extreme-networks-ap3935 -initramfs-uImage -initramfs-uImage ""
