# Xiaomi AX3600 (qualcommax-ipq807x, IPQ8071A, 512 MB RAM, 256 MB NAND)
#
# TEILWEISE: SSH-Zugang per Exploit bleibt (openwrt.org/inbox/toh/xiaomi/
# xiaomi_ax3600#obtain_ssh_access). Weg laut OpenWrt
# 8364f0816417bfe404f7bded4eaa4f4a60c6d006 [geprueft], mit dem RAMpe-Image
# ...-initramfs-factory.ubi statt des OpenWrt-Images:
#   nvram get flag_boot_rootfs        (0 = rootfs, 1 = rootfs_1)
#   cat /proc/mtd                     (mtd12/mtd13 bestaetigen)
#   bei 0: ubiformat /dev/mtd13 -y -f /tmp/<rampe>.ubi -s 2048 -O 2048 &&
#          nvram set flag_boot_rootfs=1 && nvram set flag_last_success=1 && nvram commit
#   sonst: ubiformat /dev/mtd12 -y -f /tmp/<rampe>.ubi -s 2048 -O 2048 &&
#          nvram set flag_boot_rootfs=0 && nvram set flag_last_success=0 && nvram commit
#   reboot
# Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade hochladen.
#
# Image: ARTIFACT initramfs-factory.ubi (ipq807x.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055, Device/xiaomi_ax3600):
# append-image-stage initramfs-uImage.itb | ubinize-kernel, nur mit
# CONFIG_TARGET_ROOTFS_INITRAMFS [geprueft]. Dateiname
# openwrt-qualcommax-ipq807x-xiaomi_ax3600-initramfs-factory.ubi; extra_images
# {'-initramfs-factory', '-initramfs-factory', '.ubi'} [geprueft: Code; Bau offen].
# Target-Configs: TARGET_ROOTFS_INITRAMFS (Gluon schaltet es fuer qualcommax
# nicht ein) [geprueft]; Kompression ZSTD ist Kconfig-Default [geprueft].
# Groesse: KERNEL_SIZE 36608k; OpenWrt-24.10.8-Datei 14417920 Byte [geprueft].
# Passt [abgeleitet]. RAM 512 MB.
# Vorbereitungsskript: keins (ubiformat laeuft in der Stock-FW).
# Ungetestet.
ensure_target_config qualcommax-ipq807x TARGET_ROOTFS_INITRAMFS
ensure_extra_image qualcommax-ipq807x xiaomi-ax3600 -initramfs-factory -initramfs-factory .ubi
