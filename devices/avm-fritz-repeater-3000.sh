# AVM FRITZ!Repeater 3000 (ipq40xx-generic, IPQ4019 + QCA9984, 256 MB RAM, 128 MB NAND)
#
# TEILWEISE. Weg laut OpenWrt 148d29d47b1d555d0058dcc5dda450b74c4628ec
# [geprueft]: wie Repeater 1200, mit uboot-fritz3000.bin und TFTP-Datei
# FRITZ3000.bin:
#   ./eva_ramboot.py --offset 0x85000000 192.168.178.1 uboot-fritz3000.bin
#   (Rechner dann 192.168.1.70/24, TFTP FRITZ3000.bin = RAMpe-initramfs)
# Commit vor dem sysupgrade:
#   mtd write /path/to/uboot-fritz3000.bin uboot0
#   mtd write /path/to/uboot-fritz3000.bin uboot1
#   ubirmvol /dev/ubi0 --name=avm_filesys_0
#   ubirmvol /dev/ubi0 --name=avm_filesys_1
# -> Vorbereitungsskript, dann Community-sysupgrade.
#
# Gluon v2025.1.3 kennt das Geraet nicht. Neanderfunk traegt es mit
# broken = true ein ("third radio (QCA9984) untested") und packages =
# ATH10K_PACKAGES_IPQ40XX_QCA9984 (gluon-patches-hardware
# targets/targets-ipq40xx-generic.patch, 381b499) [geprueft]. OpenWrt 24.10
# hat das Profil avm_fritzrepeater-3000 [geprueft], also ensure_device;
# ohne broken, damit Gluon es baut. Die Paketliste wie bei Neanderfunk
# (ensure_device mit Optionen, Vorschlag lib.sh); die lokale Tabelle
# ATH10K_PACKAGES_IPQ40XX_QCA9984 steht oben in Gluons targets/ipq40xx-generic
# und ist beim Anhaengen ans Dateiende sichtbar [geprueft]. Den U-Boot nicht
# in "packages" des device() schreiben: Gluons merge() ersetzt die Liste
# (defaults/Optionen), Site-Pakete aus image-customization.lua kommen dagegen
# dazu (target_config_lib.lua: lib.target_packages + dev.options.packages +
# site_specific_packages) [geprueft]. Deshalb ensure_site_packages.
#
# U-Boot im RAMpe-Image: Paket u-boot-fritz3000 [geprueft: Makefile];
# Uebernahme ins initramfs [abgeleitet], im Bau pruefen.
# Image: rohes initramfs openwrt-ipq40xx-generic-avm_fritzrepeater-3000-initramfs-uImage.itb
# [geprueft: generic.mk am Pin a1ea57bd050c172fdc2b851824ebd9782aafb055];
# als extra_images. Target-Configs: TARGET_ROOTFS_INITRAMFS. RAM 256 MB.
#
# Vorbereitungsskript (Vorschlag, overlay/lib/gluon-rampe/prepare/avm_fritzrepeater-3000.sh):
#   ub=/uboot-fritz3000.bin
#   [ -s "$ub" ] || exit 1
#   mtd write "$ub" uboot0
#   mtd write "$ub" uboot1
#   ubirmvol /dev/ubi0 --name=avm_filesys_0
#   ubirmvol /dev/ubi0 --name=avm_filesys_1
# Ungetestet. Braucht ensure_device mit Optionen und ensure_site_packages
# (Vorschlag lib.sh/build.sh).
ensure_device ipq40xx-generic avm-fritz-repeater-3000 avm_fritzrepeater-3000 "packages = ATH10K_PACKAGES_IPQ40XX_QCA9984,"
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic avm-fritz-repeater-3000 -initramfs-uImage -initramfs-uImage .itb
ensure_site_packages avm-fritz-repeater-3000 u-boot-fritz3000
