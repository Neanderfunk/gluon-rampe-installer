# TP-Link Archer AX80 v1 (mediatek-filogic, MT7986), Gruppe B aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt 8b24289a5267e486abd9ccbf4b4ad82f14d545ae]:
#   UART: Boot mit Ctrl-C abbrechen, tftpboot initramfs-kernel.bin (Server
#   192.168.1.2), bootm.
# Danach im Browser http://192.168.1.1 das Community-sysupgrade hochladen,
# statt es per scp zu kopieren und sysupgrade -n aufzurufen.
# Datei: RAMpe-initramfs in initramfs-kernel.bin umbenennen.
# Vorbereitung: overlay/lib/gluon-rampe/prepare/tplink_archer-ax80-v1.sh setzt vor dem
# sysupgrade die vier fw_setenv-Werte aus dem Commit (bootargs, mtdids,
# mtdparts, tp_boot_idx 0). fw_setenv: uboot-envtools gehoert zu den
# DEFAULT_PACKAGES von filogic, Umgebung /dev/mtd1 0x0 0x20000
# [geprueft: target.mk, uboot-envtools files/mediatek_filogic].
#
# Image: OpenWrts Standard fuer filogic, KERNEL_INITRAMFS = kernel-bin | lzma |
# fit lzma <dtb> with-initrd | pad-to 64k, Datei ...-initramfs-kernel.bin
# [geprueft: target/linux/mediatek/image/Makefile und filogic.mk am
# OpenWrt-Stand von Gluon v2025.1.3, 5204715d14207efa956553d9d7079f6fa1aaea40].
# Gluon schaltet TARGET_ROOTFS_INITRAMFS fuer filogic schon ein; die Zeile
# unten steht zur Sicherheit.
# Gluon v2025.1.3 kennt das Geraet nicht; ensure_device traegt es wie
# gluon-patches-hardware (Zweig v2025.1.x-next, targets/filogic-mt7986.sh)
# ein. Das OpenWrt-Profil ist am Stand oben vorhanden [geprueft].
# RAM: unkritisch (MT7986, 512 MB und mehr) [abgeleitet].
# Ungetestet.
ensure_device mediatek-filogic tp-link-archer-ax80-v1 tplink_archer-ax80-v1
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
