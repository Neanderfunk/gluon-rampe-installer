# ASUS TUF-AX4200 (mediatek-filogic, MT7986, 512 MB RAM, 256 MB SPI-NAND)
#
# TEILWEISE. Zwei Wege:
# a) seriell (Commit): UART, TFTP-Server 192.168.1.66/24, rohes RAMpe-initramfs
#    als tufax4200.bin, U-Boot Taste 4, dann
#      setenv ipaddr 192.168.1.1; setenv serverip 192.168.1.66
#      tftpboot 0x46000000 tufax4200.bin; bootm 0x46000000
#    Quelle: OpenWrt e7c399bee677e9bac66e1bea697aefb8d828edfe [geprueft].
# b) ohne UART (Release-Text herbetom/openwrt-asus-filogic-factory filogic-v2,
#    10.12.2023) [geprueft]: SSH in die Stock-Firmware (admin@192.168.50.1),
#    Image per wget nach /tmp/openwrt.bin, dann
#      mtd-erase -d linux
#      mtd-write -i /tmp/openwrt.bin -d linux
#    Neustart. Die RAMpe ersetzt hier den herbetom-Sonderbau.
# Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade hochladen.
#
# Was der Sonderbau anders macht [geprueft: herbetom-Commit
# 731d3d3477c328a168b8589af8932d5df5f686ef "mediatek: embed initramfs into
# kernel image", David Bauer]: FEATURES separate_ramdisk -> ramdisk, und
# "with-initrd" im KERNEL_INITRAMFS entfernt. Das initramfs steckt also im
# Kernel statt als eigenes initrd im FIT. Gleiches Ergebnis ohne Eingriff in
# OpenWrt: TARGET_ROOTFS_INITRAMFS_SEPARATE abschalten; Build/fit haengt das
# initrd nur mit CONFIG_TARGET_ROOTFS_INITRAMFS_SEPARATE an
# (include/image-commands.mk am Pin a1ea57bd050c172fdc2b851824ebd9782aafb055)
# [abgeleitet aus Code]. Fuer Weg a) ist der Schalter nicht noetig, schadet
# aber nicht [abgeleitet].
#
# ACHTUNG: Der Schalter gilt fuer das ganze Target eines build.sh-Laufs. Die
# TUF-Geraete deshalb in einem eigenen Lauf bauen, nicht zusammen mit M30/M60
# (deren recovery.bin wurde nur mit separatem initrd gebaut und geprueft).
#
# Image: rohes initramfs openwrt-mediatek-filogic-asus_tuf-ax4200-initramfs-kernel.bin
# (KERNEL_INITRAMFS ... fit lzma ... | pad-to 64k) [geprueft]; build.sh
# sammelt es schon ein. Groesse: herbetom-Sonderbau 7929856 Byte,
# OpenWrt-24.10.8-initramfs 8847360 Byte [geprueft: GitHub-API/HTTP]. Wie
# gross das UBI-Volume "linux" der Stock-Firmware ist: offen.
# Ob ein Gluon-initramfs statt des Sonderbaus aus "linux" bootet: offen.
# Vorbereitungsskript: keins noetig (SSH-Schritt bleibt beim Nutzer).
# Ungetestet. Braucht ensure_target_config_value (Vorschlag lib.sh).
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
ensure_target_config_value mediatek-filogic TARGET_ROOTFS_INITRAMFS_SEPARATE false

# Schutz: nicht mit anderen filogic-Geraeten in einem Lauf (siehe ACHTUNG oben)
for _d in "${DEVICES[@]}"; do
	case "$_d" in asus-tuf-ax4200|asus-tuf-ax6000) ;; *)
		echo "$_d nicht im selben Lauf wie die TUF-Geraete bauen (TARGET_ROOTFS_INITRAMFS_SEPARATE)." >&2
		exit 1 ;;
	esac
done
