## Vorher prüfen

Den M3000 gibt es mit zwei verschiedenen Netzwerkchips am WAN-Anschluss, und
jede Sorte braucht ihre eigene Freifunk-Firmware. Welcher in deinem Gerät
steckt, siehst du erst in der Cudy-Oberfläche, das kommt in Schritt 4. Die
Zwischenfirmware ist für beide Sorten dieselbe Datei.

## Nach dem Anmelden prüfen

Geh zu **Diagnose-Werkzeuge → Systemprotokoll** und such dort nach `rtl8221b`.

- `rtl8221b` gefunden: Diese Anleitung passt, weiter mit dem nächsten Schritt.
- `yt8821` gefunden: Hier aufhören und mit der Anleitung und der Firmware
  für den [Cudy M3000 v2 mit Motorcomm YT8821](cudy-m3000-v2-with-motorcomm-yt8821.md)
  weitermachen.
- keins von beiden: Router neu starten und noch einmal suchen.
