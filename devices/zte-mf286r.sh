# ZTE MF286R (ath79-nand, QCA9563, 128 MB RAM, 128 MB SPI-NAND + 2 MB NOR)
#
# Weg ohne Oeffnen (Exploit-Weg, "Method 2" im Commit):
#  1. Root-Shell in der Stock-Firmware: im Web-UI unter URL-Filter einen
#     Eintrag mit "&&telnetd&&" anlegen, telnet Port 4719, admin/admin
#     (ohne telnetd im Busybox: Methode 2 des Commits per TFTP-Busybox).
#  2. Sicherung der mtd-Partitionen auf USB-Stick (Commit STEP 2; die
#     Stock-Firmware ist nicht oeffentlich).
#  3. RAMpe in die "firmware"-mtd schreiben und neu starten:
#       nandwrite -p /dev/<firmware-mtd> gluon-rampe-<Datum>-zte-mf286r-initramfs-kernel.bin
#       reboot -f
#     U-Boot startet es per "nboot", das nicht an die Kernel-Partitionsgroesse
#     gebunden ist; "firmware" (Kernel + Rootfs der Stock-Firmware) ist beim
#     MF286A 0x1d00000 Byte gross.
#  4. Community-sysupgrade ueber die Upload-Seite statt scp + sysupgrade -n.
# Quelle: OpenWrt 7ac8da00609f42b8aba74b7efc6b0d055b7cef3e ("ath79: support ZTE
# MF286A/R") [geprueft]. Die mtd-Liste und die Dateinamen im Commit gelten
# der MF286A ("Differences might indicate that this is NOT a MF286A"); fuer
# die R ist der Exploit-Weg nicht einzeln belegt [geprueft: Commit-Text].
# Gluon v2025.1.3 kennt das Geraet nicht; gluon-patches-hardware
# (targets/targets-ath79-nand.patch, ab19bf1b46d34315a92f61974dd37f8a9ede9604)
# traegt es mit broken = true ("case must be opened to install") und
# factory = false ein [geprueft]. ensure_device traegt es ohne broken ein.
# Image: ...-zte_mf286r-initramfs-kernel.bin, Device/zte_mf28x_common:
# KERNEL = kernel-bin | append-dtb | lzma | loader-kernel | uImage none,
# KERNEL_INITRAMFS = $(KERNEL); lzma-loader bei LZMA_TEXT_START 0x82800000
# [geprueft: ath79/image/nand.mk]. Platz fuer den entpackten Kernel unter dem
# Loader: ~39.6 MB [abgeleitet].
# Nach dem Flashen: nichts weiter. sysupgrade (nand_do_upgrade) schreibt den
# Kernel in "kernel" (4 MB, 0x1800000) und das UBI in den "ubi"-Verbund
# (mtd-concat); findet ubiattach dort kein UBI, formatiert nand.sh selbst
# [geprueft: package/base-files/files/lib/upgrade/nand.sh nand_attach_ubi].
# Kein Vorbereitungsskript.
# Kompression [abgeleitet, Abweichung von OpenWrt]: ath79-nand legt das
# Rootfs standardmaessig unkomprimiert in den Kernel (Config-images.in)
# [geprueft]. Entpackt ist ein ath79-initramfs dann rund 23 MB gross (Siemens
# WS-AP3610 als unkomprimierte Referenz: 23698 KB) [abgeleitet]. Mit
# TARGET_INITRAMFS_COMPRESSION_LZMA entpackt der Kernel das Rootfs selbst
# (CONFIG_RD_LZMA [geprueft: include/kernel-defaults.mk]); der von U-Boot
# bzw. lzma-loader zu entpackende Teil schrumpft. Gilt fuer alle Geraete
# dieses Targets im selben Bau; die Zeile steht deshalb in jedem
# ath79-nand-Rezept.
# RAM 128 MB: unkritisch [abgeleitet]. Werte: OpenWrt-initramfs 7133 KB,
# OpenWrt-sysupgrade 7510 KB [geprueft].
# Ungetestet.
ensure_device ath79-nand zte-mf286r zte_mf286r
ensure_target_config ath79-nand TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-nand TARGET_INITRAMFS_COMPRESSION_LZMA
