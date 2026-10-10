# Xiaomi Mi Router AX3000T (mediatek-filogic, MT7981B, 256 MB RAM, 128 MB NAND)
# Stock-Layout (Gluon: xiaomi-mi-router-ax3000t, OpenWrt-Profil
# xiaomi_mi-router-ax3000t); NICHT die -openwrt-u-boot-layout-Variante.
#
# TEILWEISE: der Exploit bleibt. Weg laut OpenWrt
# 7dbcc1215a56cc1da68c81bf92d7efa174c5e051 [geprueft]: Stock 1.0.47, SSH per
# Befehlseinschleusung in /api/misystem/arn_switch (curl mit stok, Commit
# Schritt 1), Backup per nanddump (BL2, Nvram, Bdata, Factory, FIP, ubi, KF),
# cat /proc/cmdline. Dann statt des OpenWrt-Images das RAMpe-Image
# ...-initramfs-factory.ubi nach /tmp und
#   firmware=0:  ubiformat /dev/mtd9 -y -f /tmp/<rampe>.ubi
#                nvram set flag_boot_rootfs=1; nvram set flag_last_success=1
#   firmware=1:  ubiformat /dev/mtd8 -y -f /tmp/<rampe>.ubi
#                nvram set flag_boot_rootfs=0; nvram set flag_last_success=0
#   beide:       nvram set boot_wait=on; nvram set uart_en=1
#                nvram set flag_boot_success=1; nvram set flag_try_sys1_failed=0
#                nvram set flag_try_sys2_failed=0; nvram commit; reboot
# Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade (Stock-
# Layout) hochladen.
#
# Image: ARTIFACT initramfs-factory.ubi (filogic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055): append-image-stage
# initramfs-kernel.bin | ubinize-kernel, nur mit
# CONFIG_TARGET_ROOTFS_INITRAMFS und ausserhalb des ImageBuilders [geprueft].
# Dateiname openwrt-mediatek-filogic-xiaomi_mi-router-ax3000t-initramfs-factory.ubi;
# extra_images {'-initramfs-factory', '-initramfs-factory', '.ubi'} trifft ihn
# [geprueft: Code; im Bau offen].
# Groesse: Ziel-Partition je 0x2200000 = 34 MiB (ubi_kernel im DTS)
# [geprueft]; OpenWrt-24.10.8-Datei 9830400 Byte [geprueft]. Passt
# [abgeleitet]. RAM 256 MB.
# Vorbereitungsskript: keins (Exploit und ubiformat laufen in der Stock-FW).
# Ungetestet.
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
ensure_extra_image mediatek-filogic xiaomi-mi-router-ax3000t -initramfs-factory -initramfs-factory .ubi
