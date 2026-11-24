# Xiaomi Redmi Router AX6000 (mediatek-filogic, MT7986A), Stock-Layout
# (Gluon: xiaomi-redmi-router-ax6000, OpenWrt-Profil
# xiaomi_redmi-router-ax6000-stock); NICHT die -openwrt-u-boot-layout-Variante.
# Gruppe C aus docs/PLAN-WEITERE-RAMPEN.md.
#
# TEILWEISE: der Exploit bleibt. Weg [geprueft: OpenWrt
# 18bea173a646518a64ca05ea26f87eab0540feb9, 641e4f2f0479997c71ff6c1f1b63fb9b5c67e687]:
#   Shell-Zugang zur Stock-Firmware laut OpenWrt-Wiki, nvram-Flags fuer den
#   Boot-Slot setzen, statt des OpenWrt-Images das RAMpe-Image
#   ...-initramfs-factory.ubi per ubiformat in die inaktive ubi-Partition
#   (welche aktiv ist, zeigt /proc/cmdline, firmware=0/1), Neustart.
# Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade (Stock-
# Layout) hochladen statt sysupgrade -n.
# Layout-Fragen (Stock gegen OpenWrt-U-Boot-Layout) sind am Geraet nicht
# belegt [offen].
#
# Image: ARTIFACT initramfs-factory.ubi (filogic.mk am OpenWrt-Stand von Gluon
# v2025.1.3, 5204715d14207efa956553d9d7079f6fa1aaea40): append-image-stage
# initramfs-kernel.bin | ubinize-kernel, nur mit
# CONFIG_TARGET_ROOTFS_INITRAMFS [geprueft]. Dateiname
# openwrt-mediatek-filogic-xiaomi_redmi-router-ax6000-stock-initramfs-factory.ubi;
# extra_images {'-initramfs-factory', '-initramfs-factory', '.ubi'} trifft ihn
# wie beim AX3000T [geprueft: dort im Bau 20261115].
# Gluon v2025.1.3 kennt das Geraet nicht; ensure_device traegt es wie
# gluon-patches-hardware (Zweig v2025.1.x-next, targets/filogic-mt7986.sh)
# ein.
# Groesse gegen die ubi-Partition: [offen]. RAM 512 MB.
# Vorbereitungsskript: keins (Exploit und ubiformat laufen in der Stock-FW).
# Ungetestet.
ensure_device mediatek-filogic xiaomi-redmi-router-ax6000 xiaomi_redmi-router-ax6000-stock
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
ensure_extra_image mediatek-filogic xiaomi-redmi-router-ax6000 -initramfs-factory -initramfs-factory .ubi
