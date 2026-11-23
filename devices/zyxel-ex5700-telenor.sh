# Zyxel EX5700 (Telenor) (mediatek-filogic, MT7986), Gruppe B aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt 6cc14bf66aa924962b926ea9702b6153ae418a7d]:
#   UART: Autoboot mit ESC abbrechen, initramfs per TFTP (Server
#   192.168.1.2, Datei C0A80101.img) laden und starten.
# Danach im Browser http://192.168.1.1 das Community-sysupgrade hochladen,
# statt es per scp zu kopieren und sysupgrade -n aufzurufen.
# Datei: RAMpe-initramfs in C0A80101.img umbenennen.
# Vorbereitungsskript: keins noetig.
#
# Image: OpenWrts Standard fuer filogic, KERNEL_INITRAMFS = kernel-bin | lzma |
# fit lzma <dtb> with-initrd | pad-to 64k, Datei ...-initramfs-kernel.bin
# [geprueft: target/linux/mediatek/image/Makefile und filogic.mk am
# OpenWrt-Stand von Gluon v2025.1.3, 5204715d14207efa956553d9d7079f6fa1aaea40].
# Gluon schaltet TARGET_ROOTFS_INITRAMFS fuer filogic schon ein; die Zeile
# unten steht zur Sicherheit.
# Gluon v2025.1.3 kennt das Geraet nicht; ensure_device traegt es wie
# gluon-patches-hardware (Zweig v2025.1.x-next, targets/filogic-mt7986.sh)
# ein. Das OpenWrt-Profil ist am Stand oben vorhanden [geprueft].
# RAM: unkritisch (MT7986, 512 MB und mehr) [abgeleitet].
# Ungetestet.
ensure_device mediatek-filogic zyxel-ex5700-telenor zyxel_ex5700-telenor
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
