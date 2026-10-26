## Vorher prüfen

Den M3000 gibt es mit zwei verschiedenen Netzwerkchips am WAN-Anschluss, und
jede Sorte braucht ihre eigene Freifunk-Firmware. Welcher in deinem Gerät
steckt, siehst du erst in der Cudy-Oberfläche, das kommt in Schritt 4. Die
Zwischenfirmware ist für beide Sorten dieselbe Datei.

Cudy gibt die Zwischenfirmware für den M3000 in Hardware-Version 1.0 und
2.0 heraus, und OpenWrt nennt für diese Variante dieselbe Datei. Bei uns
hat sie an einem M3000 mit YT8821 aber noch niemand ausprobiert. Wenn du es
tust, sag uns bitte Bescheid, ob es geklappt hat.

## Nach dem Anmelden prüfen

Geh zu **Diagnose-Werkzeuge → Systemprotokoll** und such dort nach `yt8821`.

- `yt8821` gefunden: Diese Anleitung passt, weiter mit dem nächsten Schritt.
- `rtl8221b` gefunden: Hier aufhören und mit der Anleitung und der Firmware
  für den [Cudy M3000 v1](cudy-m3000-v1.md) weitermachen.
- keins von beiden: Router neu starten und noch einmal suchen.
