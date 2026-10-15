# Cudy TR3000 v1 (128 MB Flash) (mediatek-filogic, MT7981B, 512 MB RAM)
#
# TEILWEISE: UART (interne Testpunkte, Gehaeuse auf), 115200 8N1. Router aus,
# RESET halten, einschalten, mindestens 5 s halten -> U-Boot-Shell. Rechner
# 192.168.1.88/24 mit TFTP-Server, rohes RAMpe-initramfs
# (out/images/gluon-rampe-<Datum>-cudy-tr3000-v1-initramfs-kernel.bin) bereitlegen, dann
#   setenv bootfile <dateiname>
#   tftpboot
#   bootm
# Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade hochladen
# (ohne Einstellungen, macht die RAMpe immer).
# Quelle: OpenWrt 63b8d98dd0d2f7797ea5b5f25978590982bbbb5d [geprueft].
# Eine Cudy-Zwischenfirmware fuer die 128-MB-Version fehlt (Inventar,
# Stand 08.10.2026). Ob Cudys TFTP-Recovery (recovery.bin von 192.168.1.88)
# ein fremdes initramfs nimmt: offen (Inventar, Befund 11).
#
# Image: rohes initramfs openwrt-mediatek-filogic-cudy_tr3000-v1-initramfs-kernel.bin
# (Device/Default: fit lzma ... with-initrd) [geprueft: filogic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]; build.sh sammelt es schon ein.
# TFTP in den RAM, keine Flash-Grenze; OpenWrt-24.10.8-Datei 8718636 Byte.
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
