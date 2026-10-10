# ASUS TUF-AX6000 (mediatek-filogic, MT7986, 512 MB RAM, 256 MB SPI-NAND)
#
# TEILWEISE. Zwei Wege:
# a) seriell ohne Oeffnen (Commit): drei Loecher im Gehaeuse (von unten RX,
#    TX, GND), 115200 8N1; TFTP-Server 192.168.1.70/24, rohes RAMpe-initramfs
#    als TUF-AX6000.bin; U-Boot Taste 4:
#      setenv ipaddr 192.168.1.1; setenv serverip 192.168.1.70
#      tftpboot 0x46000000 TUF-AX6000.bin; bootm 0x46000000
#    oder Taste 1 (Load System code to SDRAM via TFTP, Name eingeben).
#    Quelle: OpenWrt d522ccecb28f941aadcaf7a50cd6daa861f468a7 [geprueft].
# b) ohne UART: SSH + mtd-write wie TUF-AX4200 (herbetom filogic-v2, Image
#    fuer beide TUF-Modelle) [geprueft: Release-Text]:
#      mtd-erase -d linux
#      mtd-write -i /tmp/openwrt.bin -d linux
# Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade hochladen.
#
# Sonderbau und Schalter TARGET_ROOTFS_INITRAMFS_SEPARATE: wie bei
# asus-tuf-ax4200.sh (herbetom-Commit 731d3d3477c328a168b8589af8932d5df5f686ef
# aendert dasselbe fuer beide Geraete) [geprueft]; Wirkung des Schalters
# [abgeleitet]. Eigener build.sh-Lauf, nicht mit M30/M60 zusammen.
#
# Image: rohes initramfs openwrt-mediatek-filogic-asus_tuf-ax6000-initramfs-kernel.bin
# (filogic.mk am Pin a1ea57bd050c172fdc2b851824ebd9782aafb055: fit lzma ...
# with-initrd | pad-to 64k) [geprueft]. Groesse herbetom 7929856 Byte
# [geprueft]; Groesse des Volumes "linux": offen. RAM 512 MB [Commit].
# Vorbereitungsskript: keins noetig.
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
