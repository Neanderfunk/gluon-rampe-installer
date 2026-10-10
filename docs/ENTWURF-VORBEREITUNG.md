# Entwurf: Vorbereitung vor dem sysupgrade (noch nicht übernommen)

Stand 10.10.2026, aus der Rezept-Recherche. Nicht gebaut, nicht getestet.
Für die "teilweise"-Geräte, bei denen der Upload allein nicht reicht: Aruba
AP-303/303H/365, AVM FRITZ!Box 7530/Repeater 1200/3000, ZTE MF289F.

## Aufbau und Skripte

Machbar für Aruba AP-303/303H/365, AVM 7530/Repeater 1200/3000 und ZTE
MF289F [abgeleitet]. Die Befehle stammen wörtlich aus den Commits; ergänzt
sind nur Partitionssuche per Label statt fester mtd-Nummer und `-y` für
`ubiformat` [abgeleitet]. Nicht machbar bzw. nicht belegt: Aruba AP-32x
(Umbau im APBoot), AP11-Entsperrung, AVM-EVA-Schritt, alle seriellen und
Exploit-Schritte.

Aufbau (Vorschlag): Skripte unter `overlay/lib/gluon-rampe/prepare/<board_name
mit _ statt ,>.sh`, der RAMpe-Controller ruft sie in Schritt 3 **synchron**
vor `sysupgrade` auf und bricht mit Fehlermeldung ab, wenn sie scheitern
(Gluons `fork_exec` leitet sonst alles nach /dev/null). `*.early.sh` (nur
MF289F) läuft auf ausdrücklichen Klick vor der Imageprüfung. Board-Namen aus
den platform.sh-Zweigen: `aruba,ap-303`, `aruba,ap-303h`, `aruba,ap-365`,
`avm,fritzbox-7530`, `avm,fritzrepeater-1200`, `avm,fritzrepeater-3000`,
`zte,mf289f` [geprüft]. Der Controller wäre eine geänderte Kopie von Gluons
`upgrade.lua` (Apache-2.0, wie schon `upgrade.html`).

Skripte:

```sh
# overlay/lib/gluon-rampe/prepare/aruba_ap-303.sh
# (gleicher Inhalt: aruba_ap-303h.sh, aruba_ap-365.sh)
# Quelle: OpenWrt 102c8c55f217606cdbdc9a449667e034676b3e75 (AP-303, mtd1),
# c6e972c8772a628a1a2f2e5590d7c6f4acef9ab0 (AP-303H, mtd16),
# 300b7fe85a743ab0e039457a5a551819b49450da (AP-365, "label ubi").
. /lib/functions.sh
mtd=$(find_mtd_index ubi)
[ -n "$mtd" ] || exit 1
ubidetach -p "/dev/mtd$mtd" || true
ubiformat "/dev/mtd$mtd" -y

# overlay/lib/gluon-rampe/prepare/avm_fritzrepeater-1200.sh
# (avm_fritzrepeater-3000.sh: uboot-fritz3000.bin)
# Quelle: OpenWrt 7f187229a8e9b7966248b1e024217e07a9fc3e50 (1200),
# 148d29d47b1d555d0058dcc5dda450b74c4628ec (3000).
ub=/uboot-fritz1200.bin
[ -s "$ub" ] || exit 1
mtd write "$ub" uboot0 || exit 1
mtd write "$ub" uboot1 || exit 1
ubirmvol /dev/ubi0 --name=avm_filesys_0
ubirmvol /dev/ubi0 --name=avm_filesys_1

# overlay/lib/gluon-rampe/prepare/avm_fritzbox-7530.sh
# Quelle: OpenWrt 95b0c07a618fe5fd93a26931152ced483bba143b.
# OFFEN: 7520 und 7530 teilen board_name und Image, brauchen aber
# verschiedene U-Boots. Ohne belegte Erkennung nicht automatisch schreiben.
case "${RAMPE_VARIANT:-}" in        # z.B. Auswahlfeld auf der Seite
	7530) ub=/uboot-fritz7530.bin ;;
	7520) ub=/uboot-fritz7520.bin ;;
	*) echo "7520 oder 7530? Variante nicht angegeben." >&2; exit 1 ;;
esac
[ -s "$ub" ] || exit 1
mtd write "$ub" uboot0 || exit 1
mtd write "$ub" uboot1 || exit 1
ubirmvol /dev/ubi0 --name=avm_filesys_0
ubirmvol /dev/ubi0 --name=avm_filesys_1

# overlay/lib/gluon-rampe/prepare/zte_mf289f.early.sh  (VOR sysupgrade -T)
# Quelle: OpenWrt 0de6a3339f1aadc1de2c9371435e3de239a00645 und
# platform_check_image in target/linux/ipq40xx/base-files/lib/upgrade/platform.sh.
. /lib/functions.sh
mtd=$(find_mtd_index rootfs)
[ -n "$mtd" ] || exit 1
ubiattach -m "$mtd" || true          # Commit: "this can return an error"
ubirmvol /dev/ubi0 -N ubi_rootfs || true
ubirmvol /dev/ubi0 -N ubi_rootfs_data || true   # "some devices doesn't have it"
```

