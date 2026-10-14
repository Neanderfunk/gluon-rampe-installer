# D-Link DAP-X1860 A1 (ramips-mt7621, 256 MB RAM, NAND)
#
# Rueckfall, falls das Gluon-factory nicht klappt: Reset beim Einstecken,
# Web-Recovery 192.168.0.50; laut OpenWrt-Commit factory.bin hochladen
# [geprueft: Inventar], laut Neanderfunk-Notiz (01.10.2026) dagegen
# OpenWrt-initramfs und danach sysupgrade - Widerspruch offen [Inventar].
# Fuer den initramfs-Weg die RAMpe statt OpenWrt.
# Ungetestet.
ensure_target_config ramips-mt7621 TARGET_ROOTFS_INITRAMFS
