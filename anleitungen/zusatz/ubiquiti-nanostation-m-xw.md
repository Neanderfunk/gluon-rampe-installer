## Vorher prüfen

Die NanoStation M XW hat **zwei** Netzwerkanschlüsse. Nicht verwechseln mit der [NanoStation Loco M XW](ubiquiti-nanostation-loco-m-xw.md) mit einem Anschluss.

Die Freifunk-Firmware für dieses Gerät ist nur für die Bauart **XW**. Die
Bauart steht in der Versionsangabe der Ubiquiti-Firmware (AirOS, unter
"Settings → System"), zum Beispiel "XW.v6…". Geräte der Bauart XM brauchen
ein anderes Image.

Laut OpenWrt nehmen XW-Geräte fremde Firmware nur bis AirOS 6.0.4 an; neuere
Versionen verlangen signierte Firmware. Ob das auch für den TFTP-Weg gilt,
ist nicht geklärt. Klappt es nicht, beschreibt OpenWrt unter
<https://openwrt.org/toh/ubiquiti/common> den Weg über eine ältere
AirOS-Version.
