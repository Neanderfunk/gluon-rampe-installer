# Extreme Networks WS-AP3805i (ath79-generic, QCA9557, 256 MB RAM, 64 MB NOR)
#
# Weg: seriell ueber UART J10 (Gehaeuse auf, 3.3 V, 115200 8N1), Autoboot
# anhalten (admin/new2day), dann:
#   setenv boot_openwrt 'setenv bootargs; bootm 0xa1280000'
#   setenv ramboot_openwrt 'setenv serverip 192.168.1.66; tftpboot 0x89000000 1D01A8C0.img; bootm'
#   setenv bootcmd 'run boot_openwrt'
#   saveenv
#   run ramboot_openwrt
# TFTP-Server 192.168.1.66/24, Datei 1D01A8C0.img (= RAMpe umbenannt).
# Danach Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt f8c87aa2d27ab405f284dd4357377ab5c893a345 [geprueft].
# Image: ...-extreme-networks_ws-ap3805i-initramfs-kernel.bin = uImage lzma [geprueft].
# Nach dem Flashen: nichts; bootcmd/saveenv seriell erledigt. fw_env.config
# fehlt fuer dieses Geraet [geprueft: uboot-envtools/files/ath79].
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
# RAM 256 MB: unkritisch. Werte: OpenWrt-initramfs 6376 KB [geprueft].
# Ungetestet.
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
