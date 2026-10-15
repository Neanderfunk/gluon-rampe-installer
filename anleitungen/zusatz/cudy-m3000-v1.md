## Vorher prüfen

Den M3000 gibt es mit zwei verschiedenen Netzwerkchips am WAN-Anschluss, und
jede Sorte braucht ihre eigene Freifunk-Firmware. Welche du hast, zeigt die
Cudy-Oberfläche: Nach Schritt 3 unter **Diagnose-Werkzeuge → Systemprotokoll**
nach `rtl8221b` suchen.

- `rtl8221b` gefunden: Diese Anleitung passt.
- `yt8821` gefunden: Nimm die Anleitung und die Firmware für den
  [Cudy M3000 v2 mit Motorcomm YT8821](cudy-m3000-v2-with-motorcomm-yt8821.md).
- keins von beiden: Router neu starten und noch einmal suchen.
