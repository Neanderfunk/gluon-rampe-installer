# devices/lib.sh - Helfer fuer die Geraete-Rezepte.
#
# Ein Rezept (devices/<gluon-geraetename>.sh) schaltet im Gluon-Baum ein, was
# der Installer fuer dieses Geraet braucht: ein initramfs und das Image, das
# sich ueber die Hersteller-Firmware oder -Recovery einspielen laesst. Beides
# per Aenderung an gluon/targets/<target>. build.sh setzt targets/ vor jedem
# Lauf per git zurueck, die Rezepte muessen also nur hinzufuegen.
#
# Erwartet GLUON_DIR (von build.sh gesetzt), fuer ensure_site_* RAMPE_SITEDIR
# (Kopie von site/, von build.sh gesetzt) und fuer ensure_openwrt_backport
# RAMPE_HW_PATCHES (Checkout von gluon-patches-hardware, Branch v2025.1.x).
#
# build.sh ruft die Rezepte VOR "make update" auf: ensure_openwrt_backport
# legt Patches unter patches/openwrt ab, die "make update" einspielt. Alles
# andere aendert nur targets/ bzw. RAMPE_SITEDIR, die "make update" nicht anfasst.

# ensure_target_config <target> <OPENWRT_CONFIG>
#   haengt config('<OPENWRT_CONFIG>', true) an targets/<target>, falls es fehlt
ensure_target_config () {
	ensure_target_config_value "$1" "$2" true
}

# ensure_target_config_value <target> <OPENWRT_CONFIG> <lua-wert>
#   wie ensure_target_config, aber mit beliebigem Wert (true, false, 'text', 3).
#   Gilt fuer das ganze Target des Laufs, also fuer alle Geraete darin.
ensure_target_config_value () {
	local f="$GLUON_DIR/targets/$1"
	[ -f "$f" ] || { echo "Target $1 gibt es in diesem Gluon nicht." >&2; return 1; }
	if grep -q "^config('$2'," "$f" && ! grep -qF "config('$2', $3)" "$f"; then
		echo "Target $1: config('$2', ...) steht schon mit anderem Wert drin." >&2
		return 1
	fi
	if ! grep -qF "config('$2', $3)" "$f"; then
		sed -i "1i config('$2', $3)" "$f"
		echo "  $1: config('$2', $3) ergaenzt"
	fi
}

# ensure_extra_image <target> <gluon-geraet> <openwrt-suffix> <gluon-suffix> <endung>
#   sorgt dafuer, dass Gluon fuer das Geraet dieses zusaetzliche Image
#   einsammelt, z.B.  -squashfs-recovery  -recovery  .bin
ensure_extra_image () {
	python3 - "$GLUON_DIR/targets/$1" "$2" "$3" "$4" "$5" <<'PY'
import re, sys
path, dev, osuf, gsuf, ext = sys.argv[1:6]
s = open(path).read()
m = re.search(r"device\('%s',\s*'[^']+'" % re.escape(dev), s)
if not m:
    sys.exit("Geraet %s steht nicht in %s" % (dev, path))
# Ende des device(...)-Aufrufs: Klammern zaehlen
i, depth = m.start() + len('device'), 0
for j in range(i, len(s)):
    if s[j] == '(':
        depth += 1
    elif s[j] == ')':
        depth -= 1
        if depth == 0:
            end = j
            break
block = s[m.start():end + 1]
entry = "{'%s', '%s', '%s'}" % (osuf, gsuf, ext)
if osuf in block:
    sys.exit(0)
if 'extra_images' in block:
    new = re.sub(r"extra_images\s*=\s*\{", "extra_images = {\n\t\t%s," % entry, block, count=1)
elif block.rstrip().endswith('})'):
    head = block[:block.rstrip().rfind('})')].rstrip()
    # letzte Option ohne Komma (z.B. "packages = {...}" bei xiaomi-ax3600)
    if not head.endswith((',', '{')):
        head += ','
    new = head + "\n\textra_images = {\n\t\t%s,\n\t},\n})" % entry
else:
    new = block[:-1] + ", {\n\textra_images = {\n\t\t%s,\n\t},\n})" % entry
s = s[:m.start()] + new + s[end + 1:]
open(path, 'w').write(s)
print("  %s: extra_images %s ergaenzt" % (dev, entry))
PY
}

