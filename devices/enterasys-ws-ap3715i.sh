# Enterasys WS-AP3715i (mpc85xx-p1010, P1010, 256 MB RAM, 32 MB NOR)
#
# Weg: seriell (Cisco-RJ45, 115200 8N1, Gehaeuse bleibt zu), U-Boot anhalten
# (admin/new2day), dann:
#   setenv ramboot_openwrt "setenv ipaddr 192.168.1.1; setenv serverip 192.168.1.66; tftpboot 0x2000000 ap3715.bin; bootm"
#   setenv boot_openwrt "sf probe 0; sf read 0x2000000 0x140000 0x1000000; bootm 0x2000000"
#   setenv bootcmd "run boot_openwrt"
#   saveenv
#   run ramboot_openwrt
# TFTP-Server 192.168.1.66/24, Datei ap3715.bin (= RAMpe umbenannt).
# Danach Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 765f66810a3324cc35fa6471ee8eeee335ba8c2b [geprueft].
# Image: ...-enterasys_ws-ap3715i-initramfs-kernel.bin;
# KERNEL = kernel-bin | lzma | uImage lzma (simpleImage.ws-ap3715i),
# KERNEL_INITRAMFS erbt das, KERNEL_LOADADDR 0x1500000 [geprueft: p1010.mk].
# U-Boot entpackt von 0x2000000 nach 0x1500000. Ist das entpackte
# simpleImage groesser als 11 MB (0x2000000 - 0x1500000), ueberlappen Ziel
# und Quelle; ein U-Boot mit Ueberlappungspruefung in bootm bricht dann ab
# [abgeleitet, U-Boot-Stand des Geraets unbekannt]. Das simpleImage enthaelt Kernel und
# lzma-cpio (mpc85xx-Default LZMA [geprueft]) und ist selbst schon
# komprimiert; OpenWrt-initramfs 7449 KB [geprueft: Download-Liste]. Die
# RAMpe sollte aehnlich gross sein [abgeleitet]. Nach dem Bau Groesse
# pruefen; das ist die engste Stelle in dieser Gruppe ausser den 64-MB-Geraeten.
# Nach dem Flashen: nichts; bootcmd/saveenv seriell erledigt. fw_env.config
# fuer enterasys,ws-ap3715i vorhanden (cfg1/cfg2) [geprueft]; ein
# Vorbereitungsskript braeuchte es nicht.
# RAM 256 MB: unkritisch.
# Ungetestet.
ensure_target_config mpc85xx-p1010 TARGET_ROOTFS_INITRAMFS
