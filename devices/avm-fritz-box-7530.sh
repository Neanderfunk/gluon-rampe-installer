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
# U-Boot im RAMpe-Image: Paket u-boot-fritz7530 bzw. u-boot-fritz7520
# (package/boot/uboot-fritz4040, BUILD_DEVICES avm_fritzbox-7530 fuer beide)
# installiert uboot-fritzXXXX.bin nach / (include/u-boot.mk,
# Package/u-boot/install/default: $(CP) ... $(1)/) [geprueft]. Dass Gluon
# das Paket per Geraete-packages ins initramfs nimmt: [abgeleitet], nach dem
# ersten Bau im cpio pruefen. build.sh kann die .bin fuer eva_ramboot.py
# zusaetzlich aus staging_dir/target-*/image/ nach out/images/ kopieren
# (Build/InstallDev legt sie dort ab) [abgeleitet].
#
# 7520 oder 7530? Das RAMpe-Image ist fuer beide dasselbe (ein Profil, ein
# board_name avm,fritzbox-7530). Das Vorbereitungsskript muss den richtigen
# U-Boot waehlen. Wie man 7520 und 7530 im laufenden System unterscheidet
# (z. B. fritz_tffs_nand -d <nand-tffs> -n HWRevision; fritz-tffs-nand ist
# DEVICE_PACKAGE), ist OFFEN; ohne sichere Erkennung darf das Skript keinen
# U-Boot schreiben, sondern muss abbrechen oder die Seite fragt nach.
#
# Image: rohes initramfs openwrt-ipq40xx-generic-avm_fritzbox-7530-initramfs-uImage.itb
# (Device/FitImageLzma) [geprueft: generic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]; als extra_images.
# Target-Configs: TARGET_ROOTFS_INITRAMFS [geprueft: Gluon aus].
# Groesse: TFTP in den RAM; OpenWrt-24.10.8-initramfs 8274508 Byte
# [geprueft]. uboot0/uboot1 je 0x400000 [geprueft: DTS]. RAM 256 MB.
#
# Vorbereitungsskript (Vorschlag, overlay/lib/gluon-rampe/prepare/avm_fritzbox-7530.sh):
#   ub=/uboot-fritz7530.bin            # bzw. /uboot-fritz7520.bin, Erkennung offen
#   [ -s "$ub" ] || exit 1
#   mtd write "$ub" uboot0
#   mtd write "$ub" uboot1
#   ubirmvol /dev/ubi0 --name=avm_filesys_0
#   ubirmvol /dev/ubi0 --name=avm_filesys_1
# sysupgrade -T hat fuer avm,fritzbox-7530 keine Sonderpruefung, der Lauf
# direkt vor sysupgrade reicht [geprueft: platform.sh].
# Ungetestet. Braucht ensure_site_packages (Vorschlag lib.sh/build.sh; additiv,
# anders als packages im device(), das Gluons merge() ersetzt [geprueft]).
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic avm-fritz-box-7530 -initramfs-uImage -initramfs-uImage .itb
ensure_site_packages avm-fritz-box-7530 u-boot-fritz7530 u-boot-fritz7520
