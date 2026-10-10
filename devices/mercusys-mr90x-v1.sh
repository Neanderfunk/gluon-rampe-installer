# Mercusys MR90X v1 (mediatek-filogic, MT7986B, 512 MB RAM)
#
# Weg ab Werk laut OpenWrt e4fe3097ef6a961874b66932a0ac4be18070630a und Wiki:
# SSH in die Stock-Firmware (Port 20001, Web-Passwort), Telnet-Zugang ueber
# den IPTV-Hotplug, fremdes busybox fuer ubiupdatevol, initramfs ins
# UBI-Volume "kernel", fw_setenv (u. a. tp_boot_idx 0), Neustart. Danach laeuft
# das initramfs; hier die Gluon-RAMpe statt des OpenWrt-initramfs, die das
# Community-sysupgrade per Upload einspielt (sonst scp + sysupgrade -n).
# Gebraucht wird der rohe initramfs-Kernel (out/gluon-rampe-<geraet>-initramfs-kernel.bin).
# Ungetestet. Nicht verwechseln mit dem OpenWrt-Profil mercusys_mr90x-v1-ubi
# (OpenWrt-U-Boot-Layout), das Gluon nicht baut.
ensure_target_config mediatek-filogic TARGET_ROOTFS_INITRAMFS
