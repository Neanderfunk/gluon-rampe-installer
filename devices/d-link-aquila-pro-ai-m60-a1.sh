# D-Link AQUILA PRO AI M60 A1 (mediatek-filogic, MT7986, 512 MB RAM, 128 MB NAND)
#
# Einspielen ueber die D-Link-Recovery: Reset beim Einschalten halten, bis die
# LED rot blinkt, Rechner 192.168.200.x/24, http://192.168.200.1, das
# RAMpe-Image ...-recovery.bin hochladen (Chromium-Browser). Danach die
# RAMpe unter http://192.168.1.1 (LAN-Port), Community-sysupgrade hochladen.
# Quelle: OpenWrt 7271ee587cd104d30d6d46dd3c623c9d4602bd0c [geprueft].
#
# Image: IMAGE recovery.bin (filogic.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055, Device/dlink_aquila-pro-ai-m60-a1):
# append-image-stage initramfs-kernel.bin | sysupgrade-tar | pad-to 51200k |
# dlink-ai-recovery-header DLK6E8202001 ..., nur mit
# CONFIG_TARGET_ROOTFS_INITRAMFS [geprueft]. Dateiname
# openwrt-mediatek-filogic-dlink_aquila-pro-ai-m60-a1-squashfs-recovery.bin.
# Gluon v2025.1.3 (e2fe4b52effcf32e498e1afa283dbe8dccf21ffb) schaltet
# TARGET_ROOTFS_INITRAMFS fuer filogic schon ein und sammelt
# {'-squashfs-recovery', '-recovery', '.bin'} schon als extra_images ein
# [geprueft: targets/mediatek-filogic]. Beide Zeilen unten sind deshalb ohne
# Wirkung und stehen nur zur Dokumentation (und falls Gluon das Image wie bei
# der M30 (#3816) einmal entfernt).
#
# Groesse: initramfs muss in 51200k passen; OpenWrt-24.10.8-recovery.bin hat
# genau 52428880 Byte (gepolstert), das RAMpe-initramfs der M30 hat 8102912
# Byte [geprueft: out/ vom 11.09.2026]. RAM 512 MB [Commit].
#
# Bedingungen [geprueft, Commit]: nur wenn die erste UBI-Partition aktiv ist.
# Sonst haengt der Start; dann vorher das UBI-Switch-Image von RolandoMagico
# (github.com/RolandoMagico/openwrt/releases/tag/M60-Recovery-UBI-Switch)
# ueber dieselbe Recovery einspielen. Ob die RAMpe in diesem Fall nach dem
# Switch-Image als zweiter Schritt reicht, ist offen.
# Vorbereitungsskript: keins noetig.
# Ungetestet.
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
ensure_extra_image mediatek-filogic d-link-aquila-pro-ai-m60-a1 -squashfs-recovery -recovery .bin
