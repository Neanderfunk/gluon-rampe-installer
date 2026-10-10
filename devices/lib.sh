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