# ensure_device <target> <gluon-geraet> <openwrt-profil> [<lua-option>]
#   haengt device('<gluon-geraet>', '<openwrt-profil>', {factory = false}) an
#   targets/<target>, falls Gluon das Geraet nicht kennt. Fuer Geraete, die
#   OpenWrt schon hat (oder per ensure_openwrt_backport bekommt), Gluon aber
#   (noch) nicht. Optional eine weitere Option als Lua-Text, z.B.
#   "packages = QCA9980_PACKAGES," (lokale Tabellen oben in der Targetdatei
#   sind am Dateiende sichtbar). Achtung: packages ersetzt die defaults-Liste
#   (Gluons merge()); fuer zusaetzliche Pakete ensure_site_packages nehmen.
ensure_device () {
	local f="$GLUON_DIR/targets/$1"
	[ -f "$f" ] || { echo "Target $1 gibt es in diesem Gluon nicht." >&2; return 1; }
	if ! grep -q "device('$2'," "$f"; then
		{
			printf "\ndevice('%s', '%s', {\n\tfactory = false,\n" "$2" "$3"
			[ -z "${4:-}" ] || printf "\t%s\n" "$4"
			printf "})\n"
		} >> "$f"
		echo "  $1: device('$2', '$3') ergaenzt${4:+ ($4)}"
	fi
}

# ensure_site_packages <gluon-geraet> <paket> [<paket> ...]
#   nimmt Pakete fuer genau dieses Geraet zusaetzlich ins Image, ueber
#   image-customization.lua der Lauf-Kopie der Site (RAMPE_SITEDIR). Gluon
#   haengt Site-Pakete an die Geraete-Pakete an (target_config_lib.lua),
#   statt sie zu ersetzen.
ensure_site_packages () {
	local dev="$1"; shift
	local f="${RAMPE_SITEDIR:?RAMPE_SITEDIR nicht gesetzt}/image-customization.lua"
	local list line
	list=$(printf "'%s', " "$@"); list=${list%, }
	line="if device({'$dev'}) then packages {$list} end"
	if ! grep -qxF "$line" "$f"; then
		printf '%s\n' "$line" >> "$f"
		echo "  site: $line"
	fi
}

# ensure_site_unbroken <gluon-geraet>
#   baut ein Geraet, das Gluon mit broken = true fuehrt (image-customization
#   broken(false)), ohne BROKEN=1 fuer den ganzen Lauf.
ensure_site_unbroken () {
	local f="${RAMPE_SITEDIR:?RAMPE_SITEDIR nicht gesetzt}/image-customization.lua"
	local line="if device({'$1'}) then broken(false) end"
	if ! grep -qxF "$line" "$f"; then
		printf '%s\n' "$line" >> "$f"
		echo "  site: $line"
	fi
}

# ensure_openwrt_backport <verzeichnis> <praefix>
#   legt die OpenWrt-Patches devices/<verzeichnis>/0*.patch aus
#   gluon-patches-hardware (RAMPE_HW_PATCHES) als
#   patches/openwrt/<praefix>-<name>.patch im Gluon-Baum ab, wie dort
#   devices/<verzeichnis>/openwrt.sh. Wirkt nur, weil build.sh die Rezepte vor
#   "make update" aufruft; build.sh raeumt patches/ vor jedem Lauf auf.
ensure_openwrt_backport () {
	local src="${RAMPE_HW_PATCHES:?RAMPE_HW_PATCHES (gluon-patches-hardware, v2025.1.x) nicht gesetzt}/devices/$1"
	local dest="$GLUON_DIR/patches/openwrt" p n=0
	[ -d "$src" ] || { echo "Backport $src fehlt." >&2; return 1; }
	for p in "$src"/0*.patch; do
		[ -f "$p" ] || continue
		cp "$p" "$dest/$2-$(basename "$p")"
		n=$((n + 1))
	done
	[ "$n" -gt 0 ] || { echo "Keine Patches in $src." >&2; return 1; }
	echo "  patches/openwrt: $n Patch(es) aus $1 ($2-*)"
}

