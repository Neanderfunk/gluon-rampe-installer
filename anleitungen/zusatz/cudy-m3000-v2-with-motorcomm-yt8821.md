## Vorher prüfen

Den M3000 gibt es mit zwei verschiedenen Netzwerkchips am WAN-Anschluss, und
jede Sorte braucht ihre eigene Freifunk-Firmware. Welche du hast, zeigt die
Cudy-Oberfläche: Nach Schritt 3 unter **Diagnose-Werkzeuge → Systemprotokoll**
nach `yt8821` suchen.

- `yt8821` gefunden: Diese Anleitung passt.
- `rtl8221b` gefunden: Nimm die Anleitung und die Firmware für den
  [Cudy M3000 v1](cudy-m3000-v1.md).
- keins von beiden: Router neu starten und noch einmal suchen.

Cudy gibt die Zwischenfirmware für den M3000 in Hardware-Version 1.0 und
2.0 heraus, und OpenWrt nennt für diese Variante dieselbe Datei. Bei uns
hat sie an einem M3000 mit YT8821 aber noch niemand ausprobiert. Wenn du es
tust, sag uns bitte Bescheid, ob es geklappt hat.
