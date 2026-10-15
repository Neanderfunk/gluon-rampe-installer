## Vorher prüfen

WNDR3700 v1, WNDR3700 v2, WNDR3800, WNDR3800CH und WNDRMAC v2 sind eine
Gerätefamilie, aber jedes Modell braucht sein **eigenes** Image. Der
WNDR3700 v3 geht nicht (anderer Chip), der WNDR3700 v4 ist ein anderes
Gerät mit eigenem Image.

**v1 oder v2?** Auf dem Aufkleber sind die beiden oft nicht zu
unterscheiden. Hinweise laut OpenWrt: Auf dem Karton steht bei der v2
"(WNDR3700v2)" unter "Package Contents"; die Netgear-Oberfläche zeigt die
Hardware-Version unter "Maintenance" bzw. "Router Status"; Herstellerfirmware
1.0.4.x und höher gehört zur v1, 1.0.1.x und älter zur v2.

Außerhalb Nordamerikas warnt die Netgear-Oberfläche womöglich, das Image
gebe sich als Nordamerika-Version aus. Laut OpenWrt kannst du das
ignorieren.

Geräte mit nordamerikanischer Netgear-Firmware nehmen das Freifunk-Image
womöglich nicht an; dafür gäbe es ein eigenes Image, das Gluon nicht baut.
