# MikroTik hAP ac2 (RBD52G-5HacD2HnD) (ipq40xx-mikrotik, IPQ4018, 128 MB RAM, 16 MB NOR)
#
# Weg: RouterBOOT-Netboot. Rechner mit BOOTP/DHCP- und TFTP-Server (z. B.
# dnsmasq), Geraet holt die Datei per Netboot und startet sie im RAM; hier
# die Gluon-RAMpe statt des OpenWrt-initramfs. Danach Community-sysupgrade
# ueber die Upload-Seite (192.168.1.1). Einzelschritte des Netboots (Reset
# halten, Port, RouterOS-Version) stehen nicht im Commit, nur der Verweis auf
# openwrt.org/toh/mikrotik/common [abgeleitet].
# Quelle: OpenWrt faea7becafc634dc882f0ad8f9388862ccd5bd0d ("Boot the initramfs
# image via TFTP and then flash the sysupgrade image using sysupgrade -n")
# [geprueft].
# Image: openwrt-ipq40xx-mikrotik-mikrotik_hap-ac2-initramfs-kernel.bin =
# KERNEL (kernel-bin | append-dtb-elf), also ELF mit angehaengtem DTB; das
# Rootfs steckt lzma-komprimiert im Kernel (mikrotik.inc setzt
# TARGET_INITRAMFS_COMPRESSION_LZMA) [geprueft: ipq40xx/image/mikrotik.mk,
# Gluon targets/mikrotik.inc]. build.sh legt es als
# out/images/gluon-rampe-<Datum>-mikrotik-hap-ac2-initramfs-kernel.bin ab.
# Gluon (mikrotik.inc) liefert genau dieses initramfs sonst als "factory"
# aus: copy_output.lua kopiert es nach output/images/factory/ und loescht
# es in openwrt/bin, build.sh faende dann nichts. Darum factory = false
# [geprueft: scripts/copy_output.lua, Simulation target_lib.lua]. Gluons
# eigenes "factory" ist ein Community-Gluon als initramfs ohne
# 91_installer_initramfs, startet also nicht im Config-Mode [abgeleitet aus
# NOTIZEN.md-Befund, auf MikroTik nicht getestet].
# Nach dem Flashen: platform.sh loescht bei tmpfs-root die Partition
# firmware selbst ("mtd erase firmware"), keine Vorbereitung noetig
# [geprueft: target/linux/ipq40xx/base-files/lib/upgrade/platform.sh,
# mikrotik,hap-ac2].
# RAM 128 MB: unkritisch [abgeleitet].
# Offen: Groessengrenze des RouterBOOT-Netboots fuer ELF-Dateien (nicht belegt).
# Ungetestet.
# Braucht lib.sh: ensure_device_option (Vorschlag, siehe UEBERSICHT.md).
ensure_device_option ipq40xx-mikrotik mikrotik-hap-ac2 factory false
