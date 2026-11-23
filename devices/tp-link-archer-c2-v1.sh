# TP-Link Archer C2 v1 (ramips-mt7620), Gruppe A aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt 8375623a064037bbdd914bd9e7529eefa7172560]:
#   TFTP-Recovery: TFTP-Server auf 192.168.0.66, Datei
#   ArcherC2V1_tp_recovery.bin, WPS/Reset beim Einschalten 10 s halten.
#   Ueberschreibt die Bootloader-Partition; bis zu 20-25 min.
# Statt OpenWrt-sysupgrade steckt hier das sysupgrade der RAMpe hinter dem
# U-Boot-Teil. Die Recovery schreibt alles in den Flash, der Router startet
# danach die RAMpe von dort (squashfs, Config-Mode beim ersten Start); dann
# im Browser http://192.168.1.1 das Community-sysupgrade hochladen.
# Ergebnis: <praefix>-tp-recovery.bin, umbenennen in ArcherC2V1_tp_recovery.bin.
#
# Herstellerdatei: EU-Firmware von tp-link.com/en (neueste mit up_boot, 170207).
# Im Bauschritt geholt (hersteller_datei, Cache ausserhalb des Repos),
# SHA256 von ZIP und .bin fest; geprueft am 23.11.2026: an Offset 512 liegt
# ein U-Boot 1.1.3. Den Byte-Vergleich mit den Befehlen der Anleitung
# macht test/nachbau-tplink.sh.
#
# Groesse: sysupgrade hoechstens IMAGE_SIZE 7808k [geprueft: ramips/image/mt7620.mk
# am OpenWrt-Stand von Gluon v2025.1.3]; das ist genau der Platz hinter dem
# U-Boot-Teil in der Herstellerdatei.
# RAM 64 MB: ob die RAMpe neben dem hochgeladenen sysupgrade in den RAM
# passt, ist am Geraet zu pruefen [offen].
# Gluon baut das Geraet schon (factory = false), nur das sysupgrade.
# Ungetestet.
nach_dem_bau tp-link-archer-c2-v1 nachbau_tplink_uboot_tftp \
	'https://static.tp-link.com/Archer%20C2(EU)_V1_170207.zip' \
	01cea759f175b7ac8024df3fb9cba53c5665ab69963a04b3eacb2caaf5e3b64d \
	'Archer_C2v1_0.9.1_5.0_up_boot(170207)_2017-02-07_14.16.09.bin' \
	9362520ef285dafbbb51638fc86087eafd78773ec27fe699c05fd19a0e367bc5 7808
