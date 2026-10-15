# OCEDO Raccoon (ath79-generic, AR9344 + AR9382, 128 MB RAM, 16 MB NOR)
#
# Weg: Reset-Taste beim Einschalten halten; der Bootloader holt per TFTP von
# 192.168.100.8 die Datei "raccoon-uImage-initramfs-lzma.bin" (je nach Stand der
# Hersteller-Software auch "raccoon-uimage-factory") und startet sie im RAM.
# Die Datei ist hier die RAMpe (out/images/gluon-rampe-<Datum>-ocedo-raccoon-initramfs-kernel.bin
# umbenennen). Danach Community-sysupgrade ueber die Upload-Seite. Kein
# Oeffnen, keine Konsole.
# Quelle: OpenWrt 647614803473757e3b2d93d46938afccd61a5a5d [geprueft]:
#   "Hold down the reset button while powering on the device. It will load a
#    ramdisk image named 'raccoon-uImage-initramfs-lzma.bin' from 192.168.100.8."
#   "Due to the flip-flop bootloader ... you need to set the partition the
#    bootloader is selecting ... fw_setenv bootcmd run bootcmd_1"
# Image: ...-ocedo_raccoon-initramfs-kernel.bin = uImage lzma (ath79
# Device/Default) [geprueft], passt zum erwarteten Namen "uImage-initramfs-lzma".
# Gluon fuehrt das Geraet mit factory = false, das initramfs bleibt in
# openwrt/bin und build.sh sammelt es ein [geprueft].
# Nach dem Flashen: bootcmd umstellen. OpenWrts sysupgrade tut das nicht
# [geprueft: ath79/generic/base-files/lib/upgrade/platform.sh ohne
# ocedo-Eintrag]. Vorbereitungsskript noetig: prepare.d/ocedo,raccoon
# (Vorschlag) fuehrt genau "fw_setenv bootcmd run bootcmd_1" aus;
# uboot-envtools ist ath79-DEFAULT_PACKAGES, fw_env.config fuer ocedo,raccoon
# kommt aus package/boot/uboot-envtools/files/ath79 [geprueft].
# Offen: an welche Adresse der OCEDO-Bootloader das Image laedt (nicht belegt);
# davon haengt ab, wie gross das entpackte Image sein darf.
# Kompression [abgeleitet, Abweichung von OpenWrt]: ath79 legt das Rootfs
# standardmaessig unkomprimiert in den Kernel (Config-images.in: LZMA-Default
# nur fuer ath79_mikrotik) [geprueft]. Wie gross das entpackt ist, zeigt das
# Siemens WS-AP3610, dessen initramfs unkomprimiert ausgeliefert wird:
# OpenWrt 24.10.8 23698 KB [geprueft: Download-Liste]; die anderen
# ath79-generic-Geraete teilen denselben Kernel [abgeleitet]. U-Boot entpackt
# "uImage lzma" nach KERNEL_LOADADDR 0x80060000 [geprueft: ath79/image/Makefile];
# laedt man das Image nach 0x81000000, sind darunter nur ~15.6 MB frei, und ein
# U-Boot mit kleinem CONFIG_SYS_BOOTM_LEN bricht vorher ab [abgeleitet, je
# Bootloader unbekannt]. Mit TARGET_INITRAMFS_COMPRESSION_LZMA entpackt der
# Kernel das Rootfs selbst (CONFIG_RD_LZMA wird gesetzt [geprueft:
# include/kernel-defaults.mk]), der von U-Boot zu entpackende Teil schrumpft
# auf grob Kernel + lzma-cpio, und beim Start liegt weniger doppelt im RAM.
# Gilt fuer alle Geraete dieses Targets im selben Bau; deshalb steht die
# Zeile in jedem ath79-generic-Rezept.
# RAM 128 MB: unkritisch [abgeleitet]. Werte: OpenWrt-initramfs 6033 KB;
# Neanderfunk-sysupgrade, Gluon-2023.2-Testbau 26090815sta, 6751017 Byte [geprueft].
# Ungetestet.
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
