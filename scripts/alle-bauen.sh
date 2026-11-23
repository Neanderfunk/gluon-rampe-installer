#!/bin/bash
#
# alle-bauen.sh - baut alle Gluon-RAMpe-Images: die build.sh-Laeufe aus
# docs/GERAETE.md ("Bau-Laeufe") plus x86-64, nacheinander, mit derselben
# Release-Kennung fuer alle Laeufe.
#
#   RAMPE_HW_PATCHES=<pfad>/gluon-patches-hardware scripts/alle-bauen.sh
#
# Umgebung:
#   RAMPE_HW_PATCHES  Pflicht: Checkout von gluon-patches-hardware, Branch
#                     v2025.1.x (Kernel-Fixes fuer alle Laeufe, siehe build.sh,
#                     und Backports fuer AP-32x und EAP620 HD)
#   RAMPE_HW_PATCHES_NEXT  Checkout desselben Repos, Branch v2025.1.x-next,
#                     nur fuer die Laeufe, die mit "next " beginnen (Backports,
#                     die es nur dort gibt, z. B. EAP683). Fehlt die Variable,
#                     zaehlen diese Laeufe als fehlgeschlagen, die anderen
#                     laufen normal.
#   GLUON_RELEASE     Kennung im Dateinamen, Default: Datum beim Start.
#                     Bleibt ueber alle Laeufe gleich, auch ueber Mitternacht.
#   BUILD             Default "./build.sh"; im Container
#                     "contrib/docker/run.sh ./build.sh"
#   GLUON_REF, JOBS   wie bei build.sh
#
# Ein fehlgeschlagener Lauf haelt die anderen nicht auf; am Ende steht, welche
# Laeufe fehlten, und der Exit-Code ist dann 1. Dauer: Stunden, also in tmux.
#
# SPDX-License-Identifier: BSD-3-Clause

set -u
cd "$(dirname "$0")/.."

: "${RAMPE_HW_PATCHES:?RAMPE_HW_PATCHES (gluon-patches-hardware, Branch v2025.1.x) setzen}"
[ -d "$RAMPE_HW_PATCHES/devices" ] || { echo "$RAMPE_HW_PATCHES/devices fehlt" >&2; exit 2; }
export RAMPE_HW_PATCHES
export GLUON_RELEASE="${GLUON_RELEASE:-$(date +%Y%m%d)}"
read -r -a BUILD <<< "${BUILD:-./build.sh}"