# ensure_device_option <target> <gluon-geraet> <schluessel> <lua-wert>
#   setzt eine einfache Option im device(...)-Block von targets/<target>.
#   Steht der Schluessel schon da, wird sein Wert ersetzt (ein zweiter
#   gleichnamiger Schluessel im Lua-Tabellenkonstruktor waere undefiniert).
#   Nur fuer einfache Werte (true/false/'text'), keine Tabellen.
#   Beispiele:
#     ensure_device_option ipq40xx-mikrotik mikrotik-hap-ac2 factory false
#       (Gluons mikrotik.inc liefert das initramfs sonst als "factory" aus,
#        copy_output.lua loescht dabei den rohen initramfs-Kernel)
#     ensure_device_option ath79-generic sophos-ap15 broken false
#       (sonst kennt Gluon das Geraet ohne BROKEN=1 nicht)
ensure_device_option () {
	python3 - "$GLUON_DIR/targets/$1" "$2" "$3" "$4" <<'PY'
import re, sys
path, dev, key, val = sys.argv[1:5]
s = open(path).read()
m = re.search(r"device\('%s',\s*'[^']+'" % re.escape(dev), s)
if not m:
    sys.exit("Geraet %s steht nicht in %s" % (dev, path))
i, depth = m.start() + len('device'), 0
for j in range(i, len(s)):
    if s[j] == '(':
        depth += 1
    elif s[j] == ')':
        depth -= 1
        if depth == 0:
            end = j
            break
block = s[m.start():end + 1]
kre = re.compile(r"(\b%s\s*=\s*)([^,\n}]+)" % re.escape(key))
if kre.search(block):
    new = kre.sub(lambda mm: mm.group(1) + val, block, count=1)
elif block.rstrip().endswith('})'):
    new = block[:block.rstrip().rfind('})')].rstrip() + "\n\t%s = %s,\n})" % (key, val)
else:
    new = block[:-1] + ", {\n\t%s = %s,\n})" % (key, val)
if new == block:
    sys.exit(0)
s = s[:m.start()] + new + s[end + 1:]
open(path, 'w').write(s)
print("  %s: %s = %s gesetzt" % (dev, key, val))
PY
}

# ---------------------------------------------------------------------------
# Nachbau nach dem Bau (Gruppe A aus docs/PLAN-WEITERE-RAMPEN.md)
#
# Manche Wege brauchen ein Image, das OpenWrt nicht baut: die RAMpe mit einem
# Teil der Hersteller-Firmware davor (TP-Link-U-Boot) oder mit einer
# Polsterung (ZTE-TFTP). Ein Rezept meldet dafuer mit nach_dem_bau einen
# Befehl an; build.sh ruft ihn nach dem Einsammeln auf, mit
#   RAMPE_GERAET      Gluon-Geraetename
#   RAMPE_SYSUPGRADE  sysupgrade-Image der RAMpe (Gluon output/images)
#   RAMPE_INITRAMFS   eingesammeltes initramfs der RAMpe (falls gebaut)
#   RAMPE_ZIEL        Verzeichnis der veroeffentlichten Images
#   RAMPE_PRAEFIX     gluon-rampe-<Release>-<Geraet>
# Schlaegt der Befehl fehl, fehlt nur dieses Geraet; build.sh meldet es und
# endet am Schluss mit Exit 1.
#
# Herstellerdateien holt hersteller_datei in einen Cache ausserhalb des Repos
# (RAMPE_CACHE, Default ~/.cache/gluon-rampe/hersteller), mit festen
# SHA256-Summen fuer den Download und die ausgepackte Datei. Wer den Download
# von Hand erledigt, legt die Datei unter ihrem Originalnamen (wie in der URL,
# ohne %-Kodierung) in dieses Verzeichnis; stimmt die Pruefsumme, wird sie
# genommen und nichts geladen.
# Die Funktionen pruefen jeden Schritt selbst und geben 1 zurueck: build.sh
# ruft sie in einem "||"-Zusammenhang auf, dort wirkt set -e nicht.
# ---------------------------------------------------------------------------

declare -gA RAMPE_NACHBAU=()

# nach_dem_bau <gluon-geraet> <funktion> [<argument> ...]
nach_dem_bau () {
	local g="$1"; shift
	RAMPE_NACHBAU[$g]="$(printf '%q ' "$@")"
	echo "  $g: nach dem Bau: $1"
}

