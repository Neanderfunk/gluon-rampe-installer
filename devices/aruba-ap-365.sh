# Aruba AP-365 (ipq40xx-generic, IPQ4029, 512 MB RAM), dazu Alias
# aruba-instant-on-ap17 (ein Image fuer beide, kein eigenes Rezept)
#
# TEILWEISE. Weg laut OpenWrt 300b7fe85a743ab0e039457a5a551819b49450da
# [geprueft]: wie AP-303 (ttyMSM1, TFTP 192.168.1.75, Geraet 192.168.1.105,
# ipq40xx.ari per netget). Konsole: USB-Konsole echt (CP2101), 9600 8N1
# [Inventar]. Commit vor dem sysupgrade:
#   "Make sure you use the mtd partition with the label "ubi" here!"
#   ubidetach -p /dev/mtd1; ubiformat /dev/mtd1
# -> Vorbereitungsskript der RAMpe, Partition per Label "ubi"
# [geprueft: Commit, DTS glenmorangie.dtsi].
# Ob beim AP17 das apboot gesperrt ist wie beim AP11: offen.
#
# Image: rohes initramfs openwrt-ipq40xx-generic-aruba_ap-365-initramfs-uImage.itb,
# als ipq40xx.ari umbenennen [geprueft: generic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]. Configs, Kompression wie
# aruba-ap-303.sh. RAM 512 MB [Inventar].
#
# Vorbereitungsskript (Vorschlag, overlay/lib/gluon-rampe/prepare/aruba_ap-365.sh):
#   mtd=$(find_mtd_index ubi)
#   ubidetach -p /dev/mtd$mtd || true
#   ubiformat /dev/mtd$mtd -y
# Ungetestet.
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic aruba-ap-365 -initramfs-uImage -initramfs-uImage .itb
