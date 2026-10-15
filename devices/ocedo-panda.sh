# OCEDO Panda (mpc85xx-p1020, P1020, 1 GB RAM, 256 MB NAND)
#
# Weg: TFTP-Server 192.168.100.8/24 mit
#   panda-uimage-factory  = RAMpe (out/images/gluon-rampe-<Datum>-ocedo-panda-initramfs-kernel.bin)
#   panda.fdt             = DTB (out/images/gluon-rampe-<datum>-ocedo-panda-fdt.bin)
# Reset-Taste beim Einschalten halten; der Bootloader holt beides und startet
# im RAM. Danach Community-sysupgrade ueber die Upload-Seite. Kein Oeffnen,
# keine Konsole.
# Quelle: OpenWrt b368373fab45f31963cd2bc1c6ab90e0a577e611 [geprueft].
# Image: ...-ocedo_panda-initramfs-kernel.bin, KERNEL = kernel-bin | gzip |
# fit gzip <dtb>, KERNEL_INITRAMFS erbt das -> FIT (schon im Commit von 2019
# so) [geprueft: mpc85xx/image/p1020.mk]. Rootfs-Kompression: mpc85xx-Default
# LZMA [geprueft: Config-images.in].
# DTB: IMAGES enthaelt fdt.bin (IMAGE/fdt.bin := append-dtb) ->
# openwrt-mpc85xx-p1020-ocedo_panda-squashfs-fdt.bin; Gluon sammelt es per
# extra_images als other/gluon-rampe-<datum>-ocedo-panda-fdt.bin ein
# [geprueft: Simulation target_lib.lua, Namensschema image.mk]. Es ist
# nicht RAMpe-spezifisch; das OpenWrt-Release-fdt.bin (11.2 KB) taete es auch.
# Vor dem sysupgrade (Commit Schritte 6 und 7), sonst passt das neue UBI nicht
# neben die Hersteller-Volumes und U-Boot startet weiter die
# Hersteller-Firmware:
#   ubirmvol /dev/ubi0 --name=kernel1
#   ubirmvol /dev/ubi0 --name=rootfs1
#   ubirmvol /dev/ubi0 --name=devicetree1
#   fw_setenv bootcmd_owrt "ubi part ubi && ubi read 0x1000000 kernel && bootm 0x1000000"
#   fw_setenv bootargs_owrt "setenv bootargs console=ttyS0,115200 ubi.mtd=3,2048"
#   fw_setenv bootcmd "run bootargs_owrt; run bootcmd_owrt"
# Vorbereitungsskript prepare.d/ocedo,panda (Vorschlag) fuehrt genau das aus.
# Voraussetzungen [geprueft]: ubi0 haengt per bootargs-override
# "ubi.mtd=3,2048" (panda.dts); ubi-utils kommen ueber base-files
# (+NAND_SUPPORT:ubi-utils); uboot-envtools ist mpc85xx-DEFAULT_PACKAGES,
# fw_env.config fuer ocedo,panda: /dev/mtd1 + /dev/mtd2.
# Danach: platform.sh -> nand_do_upgrade, legt Volume "kernel" im UBI an
# [geprueft: mpc85xx platform.sh]; passt zu "ubi read ... kernel".
# Kompatibilitaet: compat_version 1.1 (DSA) in Image und RAMpe [geprueft].
# RAM 1 GB: unkritisch. Werte: OpenWrt-initramfs 8946 KB [geprueft].
# Ungetestet.
ensure_target_config mpc85xx-p1020 TARGET_ROOTFS_INITRAMFS
ensure_extra_image mpc85xx-p1020 ocedo-panda -squashfs-fdt -fdt .bin
