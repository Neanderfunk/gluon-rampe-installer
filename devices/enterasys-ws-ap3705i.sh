# Enterasys WS-AP3705i (ath79-generic, AR9344, 128 MB RAM, 2x 16 MB NOR)
#
# Weg: seriell (Cisco-RJ45 hinten, 115200 8N1, Gehaeuse bleibt zu), U-Boot
# anhalten (admin/new2day), Umgebung setzen und RAMpe per TFTP laden:
#   setenv boot_openwrt 'setenv bootargs; bootm 0xbf230000'
#   setenv ramboot_openwrt 'setenv serverip 192.168.1.66; tftpboot 0x85000000; bootm'
#   setenv bootcmd 'run boot_openwrt'
#   saveenv
#   run ramboot_openwrt
# TFTP-Server 192.168.1.66/24, Datei 1401A8C0.img (= RAMpe umbenannt).
# Danach Community-sysupgrade ueber die Upload-Seite statt "sysupgrade -n".
# Quelle: OpenWrt ebddc5f984a240980303aed68524eb615484eef8 [geprueft].
# Image: ...-enterasys_ws-ap3705i-initramfs-kernel.bin = uImage lzma [geprueft].
# Ladeadresse 0x85000000: 80 MB Abstand zu 0x80060000, Platz unkritisch
# [abgeleitet].
# Nach dem Flashen: nichts; bootcmd/saveenv sind schon seriell erledigt.
# Vorbereitungsskript waere moeglich, bringt aber nichts, weil die Konsole
# fuer das TFTP-Laden ohnehin dran ist; fw_env.config gibt es fuer dieses
# Geraet nicht [geprueft: uboot-envtools/files/ath79].
# Kompression [abgeleitet, Abweichung von OpenWrt]: ath79 legt das Rootfs
# standardmaessig unkomprimiert in den Kernel (Config-images.in: LZMA-Default
# nur fuer ath79_mikrotik) [geprueft]. Wie gross das entpackt ist, zeigt das
# Siemens WS-AP3610, dessen initramfs unkomprimiert ausgeliefert wird:
# OpenWrt 24.10.8 23698 KB [geprueft: Download-Liste]; die anderen
# ath79-generic-Geraete teilen denselben Kernel [abgeleitet]. U-Boot entpackt
# "uImage lzma" nach KERNEL_LOADADDR 0x80060000 [geprueft: ath79/image/Makefile];
# laedt man das Image nach 0x81000000, sind darunter nur ~15.6 MB frei, und ein
# U-Boot mit kleinem CONFIG_SYS_BOOTM_LEN bricht vorher ab [abgeleitet, je
# Bootloader unbekannt]. Mit TARGET_INITRAMFS_COMPRESSION_LZMA entpackt der
# Kernel das Rootfs selbst (CONFIG_RD_LZMA wird gesetzt [geprueft:
# include/kernel-defaults.mk]), der von U-Boot zu entpackende Teil schrumpft
# auf grob Kernel + lzma-cpio, und beim Start liegt weniger doppelt im RAM.
# Gilt fuer alle Geraete dieses Targets im selben Bau; deshalb steht die
# Zeile in jedem ath79-generic-Rezept.
# RAM 128 MB: unkritisch. Werte: OpenWrt-initramfs 6033 KB [geprueft].
# Ungetestet.
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
