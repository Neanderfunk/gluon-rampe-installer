# Extreme Networks WS-AP3825i (mpc85xx-p1020, P1020, 256 MB RAM, 64 MB NOR)
#
# Weg: seriell (Cisco-RJ45 neben der 12-V-Buchse, 115200), Autoboot anhalten
# (admin/new2day), boot_openwrt/bootcmd setzen + saveenv, RAMpe per TFTP
# (DHCP+TFTP, z. B. dnsmasq) laden und bootm in Einzelschritten ausfuehren:
#   setenv boot_openwrt "cp.b 0xEC000000 0x2000000 0x2000000; interrupts off; bootm start 0x2000000; bootm loados; fdt resize; fdt boardsetup; fdt chosen; bootm prep; bootm go;"
#   setenv bootcmd "run boot_openwrt"
#   saveenv
#   setenv ipaddr <ip>; setenv serverip <tftp-server>;
#   tftpboot 0x2000000 <rampe>; interrupts off; bootm start 0x2000000;
#   bootm loados; fdt resize; fdt boardsetup; fdt chosen; bootm prep; bootm go;
# Danach Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 7e614820a89208c4e91a3a5f9de07a5402accdaa [geprueft]; seit
# ed82189339b8bcecfe709f1ce8f3500fb4aedab1 bootwrapper ("This does not require
# adapting the U-Boot bootcommand"), f058dad1b62d0d6c25ffd8365a8fbf0efb7f6f84
# (Kernel nicht doppelt komprimiert), 84a48ce400b2c7b0779f51e83c68de5f8ec58ffd
# (Ladeadresse 0x1500000) [geprueft].
# Image: ...-extreme-networks_ws-ap3825i-initramfs-kernel.bin,
# KERNEL = kernel-bin | fit none <dtb> (simpleImage.ws-ap3825i),
# KERNEL_INITRAMFS erbt -> FIT [geprueft: p1020.mk].
# Nach dem Flashen: nichts; bootcmd/saveenv seriell erledigt. fw_env.config
# fuer extreme-networks,ws-ap3825i vorhanden (cfg1/cfg2) [geprueft]; ein
# Vorbereitungsskript koennte boot_openwrt/bootcmd setzen, die Konsole ist
# fuer das TFTP-Laden aber ohnehin dran - kein Gewinn.
# Laut Inventar (Neanderfunk-Notiz recovery-wege.md) nach dem Flashen bis
# 600 s ohne Ping [nicht selbst geprueft].
# RAM 256 MB: unkritisch. Werte: OpenWrt-initramfs 7967 KB [geprueft].
# Ungetestet.
ensure_target_config mpc85xx-p1020 TARGET_ROOTFS_INITRAMFS
