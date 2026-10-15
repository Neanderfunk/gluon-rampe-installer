## Vorher prüfen

**Dateiname:** Laut OpenWrt (Stand 2017) muss die Datei genau
`lede-gl-b1300.bin` heißen. Ob neuere Bootloader das noch verlangen, ist
nicht geklärt; mit diesem Namen bist du auf der sicheren Seite.

**LEDs im Notfall-Modus:** Laut GL.iNet bleibt die Power-LED an, die rechte
WLAN-LED blinkt 4-mal, dann leuchtet die mittlere LED. Bei alten B1300
blinken mittlere und rechte LED 5-mal und bleiben dann an.

## Notfall für Erfahrene: TFTP

Liegt die Datei `lede-gl-b1300.bin` auf einem TFTP-Server mit der Adresse
`192.168.1.2` ([TFTP-Server einrichten](grundlagen/tftp-server.md)), holt
der Bootloader sie im Notfall-Modus selbst ab.
