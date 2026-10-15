# ASUS RT-AX59U (mediatek-filogic, MT7986, 512 MB RAM, 128 MB SPI-NAND)
#
# TEILWEISE. Die RAMpe deckt nur den seriellen Weg ab: UART (Pinout auf der
# Platine), TFTP-Server 192.168.1.70/24, das rohe RAMpe-initramfs
# (out/images/gluon-rampe-<Datum>-asus-rt-ax59u-initramfs-kernel.bin) als rtax59u.bin
# ablegen, U-Boot mit Taste 4 anhalten, dann
#   setenv ipaddr 192.168.1.1; setenv serverip 192.168.1.70
#   tftpboot 0x46000000 rtax59u.bin; bootm 0x46000000
# Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade hochladen.
# Quelle: OpenWrt 782eb050082acac93c2f9b3eb22348234bc93e99 [geprueft].
#
# Web-UI-Weg: der Commit nennt nur ein fremdes "transit TRX" aus einem
# Google-Drive-Ordner [geprueft]. OpenWrt baut fuer die RT-AX59U kein
# initramfs.trx, weder am Pin a1ea57bd050c172fdc2b851824ebd9782aafb055 noch in
# main (53ec2d05a487e6011cfa096de9211d15197c501b, 10.10.2026) [geprueft].
# Ein RAMpe-TRX nach dem Muster der RT-AX52 waere nur ueber einen Eingriff in
# openwrt/target/linux/mediatek/image/filogic.mk zu bauen (siehe
# UEBERSICHT.md, ensure_openwrt_snippet); ob die Stock-UI es annimmt: offen.
#
# Gluon v2025.1.3 kennt das Geraet nicht; Neanderfunk traegt es per
# gluon-patches-hardware 8dbae18666543aa9b8b5e7faa1d267024d62071e ein
# (targets/targets-mediatek-filogic.patch). OpenWrt 24.10 hat das Profil
# asus_rt-ax59u schon [geprueft: filogic.mk am Pin], also reicht ensure_device.
# Nicht verwechseln mit asus_rt-ax59u-ubi (nur main, OpenWrt-U-Boot-Layout).
#
# Image: rohes initramfs openwrt-mediatek-filogic-asus_rt-ax59u-initramfs-kernel.bin
# (KERNEL_INITRAMFS aus Device/Default, FIT mit initrd); build.sh sammelt es
# schon ein. RAM 512 MB, beim TFTP-Weg keine Flash-Grenze [abgeleitet].
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_device mediatek-filogic asus-rt-ax59u asus_rt-ax59u
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
