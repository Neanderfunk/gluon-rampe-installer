# MikroTik wAP ac (RBwAPG-5HacD2HnD, ipq40xx) (ipq40xx-mikrotik, IPQ4018, 128 MB RAM, 16 MB NOR)
#
# Nicht verwechseln mit dem ath79-wAP-AC (RBwAPG-5HacT2HnD), siehe
# mikrotik-routerboard-wap-g-5hact2hnd.sh.
# Weg: RouterBOOT-Netboot (BOOTP/DHCP + TFTP), RAMpe startet im RAM, danach
# Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 7f54bf6fe2ac331d018cd273bb1abe04493b5457 ("Boot the initramfs
# image via TFTP, then flash the sysupgrade image using sysupgrade. Details at
# https://openwrt.org/toh/mikrotik/common") [geprueft].
# Gluon v2025.1.3 kennt das Geraet nicht (nur Neanderfunk-Patch
# gluon-patches-hardware targets/targets-ipq40xx-mikrotik.patch, Stand
# ab19bf1b46d34315a92f61974dd37f8a9ede9604); das Rezept traegt es ein
# [geprueft]. Profil mikrotik_wap-ac, DEVICE_PACKAGES
# -kmod-ath10k-ct kmod-ath10k-ct-smallbuffers [geprueft: ipq40xx/image/mikrotik.mk].
# Image: ...-mikrotik_wap-ac-initramfs-kernel.bin, ELF wie beim hAP ac2;
# TARGET_ROOTFS_INITRAMFS und LZMA kommen aus Gluons mikrotik.inc [geprueft].
# ensure_device setzt factory = false, damit Gluon das initramfs nicht als
# factory einsammelt und loescht.
# Nach dem Flashen: nichts weiter ("mtd erase firmware" bei tmpfs-root).
# RAM 128 MB: unkritisch [abgeleitet].
# Ungetestet.
ensure_device ipq40xx-mikrotik mikrotik-wap-ac mikrotik_wap-ac
