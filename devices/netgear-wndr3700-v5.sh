# NETGEAR WNDR3700 v5 (ramips-mt7621, 128 MB RAM, 16 MB NOR)
#
# Dauerhafte RAMpe statt OpenWrt-Zwischenschritt: OpenWrt baut ein
# Sercomm-factory.img, Gluon setzt factory = false und broken = true
# ("untested") [geprueft].
# Weg: factory.img per nmrpflash, danach Gluon-sysupgrade [geprueft:
# Inventar]; hier: RAMpe-factory.img per nmrpflash, Config-Mode der RAMpe,
# Community-sysupgrade hochladen [abgeleitet].
# Image: Device/netgear_sercomm_nor (ramips/image/Makefile, Pin 5204715d14207efa956553d9d7079f6fa1aaea40):
# IMAGES += factory.img, pad-extra SERCOMM_PAD | ... | sercom-footer | zip |
# sercom-seal [geprueft].
# Ungetestet.
ensure_device_option ramips-mt7621 netgear-wndr3700-v5 broken false
ensure_extra_image ramips-mt7621 netgear-wndr3700-v5 -squashfs-factory -factory .img
