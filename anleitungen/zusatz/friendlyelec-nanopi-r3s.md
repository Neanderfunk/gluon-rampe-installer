## Vorher prüfen

Den R3S gibt es mit 1 oder 2 GB Arbeitsspeicher und mit oder ohne
eingebauten Speicher (eMMC); die Freifunk-Firmware ist für alle gleich. Ist
im eingebauten Speicher noch das System von FriendlyElec, ist nicht belegt,
dass der R3S zuerst von der Karte startet.

## Für Erfahrene: in den eingebauten Speicher

Laut OpenWrt: erst von der Karte starten, dann auf dem Gerät das ausgepackte
Image in den eingebauten Speicher schreiben (`dd if=<Image>.img
of=/dev/mmcblk0`, danach `sync`), Karte ziehen, neu starten.
