## Vorher prüfen

Den M3000 gibt es mit zwei verschiedenen Netzwerkchips am WAN-Anschluss, und
jede Sorte braucht ihre eigene Freifunk-Firmware. Welche du hast, zeigt die
Cudy-Oberfläche: Nach Schritt 3 unter **Diagnose-Werkzeuge → Systemprotokoll**
nach `yt8821` suchen.

- `yt8821` gefunden: Diese Anleitung passt.
- `rtl8221b` gefunden: Nimm die Anleitung und die Firmware für den
  [Cudy M3000 v1](cudy-m3000-v1.md).
- keins von beiden: Router neu starten und noch einmal suchen.

Ob die Zwischenfirmware aus dem Ordner "M3000_1.0_2.0" auch zu dieser
Variante passt, ist noch nicht geklärt. Wenn du es ausprobierst, sag uns
bitte Bescheid, ob es geklappt hat.
