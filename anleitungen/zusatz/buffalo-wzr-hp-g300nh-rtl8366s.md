## Vorher prüfen

Den WZR-HP-G300NH gibt es mit zwei verschiedenen Netzwerkchips (RTL8366S und
RTL8366RB). Die Freifunk-Firmware gibt es **nur für die S-Variante**; mit der
falschen startet das Gerät ohne Netzwerk. Die Variante steht nicht als Text
auf dem Aufkleber. Einen Hinweis gibt der Modellcode (vier oder fünf Zeichen)
oben rechts auf dem Aufkleber mit dem WLAN-Namen; laut der Tabelle im
OpenWrt-Wiki:

- RTL8366S: A0A0, A0A1, A0A3, A0D0, A2F0B, B0B0, B0B0G, B0C0
- RTL8366RB: A0F0B, A1A3, A2A0

Ein Forenbeitrag ordnet A0D0 und B0C0 dagegen der RB-Variante zu. Bei diesen
beiden Codes also besonders vorsichtig sein.

## Notfall für Erfahrene: TFTP im Bootloader

Laut OpenWrt nimmt der Bootloader beim Einschalten ein tftp-Image an. Rechner
fest auf `192.168.11.2`, angeschlossen über einen Switch an der LAN-Buchse
neben WAN. Vor dem Einschalten:

```
arp -s 192.168.11.1 02:AA:BB:CC:DD:1A
curl -T <tftp-Image> tftp://192.168.11.1
```

Während das Image geschrieben wird, blinkt die Diag-LED eine Weile.
