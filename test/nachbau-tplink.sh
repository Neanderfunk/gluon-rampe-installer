#!/bin/bash
#
# nachbau-tplink.sh - prueft den Nachbau nach dem Bau (devices/lib.sh) fuer
# die TP-Link-Geraete der Gruppe A und die ZTE MF286R, ohne Gluon-Bau.
#
#   test/nachbau-tplink.sh
#
# Je Rezept: Herstellerdatei ueber hersteller_datei holen (Download, beide
# SHA256), den Nachbau mit einem Platzhalter-sysupgrade bzw. -initramfs
# (Zufallsbytes) laufen lassen und das Ergebnis Byte fuer Byte mit dem
# vergleichen, was die Befehle aus den OpenWrt-Commits von Hand erzeugen.
# Die Befehle stehen hier ein zweites Mal, unabhaengig von devices/lib.sh,
# woertlich aus den Commits.
# Dazu: ein zu grosses sysupgrade muss abgelehnt werden, eine falsche
# Pruefsumme ebenso.
#
# Braucht Netz (tp-link.com) beim ersten Lauf; danach aus dem Cache
# (RAMPE_CACHE, Default ~/.cache/gluon-rampe/hersteller).
#
# SPDX-License-Identifier: BSD-3-Clause

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# Die Rezepte erwarten GLUON_DIR/RAMPE_SITEDIR nicht, solange sie nur
# nach_dem_bau aufrufen.
# shellcheck source=../devices/lib.sh
. "$ROOT/devices/lib.sh"
for d in tp-link-archer-c2-v1 tp-link-archer-c20-v1 tp-link-archer-c20-v5 \
         tp-link-archer-c50-v4 tp-link-archer-c50-v6-ca-eu-ru; do
	# shellcheck source=/dev/null
	. "$ROOT/devices/$d.sh" >/dev/null
done
# Aus zte-mf286r.sh nur die nach_dem_bau-Zeile: der Rest braucht GLUON_DIR.
eval "$(grep '^nach_dem_bau zte-mf286r ' "$ROOT/devices/zte-mf286r.sh")"

fehler=0
ok () { echo "  ok: $*"; }
nok () { echo "  FEHLER: $*"; fehler=1; }

# Platzhalter: 5 MB Zufall als "sysupgrade", 7 MB als "initramfs"
head -c 5242880 /dev/urandom > "$W/sysupgrade.bin"
head -c 7340032 /dev/urandom > "$W/initramfs.bin"

lauf () {
	local d="$1"
	mkdir -p "$W/out-$d"
	( RAMPE_GERAET="$d"; RAMPE_SYSUPGRADE="$2"; RAMPE_INITRAMFS="$W/initramfs.bin"
	  RAMPE_ZIEL="$W/out-$d"; RAMPE_PRAEFIX="gluon-rampe-test-$d"
	  eval "${RAMPE_NACHBAU[$d]}" )
}

stock_von () {
	# Argumente 1-4 der nach_dem_bau-Zeile (url, zip-sum, mitglied, bin-sum)
	local -a a
	eval "a=(${RAMPE_NACHBAU[$1]})"
	hersteller_datei "${a[1]}" "${a[2]}" "${a[3]}" "${a[4]}"
}

