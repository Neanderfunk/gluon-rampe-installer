# Entwurf: Vorbereitung vor dem sysupgrade

Stand 10.10.2026, aus der Rezept-Recherche. **Seit 15.10.2026 ist Variante A
für AVM FRITZ!Box 7520/7530 und FRITZ!Repeater 1200/3000 übernommen**
(Controller `overlay/lib/gluon/config-mode/controller/admin/upgrade.lua`,
Skripte `overlay/lib/gluon-rampe/prepare/`, ohne den `.early`-Teil; die
7520/7530-Wahl nach HWRevision statt per Feld, siehe NOTIZEN). Für alle
anderen Geräte unten bleibt es Entwurf: nicht gebaut, nicht getestet.
Für die "teilweise"-Geräte, bei denen der Upload allein nicht reicht: Aruba
AP-303/303H/365, AVM FRITZ!Box 7530/Repeater 1200/3000, ZTE MF289F (Variante A);
OCEDO Koala/Raccoon/Panda, Sophos RED 15w, ZTE MF281, AVM 7412/7430 (Variante B).

## Variante A: Haken im Controller der Upload-Seite

### Aufbau und Skripte

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

## Variante B: Haken in `platform_pre_upgrade`

Zweiter Entwurf aus der Rezept-Recherche (Gruppe B), ebenfalls nicht übernommen.
Statt den Controller zu ändern, hängt sich die RAMpe in OpenWrts sysupgrade:
stage2 ruft `platform_pre_upgrade` auf, nachdem die Dienste beendet sind. Das
greift nur auf Targets ohne eigenes `platform_pre_upgrade` (in 24.10 haben
filogic, qualcommax und imx eins), und Fehler sieht man nur auf der seriellen
Konsole, weil die Seite dann schon "wird aktualisiert" zeigt. Variante A
(Controller) meldet Fehler auf der Seite und deckt auch die ipq40xx-Geräte
ab; vor der Übernahme beide abwägen.

`overlay/lib/gluon-rampe/prepare.d/avm,fritz7412`:

```sh
#!/bin/sh
# AVM FRITZ!Box 7412 / 7430 (lantiq-xrx200): Steht linux_fs_start auf 1,
# waehlt der Bootloader den falschen Partitionssatz.
# Quelle: OpenWrt 20f48c8ae334f8502e756282995cc84d89fa81c1 (7412) und
# 6c85a449a988876fdfd4ce84d6aa5ffe4a2820c1 (7430):
#   fritz_tffs_nand -d /dev/mtd1 -n linux_fs_start
# mtd1 ist laut DTS "nand-tffs"; hier ueber den Namen gesucht.
# Bei 1 nicht flashen, sondern neu starten: die Box startet dann FRITZ!OS
# (die RAMpe lag nur im RAM). Abhilfe laut Commit: FRITZ!OS-Update oder
# Recovery, beim 7430 auch per FTP auf 0 setzen.
# Ungetestet. Die Meldung erscheint nur auf der Konsole.
. /lib/functions.sh
idx="$(find_mtd_index nand-tffs)"
[ -n "$idx" ] || exit 0
val="$(fritz_tffs_nand -d "/dev/mtd$idx" -n linux_fs_start 2>/dev/null | tr -d '\000\n ')"
if [ "$val" = 1 ]; then
	echo "linux_fs_start=1: Abbruch ohne Flashen, Neustart in FRITZ!OS"
	sync
	reboot -f
fi
exit 0
```

`overlay/lib/gluon-rampe/prepare.d/avm,fritz7430`:

