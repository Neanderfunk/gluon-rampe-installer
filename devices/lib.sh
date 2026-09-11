# devices/lib.sh - Helfer fuer die Geraete-Rezepte.
#
# Ein Rezept (devices/<gluon-geraetename>.sh) schaltet im Gluon-Baum ein, was
# der Installer fuer dieses Geraet braucht: ein initramfs und das Image, das
# sich ueber die Hersteller-Firmware oder -Recovery einspielen laesst. Beides
# per Aenderung an gluon/targets/<target>. build.sh setzt targets/ vor jedem
# Lauf per git zurueck, die Rezepte muessen also nur hinzufuegen.
#
# Erwartet GLUON_DIR (von build.sh gesetzt).

# ensure_target_config <target> <OPENWRT_CONFIG>
#   haengt config('<OPENWRT_CONFIG>', true) an targets/<target>, falls es fehlt
ensure_target_config () {
	local f="$GLUON_DIR/targets/$1"
	[ -f "$f" ] || { echo "Target $1 gibt es in diesem Gluon nicht." >&2; return 1; }
	if ! grep -q "config('$2', true)" "$f"; then
		sed -i "1i config('$2', true)" "$f"
		echo "  $1: config('$2', true) ergaenzt"
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
    new = block[:block.rstrip().rfind('})')].rstrip() + "\n\textra_images = {\n\t\t%s,\n\t},\n})" % entry
else:
    new = block[:-1] + ", {\n\textra_images = {\n\t\t%s,\n\t},\n})" % entry
s = s[:m.start()] + new + s[end + 1:]
open(path, 'w').write(s)
print("  %s: extra_images %s ergaenzt" % (dev, entry))
PY
}
