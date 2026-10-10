# TP-Link Archer D50 v1 (ath79-generic, QCA9531 + QCA9882, 64 MB RAM, 8 MB NOR)
#
# Weg: Gehaeuse oeffnen, UART-Header J2 (Qualcomm-CPU), Autoboot anhalten,
# IP-Adressen fuer U-Boot und TFTP-Server selbst setzen, RAMpe laden:
#   tftpboot 0x81000000 <rampe>.bin
#   bootm 0x81000000
# Danach Community-sysupgrade ueber die Upload-Seite. (Der Commit nennt als
# Hauptweg das sysupgrade direkt per U-Boot: tftpboot, "erase 0x9f020000
# +$filesize", "cp.b 0x81000000 0x9f020000 $filesize". Der braucht keine
# RAMpe; die RAMpe spart nur das Rechnen mit Adressen.)
# Quelle: OpenWrt f5d2c91415a68f554815860d574145644fc31c16 [geprueft].
# Gluon v2025.1.3: broken = true ("64M ath9k + ath10k & power LED not
# working") [geprueft]; Rezept setzt broken = false fuer diesen Bau.
# Image: ...-tplink_archer-d50-v1-initramfs-kernel.bin,
# KERNEL_INITRAMFS = kernel-bin | append-dtb | lzma | tplink-v2-header -s -V "ver. 1.0"
# [geprueft: ath79/image/generic-tp-link.mk, seit 2019 so]; der Commit bootet
# es mit bootm 0x81000000.
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
#   Ladeadresse: bei 0x81000000 bleiben unter dem Image nur ~15.6 MB fuer den
#   entpackten Kernel. Mit lzma-cpio sollte das reichen; sonst hoeher laden
#   (z. B. 0x82000000, RAM endet bei 0x84000000) [abgeleitet, offen].
# RAM 64 MB [Commit]: knapp [abgeleitet]. Wie bei den 64-MB-MikroTik: die
# RAMpe ist etwa so gross wie das OpenWrt-initramfs, der Commit beschreibt
# das initramfs-Booten fuer dieses Geraet. Fest im RAM: entpacktes Rootfs
# (~11 MB, RAMpe-Bau filogic [geprueft]) + hochgeladenes sysupgrade in /tmp;
# Gluon-Funk ist aus. Mit lzma-cpio liegt beim Start weniger doppelt im RAM.
# Beim ersten Test "free" nach dem Upload notieren.
#   Obergrenze sysupgrade: IMAGE_SIZE 7808k [geprueft]; Neanderfunk-sysupgrade
#   Gluon-2023.2-Testbau 26090815sta: 7209783 Byte [geprueft]. OpenWrt-
#   initramfs 6466 KB [geprueft].
# Nach dem Flashen: nichts weiter.
# Ungetestet.
# Braucht lib.sh: ensure_device_option (Vorschlag, siehe UEBERSICHT.md).
ensure_device_option ath79-generic tp-link-archer-d50-v1 broken false
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
