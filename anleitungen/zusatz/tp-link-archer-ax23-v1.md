## Vorher prüfen

Hardware-Version 1.0, 1.2 und 1.20 sind gleich, auch der "AX1800" mit
Hardware 1.20 läuft. Der **Archer AX23 v2 geht nicht**, er hat einen ganz
anderen Chip.

## Notfall: Web-Recovery

Der AX23 hat eine Notfall-Seite, die das factory-Image annimmt: Strom aus,
Reset-Taste gedrückt halten, Strom ein, halten, bis die orange WAN-LED
leuchtet. Dann mit fester Adresse im Netz 192.168.0.x die Seite
`http://192.168.0.1` öffnen und das factory-Image hochladen. Laut OpenWrt
geht der Upload auch mit curl ([curl benutzen](grundlagen/curl.md)):

```
curl -F firmware=@factory.bin http://192.168.0.1/f2.htm
```