```sh
#!/bin/sh
# AVM FRITZ!Box 7412 / 7430 (lantiq-xrx200): Steht linux_fs_start auf 1,
# waehlt der Bootloader den falschen Partitionssatz.
# Quelle: OpenWrt 20f48c8ae334f8502e756282995cc84d89fa81c1 (7412) und
# 6c85a449a988876fdfd4ce84d6aa5ffe4a2820c1 (7430):
#   fritz_tffs_nand -d /dev/mtd1 -n linux_fs_start
# mtd1 ist laut DTS "nand-tffs"; hier ueber den Namen gesucht.
# Bei 1 nicht flashen, sondern neu starten: die Box startet dann FRITZ!OS
# (die RAMpe lag nur im RAM). Abhilfe laut Commit: FRITZ!OS-Update oder
# Recovery, beim 7430 auch per FTP auf 0 setzen.
# Ungetestet. Die Meldung erscheint nur auf der Konsole.
. /lib/functions.sh
idx="$(find_mtd_index nand-tffs)"
[ -n "$idx" ] || exit 0
val="$(fritz_tffs_nand -d "/dev/mtd$idx" -n linux_fs_start 2>/dev/null | tr -d '\000\n ')"
if [ "$val" = 1 ]; then
	echo "linux_fs_start=1: Abbruch ohne Flashen, Neustart in FRITZ!OS"
	sync
	reboot -f
fi
exit 0
```

`overlay/lib/gluon-rampe/prepare.d/ocedo,koala`:

```sh
#!/bin/sh
# OCEDO Koala und Raccoon (ath79-generic): Flip-Flop-Bootloader auf den Teil
# stellen, in den sysupgrade schreibt. OpenWrts sysupgrade tut das nicht.
# Quelle: OpenWrt c4931713df8ffb3c4e5c1be7d0b6d4aa96a7dd4c (Koala) und
# 647614803473757e3b2d93d46938afccd61a5a5d (Raccoon), Abschnitt Installation:
#   fw_setenv bootcmd run bootcmd_1
# fw_env.config: package/boot/uboot-envtools/files/ath79 (ocedo,koala|raccoon).
# Ungetestet.
fw_setenv bootcmd run bootcmd_1
```

`overlay/lib/gluon-rampe/prepare.d/ocedo,panda`:

```sh
#!/bin/sh
# OCEDO Panda (mpc85xx-p1020): UBI-Volumes der Hersteller-Firmware (erster
# Satz) entfernen, damit sysupgrade Platz findet, und U-Boot auf das
# OpenWrt-Kernel-Volume umstellen.
# Quelle: OpenWrt b368373fab45f31963cd2bc1c6ab90e0a577e611, Schritte 6 und 7
# (Befehle unveraendert; bootcmd_owrt steht dort auf zwei Zeilen umbrochen).
# /dev/ubi0 haengt dank bootargs-override "ubi.mtd=3,2048" (panda.dts) schon.
# kernel2/rootfs2/devicetree2/storage bleiben, wie im Commit vorgeschlagen,
# fuer den Rueckweg stehen.
# Ungetestet.
for vol in kernel1 rootfs1 devicetree1; do
	ubirmvol /dev/ubi0 --name="$vol" || echo "Volume $vol nicht entfernt (schon weg?)"
done
fw_setenv bootcmd_owrt "ubi part ubi && ubi read 0x1000000 kernel && bootm 0x1000000"
fw_setenv bootargs_owrt "setenv bootargs console=ttyS0,115200 ubi.mtd=3,2048"
fw_setenv bootcmd "run bootargs_owrt; run bootcmd_owrt"
```

`overlay/lib/gluon-rampe/prepare.d/ocedo,raccoon`:

```sh
#!/bin/sh
# OCEDO Koala und Raccoon (ath79-generic): Flip-Flop-Bootloader auf den Teil
# stellen, in den sysupgrade schreibt. OpenWrts sysupgrade tut das nicht.
# Quelle: OpenWrt c4931713df8ffb3c4e5c1be7d0b6d4aa96a7dd4c (Koala) und
# 647614803473757e3b2d93d46938afccd61a5a5d (Raccoon), Abschnitt Installation:
#   fw_setenv bootcmd run bootcmd_1
# fw_env.config: package/boot/uboot-envtools/files/ath79 (ocedo,koala|raccoon).
# Ungetestet.
fw_setenv bootcmd run bootcmd_1
```

`overlay/lib/gluon-rampe/prepare.d/sophos,red-15w-rev1`:

