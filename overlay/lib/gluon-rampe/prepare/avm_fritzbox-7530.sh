# Gluon-RAMpe: FRITZ!Box 7530 und 7520 (ein board_name, ein Image) vor dem
# sysupgrade vorbereiten, siehe avm-uboot.sh.
#
# Beide brauchen einen eigenen U-Boot. Die Quelltexte unterscheiden sich in
# der Revision im Devicetree (7530: "236", 7520: "247") und im Ort der
# EVA-Konfiguration (0x2BD800 bzw. 0x2BE800) [geprueft:
# chunkeey/FritzBox-4040-UBOOT @9d89013f, include/configs/fritz75x0.h und
# fritz/fritz75x0.dts]. Ausgewaehlt wird deshalb nach der HWRevision der Box
# aus dem TFFS (fritz_tffs_nand -b wie in OpenWrts board.d/02_network fuer
# macdsl); alles andere als 236 oder 247 bricht ab, ohne zu schreiben.
# OFFEN: Eine per HWRevision zur 7530 umgestellte 7520 bekaeme den
# 7530-U-Boot; ob dessen EVA-Offset zu ihrem Urlader passt, ist nicht belegt.
#
# SPDX-License-Identifier: BSD-3-Clause

. /lib/gluon-rampe/prepare/avm-uboot.sh

tffs=$(find_mtd_chardev nand-tffs)
[ -n "$tffs" ] || { echo "Fehler: Partition nand-tffs nicht gefunden."; exit 1; }
rev=$(fritz_tffs_nand -b -d "$tffs" -n HWRevision 2>/dev/null)
case "$rev" in
	236) modell=7530 ;;
	247) modell=7520 ;;
	*)
		echo "Fehler: HWRevision \"$rev\" ist weder 236 (7530) noch 247 (7520)."
		echo "Nichts geschrieben."
		exit 1
		;;
esac
echo "HWRevision $rev: FRITZ!Box $modell."
avm_uboot_vorbereiten "/lib/gluon-rampe/uboot/uboot-fritz$modell.bin"
