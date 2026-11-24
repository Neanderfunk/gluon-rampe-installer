# TP-Link TL-XDR6086 (mediatek-filogic, MT7986), Gruppe C aus docs/PLAN-WEITERE-RAMPEN.md
#
# TEILWEISE: Shell-Zugang und Bootloader-Tausch bleiben Handarbeit; die
# RAMpe ersetzt nur das OpenWrt-initramfs im TFTP-Recovery-Schritt.
# Weg [geprueft: OpenWrt 21be2c26d555b33e9faf85be3e980876810b29d3]:
#   Shell-Zugang zur Stock-Firmware laut OpenWrt-Wiki (inbox/toh/tp-link/
#   xdr-6086, Abschnitt rooting), preloader.bin und bl31-uboot.fip von
#   OpenWrt laut Commit per dd nach /dev/mtdblock9, dann TFTP-Recovery des
#   OpenWrt-U-Boot: Rechner fest 192.168.1.254, Gateway 192.168.1.1, am
#   Gigabit-Port.
# Datei: RAMpe-...-initramfs-recovery.itb in
# openwrt-mediatek-filogic-tplink_tl-xdr6086-initramfs-recovery.itb umbenennen
# (TFTP-Name laut U-Boot-Umgebung) [geprueft: uboot-mediatek 24.10.8].
# Danach im Browser http://192.168.1.1 das Community-sysupgrade hochladen,
# statt es per scp zu kopieren und sysupgrade -n aufzurufen.
# Vorbereitungsskript: keins (der Tausch passiert vor der RAMpe).
#
# Image: KERNEL_INITRAMFS = kernel-bin | lzma | fit lzma <dtb> with-initrd |
# pad-to 64k, KERNEL_INITRAMFS_SUFFIX = -recovery.itb, Datei
# ...-initramfs-recovery.itb [geprueft: filogic.mk am OpenWrt-Stand von Gluon
# v2025.1.3, 5204715d14207efa956553d9d7079f6fa1aaea40]. Gluon schaltet
# TARGET_ROOTFS_INITRAMFS fuer filogic schon ein; die Zeile unten steht zur
# Sicherheit.
# Gluon v2025.1.3 kennt das Geraet nicht; ensure_device traegt es wie
# gluon-patches-hardware (Zweig v2025.1.x-next, targets/filogic-mt7986.sh)
# ein. Das OpenWrt-Profil ist am Stand oben vorhanden [geprueft].
# Bootloader-Dateien (preloader.bin, bl31-uboot.fip) liefert diese RAMpe
# nicht: sie kommen weiter von OpenWrt.
# RAM: unkritisch (MT7986, 512 MB und mehr) [abgeleitet].
# Ungetestet.
ensure_device mediatek-filogic tp-link-tl-xdr6086 tplink_tl-xdr6086
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
