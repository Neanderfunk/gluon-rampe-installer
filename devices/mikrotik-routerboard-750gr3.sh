# MikroTik hEX RB750Gr3 (ramips-mt7621, MT7621A, 256 MB RAM, 16 MB NOR)
#
# Weg: RouterBOOT-Netboot nach der ueblichen MikroTik-Methode (BOOTP/DHCP +
# TFTP), RAMpe im RAM, danach Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 52f2d7d2a9dc3e142bb957462a30806eb5cebaf4 ("Installation through
# RouterBoot follows the usual MikroTik method
# https://openwrt.org/toh/mikrotik/common") [geprueft]; Einzelschritte
# (Reset beim Einschalten, Port, ggf. RouterOS v6) nur im Wiki [abgeleitet].
# Gluon v2025.1.3 kennt das Geraet nicht; gluon-patches-hardware
# (targets/targets-ramips-mt7621.patch, ab19bf1b46d34315a92f61974dd37f8a9ede9604)
# traegt es mit Alias mikrotik-routerboard-hex-v3, factory = false und
# packages {'-hostapd-mini'} ein [geprueft]. Fuer das initramfs reicht der
# Eintrag ohne Paketliste; ob ohne '-hostapd-mini' etwas schiefgeht, ist
# offen (Geraet ohne WLAN, OpenWrt nimmt -wpad-basic-mbedtls heraus).
# Image: openwrt-ramips-mt7621-mikrotik_routerboard-750gr3-initramfs-kernel.bin;
# Device/MikroTik: KERNEL_NAME vmlinuz, KERNEL = kernel-bin | append-dtb-elf,
# KERNEL_INITRAMFS erbt KERNEL -> ELF mit DTB [geprueft: ramips/image/mt7621.mk,
# include/image.mk Device/Init]. Rootfs-Kompression im Kernel: ramips-Default
# LZMA [geprueft: config/Config-images.in].
# Gluon schaltet TARGET_ROOTFS_INITRAMFS fuer ramips-mt7621 nicht ein
# [geprueft: targets/generic setzt false, ramips-mt7621 nicht true].
# Kompatibilitaet: dsa-migration, compat_version 1.1 im Image und in
# 05_compat-version der RAMpe [geprueft], passt.
# Nach dem Flashen: nichts weiter; platform.sh: "mtd erase firmware" bei
# tmpfs-root [geprueft: ramips/mt7621/base-files/lib/upgrade/platform.sh].
# RAM 256 MB: unkritisch [abgeleitet]. Werte: OpenWrt-initramfs 5966 KB,
# OpenWrt-sysupgrade 6273 KB [geprueft: Download-Liste 24.10.8].
# Offen: Groessengrenze des RouterBOOT-Netboots.
# Ungetestet.
ensure_device ramips-mt7621 mikrotik-routerboard-750gr3 mikrotik_routerboard-750gr3
ensure_target_config ramips-mt7621 TARGET_ROOTFS_INITRAMFS
