# TP-Link Archer C60 v1 (ath79-generic, QCA9561, 64 MB RAM, 8 MB NOR)
#
# Nur ueber die serielle Konsole: OpenWrt 24.10.8 liefert kein factory, Gluon
# setzt factory = false; TP-Link-Web und -TFTP nehmen nur safeloader-factory
# [geprueft: Inventar]. Bisheriger UART-Weg: sysupgrade aus U-Boot nach
# 0x9f020000 schreiben [geprueft: Inventar]. Mit der RAMpe stattdessen:
# U-Boot anhalten, RAMpe-initramfs per TFTP in den RAM laden und starten,
# Community-sysupgrade ueber die Upload-Seite [abgeleitet].
# RAM 64 MB: knapp fuer ein initramfs mit Upload [abgeleitet], Groesse beim
# Bau pruefen.
# Ungetestet.
ensure_target_config ath79-generic TARGET_ROOTFS_INITRAMFS
ensure_target_config ath79-generic TARGET_INITRAMFS_COMPRESSION_LZMA
