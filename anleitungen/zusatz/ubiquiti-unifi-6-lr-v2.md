## Vorher prüfen

Den U6 LR gibt es in drei Versionen, die sich außen wenig unterscheiden.
Jede braucht ihr eigenes Image; mit dem falschen hat das Gerät danach
vermutlich kein Netzwerk.

- **v1:** LED-Leiste, die in Farben leuchten kann
- **v2:** statt der Leiste nur zwei einfache LEDs (weiß und blau)
- **v3:** wie v2, aber mit anderem Netzwerkchip; laut OpenWrt ab
  Produktionswoche 34/2022

Die frühe "U6 LR-EA" ist keine dieser Versionen.

Ab Ubiquiti-Firmware 6.2 muss vor den Schreibbefehlen der Schreibschutz
aufgehoben werden (`echo 5edfacbf > /proc/ubnthal/.uf`). Ältere
Ubiquiti-Firmware antwortet laut OpenWrt eventuell unter `192.168.1.34`
statt `192.168.1.20`.

Beim Einschalten leuchtet die weiße LED, die blaue geht an, sobald das System
läuft.
