# AVM FRITZ!Box 7430 (lantiq-xrx200, VRX220, 128 MB RAM, 128 MB NAND)
#
# Weg: EVA-Ramboot per scripts/flashing/eva_ramboot.py einige Sekunden nach
# dem Einschalten (Ersatzadresse 169.254.120.1), RAMpe im RAM, danach
# Community-sysupgrade ueber die Upload-Seite.
#   eva_ramboot.py 192.168.178.1 out/gluon-rampe-<Datum>-avm-fritz-box-7430-initramfs-kernel.bin
# Quelle: OpenWrt 6c85a449a988876fdfd4ce84d6aa5ffe4a2820c1 [geprueft]
# ("./scripts/flashing/eva_ramboot.py 192.168.178.1 <path to your initramfs
# image>", "If the script fails to reach the device, maybe try 169.254.120.1"):
#   Ramdisk-Kompression: im 7430-Commit nicht genannt; die Geschwister
#   7412/7362 SL verlangen lzma, hier deshalb ebenso [abgeleitet];
#   vor dem sysupgrade pruefen: fritz_tffs_nand -d /dev/mtd1 -n linux_fs_start,
#   bei 1 waehlt der Bootloader den falschen Partitionssatz.
# Image: ...-avm_fritz7430-initramfs-kernel.bin, EVA-Image (Device/AVM)
# [geprueft: lantiq/image/Makefile, vr9.mk].
# lzma: OpenWrt-Default fuer lantiq ist LZMA [geprueft: Config-images.in];
# ausdruecklich gesetzt, damit Gluon bei Abweichung abbricht.
# Werte: OpenWrt-initramfs 7753 KB, OpenWrt-sysupgrade 7971 KB [geprueft].
# Vorbereitung: overlay/lib/gluon-rampe/prepare.d/avm,fritz7430 (Vorschlag)
# liest linux_fs_start (mtd "nand-tffs" = mtd1 laut DTS [geprueft]; Werkzeug
# fritz_tffs_nand aus DEVICE_PACKAGES fritz-tffs-nand [geprueft: vr9.mk]) und
# startet bei 1 ohne zu flashen neu (zurueck in FRITZ!OS). Abhilfe laut
# Commit: FRITZ!OS-Update oder Recovery, oder per FTP auf 0 setzen.
# RAM: unkritisch [abgeleitet].
# Ungetestet.
ensure_target_config lantiq-xrx200 TARGET_ROOTFS_INITRAMFS
ensure_target_config lantiq-xrx200 TARGET_INITRAMFS_COMPRESSION_LZMA