# Wie docs/GERAETE.md, "Bau-Laeufe". Die TUF-Geraete brauchen einen eigenen
# Lauf (TARGET_ROOTFS_INITRAMFS_SEPARATE gilt fuers ganze Target).
LAEUFE=(
	"mediatek-filogic d-link-aquila-pro-ai-m30-a1 d-link-aquila-pro-ai-m60-a1 mercusys-mr90x-v1 mercusys-mr80x-v3 asus-rt-ax52 asus-rt-ax59u xiaomi-mi-router-ax3000t cudy-tr3000-v1"
	"mediatek-filogic asus-tuf-ax4200 asus-tuf-ax6000"
	"ramips-mt7621 asus-rt-ax53u genexis-pulse-ex400 zyxel-wsm20"
	"ipq40xx-generic aruba-ap-303 aruba-ap-303h aruba-ap-365 asus-lyra-map-ac2200 zte-mf289f extreme-networks-ws-ap3915i avm-fritz-box-7530 avm-fritz-repeater-1200 avm-fritz-repeater-3000"
	"qualcommax-ipq807x netgear-wax218 xiaomi-ax3600 tp-link-eap620-hd-v1"
	"ipq806x-generic extreme-networks-ap3935 aruba-ap-32x"
	"ipq40xx-mikrotik mikrotik-hap-ac2 mikrotik-wap-ac mikrotik-sxtsq-5-ac-rbsxtsqg-5acd"
	"ath79-mikrotik mikrotik-routerboard-951ui-2nd-hap mikrotik-routerboard-mapl-2nd mikrotik-routerboard-wapr-2nd mikrotik-routerboard-wap-g-5hact2hnd"
	"ramips-mt7621 mikrotik-routerboard-750gr3"
	"lantiq-xrx200 avm-fritz-box-3390 avm-fritz-box-7362-sl avm-fritz-box-7412 avm-fritz-box-7430"
	"ath79-generic ocedo-koala ocedo-raccoon enterasys-ws-ap3705i extreme-networks-ws-ap3805i siemens-ws-ap3610 sophos-ap15 tp-link-archer-d50-v1 d-link-dir-505"
	"ath79-nand zte-mf286r zte-mf281 aerohive-hiveap-121"
	"mpc85xx-p1020 ocedo-panda enterasys-ws-ap3710i extreme-networks-ws-ap3825i aerohive-hiveap-330"
	"mpc85xx-p1010 enterasys-ws-ap3715i sophos-red-15w-rev.1"
	"ath79-nand gl.inet-gl-e750 gl.inet-gl-xe300"
	# Gruppe B aus docs/PLAN-WEITERE-RAMPEN.md: serieller Weg, RAMpe statt
	# OpenWrt-initramfs im TFTP-Schritt
	"mediatek-filogic acer-predator-connect-w6 acer-predator-connect-w6d acer-connect-vero-w6m adtran-sdg-8612 adtran-sdg-8614 adtran-sdg-8622 adtran-sdg-8632 tp-link-archer-ax80-v1 tp-link-re6000xd zyxel-ex5700-telenor"
	"next mediatek-filogic tp-link-eap683-lr tp-link-eap683-ur"
	# Gruppe A: TP-Link mit U-Boot-Teil aus der Hersteller-Firmware (Nachbau
	# nach dem Bau, devices/lib.sh; Herstellerdateien im Cache RAMPE_CACHE)
	"ramips-mt7620 tp-link-archer-c2-v1 tp-link-archer-c20-v1"
	"ramips-mt76x8 tp-link-archer-c20-v5 tp-link-archer-c50-v4 tp-link-archer-c50-v6-ca-eu-ru"
	"ipq40xx-generic linksys-mr8300-dallas"
	"ramips-mt7621 netgear-wndr3700-v5 xiaomi-mi-router-3g xiaomi-mi-router-ac2100 xiaomi-redmi-router-ac2100 d-link-dap-x1860-a1"
	"ath79-generic tp-link-archer-c60-v1 d-link-dir825b1"
	"x86-64 x86-64"
)

# Jedes Rezept in devices/ muss in genau einem Lauf stehen.
geplant=$(printf '%s\n' "${LAEUFE[@]}" | sed 's/^next //' | awk '{for (i = 2; i <= NF; i++) print $i}' | sort)
rezepte=$(find devices -name '*.sh' ! -name lib.sh -printf '%f\n' | sed 's/\.sh$//' | sort)
if [ "$geplant" != "$rezepte" ]; then
	echo "Laeufe und devices/ passen nicht zusammen:" >&2
	diff <(echo "$rezepte") <(echo "$geplant") >&2
	exit 2
fi

echo "== Gluon-RAMpe, GLUON_RELEASE=$GLUON_RELEASE, ${#LAEUFE[@]} Laeufe, $(echo "$rezepte" | wc -l) Geraete"
fehler=()
n=0
for lauf in "${LAEUFE[@]}"; do
	n=$((n + 1))
	read -r -a a <<< "$lauf"
	echo "== [$n/${#LAEUFE[@]}] $(date '+%F %T') ${a[*]}"
	if [ "${a[0]}" = next ]; then
		a=("${a[@]:1}")
		if [ -z "${RAMPE_HW_PATCHES_NEXT:-}" ] || [ ! -d "${RAMPE_HW_PATCHES_NEXT}/devices" ]; then
			echo "   RAMPE_HW_PATCHES_NEXT (gluon-patches-hardware, Branch v2025.1.x-next) fehlt - Lauf ausgelassen" >&2
			fehler+=("$lauf")
			continue
		fi
		RAMPE_HW_PATCHES="$RAMPE_HW_PATCHES_NEXT" "${BUILD[@]}" "${a[@]}" || fehler+=("$lauf")
		continue
	fi
	"${BUILD[@]}" "${a[@]}" || fehler+=("$lauf")
done

echo "== fertig $(date '+%F %T'), Images in out/images/"
if [ ${#fehler[@]} -gt 0 ]; then
	echo "== ${#fehler[@]} Lauf/Laeufe fehlgeschlagen (Logs in out/logs/):"
	printf '   %s\n' "${fehler[@]}"
	exit 1
fi
