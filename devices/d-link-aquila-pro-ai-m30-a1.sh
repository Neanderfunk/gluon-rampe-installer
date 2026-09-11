# D-Link AQUILA PRO AI M30 A1 (mediatek-filogic, MT7981)
#
# Einspielen ueber die D-Link-Recovery (Reset beim Einschalten halten,
# 192.168.200.1). OpenWrt 24.10 baut recovery.bin mit initramfs-Kernel und
# D-Link-Header (124f61eddb) - genau das Format fuer den Installer.
#
# Gluon hat das recovery-Image fuer die Community-Firmware entfernt (#3816),
# weil ein Gluon als initramfs dort nie in den Config-Mode kam. Der Installer
# behebt genau das (overlay/lib/preinit/91_installer_initramfs), braucht das
# Image also wieder.
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
ensure_extra_image mediatek-filogic d-link-aquila-pro-ai-m30-a1 -squashfs-recovery -recovery .bin
