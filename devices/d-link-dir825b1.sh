# D-Link DIR-825 B1 (ath79-generic, AR7161, 64 MB RAM, 8 MB NOR)
#
# Weg ab Werk offen: OpenWrt hat das factory-Rezept mit 4309be6bcb3d
# abgeschaltet ("max image sizes too small", FACTORY_SIZE 6144k) [geprueft:
# Inventar]. Zu pruefen, ob die D-Link-Recovery ein initramfs annimmt; das
# OpenWrt-initramfs 24.10.8 hat 6145 KB, also knapp ueber 6144k [geprueft:
# Inventar]. Das RAMpe-initramfs wird hier gebaut, um die Groesse zu sehen.
# Ungetestet, Weg unbelegt.
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
