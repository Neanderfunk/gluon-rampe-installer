# Gluon-RAMpe: gemeinsamer Teil fuer Aruba AP-303, AP-303H und AP-365 (und
# ihre Instant-On-Aliase AP11, AP11D, AP17). Vor dem ersten sysupgrade muss
# die UBI-Partition der Herstellerfirmware neu formatiert werden. Quelle,
# woertlich: OpenWrt 102c8c55f217606cdbdc9a449667e034676b3e75 (AP-303,
# "ubidetach -p /dev/mtd1; ubiformat /dev/mtd1", dann "sysupgrade -n"), fuer
# AP-303H mit /dev/mtd16, fuer AP-365 mit /dev/mtd1 (siehe devices/).
# Ergaenzt: Partition ueber ihr Label "ubi" statt fester mtd-Nummer (das
# Label nutzt auch das sysupgrade, CI_UBIPART), ubiformat ohne Rueckfrage
# (-y), ein nicht angehaengtes UBI ist kein Fehler.
# Wird von den Geraeteskripten per "." eingebunden, nicht selbst ausgefuehrt.
#
# SPDX-License-Identifier: BSD-3-Clause

. /lib/functions.sh

aruba_ubi_vorbereiten() {
	local mtd

	mtd=$(find_mtd_index ubi)
	[ -n "$mtd" ] || { echo "Fehler: Partition ubi nicht gefunden."; return 1; }
	command -v ubiformat >/dev/null || { echo "Fehler: ubiformat fehlt in dieser RAMpe."; return 1; }
	ubidetach -p "/dev/mtd$mtd" 2>/dev/null || true
	echo "ubiformat /dev/mtd$mtd"
	ubiformat "/dev/mtd$mtd" -y || { echo "Fehler: ubiformat /dev/mtd$mtd fehlgeschlagen."; return 1; }
}
