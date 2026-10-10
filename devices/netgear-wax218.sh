# Netgear WAX218 (qualcommax-ipq807x, IPQ8072A, 366 MB RAM nutzbar, 256 MB NAND)
#
# Einspielen ueber die Stock-Web-UI: System Manager -> Firmware -> "Local
# Firmware Upgrade", das RAMpe-Image ...-web-ui-factory.fit hochladen,
# "Upload", dann "Proceed". Das Geraet startet von selbst neu. Danach die
# RAMpe unter http://192.168.1.1 (einziger Port), Community-sysupgrade hochladen.
# Quelle: OpenWrt 7801161c4bb2413817b3dfd01695050e2da27bf3, "Web UI method"
# [geprueft]. Der Commit nimmt bewusst ein initramfs, weil die Stock-UI
# mal nach mtd12, mal nach mtd14 schreibt [geprueft].
#
# Image: ARTIFACT web-ui-factory.fit (ipq807x.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055, Device/netgear_wax218):
# append-image initramfs-uImage.itb | ubinize-kernel | qsdk-ipq-factory-nand,
# nur mit CONFIG_TARGET_ROOTFS_INITRAMFS und ausserhalb des ImageBuilders
# [geprueft]. Dateiname openwrt-qualcommax-ipq807x-netgear_wax218-web-ui-factory.fit;
# extra_images {'-web-ui-factory', '-web-ui-factory', '.fit'} [geprueft: Code;
# im Bau offen].
# Target-Configs: Gluon schaltet fuer qualcommax kein initramfs ein (generic:
# TARGET_ROOTFS_INITRAMFS false) [geprueft]. Kompression: Kconfig-Default fuer
# qualcommax ist ZSTD [geprueft: config/Config-images.in], FEATURES ohne
# separate_ramdisk, das initramfs steckt im Kernel [geprueft]. Keine eigene
# Kompressionszeile noetig.
#
# Gluon v2025.1.3 kennt das Geraet nicht; Neanderfunk traegt es per
# gluon-patches-hardware (targets/targets-qualcommax-ipq807x.patch) ein.
# OpenWrt 24.10 hat das Profil netgear_wax218 [geprueft], also ensure_device.
# Groesse: OpenWrt-24.10.8-web-ui-factory.fit 14026063 Byte [geprueft];
# Groesse von mtd12/mtd14: offen. RAM reicht [abgeleitet].
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_device qualcommax-ipq807x netgear-wax218 netgear_wax218
ensure_target_config qualcommax-ipq807x TARGET_ROOTFS_INITRAMFS
ensure_extra_image qualcommax-ipq807x netgear-wax218 -web-ui-factory -web-ui-factory .fit
