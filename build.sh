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
# out/images enthaelt nur, was auf den Download-Server gehoert, und wird "as is"
# gespiegelt; Logs und aeltere Staende liegen daneben.
IMAGES="$OUT/images"
LOGS="$OUT/logs"
ARCHIV="$OUT/archiv"
# Release-Kennung der Images (Default wie site/site.mk: Baudatum). Einmal je
# Lauf festgelegt und an make durchgereicht, damit alle eingesammelten Dateien
# denselben Stand im Namen tragen, auch ueber Mitternacht.
RELEASE="${GLUON_RELEASE:-$(date +%Y%m%d)}"

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
git -C "$GLUON_DIR" checkout -q -- targets patches package/gluon-config-mode-theme
git -C "$GLUON_DIR" clean -fdq -- patches package

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

echo "== Eigene Pakete (package/) -> gluon/package"
# Gluons package/ ist ein src-link-Feed; was hier liegt, nimmt make update mit.
# Vor jedem Lauf raeumt "git clean" oben die Kopien wieder weg.
cp -a "$ROOT/package/." "$GLUON_DIR/package/"

echo "== make update"
make -C "$GLUON_DIR" update GLUON_SITEDIR="$RAMPE_SITEDIR"

echo "== Overlay -> openwrt/files"
# openwrt/files gehoert in diesem Baum allein der Gluon-RAMpe.
rm -rf "$GLUON_DIR/openwrt/files"
cp -a "$ROOT/overlay" "$GLUON_DIR/openwrt/files"

echo "== HTTPS-Umleitung: Schluessel und selbstsigniertes Zertifikat"
# Fuer S51rampe-https (Port 443 leitet auf http:// um). Je Lauf neu erzeugt,
# damit kein privater Schluessel im Repo liegt. Er schuetzt nichts: ueber
# diese Verbindung geht nur die Umleitung, der Browser warnt ohnehin.
command -v openssl >/dev/null || { echo "openssl fehlt (HTTPS-Umleitung)" >&2; exit 1; }
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes -days 3650 \
	-subj "/CN=Gluon-RAMpe" -addext "subjectAltName=IP:192.168.1.1" \
	-keyout "$GLUON_DIR/openwrt/files/lib/gluon/rampe-https/key.pem" \
	-out "$GLUON_DIR/openwrt/files/lib/gluon/rampe-https/cert.pem" 2>/dev/null \
	|| { echo "Zertifikat fuer die HTTPS-Umleitung nicht erzeugt" >&2; exit 1; }

echo "== Config-Mode: gluon.css mit Versionsanhang"
# Gluon liefert /static/ ohne Cache-Control und mit festem Last-Modified aus;
# Browser halten gluon.css deshalb lange im Cache. Unter 192.168.1.1 laeuft vor
# und nach der RAMpe ein anderer Config-Mode (anderes Gluon, andere Community):
# ohne eigene Adresse kaeme dessen gluon.css aus dem Cache und umgekehrt. Wie
# Neanderfunks gluon-patches-packages status-page/web-static-version.patch:
# ?v=<Release aus /lib/gluon/release>, uhttpd ignoriert den Query-String.
# Im Baum zurueckgesetzt wird die Datei oben mit targets und patches.
python3 - "$GLUON_DIR/package/gluon-config-mode-theme/files/lib/gluon/config-mode/view/theme/layout.html" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
alt = 'href="/static/gluon.css"'
neu = ('href="/static/gluon.css?v=<%| ((require(\'gluon.util\').readfile('
       '\'/lib/gluon/release\') or \'\'):gsub(\'%s+\', \'\')) %>"')
if neu not in s:
    if alt not in s:
        sys.exit("gluon.css-Einbindung nicht gefunden in " + p)
    open(p, 'w').write(s.replace(alt, neu, 1))
PY

mkdir -p "$IMAGES" "$LOGS" "$ARCHIV"
LOG="$LOGS/build-$TARGET.log"
: > "$LOG"

echo "== Kernel-Modulpakete des Targets neu verpacken"
# Targets derselben Architektur (mediatek-filogic und qualcommax; ath79-* und
# lantiq; ipq40xx-generic und -mikrotik) teilen sich staging_dir/target-<arch>
# und damit pkginfo/kmod-*.provides. Baut ein Target nach einem anderen
# Kernel-Pakete neu, prueft OpenWrt sie gegen die Liste des anderen Targets:
# am 15.10.2026 scheiterte der TUF-Lauf so an "kmod-mt76-usb is missing
# dependencies: usbcore.ko" (kmod-usb-core.provides leer, vom ipq807x-Lauf).
# package/kernel/linux neu zu verpacken kostet etwa eine Minute; der Kernel
# selbst wird dabei nicht neu gebaut.
if ! { make -C "$GLUON_DIR" config GLUON_TARGET="$TARGET" GLUON_DEVICES="${DEVICES[*]}" \
		GLUON_SITEDIR="$RAMPE_SITEDIR" GLUON_RELEASE="$RELEASE" \
		&& make -C "$GLUON_DIR/openwrt" package/kernel/linux/clean; } >> "$LOG" 2>&1; then
	echo "Vorbereitung (config, package/kernel/linux/clean) fehlgeschlagen, siehe $LOG" >&2
	exit 1