```sh
#!/bin/sh
# Sophos RED 15w Rev. 1 (mpc85xx-p1010): frisches UBI anlegen.
# Quelle: OpenWrt 97e4311fca73d064d17065e7844699aa777cb157, Schritt 7:
#   ubiformat /dev/mtd4 -y
# mtd4 ist laut red-15w-rev1.dts die Partition "ubi" (u-boot, u-boot-env,
# provisioning, kernel, ubi); hier ueber den Namen gesucht.
# bootcmd/bootargs_owrt + saveenv bleiben seriell (Commit Schritt 3), die
# RAMpe kommt ohnehin nur per TFTP von der Konsole aus hoch.
# Ungetestet.
. /lib/functions.sh
idx="$(find_mtd_index ubi)"
[ -n "$idx" ] || { echo "keine mtd-Partition ubi"; exit 1; }
ubidetach -p "/dev/mtd$idx" 2>/dev/null
ubiformat "/dev/mtd$idx" -y
```

`overlay/lib/gluon-rampe/prepare.d/zte,mf281`:

```sh
#!/bin/sh
# ZTE MF281 (ath79-nand): Der Commit schreibt statt sysupgrade das
# factory-Image (Kernel + frisches UBI) mit "mtd write factory.bin firmware".
# Die RAMpe nimmt nur sysupgrade-Images. Gleichwertig [abgeleitet]: das UBI
# im Bereich "ubi" (Teil von "firmware", mtd-Layout qca9563_zte_mf281.dts)
# neu formatieren; nand_do_upgrade schreibt danach den Kernel nach "kernel"
# und legt die Volumes im leeren UBI an.
# Quelle des Original-Wegs: OpenWrt 1e1695f959e678868bb7911d059b847f38fc9cf4.
# Ungetestet, nicht durch den Commit gedeckt.
. /lib/functions.sh
idx="$(find_mtd_index ubi)"
[ -n "$idx" ] || { echo "keine mtd-Partition ubi"; exit 1; }
ubidetach -p "/dev/mtd$idx" 2>/dev/null
ubiformat "/dev/mtd$idx" -y
```

`overlay/lib/upgrade/zz-gluon-rampe.sh`:

```sh
# Gluon-RAMpe: geraeteabhaengige Vorbereitung vor dem Flashen.
#
# Manche Geraete brauchen vor dem sysupgrade einen Schritt, den OpenWrts
# Anleitung von Hand per SSH vorsieht (UBI-Volumes der Hersteller-Firmware
# entfernen, U-Boot-Umgebung umstellen, ubiformat). Die Gluon-RAMpe hat keine
# Shell fuer die Nutzer, also erledigt sie das selbst:
# /lib/gluon-rampe/prepare.d/<board_name>, falls vorhanden.
#
# Einhaengepunkt: OpenWrts stage2 (package/base-files/files/lib/upgrade/stage2)
# ruft platform_pre_upgrade auf, nachdem die Dienste beendet sind und bevor
# es in die ramfs wechselt; das Rootfs der RAMpe (fw_setenv, ubi-utils) ist
# dann noch da. Diese Datei wird per "include /lib/upgrade" nach platform.sh
# eingelesen ("zz-" sortiert hinter "platform.sh"). Bringt das Target selbst
# ein platform_pre_upgrade mit (in OpenWrt 24.10: mediatek/filogic,
# qualcommax/ipq807x, imx), bleibt dessen Fassung stehen und die
# RAMpe-Vorbereitung entfaellt dort.

if ! type platform_pre_upgrade >/dev/null 2>&1; then
platform_pre_upgrade() {
	local prep="/lib/gluon-rampe/prepare.d/$(board_name)"

	[ -x "$prep" ] || return 0
	v "Gluon-RAMpe: Vorbereitung $prep"
	"$prep" "$1" 2>&1 | while read -r line; do v "  $line"; done
}
fi
```

### Aerohive HiveAP 330: U-Boot-Patch (nur Entwurf)

Schreibt den Bootloader und braucht `kmod-mtd-rw`; absichtlich in keinem Patch.

