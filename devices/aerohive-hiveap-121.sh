# Aerohive HiveAP 121 (ath79-nand, AR9344, 128 MB RAM, 128 MB NAND)
#
# Weg laut Commit: UART mit 9600 Baud (Anschluss im Commit nicht genannt),
# U-Boot ggf. mit Passwort "administrator" oder "AhNf?d@ta06", dann das
# factory-Image per TFTP und "nand write" direkt schreiben:
#   dhcp; setenv serverip <tftp-server>;
#   tftpboot 0x81000000 <factory>; nand erase 0x800000 0x800000;
#   nand write 0x81000000 0x800000 0x800000; reset
# Quelle: OpenWrt 62db255543c8fb5d1787caf36c6c7c9c51db71cd [geprueft].
# Gluon baut fuer das Geraet ein factory (kein factory = false) [geprueft];
# dieser Weg braucht keine RAMpe. Die RAMpe waere nur die Alternative zu
# "nand write": statt des factory "tftpboot 0x81000000 <rampe>; bootm", dann
# Community-sysupgrade ueber die Upload-Seite [abgeleitet, nicht im Commit].
# Nach dem Flashen per sysupgrade: nand_do_upgrade schreibt den Kernel nach
# "kernel" (0x800000, wie der Commit) und das UBI nach "ubi"; liegt dort kein
# anhaengbares UBI, formatiert nand.sh selbst [geprueft: DTS, nand.sh].
# Ob dort ein Stock-UBI haengt, das den Platz belegt: offen.
# Image: ...-aerohive_hiveap-121-initramfs-kernel.bin = uImage lzma (ath79
# Device/Default) [geprueft]. Ladeadresse 0x81000000 wie im Commit: unter dem
# Image nur ~15.6 MB fuer den entpackten Kernel, daher lzma-cpio.
# Kompression [abgeleitet, Abweichung von OpenWrt]: ath79-nand legt das
# Rootfs standardmaessig unkomprimiert in den Kernel (Config-images.in)
# [geprueft]. Entpackt ist ein ath79-initramfs dann rund 23 MB gross (Siemens
# WS-AP3610 als unkomprimierte Referenz: 23698 KB) [abgeleitet]. Mit
# TARGET_INITRAMFS_COMPRESSION_LZMA entpackt der Kernel das Rootfs selbst
# (CONFIG_RD_LZMA [geprueft: include/kernel-defaults.mk]); der von U-Boot
# bzw. lzma-loader zu entpackende Teil schrumpft. Gilt fuer alle Geraete
# dieses Targets im selben Bau; die Zeile steht deshalb in jedem
# ath79-nand-Rezept.
# RAM 128 MB: unkritisch. Werte: OpenWrt-initramfs 6441 KB [geprueft].
# Ungetestet.
ensure_target_config ath79-nand TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-nand TARGET_INITRAMFS_COMPRESSION_LZMA