Offen beim Hook: die Auswahl 7520/7530 (`RAMPE_VARIANT`) braucht ein Feld auf
der Seite und die Weitergabe im Controller (im Patch unten nicht enthalten);
ob die RAMpe nach `ubiformat` bzw. `ubirmvol` das sysupgrade ohne erneutes
`ubiattach` schafft, hängt an `nand_do_upgrade` und ist nur für OpenWrt per
Commit belegt [abgeleitet: gleiche Befehlsfolge wie im Commit].

## Patch: Overlay, Controller (neue Datei, Kopie von Gluons upgrade.lua)

`luac -p` ok [geprüft]. Die Kopie gehört nach
`overlay/lib/gluon/config-mode/controller/admin/upgrade.lua`, Lizenzkopf von
Gluon (Apache-2.0) bleibt.

```diff
--- a/(Gluon v2025.1.3) package/gluon-web-admin/luasrc/lib/gluon/config-mode/controller/admin/upgrade.lua
+++ b/overlay/lib/gluon/config-mode/controller/admin/upgrade.lua
@@ -19,6 +19,32 @@
 local tmpfile = "/tmp/firmware.img"
 local compat_option = "--ignore-minor-compat-version"
 
+-- Gluon-RAMpe: geraeteabhaengige Vorbereitung vor dem sysupgrade.
+-- /lib/gluon-rampe/prepare/<board_name, Komma -> _>.sh       vor sysupgrade
+-- /lib/gluon-rampe/prepare/<board_name, Komma -> _>.early.sh vor sysupgrade -T
+--   (nur ZTE MF289F: platform_check_image lehnt ab, solange ubi_rootfs da ist)
+local function rampe_prepare_script(kind)
+	local f = io.open('/tmp/sysinfo/board_name')
+	if not f then
+		return nil
+	end
+	local board = f:read('*l') or ''
+	f:close()
+	local path = '/lib/gluon-rampe/prepare/' .. board:gsub(',', '_') .. kind .. '.sh'
+	if unistd.access(path) then
+		return path
+	end
+end
+
+local function rampe_prepare(kind)
+	local script = rampe_prepare_script(kind)
+	if not script then
+		return true
+	end
+	return os.execute(string.format(
+		'exec /bin/sh %q >>/tmp/gluon-rampe-prepare.log 2>&1', script)) == 0
+end
+
 
 local function filehandler(_, chunk, eof)
 	if not unistd.access(tmpfile) and not file and chunk and #chunk > 0 then
@@ -98,6 +124,13 @@
 	-- Determine state
 	local step = tonumber(http:getenv("REQUEST_METHOD") == "POST" and http:formvalue("step")) or 1
 
+	-- Gluon-RAMpe: Vorbereitung vor der Pruefung, nur auf ausdruecklichen
+	-- Klick (Feld rampe_early, die View zeigt es nur, wenn ein .early.sh da ist)
+	local early_failed = false
+	if http:getenv("REQUEST_METHOD") == "POST" and http:formvalue("rampe_early") == "1" then
+		early_failed = not rampe_prepare('.early')
+	end
+
 	local has_image   = unistd.access(tmpfile)
 	local has_support = has_image and image_supported(tmpfile)
 
@@ -111,6 +144,8 @@
 
 		renderer.render_layout('admin/upgrade', {
 			bad_image = has_image and not has_support,
+			rampe_early = rampe_prepare_script('.early') ~= nil,
+			rampe_early_failed = early_failed,
 		}, 'gluon-web-admin')
 
 	-- Step 2: present uploaded file, show checksum, confirmation
@@ -123,6 +158,15 @@
 		}, 'gluon-web-admin')
 
 	elseif step == 3 then
+		-- Gluon-RAMpe: Vorbereitung (ubiformat, U-Boot schreiben ...) synchron,
+		-- damit ein Fehler auf der Seite landet statt hinter /dev/null
+		if not rampe_prepare('') then
+			renderer.render_layout('admin/upgrade', {
+				bad_image = false,
+				rampe_prepare_failed = true,
+			}, 'gluon-web-admin')
+			return
+		end
 		local cmd = {[0] = '/sbin/sysupgrade', compat_option, tmpfile}
 		if http:formvalue('keepcfg') ~= '1' then
 			table.insert(cmd, 1, '-n')
```