for d in tp-link-archer-c2-v1 tp-link-archer-c20-v1; do
	echo "== $d"
	lauf "$d" "$W/sysupgrade.bin" >/dev/null || { nok "Nachbau scheitert"; continue; }
	stock=$(stock_von "$d")
	h="$W/hand-$d"; mkdir -p "$h"
	if [ "$d" = tp-link-archer-c2-v1 ]; then
		# OpenWrt 8375623a
		dd if="$stock" of="$h/c2v1_uboot.bin" bs=1 skip=512 count=131072 status=none
		cat "$h/c2v1_uboot.bin" "$W/sysupgrade.bin" > "$h/ArcherC2V1_tp_recovery.bin"
		hand="$h/ArcherC2V1_tp_recovery.bin"
	else
		# OpenWrt 161a3be5 / Geraetedaten stock_teile
		dd if="$stock" of="$h/uboot.bin" bs=512 count=256 skip=1 status=none
		cat "$h/uboot.bin" "$W/sysupgrade.bin" > "$h/ArcherC20V1_tp_recovery.bin"
		hand="$h/ArcherC20V1_tp_recovery.bin"
	fi
	cmp -s "$hand" "$W/out-$d/gluon-rampe-test-$d-tp-recovery.bin" \
		&& ok "tp-recovery.bin gleich der Handarbeit" || nok "tp-recovery.bin weicht ab"
done

for d in tp-link-archer-c20-v5 tp-link-archer-c50-v4 tp-link-archer-c50-v6-ca-eu-ru; do
	echo "== $d"
	lauf "$d" "$W/sysupgrade.bin" >/dev/null || { nok "Nachbau scheitert"; continue; }
	stock=$(stock_von "$d")
	h="$W/hand-$d"; mkdir -p "$h"
	# OpenWrt 86e7353b, woertlich (tpl.bin, owrt.bin)
	cp "$stock" "$h/tpl.bin"; cp "$W/sysupgrade.bin" "$h/owrt.bin"
	( cd "$h"
	  dd if=tpl.bin of=boot.bin bs=131584 count=1 status=none
	  cat owrt.bin >> boot.bin
	  cp boot.bin web-boot.bin
	  dd if=/dev/zero of=tp_recovery.bin bs=196608 count=1 status=none
	  dd if=tpl.bin of=tmp.bin bs=131584 count=1 status=none
	  dd if=tmp.bin of=boot.bin bs=512 skip=1 status=none
	  cat boot.bin >> tp_recovery.bin
	  cat owrt.bin >> tp_recovery.bin )
	cmp -s "$h/web-boot.bin" "$W/out-$d/gluon-rampe-test-$d-boot.bin" \
		&& ok "boot.bin gleich der Handarbeit" || nok "boot.bin weicht ab"
	cmp -s "$h/tp_recovery.bin" "$W/out-$d/gluon-rampe-test-$d-tp-recovery.bin" \
		&& ok "tp-recovery.bin gleich der Handarbeit" || nok "tp-recovery.bin weicht ab"
done

echo "== zte-mf286r"
lauf zte-mf286r "$W/sysupgrade.bin" >/dev/null || nok "Nachbau scheitert"
# OpenWrt 7ac8da00, "Method 3"
dd if=/dev/zero of="$W/padding.bin" bs=8M count=1 status=none
cat "$W/padding.bin" "$W/initramfs.bin" > "$W/root_uImage"
cmp -s "$W/root_uImage" "$W/out-zte-mf286r/gluon-rampe-test-zte-mf286r-tftp-root_uImage.bin" \
	&& ok "root_uImage gleich der Handarbeit" || nok "root_uImage weicht ab"

echo "== Ablehnungen"
head -c $(( 7616 * 1024 + 1 )) /dev/urandom > "$W/zu-gross.bin"
if lauf tp-link-archer-c50-v4 "$W/zu-gross.bin" >/dev/null 2>&1; then
	nok "zu grosses sysupgrade (7616k + 1) angenommen"
else
	ok "zu grosses sysupgrade abgelehnt"
fi
if RAMPE_CACHE="$W/cache" hersteller_datei "file://$W/sysupgrade.bin" \
		0000000000000000000000000000000000000000000000000000000000000000 - \
		0000000000000000000000000000000000000000000000000000000000000000 >/dev/null 2>&1; then
	nok "falsche Pruefsumme angenommen"
else
	ok "falsche Pruefsumme abgelehnt"
fi

(( fehler == 0 )) && echo "Alles gleich." || { echo "Abweichungen, siehe oben."; exit 1; }
