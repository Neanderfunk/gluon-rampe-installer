# ASUS RT-AX53U / RT-AX1800U (ramips-mt7621, 256 MB RAM, 128 MB NAND)
#
# Einspielen ueber die ASUS-Rescue (TFTP-Server im Geraet): alle Kabel ab,
# Rechner 192.168.1.10/24 an LAN1 (genau dieser Port), Router aus, Reset
# halten, einschalten, halten bis die Power-LED sehr langsam blinkt. Dann
# das rohe RAMpe-initramfs hochladen:
#   curl -T gluon-rampe-<Datum>-asus-rt-ax53u-initramfs-kernel.bin tftp://192.168.1.1
# oder Windows: ASUS Firmware Restoration. Danach die RAMpe unter
# http://192.168.1.1, Community-sysupgrade hochladen.
# Quelle: OpenWrt-Wiki toh/asus/rt-ax53u (10.10.2026) [abgeleitet: Wiki];
# der Commit 8c00fd9b4519bf0ef8fb3470a6df421b9f38c03c nennt nur das
# serielle U-Boot-Menue mit factory.bin [geprueft]. Laut Wiki laedt der
# Weg das initramfs "komplett in RAM" [abgeleitet].
#
# Gluon baut fuer das Geraet ein factory (nur fuer das serielle U-Boot-Menue
# brauchbar: append-kernel | pad-to KERNEL_SIZE | append-ubi). Die RAMpe
# braucht nur das initramfs.
# Image: rohes initramfs openwrt-ramips-mt7621-asus_rt-ax53u-initramfs-kernel.bin
# (Device/Default, ramips: KERNEL_DTB | uImage lzma) [geprueft: image/Makefile
# am Pin a1ea57bd050c172fdc2b851824ebd9782aafb055]; build.sh sammelt es schon ein.
# Kompression: Kconfig-Default fuer ramips ist TARGET_INITRAMFS_COMPRESSION_LZMA
# [geprueft: config/Config-images.in], keine eigene Zeile noetig.
# Groesse: OpenWrt-24.10.8-initramfs 7519444 Byte [geprueft]; Partition
# "firmware" 0x3200000 = 50 MiB [geprueft: DTS]. RAM 256 MB.
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_target_config ramips-mt7621 TARGET_ROOTFS_INITRAMFS
