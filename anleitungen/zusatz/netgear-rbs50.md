## Vorher prüfen

Der RBS50 ist der Satellit eines Orbi-Sets (RBK50), der [RBR50](netgear-rbr50.md) der Router; beide brauchen ihr eigenes Image.

Beim Orbi ist nmrpflash der einfachste Weg; die Netgear-Oberfläche schreibt die Firmware an die falsche Stelle (siehe unten).

## Für Erfahrene: über die Netgear-Oberfläche

Die Freifunk-Firmware läuft nur vom ersten der beiden Firmware-Speicher, die
Netgear-Oberfläche schreibt aber immer in den gerade nicht benutzten. Laut
OpenWrt geht es trotzdem: Über `http://192.168.1.250/debug.htm`
(Benutzer `admin`, Passwort `password`) Telnet einschalten, per Telnet
`artmtd -w boot_part 02` setzen, neu starten, dann das factory-Image über die
Oberfläche hochladen.
