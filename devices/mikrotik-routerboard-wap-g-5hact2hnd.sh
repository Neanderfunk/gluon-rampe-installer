# MikroTik RouterBOARD wAP G-5HacT2HnD (wAP AC, ath79) (ath79-mikrotik, QCA9556 + QCA9880, 64 MB RAM, 16 MB NOR)
#
# Nicht verwechseln mit dem ipq40xx-wAP-ac (mikrotik-wap-ac.sh).
# Weg: RouterBOOT-Netboot (BOOTP/DHCP + TFTP), RAMpe im RAM, danach
# Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 6aaa5ce2c5138877e0f0504c3bd536b40e9af928 (Commit nennt den Weg
# nicht ausdruecklich, er fuehrt das gemeinsame MikroTik-Rezept
# common-mikrotik.mk ein; Netboot-Weg aus den Geschwister-Commits und
# openwrt.org/toh/mikrotik/common [abgeleitet]).
# Gluon v2025.1.3 kennt das Geraet nicht; gluon-patches-hardware
# (targets/targets-ath79-mikrotik.patch, ab19bf1b46d34315a92f61974dd37f8a9ede9604)
# traegt es mit factory = false ein [geprueft]. Das Rezept traegt es fuer
# diesen Bau ein.
# Image: ...-mikrotik_routerboard-wap-g-5hact2hnd-initramfs-kernel.bin
# (ELF-lzma-loader) [geprueft].
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
#   Zusaetzlich laedt ath10k (QCA9880, ath10k-ct-smallbuffers) beim Start
#   seine Firmware, auch wenn die Radios aus sind [abgeleitet]; das ist
#   unter den vier ath79-MikroTik der knappste Fall.
#   Werte: OpenWrt-initramfs 6877 KB, OpenWrt-sysupgrade 7296 KB,
#   IMAGE_SIZE 16256k [geprueft].
# Ungetestet.
ensure_device ath79-mikrotik mikrotik-routerboard-wap-g-5hact2hnd mikrotik_routerboard-wap-g-5hact2hnd