fi

echo "== make GLUON_TARGET=$TARGET GLUON_DEVICES=\"${DEVICES[*]}\" GLUON_RELEASE=$RELEASE -j$JOBS  (Log: $LOG)"
if ! make -C "$GLUON_DIR" GLUON_TARGET="$TARGET" GLUON_DEVICES="${DEVICES[*]}" \
		GLUON_SITEDIR="$RAMPE_SITEDIR" GLUON_RELEASE="$RELEASE" -j"$JOBS" >> "$LOG" 2>&1; then
	echo "Bau fehlgeschlagen, Ende des Logs:" >&2
	tail -n 30 "$LOG" >&2
	echo "Einzelheiten: make -C $GLUON_DIR GLUON_TARGET=$TARGET GLUON_SITEDIR=$RAMPE_SITEDIR -j1 V=s" >&2
	exit 1
fi

echo "== Einsammeln nach $IMAGES"
for d in "${DEVICES[@]}"; do
	found=0
	# Aeltere Staende dieses Geraets nach archiv/: in images/ liegt je Geraet nur
	# der aktuelle. Nach dem Geraetenamen muss eine Image-Endung folgen, damit
	# aruba-ap-303 nicht aruba-ap-303h und netgear-wndr3700 nicht -wndr3700-v2 trifft.
	for alt in "$IMAGES"/gluon-rampe-*; do
		[ -f "$alt" ] || continue
		b=${alt##*/}
		[[ $b =~ ^gluon-rampe-([0-9]{8})-"$d"-(initramfs|recovery|factory|web-ui-factory|kernel1|rootfs0|fdt) ]] || continue
		[ "${BASH_REMATCH[1]}" = "$RELEASE" ] || mv -v "$alt" "$ARCHIV/"
	done
	# Hersteller-Images (recovery, factory ...), die Gluon unter other/ ablegt
	while IFS= read -r -d '' f; do
		cp -v "$f" "$IMAGES/" && found=1
	done < <(find "$GLUON_DIR/output/images/other" -name "gluon-rampe-*-$d-*" \
		! -name '*-kernel.bin' ! -name '*-rootfs.img.gz' -print0)
	# Der rohe initramfs-Kernel: fuer TFTP-/RAM-Boot und QEMU. Der Name haengt
	# am KERNEL_INITRAMFS_SUFFIX des Geraets (-initramfs-kernel.bin,
	# -initramfs-uImage.itb, -initramfs-zImage.itb, -initramfs.ari ...). Was
	# Gluon per extra_images schon nach other/ kopiert hat, hat copy_output.lua
	# hier geloescht, es kommt also nicht doppelt. Achtung: Sammelt Gluon ihn
	# selbst als factory ein (mikrotik.inc: factory = '-initramfs-kernel'),
	# fehlt er hier; das Rezept muss das abschalten
	# (ensure_device_option <target> <geraet> factory false).
	profile=$(grep -o "device('$d',[[:space:]]*'[^']*'" "$GLUON_DIR/targets/$TARGET" | sed "s/.*'\([^']*\)'$/\1/")
	for k in "$GLUON_DIR"/openwrt/bin/targets/*/*/openwrt-*-"$profile"-initramfs*; do
		[ -f "$k" ] || continue
		cp -v "$k" "$IMAGES/gluon-rampe-$RELEASE-$d-${k##*-"$profile"-}" && found=1
		# TFTP mit 512-Byte-Bloecken und 16-Bit-Blockzaehler endet bei 32 MiB,
		# eva_ramboot.py bricht ab 0x2000000 Byte ab.
		size=$(stat -c %s "$k")
		(( size < 0x2000000 )) || echo "WARNUNG: $d: initramfs $size Byte >= 32 MiB (TFTP/EVA-Grenze)" >&2
	done
	(( found )) || echo "WARNUNG: fuer $d wurde nichts eingesammelt - Rezept pruefen (factory/extra_images, TARGET_ROOTFS_INITRAMFS)." >&2
done
# OpenWrt-U-Boot der AVM-ipq40xx-Geraete fuer eva_ramboot.py (Paket
# uboot-fritz4040 legt sie nach STAGING_DIR_IMAGE), nur wenn gebaut
for u in "$GLUON_DIR"/openwrt/staging_dir/target-*/image/uboot-fritz*.bin; do
	[ -f "$u" ] || continue
	cp -v "$u" "$IMAGES/"
done
# SHA256SUMS und LISTE.md (Geraet, Datei, Art, Groesse, SHA256) fuer images/
python3 "$ROOT/scripts/rampe-liste.py" "$IMAGES"
ls -la "$IMAGES"
