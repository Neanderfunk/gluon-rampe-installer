# ASUS RT-AX52 (mediatek-filogic, MT7981B, 256 MB RAM, 128 MB SPI-NAND)
#
# Einspielen ueber die Stock-Web-UI: Rechner per DHCP an einen gelben
# LAN-Port, http://192.168.50.1, Ersteinrichtung abschliessen,
# Administration > Firmware Upgrade, das RAMpe-Image ...-initramfs.trx
# hochladen. Danach die RAMpe unter http://192.168.1.1, Community-sysupgrade
# hochladen.
# Quelle: OpenWrt 99708cc16dbd7c93db80698fbe5c69f07995a3e6, Abschnitt
# "Vendor-UI Method" [geprueft].
#
# Image: ARTIFACT initramfs.trx (filogic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055, Device/asus_rt-ax52):
# append-image-stage initramfs-kernel.bin | uImage none |
# asus-trx -v 3 -n RT-AX52, gebaut ausserhalb des ImageBuilders [geprueft].
# OpenWrt legt ARTIFACTS als $(BIN_DIR)/$(DEVICE_IMG_PREFIX)-<artifact> ab
# (include/image.mk, Device/Build/artifact), also
# openwrt-mediatek-filogic-asus_rt-ax52-initramfs.trx; Gluons copy_output.lua
# sucht openwrt-<board>-<subtarget>-<profil><in_suffix><extension>. Mit
# {'-initramfs', '-initramfs', '.trx'} stimmt der Name [geprueft: Code; im
# Bau noch nicht bestaetigt].
# Target-Configs: TARGET_ROOTFS_INITRAMFS und LZMA setzt Gluon fuer filogic
# schon [geprueft]; die Zeile unten ist ohne Wirkung.
#
# Groesse: kein IMAGE_SIZE fuer das TRX. OpenWrt-24.10.8-initramfs.trx:
# 8585304 Byte; das RAMpe-initramfs der M30 war ~5 % kleiner als das
# OpenWrt-initramfs [geprueft]. Ob die ASUS-UI eine Obergrenze hat: offen.
# RAM 256 MB [Commit], reicht [abgeleitet].
#
# Notweg (seriell, Rueckweg): TFTP-Server 192.168.1.70, Datei rtax52.bin =
# rohes initramfs (out/images/gluon-rampe-<Datum>-asus-rt-ax52-initramfs-kernel.bin
# umbenannt), U-Boot-Menue Taste 4 [geprueft, Commit].
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
ensure_extra_image mediatek-filogic asus-rt-ax52 -initramfs -initramfs .trx