# hersteller_datei <url> <sha256-download> <mitglied> <sha256-datei>
#   gibt den Pfad der gepruefen Datei aus. <mitglied>: Dateiname im ZIP
#   (genau, ohne Verzeichnis), "-" wenn der Download selbst die Datei ist.
hersteller_datei () {
	local url="$1" sum_dl="$2" mitglied="$3" sum_bin="$4"
	local cache="${RAMPE_CACHE:-$HOME/.cache/gluon-rampe/hersteller}"
	local dl="$cache/$sum_dl" bin="$cache/$sum_bin"
	mkdir -p "$cache" || return 1
	if [ ! -f "$bin" ] || [ "$(sha256sum < "$bin" | cut -c1-64)" != "$sum_bin" ]; then
		local hand
		hand="$cache/$(python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1].rsplit("/", 1)[-1]))' "$url")"
		if [ -f "$hand" ] && [ "$(sha256sum < "$hand" | cut -c1-64)" = "$sum_dl" ]; then
			cp "$hand" "$dl" || return 1
		fi
		if [ ! -f "$dl" ] || [ "$(sha256sum < "$dl" | cut -c1-64)" != "$sum_dl" ]; then
			echo "    Herstellerdatei holen: $url" >&2
			curl -fsSL --retry 3 -o "$dl.part" "$url" || { echo "    Download fehlgeschlagen: $url" >&2; return 1; }
			mv "$dl.part" "$dl"
		fi
		[ "$(sha256sum < "$dl" | cut -c1-64)" = "$sum_dl" ] \
			|| { echo "    SHA256 des Downloads stimmt nicht: $url" >&2; return 1; }
		if [ "$mitglied" = "-" ]; then
			cp "$dl" "$bin.part" || return 1
		else
			python3 - "$dl" "$mitglied" "$bin.part" <<'PY' || { echo "    $mitglied nicht im ZIP" >&2; return 1; }
import sys, zipfile
z = zipfile.ZipFile(sys.argv[1])
treffer = [n for n in z.namelist() if n.rsplit('/', 1)[-1] == sys.argv[2]]
if len(treffer) != 1:
    sys.exit(1)
open(sys.argv[3], 'wb').write(z.read(treffer[0]))
PY
		fi
		mv "$bin.part" "$bin"
		[ "$(sha256sum < "$bin" | cut -c1-64)" = "$sum_bin" ] \
			|| { echo "    SHA256 der Herstellerdatei stimmt nicht: $mitglied" >&2; return 1; }
	fi
	printf '%s\n' "$bin"
}

# groesse_hoechstens <datei> <bytes> <was>
groesse_hoechstens () {
	local n
	n=$(stat -c %s "$1") || return 1
	(( n <= $2 )) || { echo "    $3: $n Byte, erlaubt $2" >&2; return 1; }
}

# nachbau_tplink_uboot_tftp <url> <sha256-zip> <mitglied> <sha256-bin> <image-size-kb>
#   Archer C2 v1, C20 v1 (OpenWrt 8375623a, 161a3be5): TFTP-Recovery-Image
#   aus dem U-Boot der TP-Link-Firmware und der RAMpe (sysupgrade),
#   woertlich wie dort:
#     dd if=<stock> of=uboot.bin bs=1 skip=512 count=131072
#     cat uboot.bin <sysupgrade> > <Name>_tp_recovery.bin
#   Ergebnis: <praefix>-tp-recovery.bin (umbenennen in ArcherC2V1_tp_recovery.bin usw.)
nachbau_tplink_uboot_tftp () {
	local stock ziel="$RAMPE_ZIEL/$RAMPE_PRAEFIX-tp-recovery.bin" tmp
	[ -f "${RAMPE_SYSUPGRADE:-}" ] || { echo "    sysupgrade der RAMpe fehlt" >&2; return 1; }
	groesse_hoechstens "$RAMPE_SYSUPGRADE" $(( $5 * 1024 )) "sysupgrade (IMAGE_SIZE)" || return 1
	stock=$(hersteller_datei "$1" "$2" "$3" "$4") || return 1
	tmp=$(mktemp -d) || return 1
	dd if="$stock" of="$tmp/uboot.bin" bs=1 skip=512 count=131072 status=none \
		&& cat "$tmp/uboot.bin" "$RAMPE_SYSUPGRADE" > "$tmp/out.bin" \
		&& groesse_hoechstens "$tmp/uboot.bin" 131072 "U-Boot-Teil" \
		&& mv "$tmp/out.bin" "$ziel" \
		|| { rm -rf "$tmp"; return 1; }
	rm -rf "$tmp"
	echo "    $(basename "$ziel")"
}

