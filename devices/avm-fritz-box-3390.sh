# AVM FRITZ!Box 3390 (lantiq-xrx200, Lantiq-Teil; 128 MB RAM, 128 MB NAND)
#
# Weg: EVA-Ramboot. Kurz nach dem Einschalten laedt OpenWrts
# scripts/flashing/eva_ramboot.py das initramfs per FTP (adam2/adam2) in den
# RAM und startet es; hier die RAMpe. Danach Community-sysupgrade ueber die
# Upload-Seite (192.168.1.1) statt "sysupgrade per scp".
#   eva_ramboot.py 192.168.178.1 out/gluon-rampe-<Datum>-avm-fritz-box-3390-initramfs-kernel.bin
# Quelle: OpenWrt 73ec21cde2cde1fc27f66b08e8762cdc3c78b61a ("Use the
# eva_ramboot.py script to boot the initramfs image. Then, transfer the
# sysupgrade image to the device and run sysupgrade") [geprueft]. IP
# 192.168.178.1 aus den Geschwister-Commits 7412/7430 [abgeleitet].
# Gluon v2025.1.3 kennt das Geraet nicht; gluon-patches-hardware
# (devices/targets-lantiq-xrx200-devices.patch,
# ab19bf1b46d34315a92f61974dd37f8a9ede9604) traegt es mit factory = false ein
# [geprueft]. Das Rezept traegt es fuer diesen Bau ein.
# Image: openwrt-lantiq-xrx200-avm_fritz3390-initramfs-kernel.bin;
# Device/AVM: KERNEL = kernel-bin | append-dtb | lzma | eva-image,
# KERNEL_INITRAMFS = $(KERNEL) -> EVA-Image [geprueft: lantiq/image/Makefile].
# lzma-Bedingung: Die Geschwister-Commits verlangen lzma als
# Ramdisk-Kompression ("bootloader stalls when receiving uncompressed
# images"). OpenWrt-Default fuer lantiq ist ohnehin LZMA [geprueft:
# config/Config-images.in]; das Rezept setzt es trotzdem ausdruecklich, damit
# Gluon den Bau abbricht, falls es nicht greift (config() ist Pflicht).
# Fuer die 3390 selbst nennt der Commit die Bedingung nicht [geprueft].
# eva_ramboot.py: Image < 0x2000000 Byte (assert), legt es ans obere Ende der
# 128 MB und setzt memsize darunter; Linux sieht also 128 MB minus Image
# [geprueft: scripts/flashing/eva_ramboot.py]. Werte: OpenWrt-initramfs
# 7722 KB, OpenWrt-sysupgrade 7931 KB [geprueft: Download-Liste 24.10.8].
# RAM: unkritisch [abgeleitet].
# Nur der Lantiq-Teil (5 GHz); der AR9342-Teil (2.4 GHz) ist laut Commit
# nicht unterstuetzt [geprueft].
# Nach dem Flashen: nichts weiter laut Commit.
# Ungetestet.
ensure_device lantiq-xrx200 avm-fritz-box-3390 avm_fritz3390
ensure_target_config lantiq-xrx200 TARGET_ROOTFS_INITRAMFS
ensure_target_config lantiq-xrx200 TARGET_INITRAMFS_COMPRESSION_LZMA
