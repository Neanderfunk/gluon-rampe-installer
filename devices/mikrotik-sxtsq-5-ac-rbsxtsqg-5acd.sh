# MikroTik SXTsq 5 ac (RBSXTsqG-5acD), Alias DISC Lite5 ac (mikrotik-discg-5acd)
# (ipq40xx-mikrotik, IPQ4018, 256 MB RAM laut Commit, 16 MB NOR)
#
# Weg: RouterBOOT-Netboot (BOOTP/DHCP + TFTP), RAMpe startet im RAM, danach
# Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt d1f1e5269ed992e6fc30d575b43b0913c9e58ca2 ("Boot via TFTP the
# initramfs image. Then, upload a sysupgrade image via SSH and flash it
# normally") [geprueft].
# DISC: in Gluon nur Alias dieses Geraets [geprueft: targets/ipq40xx-mikrotik].
# Ein eigenes Rezept mikrotik-discg-5acd.sh geht nicht: build.sh gibt den
# Namen als GLUON_DEVICES weiter, target_lib.lua kennt Aliasse dort nicht
# ("unknown devices given") [geprueft: Simulation]. Fuer den DISC dieses
# Image nehmen; das Community-sysupgrade gibt es unter dem Alias-Namen.
# Ob der DISC dieselbe RAM-Ausstattung hat: offen.
# Image: ...-mikrotik_sxtsq-5-ac-initramfs-kernel.bin (ELF, lzma-cpio).
# Gluon setzt hier schon factory = false, also bleibt der rohe Kernel in
# openwrt/bin liegen; kein Eingriff am device(...) noetig [geprueft].
# TARGET_ROOTFS_INITRAMFS setzt mikrotik.inc fuers ganze Target [geprueft].
# Nach dem Flashen: nichts weiter.
# Ungetestet.
# Kein Eingriff noetig: mikrotik.inc setzt TARGET_ROOTFS_INITRAMFS schon,
# Gluon setzt factory = false schon. Die Zeile ist nur Rueckversicherung.
ensure_target_config ipq40xx-mikrotik TARGET_ROOTFS_INITRAMFS
