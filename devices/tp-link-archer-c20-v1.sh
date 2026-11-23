# TP-Link Archer C20 v1 (ramips-mt7620), Gruppe A aus docs/PLAN-WEITERE-RAMPEN.md
#
# Weg [geprueft: OpenWrt 161a3be5adb21135eb75da81247fa5e04b6ea676 (dd mit bs=512 count=256 skip=1, gleiche Bytes wie beim C2 v1)]:
#   TFTP-Recovery: Reset beim Einschalten 6-7 s halten, Datei
#   ArcherC20V1_tp_recovery.bin von 192.168.0.66.
# Statt OpenWrt-sysupgrade steckt hier das sysupgrade der RAMpe hinter dem
# U-Boot-Teil. Die Recovery schreibt alles in den Flash, der Router startet
# danach die RAMpe von dort (squashfs, Config-Mode beim ersten Start); dann
# im Browser http://192.168.1.1 das Community-sysupgrade hochladen.
# Ergebnis: <praefix>-tp-recovery.bin, umbenennen in ArcherC20V1_tp_recovery.bin.
#
# Herstellerdatei: EU-Firmware mit up_boot (160427).
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
nach_dem_bau tp-link-archer-c20-v1 nachbau_tplink_uboot_tftp \
	'https://static.tp-link.com/res/down/soft/Archer_C20(EU)_V1_160427.zip' \
	c4d783d52d10a03beb0040acf9196cb853e1ea6f0dab0646e46758e1fa209a77 \
	'Archer_C20v1_0.9.1_4.0_up_boot(160427)_2016-04-27_13.53.59.bin' \
	d2c9f935ec2321c8aa633a1641400abe685b816336480b3fd8629c11c707aace 7808
