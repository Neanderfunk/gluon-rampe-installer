# ZTE MF289F (ipq40xx-generic, IPQ4019, 256 MB RAM, NAND)
#
# TEILWEISE. Weg laut OpenWrt 0de6a3339f1aadc1de2c9371435e3de239a00645
# [geprueft]: Gehaeuse auf, UART (GND neben "MF289F MIMO-V1.0"), 115200 8N1;
# TFTP-Server 192.168.0.2 an WAN/LAN1; U-Boot mit ESC anhalten:
#   setenv serverip 192.168.0.2
#   setenv ipaddr 192.168.0.1
#   set fdt_high 0x85000000
#   tftp <rampe>-initramfs-zImage.itb
#   bootm $loadaddr
# Danach die RAMpe. Vor dem sysupgrade verlangt der Commit (nach Backup von
# mtd16 "web" und mtd17 "rootfs"):
#   ubiattach -m 17
#   ubirmvol /dev/ubi0 -N ubi_rootfs
#   ubirmvol /dev/ubi0 -N ubi_rootfs_data
#
# ACHTUNG: Hier reicht ein Vorbereitungsskript "vor sysupgrade" NICHT.
# platform_check_image in ipq40xx platform.sh laesst sysupgrade -T fuer
# zte,mf289f scheitern, solange ubi_rootfs oder ubi_rootfs_data da sind
# [geprueft: platform.sh am Pin a1ea57bd050c172fdc2b851824ebd9782aafb055].
# Die RAMpe-Seite lehnt das Community-Image also schon beim Upload ab. Die
# Vorbereitung muss VOR der Pruefung laufen (eigener Schritt auf der Seite,
# mit Backup-Download und Bestaetigung), siehe UEBERSICHT.md.
#
# Gluon fuehrt das Geraet mit broken = true ("case must be opened to
# install") [geprueft: targets/ipq40xx-generic]. Ohne Freigabe verwirft
# Gluon es (want_device), und der Bau bricht mit "unknown devices given" ab
# [geprueft: target_lib.lua]. Freigabe gezielt per image-customization
# broken(false) (Gluon-API, image_customization_lib.lua) [geprueft], hier
# ueber ensure_site_unbroken; alternativ BROKEN=1 fuer den ganzen Lauf.
#
# Image: rohes initramfs openwrt-ipq40xx-generic-zte_mf289f-initramfs-zImage.itb
# (Device/FitzImage: KERNEL_SUFFIX -zImage.itb, fit none) [geprueft]. Der
# Commit nennt noch "...-initramfs-fit-zImage.itb" (aelterer Name). Als
# extra_images, weil build.sh nur *-initramfs-kernel.bin sucht.
# Target-Configs: TARGET_ROOTFS_INITRAMFS [geprueft: Gluon aus]. Groesse:
# TFTP in den RAM; OpenWrt-24.10.8-initramfs 7529680 Byte [geprueft]. RAM 256 MB.
#
# Vorbereitungsskript (Vorschlag, overlay/lib/gluon-rampe/prepare/zte_mf289f.sh,
# Lauf VOR sysupgrade -T):
#   mtd=$(find_mtd_index rootfs)          # Commit: mtd17
#   ubiattach -m "$mtd" || true           # Commit: "can return an error"
#   ubirmvol /dev/ubi0 -N ubi_rootfs || true
#   ubirmvol /dev/ubi0 -N ubi_rootfs_data || true   # "some devices doesn't have it"
# Backup vorher anbieten: cat /dev/mtd16 (web), cat /dev/mtd17 (rootfs) als
# Download [abgeleitet: Commit nennt cat + scp].
# Ungetestet. Braucht ensure_site_unbroken und den Vorbereitungs-Schritt vor
# der Pruefung (Vorschlag UEBERSICHT.md).
ensure_site_unbroken zte-mf289f
ensure_target_config ipq40xx-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq40xx-generic zte-mf289f -initramfs-zImage -initramfs-zImage .itb
