## Achtung

Läuft auf dem Router die TP-Link-Firmware **Build 151014** (die neueste),
**nicht** direkt die Freifunk-Firmware hochladen. Der Router hängt danach in
einer Startschleife und lässt sich nur noch über den TFTP-Notfall-Weg
retten. Spiel zuerst die ältere TP-Link-Firmware **Build 140709** ein, erst
dann die Freifunk-Firmware. Das wissen wir aus eigener Erfahrung.

## Vorher prüfen

**Firmware-Version nachsehen:** Die TP-Link-Oberfläche zeigt sie auf der
Statusseite ("Firmware Version", mit "Build …" am Ende). Steht dort
**151014**: zuerst über dieselbe Seite für das Firmware-Update die
TP-Link-Firmware **Build 140709** einspielen, den Neustart abwarten und erst
dann mit Schritt 1 anfangen.

Nicht verwechseln mit dem Archer C20 v1 oder dem Archer C2, das sind andere
Geräte.

## Notfall: TFTP

Hängt der Router in einer Startschleife, holt er sich laut OpenWrt beim
Einschalten mit gedrückter Reset-Taste eine Datei namens
`ArcherC20iV1_tp_recovery.bin` von einem TFTP-Server mit der Adresse
`192.168.0.66` ([TFTP-Server einrichten](grundlagen/tftp-server.md),
[Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
