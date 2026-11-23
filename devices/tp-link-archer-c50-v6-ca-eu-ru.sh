# TP-Link Archer C50 v6 (CA/EU/RU) (ramips-mt76x8), Gruppe A aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt e9ac1b19e0f3d383ab83373c261bfb5527a29521 (Weg aus 86e7353b)]:
#   wie Archer C20 v5: boot.bin ueber Weboberflaeche oder Web-Recovery,
#   tp_recovery.bin per TFTP.
# Statt OpenWrt-sysupgrade steckt hier das sysupgrade der RAMpe hinter dem
# U-Boot-Teil. Die Recovery schreibt alles in den Flash, der Router startet
# danach die RAMpe von dort (squashfs, Config-Mode beim ersten Start); dann
# im Browser http://192.168.1.1 das Community-sysupgrade hochladen.
# Ergebnis: <praefix>-boot.bin und <praefix>-tp-recovery.bin.
#
# Herstellerdatei: nur EU: Download von tp-link.com/de (up_boot, 250119); RU-Geraete brauchen die RU-Firmware und bekommen kein Image.
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
nach_dem_bau tp-link-archer-c50-v6-ca-eu-ru nachbau_tplink_split_uboot \
	'https://static.tp-link.com/upload/firmware/2025/202501/20250121/Archer_C50v6_0.9.1_0.5_up_boot%5B250119-rel51087%5D.zip' \
	cd47c9b8f0c259cdd3ae443fb853044c30efeb73d462e3fb0f2bcff979143dcc \
	'Archer_C50v6_0.9.1_0.5_up_boot[250119-rel51087]_2025-01-19_14.34.29.bin' \
	e3b7f65b268b40a0221f33b79ac2b8e1f6355c969960ad453a37c2e28fcef410 7616
