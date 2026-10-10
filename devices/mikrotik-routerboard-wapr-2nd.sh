# MikroTik RouterBOARD wAPR-2nD (wAP R) (ath79-mikrotik, QCA9533, 64 MB RAM, 16 MB NOR)
#
# Hinweis Geraetewahl: "wAP" in der Auftragsliste ist hier der wAP R
# (mikrotik-routerboard-wapr-2nd), wie im Inventar. Den einfachen wAP
# (RBwAP-2nD) baut OpenWrt als mikrotik_routerboard-wap-2nd [geprueft:
# ath79/image/mikrotik.mk], Gluon v2025.1.3 und gluon-patches-hardware fuehren
# ihn nicht [geprueft]. Fuer den waere es ensure_device + factory false wie
# beim mAP lite.
# Weg: RouterBOOT-Netboot (BOOTP/DHCP + TFTP), RAMpe im RAM, danach
# Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 817bf0204569ca28121576c13f48186ed7b7c2ae ("TFTP boot initramfs
# image and then perform sysupgrade") [geprueft].
# Image: ...-mikrotik_routerboard-wapr-2nd-initramfs-kernel.bin (ELF-lzma-loader,
# wie hAP 951Ui) [geprueft: common-mikrotik.mk].
# Gluon liefert das initramfs sonst als "factory" aus und loescht es aus
# openwrt/bin; darum factory = false [geprueft].
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
#   Werte: OpenWrt-initramfs 6624 KB, OpenWrt-sysupgrade 7040 KB,
#   IMAGE_SIZE 16256k [geprueft].
# Ungetestet.
# Braucht lib.sh: ensure_device_option (Vorschlag, siehe UEBERSICHT.md).
ensure_device_option ath79-mikrotik mikrotik-routerboard-wapr-2nd factory false
