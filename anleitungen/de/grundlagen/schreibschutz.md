---
thema: schreibschutz
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# Schreibschutz im Flash

Manche Hersteller sperren den Speicher ihrer Geräte gegen Schreiben, damit
niemand eine andere Firmware aufspielt. Das Tückische daran: Die Sperre
meldet sich oft nicht. Die Befehle zum Schreiben laufen scheinbar fehlerfrei
durch, zeigen sogar, wie viel sie geschrieben haben, und nach dem Neustart
ist trotzdem die alte Firmware da.

**Wenn ein Gerät nach dem Flashen unverändert mit der Hersteller-Firmware
startet, ist ein Schreibschutz der häufigste Grund.**

## Bei Ubiquiti UniFi

Neuere UniFi-Firmware schützt die Bereiche, in denen die Firmware liegt
(`kernel0` und `kernel1`). Ein verstecktes Steuerfeld hebt den Schutz auf,
wenn man einen festen Wert hineinschreibt:

```
echo "5edfacbf" > /proc/ubnthal/.uf
```

Danach lassen sich die Bereiche beschreiben, bis zum nächsten Neustart. Dieser
Befehl steht in den Geräteanleitungen immer vor den Schreibbefehlen. Er gibt
keine Antwort, auch nicht, wenn er gewirkt hat.

Prüfen kannst du es so: Jeder Speicherbereich hat Kennzeichen (Flags), die
zeigen, ob er beschreibbar ist. Bei einer UniFi AC Lite sah das im
Freifunk-Forum so aus, `kernel0` ist dort `mtd2`:

```
cat /sys/class/mtd/mtd2/flags
```

- vor dem Aufheben: `0x800` (gesperrt)
- danach: `0xc00` (beschreibbar)

Steht nach dem `echo` noch `0x800` da, nicht weiterschreiben. Gerät auf
Werkseinstellungen zurücksetzen und noch einmal von vorn; im Forum hat das in
einem solchen Fall geholfen.

Bei älterer UniFi-Firmware gibt es das Steuerfeld noch nicht. Dann meldet
der `echo`-Befehl "No such file or directory", und es gibt auch keinen
Schreibschutz, der aufgehoben werden müsste.

## Woher das Wissen stammt

Der Wert und die Flags stammen aus dem Freifunk-Forum
(forum.freifunk.net, Thema "SCP/TFTP Downgrade bei Unifi AC ab Firmware
4.3.x geht nicht mehr?", Beitrag von blocktrron vom 15.09.2022). Er hat dort
auch erklärt, warum es so ist: Ein Kernel-Modul der Ubiquiti-Firmware
markiert die Bereiche als nur lesbar und hebt das wieder auf, wenn der
richtige Wert in das versteckte Feld geschrieben wird.
