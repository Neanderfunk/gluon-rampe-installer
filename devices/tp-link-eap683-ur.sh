# TP-Link EAP683 UR (mediatek-filogic, MT7986), Gruppe B aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt 708dcca80a0b19aacd32e2bd4530b88461f87581]:
#   UART (Loetstellen J255 bzw. TP13-TP15): Boot mit Ctrl+b abbrechen, im
#   Bootmenue die U-Boot-Konsole, tp_boot_idx loeschen, initramfs per TFTP
#   laden und starten. Ueber die Herstellerfirmware nicht moeglich.
# Danach im Browser http://192.168.1.1 das Community-sysupgrade hochladen,
# statt es per scp zu kopieren und sysupgrade aufzurufen.
# Vorbereitungsskript: keins noetig (tp_boot_idx loescht man schon in der
# U-Boot-Konsole).
#
# OpenWrt am Stand von Gluon v2025.1.3 kennt das Geraet nicht. Die Patches
# kommen aus gluon-patches-hardware devices/tplink-eap683 (0001 LR, 0002 UR),
# die es NUR auf dem Zweig v2025.1.x-next gibt: RAMPE_HW_PATCHES muss fuer
# diesen Lauf auf einen Checkout dieses Zweigs zeigen, sonst bricht
# ensure_openwrt_backport ab. Deshalb ein eigener Lauf in
# scripts/alle-bauen.sh, damit ein Fehlschlag die anderen nicht trifft.
# Im Neanderfunk-Bau steht der UR als Alias des LR; fuer die RAMpe getrennt,
# weil OpenWrt zwei Profile mit eigenem DTS baut.
# Image: ...-initramfs-kernel.bin wie bei allen filogic-Geraeten.
# Ungetestet.
ensure_openwrt_backport tplink-eap683 5800-hw-tplink-eap683
ensure_device mediatek-filogic tp-link-eap683-ur tplink_eap683-ur
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
