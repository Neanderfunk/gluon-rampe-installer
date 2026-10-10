# Sophos AP15 (ath79-generic, QCA9557, RAM nicht im Commit genannt, 16 MB NOR)
#
# Weg: Gehaeuse oeffnen, UART-Header (115200 8N1), Autoboot abbrechen
# (Prompt "ath> "), RAMpe per TFTP laden und starten:
#   tftpboot 0x81000000 boot.bin
#   bootm 0x81000000
# TFTP-Server 192.168.99.8/24, Dateiname frei (Beispiel boot.bin).
# Danach Community-sysupgrade ueber die Upload-Seite (der Commit nimmt auch
# dort die Web-Oberflaeche).
# Quelle: OpenWrt 0dc58214896aacf67a3759495d70e2b4e9c160d8 [geprueft]; der
# XG-Appliance-Weg der AP55/AP100 "should work too" [ungeprueft im Commit].
# Gluon v2025.1.3: broken = true ("no button and no external console port")
# [geprueft]. Ohne Eingriff kennt Gluon das Geraet im Bau nicht ("unknown
# devices given", geprueft per Simulation von target_lib.lua). Das Rezept
# setzt broken = false nur in diesem Bau (Alternative: BROKEN=1 an make).
# Image: ...-sophos_ap15-initramfs-kernel.bin = uImage lzma [geprueft].
# Ladeadresse 0x81000000: siehe Kompression unten.
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
# Nach dem Flashen: nichts weiter. fw_env.config fuer sophos,ap15 vorhanden
# [geprueft], wird aber nicht gebraucht.
# RAM: offen (im Commit nicht genannt). Werte: OpenWrt-initramfs 6033 KB
# [geprueft].
# Ungetestet.
# Braucht lib.sh: ensure_device_option (Vorschlag, siehe UEBERSICHT.md).
ensure_device_option ath79-generic sophos-ap15 broken false
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
