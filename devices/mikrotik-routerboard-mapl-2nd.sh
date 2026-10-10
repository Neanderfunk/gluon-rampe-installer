# MikroTik RouterBOARD mAPL-2nD (mAP lite) (ath79-mikrotik, QCA9533, 64 MB RAM, 16 MB NOR)
#
# Weg: RouterBOOT-Netboot (BOOTP/DHCP + TFTP), RAMpe im RAM, danach
# Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt eb38af788180d624e5b37aa5db1fe3766b138dc8 ("TFTP boot initramfs
# image and then perform sysupgrade") [geprueft].
# Gluon v2025.1.3 kennt das Geraet nicht; Neanderfunk traegt es per
# gluon-patches-hardware ein (targets/targets-ath79-mikrotik.patch,
# ab19bf1b46d34315a92f61974dd37f8a9ede9604, mit Alias
# mikrotik-routerboard-map-lite und factory = false) [geprueft]. Das Rezept
# traegt es fuer diesen Bau ein; ensure_device setzt factory = false, damit
# mikrotik.inc das initramfs nicht als factory einsammelt und loescht.
# Image: ...-mikrotik_routerboard-mapl-2nd-initramfs-kernel.bin (ELF-lzma-loader)
# [geprueft: common-mikrotik.mk].
# Nach dem Flashen: nichts weiter ("mtd erase firmware" bei tmpfs-root).
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
#   Werte: OpenWrt-initramfs 6529 KB, OpenWrt-sysupgrade 6912 KB,
#   IMAGE_SIZE 16256k [geprueft].
# Ungetestet.
ensure_device ath79-mikrotik mikrotik-routerboard-mapl-2nd mikrotik_routerboard-mapl-2nd
