# TP-Link Archer C50 v4 (ramips-mt76x8), Gruppe A aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt 01dcd574a24864c10a9c4df4304a3ce0da5c11a9 (Weg aus 86e7353b)]:
#   wie Archer C20 v5: boot.bin ueber Weboberflaeche oder Web-Recovery,
#   tp_recovery.bin per TFTP.
# Statt OpenWrt-sysupgrade steckt hier das sysupgrade der RAMpe hinter dem
# U-Boot-Teil. Die Recovery schreibt alles in den Flash, der Router startet
# danach die RAMpe von dort (squashfs, Config-Mode beim ersten Start); dann
# im Browser http://192.168.1.1 das Community-sysupgrade hochladen.
# Ergebnis: <praefix>-boot.bin und <praefix>-tp-recovery.bin.
#
# Herstellerdatei: EU-Download von tp-link.com/de (up_boot, 250117); laut OpenWrt-Wiki gleiche Hardware fuer alle Regionen. Dieselbe Datei steht als stock_getestet in den Geraetedaten.
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
nach_dem_bau tp-link-archer-c50-v4 nachbau_tplink_split_uboot \
	'https://static.tp-link.com/upload/firmware/2025/202501/20250121/Archer_C50v4_0.9.1_0.2_up_boot%5B250117-rel34867%5D.zip' \
	8d62cddf8118088286f84962f9f68684f0212892985063ebe696756631249de8 \
	'Archer_C50v4_0.9.1_0.2_up_boot[250117-rel34867].bin' \
	daa0666880e13aa8fb1296f7d207c151dca59a9a6f502ac3d3e9afed331ef5cf 7616
