# Gluon-RAMpe: TP-Link Archer AX80 v1 (board_name tplink,archer-ax80-v1) vor
# dem sysupgrade vorbereiten: die Bootloader-Umgebung setzen, die das
# OpenWrt-Layout braucht.
# Quelle, woertlich: OpenWrt 8b24289a5267e486abd9ccbf4b4ad82f14d545ae,
# "Installation (UART)": "After entering OpenWrt, please set / update the
# environment variables" (vier fw_setenv-Befehle), danach sysupgrade -n.
# Ergaenzt wie beim MR90X: Geraet und Partition pruefen, alle Werte in einem
# Schreibvorgang (fw_setenv -s), danach jeden Wert mit fw_printenv
# gegenlesen; Abbruch ohne Flashen bei jedem Fehler.
# Die Umgebung liegt in /dev/mtd1, 0x20000 [geprueft: uboot-envtools
# files/mediatek_filogic am OpenWrt-Stand der RAMpe]; mtd1 heisst im DTS
# u-boot-env (0x200000, 1 MB) [geprueft: mt7986a-tplink-archer-ax80-v1.dts].
#
# SPDX-License-Identifier: BSD-3-Clause

. /lib/functions.sh

board=$(cat /tmp/sysinfo/board_name 2>/dev/null)
[ "$board" = "tplink,archer-ax80-v1" ] || { echo "Fehler: falsches Geraet ($board). Nichts geschrieben."; exit 1; }
[ "$(find_mtd_index u-boot-env)" = "1" ] || { echo "Fehler: u-boot-env ist nicht mtd1. Nichts geschrieben."; exit 1; }
[ -s /etc/fw_env.config ] || { echo "Fehler: /etc/fw_env.config fehlt. Nichts geschrieben."; exit 1; }
command -v fw_setenv >/dev/null || { echo "Fehler: fw_setenv fehlt in dieser RAMpe. Nichts geschrieben."; exit 1; }

werte=/tmp/gluon-rampe-ax80-env.txt
cat > "$werte" <<'ENV'
bootargs ubi.mtd=ubi0 console=ttyS0,115200n1 loglevel=8 earlycon=uart8250,mmio32,0x11002000 init=/etc/preinit
mtdids spi-nand0=spi-nand0
mtdparts spi-nand0:2M(boot),1M(u-boot-env),50M(ubi0),50M(ubi1),8M(userconfig),4M(tp_data),8M(mali_data)
tp_boot_idx 0
ENV

echo "Bootloader-Umgebung setzen (4 Werte, OpenWrt 8b24289):"
fw_setenv -s "$werte" || { echo "Fehler: fw_setenv fehlgeschlagen."; exit 1; }

fehler=0
while read -r name wert; do
	ist=$(fw_printenv -n "$name" 2>/dev/null)
	if [ "$ist" = "$wert" ]; then
		echo "  $name: ok"
	else
		echo "  $name: FALSCH (gelesen: \"$ist\")"
		fehler=1
	fi
done < "$werte"
[ "$fehler" = 0 ] || { echo "Fehler: Umgebung nicht wie erwartet, es wird nicht geflasht."; exit 1; }
