# D-Link DIR-505 (ath79-generic, AR9330, 64 MB RAM, 8 MB NOR)
#
# Weg: laut Commit nur "sysupgrading from an earlier OpenWrt version, U-Boot
# TFTP or a modded U-Boot"; ath79 baut kein factory [geprueft]. Fuer die
# RAMpe also: serielle Konsole, U-Boot anhalten, RAMpe per tftpboot laden und
# mit bootm starten, danach Community-sysupgrade ueber die Upload-Seite.
# UART-Lage, IP-Adressen, Dateiname und Ladeadresse nennt der Commit nicht
# [geprueft] - alles offen, Anleitung aus Wiki/ar71xx-Zeit noetig.
# Quelle: OpenWrt c9ac7b17296ff29d9df39db8a68c449ef1514bbd [geprueft].
# Image: ...-dlink_dir-505-initramfs-kernel.bin = uImage lzma (ath79
# Device/Default) [geprueft].
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
#   Ladeadresse: bei 64 MB nicht 0x81000000 nehmen, wenn der entpackte Kernel
#   groesser als ~15.6 MB ist; mit lzma-cpio sollte es passen [abgeleitet, offen].
# RAM 64 MB [Commit]: knapp [abgeleitet]. Wie bei den 64-MB-MikroTik: die
# RAMpe ist etwa so gross wie das OpenWrt-initramfs, der Commit beschreibt
# das initramfs-Booten fuer dieses Geraet. Fest im RAM: entpacktes Rootfs
# (~11 MB, RAMpe-Bau filogic [geprueft]) + hochgeladenes sysupgrade in /tmp;
# Gluon-Funk ist aus. Mit lzma-cpio liegt beim Start weniger doppelt im RAM.
# Beim ersten Test "free" nach dem Upload notieren.
#   Obergrenze sysupgrade: IMAGE_SIZE 7680k [geprueft]; Neanderfunk-sysupgrade
#   Gluon-2023.2-Testbau 26090815sta: 6882102 Byte [geprueft]. OpenWrt-
#   initramfs 6142 KB [geprueft].
# Nach dem Flashen: nichts weiter.
# Ungetestet.
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
