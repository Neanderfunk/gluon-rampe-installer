# Aruba AP-303H (ipq40xx-generic, IPQ4029, 512 MB RAM), dazu Alias
# aruba-instant-on-ap11d (ein Image fuer beide, kein eigenes Rezept)
#
# TEILWEISE. Weg laut OpenWrt c6e972c8772a628a1a2f2e5590d7c6f4acef9ab0
# [geprueft]: wie AP-303, aber TFTP nur ueber Port E0 (WAN), Konsole
# ttyMSM0, und nandboot_openwrt mit "set fdt_high 0x87000000":
#   setenv bootargs_openwrt "setenv bootargs console=ttyMSM0,9600n8"
#   setenv nandboot_openwrt "run bootargs_openwrt; ubi part aos1;
#     ubi read 0x85000000 kernel; set fdt_high 0x87000000;
#     bootm 0x85000000"
#   setenv ramboot_openwrt "run bootargs_openwrt;
#     setenv ipaddr 192.168.1.105; setenv serverip 192.168.1.75;
#     netget; set fdt_high 0x87000000; bootm"
#   setenv bootcmd "run nandboot_openwrt"
#   saveenv
#   run ramboot_openwrt
# Die RAMpe danach ueber E1-E3 (LAN) erreichen: Gluons Config-Mode liegt auf
# den LAN-Ports (gluon-setup-mode 320-setup-ifname) [geprueft]; auch der
# Commit sagt fuer OpenWrt "plug into E1-E3".
# Commit vor dem sysupgrade: ubidetach -p /dev/mtd16; ubiformat /dev/mtd16
# -> Vorbereitungsskript der RAMpe; Partition per Label "ubi" (aos1)
# [geprueft: DTS qcom-ipq4029-ap-303h.dts].
# Ob beim AP11D das apboot gesperrt ist wie beim AP11: offen.
#
# Image: rohes initramfs openwrt-ipq40xx-generic-aruba_ap-303h-initramfs-uImage.itb,
# als ipq40xx.ari umbenennen [geprueft: Commit, generic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055]. Configs, Kompression, Groesse
# wie aruba-ap-303.sh. RAM 512 MB [Inventar].
#
# Vorbereitungsskript (Vorschlag, overlay/lib/gluon-rampe/prepare/aruba_ap-303h.sh):
#   mtd=$(find_mtd_index ubi)
#   ubidetach -p /dev/mtd$mtd || true
#   ubiformat /dev/mtd$mtd -y
# Ungetestet.
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic aruba-ap-303h -initramfs-uImage -initramfs-uImage .itb
