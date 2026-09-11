#!/bin/bash
#
# build.sh - baut Freifunk-Installer-Images.
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
#
# Ablauf: Gluon holen, "make update", die Geraete-Rezepte (devices/) und das
# Overlay (overlay/ -> openwrt/files) einspielen, bauen, die Installer-Images
# nach out/ einsammeln. Kein Parallelbetrieb, keine Domain-Schleifen: ein
# Installer ist community-unabhaengig, ein Bau je Target reicht.

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
		echo "Kein Installer-Rezept fuer '$d' (devices/$d.sh) - siehe docs/GERAETE.md." >&2
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
# Die Rezepte aendern targets/ - vorher auf den Stand von Gluon zurueck.
git -C "$GLUON_DIR" checkout -q -- targets

echo "== make update"
make -C "$GLUON_DIR" update GLUON_SITEDIR="$ROOT/site"

echo "== Geraete-Rezepte"
export GLUON_DIR
# shellcheck source=devices/lib.sh
. "$ROOT/devices/lib.sh"
for d in "${DEVICES[@]}"; do
	echo "  $d"
	# shellcheck source=/dev/null
	. "$ROOT/devices/$d.sh"
done

echo "== Overlay -> openwrt/files"
# openwrt/files gehoert in diesem Baum allein dem Installer.
rm -rf "$GLUON_DIR/openwrt/files"
cp -a "$ROOT/overlay" "$GLUON_DIR/openwrt/files"

mkdir -p "$OUT"
LOG="$OUT/build-$TARGET.log"
echo "== make GLUON_TARGET=$TARGET GLUON_DEVICES=\"${DEVICES[*]}\" -j$JOBS  (Log: $LOG)"
if ! make -C "$GLUON_DIR" GLUON_TARGET="$TARGET" GLUON_DEVICES="${DEVICES[*]}" \
		GLUON_SITEDIR="$ROOT/site" -j"$JOBS" > "$LOG" 2>&1; then
	echo "Bau fehlgeschlagen, Ende des Logs:" >&2
	tail -n 30 "$LOG" >&2
	echo "Einzelheiten: make -C $GLUON_DIR GLUON_TARGET=$TARGET GLUON_SITEDIR=$ROOT/site -j1 V=s" >&2
	exit 1
fi

echo "== Einsammeln nach $OUT"
for d in "${DEVICES[@]}"; do
	# Hersteller-Images (recovery, factory ...), die Gluon unter other/ ablegt
	find "$GLUON_DIR/output/images/other" -name "gluon-installer-*-$d-*" \
		! -name '*-kernel.bin' ! -name '*-rootfs.img.gz' -exec cp -v {} "$OUT/" \;
	# Der rohe initramfs-Kernel: fuer TFTP-/RAM-Boot und QEMU
	profile=$(grep -o "device('$d',[[:space:]]*'[^']*'" "$GLUON_DIR/targets/$TARGET" | sed "s/.*'\([^']*\)'$/\1/")
	for k in "$GLUON_DIR"/openwrt/bin/targets/*/*/openwrt-*-"$profile"-initramfs-kernel.bin; do
		[ -f "$k" ] && cp -v "$k" "$OUT/freifunk-installer-$d-initramfs-kernel.bin"
	done
done
( cd "$OUT" && sha256sum -- *.bin > SHA256SUMS 2>/dev/null || true )
ls -la "$OUT"