## Patch: Overlay, View (Skizze, ohne Zeilennummern)

```diff
--- a/overlay/lib/gluon/config-mode/view/admin/upgrade.html
+++ b/overlay/lib/gluon/config-mode/view/admin/upgrade.html
@@
 	<% if bad_image then %>
 	<p class="error"><%:The provided firmware image is not valid for this device.%></p>
 	<% end %>
+	<% if rampe_prepare_failed then %>
+	<p class="error">Die Vorbereitung dieses Geräts ist fehlgeschlagen, es wurde
+	nichts geflasht. Protokoll: /tmp/gluon-rampe-prepare.log</p>
+	<% end %>
+	<% if rampe_early_failed then %>
+	<p class="error">Das Entfernen der Herstellerfirmware ist fehlgeschlagen.</p>
+	<% end %>
 	<div class="gluon-section-node">
@@
 </form>
+<% if rampe_early then %>
+<form method="post" action="<%|url(request)%>">
+	<p>
+		Bei diesem Gerät muss die Herstellerfirmware erst entfernt werden, sonst
+		lehnt die Prüfung das Freifunk-Image ab. Das lässt sich nicht rückgängig
+		machen. Wer zurück zur Herstellerfirmware will, sichert vorher die
+		Partitionen (siehe Anleitung).
+	</p>
+	<div class="gluon-page-actions">
+		<input type="hidden" name="step" value="1">
+		<input type="hidden" name="rampe_early" value="1">
+		<input class="gluon-button" type="submit" value="Herstellerfirmware entfernen">
+	</div>
+</form>
+<% end %>
```

## Vorschlag, nicht ausgearbeitet: ensure_openwrt_snippet (RT-AX59U)

Ein RAMpe-TRX für die RT-AX59U bräuchte in
`openwrt/target/linux/mediatek/image/filogic.mk`, Device/asus_rt-ax59u,
dieselben Zeilen wie bei der RT-AX52 [geprüft: RT-AX52-Rezept]:

```make
ifeq ($(IB),)
  ARTIFACTS := initramfs.trx
  ARTIFACT/initramfs.trx := append-image-stage initramfs-kernel.bin | \
	uImage none | asus-trx -v 3 -n $$(DEVICE_MODEL)
endif
```

Das wäre ein Eingriff in den OpenWrt-Baum nach `make update` (dort setzt
`make update` ihn wieder zurück). Ob die Stock-UI der RT-AX59U ein solches
TRX annimmt, ist nicht belegt; der Commit nennt nur ein fremdes "transit TRX".
Deshalb nicht im Rezept.

Lizenz dieser Datei: CC BY-SA 4.0; die Codeausschnitte aus Gluons
`upgrade.lua` stehen unter Apache-2.0.
