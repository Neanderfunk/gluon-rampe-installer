# Aerohive HiveAP 330 / 350 (mpc85xx-p1020, P1020, 256 MB RAM, 64 MB NOR)
#
# Weg: seriell, RJ45 "console" mit RS232-Pegel (kein TTL-Adapter), 9600 8N1;
# U-Boot-Passwort "AhNf?d@ta06" oder "administrator". Aktueller Weg ab Werk
# (seit cfe79f2eb8b3c874f3d1a4441b8a60af32169974, Repartitionierung,
# compat_version 2.0):
#  1. im U-Boot owrt_boot setzen und speichern, DHCP, RAMpe laden:
#       setenv owrt_boot 'setenv bootargs "console=ttyS0,$baudrate";bootm 0xEC040000 - 0xEC000000'
#       save
#       dhcp
#       setenv bootargs console=ttyS0,$baudrate
#       tftpboot 0x1000000 192.168.1.101:<rampe>
#       bootm
#     (Commit schreibt "fw_setenv owrt_boot" in diesem U-Boot-Schritt; im
#      U-Boot heisst der Befehl setenv [abgeleitet].)
#  2. U-Boot selbst patchen, damit es beim Autoboot "run owrt_boot" ausfuehrt
#     (Shell im laufenden System, kmod-mtd-rw, strings/dd, mtd write u-boot).
#  3. sysupgrade -n. Erster Start bis ~10 min (JFFS2-Formatierung,
#     102009f3ea48a49114485fb119072850f40ae1e8).
# Quelle: OpenWrt f2b7d9dc1ca3d33f14961cf2885639f4f9e8965e (Einfuehrung) und
# cfe79f2eb8b3c874f3d1a4441b8a60af32169974 (U-Boot-Patch, neuer Weg); die
# Kurzfassung steht im DEVICE_COMPAT_MESSAGE von p1020.mk [geprueft].
# Schritt 2 braucht eine Shell - die RAMpe hat keine. Moeglich waere ein
# Vorbereitungsskript (Entwurf prepare-entwurf-aerohive-hiveap-330.sh, NICHT
# im Overlay-Patch, weil es den Bootloader schreibt). Dafuer muesste
# kmod-mtd-rw ins Image (Feed packages/kernel/mtd-rw vorhanden [geprueft]),
# z. B. per site/image-customization.lua:
#   if device({'aerohive-hiveap-330'}) then packages {'kmod-mtd-rw'} end
# Ohne Schritt 2 bootet die Community-Firmware nach dem sysupgrade nicht
# (Kernel passt nicht mehr in die alte 8-MB-Partition) [geprueft: Commit].
# Image: ...-aerohive_hiveap-330-initramfs-kernel.bin = simpleImage.hiveap-330
# als uImage none (DTB im simpleImage, kein separates .fdt mehr) [geprueft:
# p1020.mk, Commit cfe79f2: "The separate fdt download is no longer needed"].
# Kompatibilitaet: 05_fix-compat-version setzt in der RAMpe compat_version
# 2.0 fuer aerohive,hiveap-330 [geprueft: mpc85xx/base-files/etc/uci-defaults],
# das Community-sysupgrade traegt 2.0 -> sysupgrade -T passt [abgeleitet].
# RAM 256 MB: unkritisch. Werte: OpenWrt-initramfs 7627 KB [geprueft].
# Ungetestet.
ensure_target_config mpc85xx-p1020 TARGET_ROOTFS_INITRAMFS
