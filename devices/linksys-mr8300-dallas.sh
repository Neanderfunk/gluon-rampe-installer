# Linksys MR8300 "Dallas" (ipq40xx-generic, IPQ4019, 512 MB RAM, NAND)
#
# Dauerhafte RAMpe statt OpenWrt-Zwischenschritt: Gluon setzt factory = false
# (ohne Begruendung im Gluon-Commit d04ea647) [geprueft: Inventar], die
# Linksys-UI (https://192.168.1.1/fwupdate.html) nimmt aber ein factory-Image
# [geprueft: Inventar]. Danach Config-Mode der RAMpe, Community-sysupgrade
# hochladen [abgeleitet]. Dual-Boot: wie bei OpenWrt landet das Image in der
# gerade nicht aktiven Haelfte [abgeleitet].
# Image: IMAGE/factory.bin := append-kernel | pad-to KERNEL_SIZE | append-ubi |
# linksys-image type=MR8300 (ipq40xx/image/generic.mk, Device/linksys_mr8300,
# Pin 5204715d14207efa956553d9d7079f6fa1aaea40) [geprueft].
# Ungetestet.
ensure_extra_image ipq40xx-generic linksys-mr8300-dallas -squashfs-factory -factory .bin
