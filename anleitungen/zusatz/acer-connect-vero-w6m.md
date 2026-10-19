## Achtung

Den Bootloader von Acer stellst du in Schritt 6 so um, dass er die
Signatur nicht mehr prüft, und speicherst das mit `saveenv`. Ohne diese
Änderung lädt er nur Firmware, die Acer unterschrieben hat, also auch die
Freifunk-Firmware nicht. Der Bootloader selbst wird dabei nicht verändert.

## Vorher prüfen

Nicht mit dem **Acer Predator Connect W6** (oder W6d) verwechseln. Die
Namen sind ähnlich, jedes Gerät braucht aber sein eigenes Image. Der
Predator Connect W6 hat zusätzlich einen 2.5-Gbit/s-Anschluss und USB 3,
der Vero W6m nicht. Vergleich den Modellnamen auf dem Typenschild genau.
