# Enterasys WS-AP3710i (mpc85xx-p1020, P1020, 256 MB RAM, 32 MB NOR)
#
# Weg: seriell (Cisco-RJ45 neben dem Ethernet-Port, 115200 8N1, Gehaeuse
# bleibt zu), U-Boot anhalten (admin/new2day), dann:
#   setenv boot_openwrt "setenv bootargs; cp.b 0xee000000 0x1000000 0x1000000; bootm 0x1000000"
#   setenv bootcmd "run boot_openwrt"
#   saveenv
#   tftpboot 0x1000000 192.168.200.200:01C8A8C0.img; bootm
# TFTP-Server 192.168.200.200/24, Datei 01C8A8C0.img (= RAMpe umbenannt).
# Danach Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 16b01fb1b9c99513c318109bef96a1a3545c57a0 [geprueft]; seit
# eec18118d02fa5d095cb4035c42187e487d0e68c simpleImage-Wrapper (DTB-Ausrichtung),
# Installationsweg dort nicht geaendert [geprueft].
# Image: ...-enterasys_ws-ap3710i-initramfs-kernel.bin = simpleImage.ws-ap3710i
# als uImage none, KERNEL_LOADADDR 0x1500000 [geprueft: p1020.mk]; bootm
# kopiert von 0x1000000 nach 0x1500000 (ueberlappend) [abgeleitet: geht bei
# OpenWrt genauso].
# Nach dem Flashen: nichts; bootcmd/saveenv seriell erledigt. fw_env.config
# gibt es fuer dieses Geraet nicht [geprueft: uboot-envtools/files/mpc85xx],
# ein Vorbereitungsskript koennte bootcmd also nicht setzen.
# RAM 256 MB: unkritisch. Werte: OpenWrt-initramfs 7600 KB [geprueft].
# Ungetestet.
ensure_target_config mpc85xx-p1020 TARGET_ROOTFS_INITRAMFS
