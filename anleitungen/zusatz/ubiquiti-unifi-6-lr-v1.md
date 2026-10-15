## Vorher prüfen

Den U6 LR gibt es in drei Versionen, die sich außen wenig unterscheiden.
Jede braucht ihr eigenes Image; mit dem falschen hat das Gerät danach
vermutlich kein Netzwerk.

- **v1:** LED-Leiste, die in Farben leuchten kann
- **v2:** statt der Leiste nur zwei einfache LEDs (weiß und blau)
- **v3:** wie v2, aber mit anderem Netzwerkchip; laut OpenWrt ab
  Produktionswoche 34/2022

Die frühe "U6 LR-EA" ist keine dieser Versionen.

**Schreibschutz ab Herstellerfirmware 6.2:** Läuft auf dem Gerät
Ubiquiti-Firmware 6.2 oder neuer, gib laut OpenWrt nach dem Anmelden
(Schritt 5) zuerst diesen Befehl ein, bevor du mit Schritt 6 weitermachst:

```
echo 5edfacbf > /proc/ubnthal/.uf
```

Weißt du die Version nicht, gib ihn trotzdem ein. Meldet er "No such file or
directory", ist die Firmware älter und du machst einfach mit Schritt 6
weiter.

Ältere Ubiquiti-Firmware antwortet laut OpenWrt eventuell unter
`192.168.1.34` statt `192.168.1.20`.
