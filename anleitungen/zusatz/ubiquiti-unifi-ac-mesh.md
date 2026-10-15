## Vorher prüfen

AC Lite, AC LR und AC Mesh sind innen gleich, haben aber verschiedene
Antennen und brauchen je ihr **eigenes** Image. Lies den Aufkleber genau.

Am einfachsten geht es laut OpenWrt mit der Ubiquiti-Firmware **3.7.58**. Ab
Version 6.5.28 klappt nur der Weg mit `dd`, wie er hier steht. Der Befehl,
der den Schreibschutz aufhebt (`echo 5edfacbf > /proc/ubnthal/.uf`),
scheitert bei manchen Versionen ohne Meldung. Gelingt die Installation
nicht, spiel vorher eine ältere Ubiquiti-Firmware ein (per TFTP, siehe
unten).