# nachbau_tplink_split_uboot <url> <sha256-zip> <mitglied> <sha256-bin> <image-size-kb>
#   Archer C20 v5, C50 v4, C50 v6 (OpenWrt 86e7353b): boot.bin fuer
#   Weboberflaeche und Web-Recovery, tp_recovery.bin fuer TFTP, woertlich:
#     dd if=tpl.bin of=boot.bin bs=131584 count=1
#     cat owrt.bin >> boot.bin
#   und
#     dd if=/dev/zero of=tp_recovery.bin bs=196608 count=1
#     dd if=tpl.bin of=tmp.bin bs=131584 count=1
#     dd if=tmp.bin of=boot.bin bs=512 skip=1
#     cat boot.bin >> tp_recovery.bin
#     cat owrt.bin >> tp_recovery.bin
#   Ergebnis: <praefix>-boot.bin und <praefix>-tp-recovery.bin
nachbau_tplink_split_uboot () {
	local stock tmp
	[ -f "${RAMPE_SYSUPGRADE:-}" ] || { echo "    sysupgrade der RAMpe fehlt" >&2; return 1; }
	groesse_hoechstens "$RAMPE_SYSUPGRADE" $(( $5 * 1024 )) "sysupgrade (IMAGE_SIZE)" || return 1
	stock=$(hersteller_datei "$1" "$2" "$3" "$4") || return 1
	tmp=$(mktemp -d) || return 1
	(
		cd "$tmp" || exit 1
		dd if="$stock" of=boot.bin bs=131584 count=1 status=none || exit 1
		cat "$RAMPE_SYSUPGRADE" >> boot.bin || exit 1
		dd if=/dev/zero of=tp_recovery.bin bs=196608 count=1 status=none || exit 1
		dd if="$stock" of=tmp.bin bs=131584 count=1 status=none || exit 1
		dd if=tmp.bin of=boot-ohne-kopf.bin bs=512 skip=1 status=none || exit 1
		cat boot-ohne-kopf.bin >> tp_recovery.bin || exit 1
		cat "$RAMPE_SYSUPGRADE" >> tp_recovery.bin || exit 1
	) || { rm -rf "$tmp"; return 1; }
	mv "$tmp/boot.bin" "$RAMPE_ZIEL/$RAMPE_PRAEFIX-boot.bin" \
		&& mv "$tmp/tp_recovery.bin" "$RAMPE_ZIEL/$RAMPE_PRAEFIX-tp-recovery.bin" \
		|| { rm -rf "$tmp"; return 1; }
	rm -rf "$tmp"
	echo "    $RAMPE_PRAEFIX-boot.bin, $RAMPE_PRAEFIX-tp-recovery.bin"
}

# nachbau_nullen_davor <bytes> <endung>
#   initramfs der RAMpe mit <bytes> Nullbytes davor, z. B. ZTE MF286R
#   (OpenWrt 7ac8da00, "Method 3"): dd if=/dev/zero of=padding.bin bs=8M count=1;
#   cat padding.bin <initramfs> > root_uImage
#   Ergebnis: <praefix>-<endung>
nachbau_nullen_davor () {
	local ziel="$RAMPE_ZIEL/$RAMPE_PRAEFIX-$2" tmp
	[ -f "${RAMPE_INITRAMFS:-}" ] || { echo "    initramfs der RAMpe fehlt" >&2; return 1; }
	tmp=$(mktemp -d) || return 1
	head -c "$1" /dev/zero > "$tmp/padding.bin" \
		&& cat "$tmp/padding.bin" "$RAMPE_INITRAMFS" > "$tmp/out.bin" \
		&& mv "$tmp/out.bin" "$ziel" \
		|| { rm -rf "$tmp"; return 1; }
	rm -rf "$tmp"
	echo "    $(basename "$ziel")"
}
