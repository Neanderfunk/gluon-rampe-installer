# ZTE MF281 (ath79-nand, QCA9563, 128 MB RAM, 128 MB SPI-NAND + 2 MB NOR)
#
# Weg: Gehaeuse oeffnen, UART (unbestueckter Stecker neben dem SIM-Slot,
# GND - RX - TX - 3V3, 3V3 nicht anschliessen), Autoboot anhalten:
#   setenv serverip 192.168.1.66
#   setenv ipaddr 192.168.1.154
#   tftpboot 0x84000000 speedbox-2.bin
#   bootm
# TFTP-Server 192.168.1.66, Datei speedbox-2.bin (= RAMpe umbenannt).
# Quelle: OpenWrt 1e1695f959e678868bb7911d059b847f38fc9cf4 [geprueft].
# Danach schreibt der Commit NICHT das sysupgrade, sondern das factory-Image:
#   mtd write /path/to/openwrt/factory.bin firmware
# Die RAMpe nimmt nur sysupgrade-Images (sysupgrade -T). Vorschlag
# [abgeleitet, nicht durch den Commit gedeckt]: prepare.d/zte,mf281 formatiert
# vorher die mtd "ubi" (ubiformat -y); "ubi" liegt innerhalb von "firmware"
# (qca9563_zte_mf281.dts: firmware = kernel 0x600000 + ubi 0x1700000)
# [geprueft], also im selben Bereich, den der Commit ohnehin ueberschreibt.
# nand_do_upgrade schreibt danach den Kernel nach "kernel" und legt die
# Volumes neu an [geprueft: nand.sh]. Ohne das Skript wuerde nand.sh nur dann
# selbst formatieren, wenn ubiattach scheitert; ob in der Stock-Firmware an
# dieser Stelle ein anhaengbares UBI liegt, ist offen.
# Gluon v2025.1.3: broken = true ("case must be opened to install"), baut aber
# ein factory [geprueft]. Rezept setzt broken = false fuer diesen Bau.
# Image: ...-zte_mf281-initramfs-kernel.bin = lzma-loader + uImage none
# (zte_mf28x_common) [geprueft: ath79/image/nand.mk].
# Alternative ohne RAMpe: das Gluon-factory der Community per "mtd write"
# aus dem OpenWrt-initramfs (wie Commit).
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
# Braucht lib.sh: ensure_device_option (Vorschlag, siehe UEBERSICHT.md).
ensure_device_option ath79-nand zte-mf281 broken false
ensure_target_config ath79-nand TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-nand TARGET_INITRAMFS_COMPRESSION_LZMA
