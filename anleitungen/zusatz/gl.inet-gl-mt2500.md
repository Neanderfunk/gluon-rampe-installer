## Vorher prüfen

Neuere MT2500 haben einen anderen Netzwerkchip (Airoha statt MaxLinear).
Für diese Variante gibt es in OpenWrt ein eigenes Image, das Gluon nicht
baut; diese Anleitung gilt nur für die MaxLinear-Variante. Woran man die
Variante von außen erkennt, nennt keine unserer Quellen.

Einen Notfall-Modus beschreibt GL.iNet auch für den MT2500 (Power-LED blinkt
5-mal blau, dann dauerhaft weiß). Laut OpenWrt nimmt der Bootloader dort aber
keine fremden Images an.
