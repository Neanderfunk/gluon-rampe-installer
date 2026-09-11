-- Freifunk-Installer, nach einer Idee von oszilloskop:
--   https://github.com/oszilloskop/UBNT_ERX_Gluon_Factory-Image
-- Uebernommen aus build/openwrt/files/lib/gluon/config-mode/controller/ dort
-- (MIT-Lizenz, Copyright (c) 2018 Oszilloskop, siehe LICENSE.oszilloskop),
-- angepasst an Gluon 2025.1 (package-Zeile).
--
-- Die Startseite und "Erweiterte Einstellungen" zeigen direkt auf
-- "Firmware aktualisieren"; Wizard und Fernzugang gibt es nicht.

package 'gluon-web-admin'

local e=node()
if not e.target then
e.target=alias("admin")
end
entry({"admin"},alias("admin","upgrade"),_("Advanced settings"),1)
entry({"admin","info"},template("admin/info"),_("Information"),100)
