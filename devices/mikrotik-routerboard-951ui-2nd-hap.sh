# MikroTik RouterBOARD 951Ui-2nD (hAP) (ath79-mikrotik, QCA9531, 64 MB RAM, 16 MB NOR)
#
# Weg: RouterBOOT-Netboot (BOOTP/DHCP + TFTP), RAMpe startet im RAM, danach
# Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 5ce64e0646fcd5c4f374b4de898b591560c32e18 ("TFTP boot initramfs
# image and then perform sysupgrade. Follow common MikroTik procedure as in
# https://openwrt.org/toh/mikrotik/common") [geprueft]; Einzelschritte des
# Netboots nur im Wiki [abgeleitet].
# Image: openwrt-ath79-mikrotik-mikrotik_routerboard-951ui-2nd-initramfs-kernel.bin,
# KERNEL_INITRAMFS = kernel-bin | append-dtb | lzma | loader-kernel mit
# LOADER_TYPE elf: ELF-lzma-loader, der Kernel samt lzma-cpio entpackt
# (LZMA_TEXT_START 0x81800000, der entpackte Kernel muss darunter passen)
# [geprueft: ath79/image/common-mikrotik.mk, ath79/image/Makefile].
# TARGET_ROOTFS_INITRAMFS + TARGET_INITRAMFS_COMPRESSION_LZMA kommen aus
# Gluons mikrotik.inc [geprueft].
# Gluon liefert das initramfs hier sonst als "factory" aus und loescht es
# dabei aus openwrt/bin (copy_output.lua); darum factory = false [geprueft].
# Nach dem Flashen: nichts weiter; platform.sh loescht bei tmpfs-root
# "firmware" und schreibt dann (NOR, default_do_upgrade) [geprueft:
# ath79/mikrotik/base-files/lib/upgrade/platform.sh].
# RAM 64 MB [Commit]: knapp, aber voraussichtlich ausreichend [abgeleitet]:
# - Die RAMpe ist etwa so gross wie das OpenWrt-initramfs (einziger Datenpunkt
#   M30: RAMpe 7913 KB, OpenWrt-24.10.8-initramfs 8377 KB [geprueft: out/ und
#   Download-Liste]), und "initramfs booten, sysupgrade nach /tmp" ist genau
#   der Weg, den der Commit fuer dieses 64-MB-Geraet beschreibt.
# - Fest im RAM: entpacktes Rootfs (RAMpe-Bau filogic: 11 MB, root-mediatek
#   [geprueft]), dazu das hochgeladene sysupgrade in /tmp (Obergrenze
#   IMAGE_SIZE, siehe unten). Der eingebaute initramfs-Block wird nach dem
#   Entpacken mit dem init-Speicher freigegeben [abgeleitet].
# - Mehr als OpenWrt braucht nur der Config-Mode (uhttpd + gluon-web/Lua)
#   waehrend des Uploads; Funk ist aus.
# - Beim ersten Test "free" nach dem Upload notieren.
#   Werte: OpenWrt-initramfs 6529 KB, OpenWrt-sysupgrade 6912 KB [geprueft:
#   Download-Liste 24.10.8], IMAGE_SIZE 16256k [geprueft].
# Offen: Groessengrenze des RouterBOOT-Netboots.
# Ungetestet.
# Braucht lib.sh: ensure_device_option (Vorschlag, siehe UEBERSICHT.md).
ensure_device_option ath79-mikrotik mikrotik-routerboard-951ui-2nd-hap factory false
