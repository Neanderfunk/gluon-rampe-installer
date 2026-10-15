## Vorher prüfen

Die Adresse der D-Link-Oberfläche nennt keine unserer Quellen. Sie steht
meist auf dem Aufkleber.

## Notfall für Erfahrene: Emergency Web Server

Über die serielle Konsole am RJ45-Anschluss "Console" (115200 8N1,
RS-232-Kabel) lässt sich ein Notfall-Webserver starten: innerhalb von zwei
Sekunden nach dem Einschalten `q` drücken. Rechner fest auf `192.168.0.90` an
LAN1, dann `http://192.168.0.50`. Die Konsole meldet am Ende
`write image into flash...OK`; danach Strom aus und wieder an. Meldungen
"checksum bad" laut OpenWrt ignorieren.
