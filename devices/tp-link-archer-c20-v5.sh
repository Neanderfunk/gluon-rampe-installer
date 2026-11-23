# TP-Link Archer C20 v5 (ramips-mt76x8), Gruppe A aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt 86e7353bff2a5de257de8ec62e782f016eed143c]:
#   boot.bin ueber die TP-Link-Weboberflaeche oder die Web-Recovery
#   (192.168.0.1), oder tp_recovery.bin per TFTP von 192.168.0.66 mit
#   Reset beim Einschalten.
# Statt OpenWrt-sysupgrade steckt hier das sysupgrade der RAMpe hinter dem
# U-Boot-Teil. Die Recovery schreibt alles in den Flash, der Router startet
# danach die RAMpe von dort (squashfs, Config-Mode beim ersten Start); dann
# im Browser http://192.168.1.1 das Community-sysupgrade hochladen.
# Ergebnis: <praefix>-boot.bin (Weboberflaeche) und <praefix>-tp-recovery.bin (TFTP, umbenennen in tp_recovery.bin).
#
# Herstellerdatei: nur EU: Download von tp-link.com/de (up_boot, 241231). Der U-Boot-Teil muss zur Region passen [abgeleitet: Wiki C20 v5]; andere Regionen bekommen kein Image.
# Im Bauschritt geholt (hersteller_datei, Cache ausserhalb des Repos),
# SHA256 von ZIP und .bin fest; geprueft am 23.11.2026: an Offset 512 liegt
# ein U-Boot 1.1.3. Den Byte-Vergleich mit den Befehlen der Anleitung
# macht test/nachbau-tplink.sh.
#
# Groesse: sysupgrade hoechstens IMAGE_SIZE 7616k [geprueft: ramips/image/mt76x8.mk
# am OpenWrt-Stand von Gluon v2025.1.3]; das ist genau der Platz hinter dem
# U-Boot-Teil in der Herstellerdatei.
# RAM 64 MB: ob die RAMpe neben dem hochgeladenen sysupgrade in den RAM
# passt, ist am Geraet zu pruefen [offen].
# Gluon baut das Geraet schon (factory = false), nur das sysupgrade.
# Ungetestet.
nach_dem_bau tp-link-archer-c20-v5 nachbau_tplink_split_uboot \
	'https://static.tp-link.com/upload/firmware/2025/202501/20250121/Archer_C20v5_0.9.1_4.17_up_boot%5B241231-rel54986%5D.zip' \
	5460d28a016b8bb0e89e9abef6108d296efb96580c1f2c0acf25c823af90eff8 \
	'Archer_C20v5_0.9.1_4.17_up_boot[241231-rel54986]_2025-01-05_16.09.53.bin' \
	46740eba05dfa74756d138946b39a9f9c3a308f84c475c3a71d3e76756f9f556 7616
