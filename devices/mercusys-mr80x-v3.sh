# Mercusys MR80X v3 (mediatek-filogic, MT7981B, 512 MB RAM, 128 MB SPI-NAND)
#
# OpenWrt 24.10 kennt das Geraet (0ecf136f4d3126d92edc13087ce03db83b7e8223),
# Gluon v2025.1.3 nicht; das Rezept traegt es fuer diesen Bau ein.
# Weg ab Werk laut Commit nur per UART: tp_boot_idx 0, bootcmd setzen,
# initramfs per TFTP (Server 192.168.1.2), dann sysupgrade -n. Ob der
# SSH-/Telnet-Weg des MR90X auch hier geht, ist offen (nicht belegt).
# Die U-Boot-Recovery (Reset beim Einschalten, http://192.168.1.1) nimmt laut
# Commit nur OEM-Firmware.
# Ein Community-sysupgrade gibt es ab der Neanderfunk-Firmware 2025.1 (Backport
# gluon-patches-hardware ab19bf1b, 10.10.2026); Gluon selbst fuehrt ihn nicht.
# Ungetestet.
ensure_device mediatek-filogic mercusys-mr80x-v3 mercusys_mr80x-v3
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