```sh
#!/bin/sh
# ENTWURF, NICHT AKTIV - schreibt den Bootloader des Aerohive HiveAP 330.
# Gedacht als overlay/lib/gluon-rampe/prepare.d/aerohive,hiveap-330, nur nach
# Freigabe durch adorfer und erst nach einem Test mit serieller Konsole und
# Rueckweg (U-Boot-Sicherung).
#
# Quelle: OpenWrt cfe79f2eb8b3c874f3d1a4441b8a60af32169974 (Schritt 3) und
# DEVICE_COMPAT_MESSAGE in target/linux/mpc85xx/image/p1020.mk am Pin
# a1ea57bd050c172fdc2b851824ebd9782aafb055. Befehle von dort, ergaenzt um eine
# Pruefsummen-Sperre: nur das im Commit genannte U-Boot (U-Boot 2009.11,
# Jan 12 2017, Build jenkins-HiveOS-Honolulu_AP350_Rel-245) wird gepatcht.
# owrt_boot setzt der Commit schon im U-Boot (Schritt 2, seriell); hier nur
# zur Sicherheit, falls es fehlt.
# Voraussetzungen: kmod-mtd-rw im Image (site/image-customization.lua),
# uboot-envtools + fw_env.config fuer aerohive,hiveap-330 (u-boot-env, 0x0,
# 0x20000, 0x10000) [geprueft], busybox strings/md5sum/dd (Default y)
# [geprueft: package/utils/busybox/Config-defaults.in].
. /lib/functions.sh

# Ohne gepatchtes U-Boot startet die Community-Firmware nach dem Flashen
# nicht. Darum bei jedem Fehler abbrechen, BEVOR geflasht wird: Neustart,
# die RAMpe lag nur im RAM, im Flash ist noch die Hersteller-Firmware.
abbruch() { echo "$1 - Abbruch ohne Flashen, Neustart"; sync; reboot -f; exit 1; }

UBOOT_ORIG=d84b45a2e8aca60d630fbd422efc6b39
UBOOT_PATCHED=6dc420f24c2028b9cf7f0c62c0c7f692

fw_printenv -n owrt_boot >/dev/null 2>&1 || \
	fw_setenv owrt_boot 'setenv bootargs console=ttyS0,9600;bootm 0xEC040000 - 0xEC000000'

idx="$(find_mtd_index u-boot)"
[ -n "$idx" ] || abbruch "keine mtd-Partition u-boot"
cp "/dev/mtd$idx" /tmp/uboot
case "$(md5sum < /tmp/uboot | cut -d' ' -f1)" in
	"$UBOOT_PATCHED") echo "U-Boot schon gepatcht"; exit 0 ;;
	"$UBOOT_ORIG") ;;
	*) abbruch "unbekanntes U-Boot, seriell nach OpenWrt-Wiki vorgehen" ;;
esac

insmod mtd-rw i_want_a_brick=y || abbruch "mtd-rw fehlt"
cp /tmp/uboot /tmp/uboot_patched
strings -td < /tmp/uboot | grep '^ *[0-9]* *\(run owrt_boot\|setenv bootargs\).*cp\.l' | \
	awk '{print $1}' | \
	while read offset; do
		echo -n "run owrt_boot;            " | dd of=/tmp/uboot_patched bs=1 seek=${offset} conv=notrunc
	done
[ "$(md5sum < /tmp/uboot_patched | cut -d' ' -f1)" = "$UBOOT_PATCHED" ] || \
	abbruch "Patch-Ergebnis weicht ab, nichts geschrieben"
# Scheitert erst das Schreiben, ist ein Neustart das Schlimmste, was man tun
# kann (halbes U-Boot). Dann nur melden; offen, wie die RAMpe das sichtbar macht.
mtd write /tmp/uboot_patched u-boot || echo "mtd write u-boot fehlgeschlagen - NICHT ausschalten, seriell pruefen"
```

Lizenz dieser Datei: CC BY-SA 4.0; die Codeausschnitte aus Gluons
`upgrade.lua` stehen unter Apache-2.0.
