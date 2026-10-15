# Gluon-RAMpe: gemeinsamer Teil fuer AVM FRITZ!Box 7520/7530 und FRITZ!Repeater
# 1200/3000. Vor dem ersten sysupgrade muss der OpenWrt-U-Boot nach uboot0 und
# uboot1, und die UBI-Volumes der Herstellerfirmware muessen weg. Quelle,
# woertlich: OpenWrt 95b0c07a618fe5fd93a26931152ced483bba143b (7530),
# 7f187229a8e9b7966248b1e024217e07a9fc3e50 (Repeater 1200),
# 148d29d47b1d555d0058dcc5dda450b74c4628ec (Repeater 3000), jeweils Schritt 7:
#   mtd write /path/to/uboot-fritzXXXX.bin uboot0
#   mtd write /path/to/uboot-fritzXXXX.bin uboot1
#   ubirmvol /dev/ubi0 --name=avm_filesys_0
#   ubirmvol /dev/ubi0 --name=avm_filesys_1
# Ergaenzt: alle Pruefungen vor dem ersten Schreiben, und ein schon entferntes
# Volume ist kein Fehler (zweiter Versuch nach einem Abbruch).
# Wird von den Geraeteskripten per "." eingebunden, nicht selbst ausgefuehrt.
#
# SPDX-License-Identifier: BSD-3-Clause

. /lib/functions.sh

avm_uboot_vorbereiten() {
	local ub="$1" vol mtd

	[ -s "$ub" ] || { echo "Fehler: $ub fehlt in dieser RAMpe."; return 1; }
	for vol in uboot0 uboot1 ubi; do
		[ -n "$(find_mtd_index "$vol")" ] || { echo "Fehler: Partition $vol nicht gefunden."; return 1; }
	done
	if [ ! -e /dev/ubi0 ]; then
		mtd=$(find_mtd_index ubi)
		ubiattach -m "$mtd" || { echo "Fehler: UBI auf mtd$mtd nicht verfuegbar."; return 1; }
	fi

	echo "Schreibe $ub nach uboot0 und uboot1."
	mtd write "$ub" uboot0 || { echo "Fehler beim Schreiben von uboot0."; return 1; }
	mtd write "$ub" uboot1 || { echo "Fehler beim Schreiben von uboot1."; return 1; }

	for vol in avm_filesys_0 avm_filesys_1; do
		if ubinfo /dev/ubi0 -N "$vol" >/dev/null 2>&1; then
			echo "Entferne UBI-Volume $vol."
			ubirmvol /dev/ubi0 --name="$vol" || { echo "Fehler beim Entfernen von $vol."; return 1; }
		else
			echo "UBI-Volume $vol ist nicht (mehr) da."
		fi
	done
	echo "Vorbereitung fertig."
}
