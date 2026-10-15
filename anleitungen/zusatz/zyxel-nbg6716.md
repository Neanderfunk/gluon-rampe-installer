## Vorher prüfen

Den NBG6716 gibt es mit verschieden großem Speicher; von außen sieht man das
nicht, die Freifunk-Firmware nutzt in jedem Fall nur 128 MB. Der EMG2926
(Videotron) ist baugleich, lehnt NBG6716-Images aber ab.

Wie die Installation aus der Zyxel-Firmware heraus geht, beschreibt OpenWrt
nicht; diese Anleitung geht vom üblichen Weg über die Weboberfläche aus.

## Zurück zur Zyxel-Firmware

Per TFTP: Rechner fest auf `192.168.1.33`, die Zyxel-Firmware als `ras.bin`
im TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)),
WPS-Taste beim Einschalten halten. Das Schreiben dauert etwa 10 Sekunden,
danach blinken Power- und Key-LED schnell.
