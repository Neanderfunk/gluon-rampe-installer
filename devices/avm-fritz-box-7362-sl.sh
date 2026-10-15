# AVM FRITZ!Box 7362 SL (lantiq-xrx200, VRX288, 128 MB RAM, 128 MB NAND)
#
# Weg: EVA-Ramboot per scripts/flashing/eva_ramboot.py beim Einschalten
# ("approx. 4 seconds on 7362SL"), RAMpe im RAM, danach Community-sysupgrade
# ueber die Upload-Seite.
#   eva_ramboot.py 192.168.178.1 out/images/gluon-rampe-<Datum>-avm-fritz-box-7362-sl-initramfs-kernel.bin
# Quelle: OpenWrt eae6cac6a30b95bef04d033ed8a303b7e35a078b [geprueft]:
#   "IMPORTANT: set lzma compression in ramdisk options, bootloader stalls
#    when receiving uncompressed images."
#   "First boot might take a bit longer if linux_fs_start was set to 1, in
#    that case the device will reboot twice ... set linux_fs_start to 0 and
#    reboot."
# Image: ...-avm_fritz7362sl-initramfs-kernel.bin, EVA-Image (Device/AVM)
# [geprueft: lantiq/image/Makefile, vr9.mk].
# lzma: OpenWrt-Default fuer lantiq ist LZMA [geprueft: Config-images.in];
# ausdruecklich gesetzt, damit Gluon bei Abweichung abbricht.
# eva_ramboot.py: Image < 32 MiB, liegt am oberen RAM-Ende [geprueft].
# Werte: OpenWrt-initramfs 7721 KB, OpenWrt-sysupgrade 7931 KB [geprueft].
# Nach dem Flashen: linux_fs_start-Fall siehe Commit; ob die RAMpe ihn
# vorher erkennen sollte (fritz_tffs liest nur, Paket fritz-tffs ist in
# DEVICE_PACKAGES [geprueft: vr9.mk]), ist offen. Kein Vorbereitungsskript.
# Ungetestet.
ensure_target_config lantiq-xrx200 TARGET_ROOTFS_INITRAMFS
ensure_target_config lantiq-xrx200 TARGET_INITRAMFS_COMPRESSION_LZMA
