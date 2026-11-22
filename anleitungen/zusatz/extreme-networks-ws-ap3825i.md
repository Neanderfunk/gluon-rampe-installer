## Achtung

Das Schreiben der Freifunk-Firmware und der erste Start danach dauern bei
diesem Gerät **sehr lange, länger, als es sich gut anfühlt**. Es kann etwa
11 Minuten dauern, bis er wieder unter `192.168.1.1` antwortet, und die
Konsole bleibt dabei lange stumm. **Nicht den Strom ziehen**, auch wenn
scheinbar nichts passiert.

## Vorher prüfen

- Die WS-AP3825i hat dasselbe Gehäuse wie die Enterasys WS-AP3725i und die
  Adtran BSAP-2030. Ob die dieselbe Firmware vertragen, ist nicht geklärt.
  Nimm diese Anleitung nur für eine WS-AP3825i (Typenschild).

## Wenn etwas schiefgeht

- **Statt `Boot (PRI)->` erscheint eine Eingabe wie `/flash/home/admin`,
  oder `setenv` ist unbekannt.** Dann bist du nicht im Bootloader, sondern
  schon in der Herstellerfirmware. Strom ziehen, Schritt 5 wiederholen und
  Enter drücken, sobald `Scanning JFFS2 FS:` erscheint.
- **Der Start bleibt mit `ft_fixup_l2cache: FDT_ERR_NOTFOUND` stehen.** Das
  OpenWrt-initramfs ist zu neu. Nimm genau die Version 22.03.0 von oben.
