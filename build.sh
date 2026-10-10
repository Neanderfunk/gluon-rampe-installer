#!/bin/bash
#
# build.sh - baut Gluon-RAMpe-Images.
#
#   ./build.sh <GLUON_TARGET> <geraet> [<geraet> ...]
#
#   Beispiele:
#     ./build.sh mediatek-filogic d-link-aquila-pro-ai-m30-a1
#     ./build.sh x86-64 x86-64
#
# Am einfachsten im Container, der alle Werkzeuge mitbringt:
#     contrib/docker/run.sh ./build.sh mediatek-filogic d-link-aquila-pro-ai-m30-a1
#
# Umgebung (alles optional):
#   GLUON_REF   Gluon-Version, Default v2025.1.3
#   GLUON_REPO  Default https://github.com/freifunk-gluon/gluon.git
#   GLUON_DIR   Gluon-Baum, Default ./gluon (wird angelegt)
#   JOBS        make -j, Default: Zahl der Kerne
#   RAMPE_HW_PATCHES  Checkout von gluon-patches-hardware (Branch v2025.1.x),
#               nur fuer Rezepte mit ensure_openwrt_backport (AP-32x, EAP620 HD)
#
# Ablauf: Gluon holen, die Geraete-Rezepte (devices/) einspielen, "make
# update", das Overlay (overlay/ -> openwrt/files) einspielen, bauen, die RAMpe-Images
# nach out/ einsammeln. Kein Parallelbetrieb, keine Domain-Schleifen: ein
# RAMpe-Image ist community-unabhaengig, ein Bau je Target reicht.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLUON_REF="${GLUON_REF:-v2025.1.3}"
GLUON_REPO="${GLUON_REPO:-https://github.com/freifunk-gluon/gluon.git}"
GLUON_DIR="${GLUON_DIR:-$ROOT/gluon}"
JOBS="${JOBS:-$(nproc)}"
OUT="$ROOT/out"

if (( $# < 2 )); then
	sed -n '3,20p' "$0" | sed 's/^# \{0,1\}//'
	exit 1
fi
TARGET="$1"; shift
DEVICES=("$@")

for d in "${DEVICES[@]}"; do
	[ -f "$ROOT/devices/$d.sh" ] || {
		echo "Kein RAMpe-Rezept fuer '$d' (devices/$d.sh) - siehe docs/GERAETE.md." >&2
		exit 1
	}
done

echo "== Gluon $GLUON_REF in $GLUON_DIR"
if [ ! -d "$GLUON_DIR/.git" ]; then
	git clone --depth 1 -b "$GLUON_REF" "$GLUON_REPO" "$GLUON_DIR"
elif [ "$(git -C "$GLUON_DIR" describe --tags --exact-match 2>/dev/null)" != "$GLUON_REF" ]; then
	git -C "$GLUON_DIR" fetch --depth 1 origin tag "$GLUON_REF"
	git -C "$GLUON_DIR" checkout -q -f "$GLUON_REF"
fi
# Die Rezepte aendern targets/ und patches/openwrt - vorher auf den Stand von
# Gluon zurueck (abgelegte Backport-Patches sind unversioniert: clean).
git -C "$GLUON_DIR" checkout -q -- targets patches
git -C "$GLUON_DIR" clean -fdq -- patches

# Die Rezepte duerfen die Site ergaenzen (ensure_site_*): nur in einer Kopie.
RAMPE_SITEDIR="$ROOT/.site-build"
rm -rf "$RAMPE_SITEDIR"
cp -a "$ROOT/site" "$RAMPE_SITEDIR"

echo "== Geraete-Rezepte (vor make update, wegen ensure_openwrt_backport)"
export GLUON_DIR RAMPE_SITEDIR
# shellcheck source=devices/lib.sh
. "$ROOT/devices/lib.sh"
for d in "${DEVICES[@]}"; do
	echo "  $d"
	# shellcheck source=/dev/null
	. "$ROOT/devices/$d.sh"
done

echo "== make update"
make -C "$GLUON_DIR" update GLUON_SITEDIR="$RAMPE_SITEDIR"

echo "== Overlay -> openwrt/files"
# openwrt/files gehoert in diesem Baum allein der Gluon-RAMpe.
rm -rf "$GLUON_DIR/openwrt/files"
cp -a "$ROOT/overlay" "$GLUON_DIR/openwrt/files"

mkdir -p "$OUT"
LOG="$OUT/build-$TARGET.log"
echo "== make GLUON_TARGET=$TARGET GLUON_DEVICES=\"${DEVICES[*]}\" -j$JOBS  (Log: $LOG)"
if ! make -C "$GLUON_DIR" GLUON_TARGET="$TARGET" GLUON_DEVICES="${DEVICES[*]}" \
		GLUON_SITEDIR="$RAMPE_SITEDIR" -j"$JOBS" > "$LOG" 2>&1; then
	echo "Bau fehlgeschlagen, Ende des Logs:" >&2
	tail -n 30 "$LOG" >&2
	echo "Einzelheiten: make -C $GLUON_DIR GLUON_TARGET=$TARGET GLUON_SITEDIR=$RAMPE_SITEDIR -j1 V=s" >&2
	exit 1
fi

echo "== Einsammeln nach $OUT"
for d in "${DEVICES[@]}"; do
	# Hersteller-Images (recovery, factory ...), die Gluon unter other/ ablegt
	find "$GLUON_DIR/output/images/other" -name "gluon-rampe-*-$d-*" \
		! -name '*-kernel.bin' ! -name '*-rootfs.img.gz' -exec cp -v {} "$OUT/" \;
	# Der rohe initramfs-Kernel: fuer TFTP-/RAM-Boot und QEMU. Der Name haengt
	# am KERNEL_INITRAMFS_SUFFIX des Geraets (-initramfs-kernel.bin,
	# -initramfs-uImage.itb, -initramfs-zImage.itb, -initramfs.ari ...). Was
	# Gluon per extra_images schon nach other/ kopiert hat, hat copy_output.lua
	# hier geloescht, es kommt also nicht doppelt.
	profile=$(grep -o "device('$d',[[:space:]]*'[^']*'" "$GLUON_DIR/targets/$TARGET" | sed "s/.*'\([^']*\)'$/\1/")
	for k in "$GLUON_DIR"/openwrt/bin/targets/*/*/openwrt-*-"$profile"-initramfs*; do
		[ -f "$k" ] || continue
		cp -v "$k" "$OUT/gluon-rampe-$d-${k##*-"$profile"-}"
	done
done
# OpenWrt-U-Boot der AVM-ipq40xx-Geraete fuer eva_ramboot.py (Paket
# uboot-fritz4040 legt sie nach STAGING_DIR_IMAGE), nur wenn gebaut
for u in "$GLUON_DIR"/openwrt/staging_dir/target-*/image/uboot-fritz*.bin; do
	[ -f "$u" ] || continue
	cp -v "$u" "$OUT/"
done
( cd "$OUT" && find . -maxdepth 1 -type f ! -name '*.log' ! -name SHA256SUMS -printf '%P\0' \
	| sort -z | xargs -0r sha256sum -- > SHA256SUMS 2>/dev/null || true )
ls -la "$OUT"
