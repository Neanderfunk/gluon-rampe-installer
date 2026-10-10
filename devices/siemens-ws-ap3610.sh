# Siemens WS-AP3610 (ath79-generic, AR7161, 128 MB RAM, 16 MB NOR)
#
# Weg: seriell (Cisco-RJ45, 115200 8N1, Gehaeuse bleibt zu), U-Boot anhalten,
#   setenv boot_openwrt 'setenv bootargs; bootm 0xbf080000'
#   setenv ramboot_openwrt 'setenv serverip 192.168.1.66; tftpboot; bootm'
#   saveenv
#   run ramboot_openwrt
# TFTP-Server 192.168.1.66/24, Datei 1401A8C0.img (= RAMpe umbenannt).
# Danach Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt d2b8ccb1c04def81224da6f42f644c7d239b9986 [geprueft]. Der
# Commit setzt bootcmd nicht ausdruecklich (anders als beim WS-AP3705i);
# ob "run boot_openwrt" danach automatisch laeuft, ist offen.
# Image: ...-siemens_ws-ap3610-initramfs-kernel.bin,
# KERNEL_INITRAMFS = kernel-bin | append-dtb | uImage none, also
# unkomprimiert (der Flash-Kernel nutzt dagegen lzma + okli-Loader)
# [geprueft: ath79/image/generic.mk, seit d2b8ccb1 unveraendert].
# Groesse: OpenWrt 24.10.8 liefert 23698 KB [geprueft: Download-Liste]; die
# RAMpe liegt in derselben Groessenordnung (M30-Vergleich: RAMpe etwas
# kleiner als OpenWrt) [abgeleitet]. tftpboot ohne Adresse nimmt die
# Default-Ladeadresse des Bootloaders (unbekannt); bootm kopiert das
# unkomprimierte Image nach 0x80060000. TFTP mit 512-Byte-Bloecken endet ohne
# Blocknummer-Ueberlauf bei 32 MiB [abgeleitet]; build.sh-Vorschlag warnt
# darueber.
# Mit TARGET_INITRAMFS_COMPRESSION_LZMA bleibt der Kernel "uImage none",
# nur das Rootfs darin ist lzma-komprimiert und wird vom Kernel entpackt;
# das Image schrumpft grob auf Kernel + lzma-cpio [abgeleitet]. Hier
# lohnt das am meisten (TFTP-Dauer, Ladeadresse).
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
# Nach dem Flashen: nichts; boot_openwrt/saveenv seriell erledigt.
# RAM 128 MB (2x 64M DDR1 laut Commit): unkritisch [abgeleitet].
# Ungetestet.
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
