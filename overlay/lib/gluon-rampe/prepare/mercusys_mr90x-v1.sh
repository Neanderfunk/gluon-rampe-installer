# Gluon-RAMpe: Mercusys MR90X v1 (board_name mercusys,mr90x-v1) vor dem
# sysupgrade vorbereiten: die Bootloader-Umgebung setzen, die das
# OpenWrt-Layout braucht (u. a. tp_boot_idx 0, mtdparts mit ubi0/ubi1).
# Quelle, woertlich: OpenWrt e4fe3097ef6a961874b66932a0ac4be18070630a,
# "Installation (UART)" Schritt 4 und "Installation (without UART)"
# Schritt 13 (dieselben 13 Werte); OpenWrt-Wiki toh:mercusys:mr90x_v1.
# Auf dem Weg ohne UART setzt man sie dort in der Stock-Shell; die RAMpe
# setzt sie hier noch einmal, dann ist das egal.
# Ergaenzt: alle Werte in einem Schreibvorgang (fw_setenv -s), danach jeden
# Wert mit fw_printenv gegenlesen; Abbruch ohne Flashen bei jedem Fehler.
# Die Umgebung liegt in der Partition u-boot-env, 0x20000 [geprueft:
# uboot-envtools files/mediatek_filogic am OpenWrt-Stand der RAMpe].
#
# SPDX-License-Identifier: BSD-3-Clause

. /lib/functions.sh

werte=/tmp/gluon-rampe-mr90x-env.txt
cat > "$werte" <<'ENV'
baudrate 115200
bootargs ubi.mtd=ubi0 console=ttyS0,115200n1 loglevel=8 earlycon=uart8250,mmio32,0x11002000 init=/etc/preinit
fdtcontroladdr 5ffc0e70
ipaddr 192.168.1.1
loadaddr 0x46000000
mtdids spi-nand0=spi-nand0
mtdparts spi-nand0:2M(boot),1M(u-boot-env),50M(ubi0),50M(ubi1),8M(userconfig),4M(tp_data)
netmask 255.255.255.0
serverip 192.168.1.2
stderr serial@11002000
stdin serial@11002000
stdout serial@11002000
tp_boot_idx 0
ENV

[ -n "$(find_mtd_index u-boot-env)" ] || { echo "Fehler: Partition u-boot-env nicht gefunden. Nichts geschrieben."; exit 1; }
[ -s /etc/fw_env.config ] || { echo "Fehler: /etc/fw_env.config fehlt. Nichts geschrieben."; exit 1; }
command -v fw_setenv >/dev/null || { echo "Fehler: fw_setenv fehlt in dieser RAMpe. Nichts geschrieben."; exit 1; }

echo "Bootloader-Umgebung setzen (13 Werte, OpenWrt e4fe3097):"
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
