## Vorher prüfen

Der COVR-X1860 (zwei Netzwerkbuchsen, Steckernetzteil) ist ähnlich wie der
DAP-X1860 (Steckdosengerät), hat aber sein eigenes Image. Die Sets
COVR-X1862 und COVR-X1863 enthalten zwei bzw. drei COVR-X1860.

## Notfall: Web-Recovery

Reset-Taste (Unterseite) beim Einschalten gedrückt halten, bis die
Status-LED oben **rot blinkt**. Rechner fest auf `192.168.0.10`, Netzmaske
`255.255.255.0`, Kabel an die rechte LAN-Buchse. Dann in einem
Chromium-basierten Browser `http://192.168.0.1` öffnen und das
Gluon-**recovery**-Image (nicht das factory) hochladen. Die Notfall-Seite
antwortet nicht auf `ping`.
