## Achtung

Nicht mit dem **Cudy WR1300** verwechseln: Die Dateinamen sehen sich
ähnlich (`…-gl.inet-gl-b1300-sysupgrade.bin` und
`…-cudy-wr1300-v1-sysupgrade.bin`). Meldet LuCI beim Hochladen "not
supported by this image", ist es die falsche Datei.

## Notfall-Modus: Dateiname und LEDs

**Dateiname:** Laut OpenWrt (Stand 2017) muss die Datei genau
`lede-gl-b1300.bin` heißen. Ob neuere Bootloader das noch verlangen, ist
nicht geklärt; mit diesem Namen bist du auf der sicheren Seite.

**LEDs:** Bei alten B1300 blinken laut GL.iNet mittlere und rechte LED
5-mal und bleiben dann an.

## Zurück zur GL.iNet-Firmware

Über den Notfall-Modus nimmt der B1300 auch die Firmware von GL.iNet wieder
an. Lade sie unter
[dl.gl-inet.com/router/b1300/stable](https://dl.gl-inet.com/router/b1300/stable)
herunter und spiel sie über die Notfall-Seite auf, wie oben beschrieben.
Bei uns hat das geklappt: Nach etwa 9 Minuten war die GL.iNet-Oberfläche
wieder unter `http://192.168.8.1` erreichbar.

## Notfall für Erfahrene: TFTP

Liegt die Datei `lede-gl-b1300.bin` auf einem TFTP-Server mit der Adresse
`192.168.1.2` ([TFTP-Server einrichten](grundlagen/tftp-server.md)), holt
der Bootloader sie im Notfall-Modus selbst ab.
