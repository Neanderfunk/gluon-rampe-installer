# Adtran (SmartRG) SDG-8612 (mediatek-filogic, MT7986), Gruppe B aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt 3aa686f8d4d89ab28e749874c4b5e82d46685f3c]:
#   UART: Bootloader mit 'st' anhalten, setenv boot_mode openwrt; saveenv,
#   run boot1 laedt das initramfs per TFTP und schreibt es, run boot2
#   startet es. Die RAMpe liegt danach im Flash, bis das sysupgrade sie
#   ersetzt.
# Danach im Browser http://192.168.1.1 das Community-sysupgrade hochladen,
# statt es per scp zu kopieren und sysupgrade -n aufzurufen.
# Datei: RAMpe-initramfs in openwrt.612 umbenennen (interne Produktnummer).
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
ensure_device mediatek-filogic adtran-sdg-8612 smartrg_sdg-8612
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
