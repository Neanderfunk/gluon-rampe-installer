## Achtung

Läuft auf dem Router die TP-Link-Firmware **Build 151014** (die neueste),
**nicht** direkt die Freifunk-Firmware hochladen. Der Router hängt danach in
einer Startschleife und lässt sich nur noch über den TFTP-Notfall-Weg
retten. Spiel zuerst die ältere TP-Link-Firmware **Build 140709** ein, erst
dann die Freifunk-Firmware. Das wissen wir aus eigener Erfahrung.

## Vorher prüfen

**Firmware-Version nachsehen:** Die TP-Link-Oberfläche zeigt sie auf der
Statusseite ("Firmware Version", mit "Build …" am Ende). Steht dort
**151014**: zuerst über dieselbe Seite für das Firmware-Update die
TP-Link-Firmware **Build 140709** einspielen, den Neustart abwarten und erst
dann mit Schritt 1 anfangen.

Nicht verwechseln mit dem Archer C20 v1 oder dem Archer C2, das sind andere
Geräte.

## Die Rettungsdatei vorbereiten

Für den TFTP-Notfall-Weg (oben) braucht der C20i die **TP-Link-Firmware ohne
ihren ersten 512-Byte-Block**, umbenannt in `ArcherC20iV1_tp_recovery.bin`.
So haben wir unseren C20i aus der Startschleife geholt. Unter Linux oder
macOS im Ordner mit der TP-Link-Datei:

```sh
dd if=<TP-Link-Firmware>.bin of=ArcherC20iV1_tp_recovery.bin bs=512 skip=1
```

Die fertige Datei war bei uns 8.126.464 Bytes groß. Danach läuft wieder die
TP-Link-Firmware; dann wie oben erst Build 140709, dann die
Freifunk-Firmware.
