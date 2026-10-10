# TP-Link EAP620 HD v1 (qualcommax-ipq807x, IPQ8072A, 1 GB RAM, 128 MB NAND)
#
# TEILWEISE, und NUR MIT BACKPORT. Weg laut OpenWrt
# 4b6e7da0f7499acb69feaacca79e0ee826c0b8db (Commit-Text im Neanderfunk-
# Backport gluon-patches-hardware v2025.1.x ab19bf1b46d34315a92f61974dd37f8a9ede9604,
# devices/tplink-eap620-hd-v1/0001-...patch) [geprueft]: JP1 bestuecken, R58
# und R62 bruecken, 3.3-V-UART 115200 8N1, U-Boot mit Ctrl+B anhalten, dann
#   setenv serverip <TFTP-Server>; setenv ipaddr <AP>
#   tftpboot 0x44000000 <rampe>-initramfs-uImage.itb
#   bootm
# Danach die RAMpe unter http://192.168.1.1 (einziger Port), Community-
# sysupgrade hochladen.
# Der serielle Teil bleibt. Den Weg ohne UART (OpenWrt-25.12 web-ui-factory.bin,
# 8a15a75e9414bbb839ac457701b041454e89bbc4) deckt die RAMpe nicht ab: das ist
# ein squashfs-Flash-Image (tplink-image-2022, fehlt in 24.10), kein
# initramfs [abgeleitet, laut Backport-README].
#
# Backport: OpenWrt 24.10 kennt das Profil tplink_eap620hd-v1 nicht. Die
# RAMpe muss vor "make update" den Patch aus gluon-patches-hardware unter
# patches/openwrt ablegen (dort devices/tplink-eap620-hd-v1/openwrt.sh,
# Praefix 5500-hw-tplink-eap620-hd-v1). Dafuer ist build.sh zu erweitern
# (Rezepte vor make update, ensure_openwrt_backport, siehe UEBERSICHT.md).
# Den Gluon-Eintrag macht ensure_device (der targets.sh des Backports setzt
# auf den WAX218-Eintrag von Neanderfunk auf und passt hier nicht).
#
# Image: rohes initramfs openwrt-qualcommax-ipq807x-tplink_eap620hd-v1-initramfs-uImage.itb
# (Device/FitImage: KERNEL_SUFFIX -uImage.itb) [geprueft: Patch +
# qualcommax image/Makefile]. build.sh sucht nur *-initramfs-kernel.bin,
# deshalb hier als extra_images (landet unter other/, build.sh kopiert es).
# Target-Configs: TARGET_ROOTFS_INITRAMFS [geprueft: Gluon schaltet es nicht ein].
# RAM 1 GB [Commit-Text]; TFTP in den RAM, keine Flash-Grenze.
# Vorbereitungsskript: keins noetig.
# Ungetestet. Braucht ensure_openwrt_backport und RAMPE_HW_PATCHES (Vorschlag).
ensure_openwrt_backport tplink-eap620-hd-v1 5500-hw-tplink-eap620-hd-v1
ensure_device qualcommax-ipq807x tp-link-eap620-hd-v1 tplink_eap620hd-v1
ensure_target_config qualcommax-ipq807x TARGET_ROOTFS_INITRAMFS
ensure_extra_image qualcommax-ipq807x tp-link-eap620-hd-v1 -initramfs-uImage -initramfs-uImage .itb
