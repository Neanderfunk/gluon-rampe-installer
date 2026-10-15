---
thema: avm-eva
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# Der Bootloader von AVM (EVA)

FRITZ!Boxen und FRITZ!Repeater von AVM haben einen Bootloader namens **EVA**
(bei älteren Geräten ADAM2). In den ersten Sekunden nach dem Einschalten
nimmt er Verbindungen per **FTP** an. Darüber lässt sich eine Firmware in den
Speicher schreiben oder eine Firmware direkt in den Arbeitsspeicher laden.
Eine Taste braucht es dafür nicht, nur das richtige Timing.

## Rechner vorbereiten

- **Feste Adresse:** Die Box ist im Bootloader unter `192.168.178.1`
  erreichbar. Der Rechner bekommt eine feste Adresse im selben Netz, zum
  Beispiel `192.168.178.2`, Netzmaske `255.255.255.0`, Gateway
  `192.168.178.1`, kein DNS ([Feste IP-Adresse einstellen](feste-ip.md)).
- **WLAN am Rechner aus,** nur das eine Kabel zur Box.
- **Ein einfacher Switch** zwischen Box und Rechner hilft: Ohne ihn baut der
  Rechner die Verbindung nach dem Einschalten der Box oft erst auf, wenn das
  Zeitfenster schon vorbei ist.

## Das Zeitfenster

Strom an der Box ziehen, wieder einstecken, und **sofort** verbinden. Das
Fenster ist nur wenige Sekunden offen; die Angaben schwanken zwischen etwa 4
und 10 Sekunden. Verpasst? Strom ziehen und noch einmal. Die Programme unten
probieren es von selbst immer wieder, bis die Box antwortet.

## Mit fritzflash.py (Freifunk Darmstadt)

Für viele Geräte gibt es ein fertiges Programm:
[fritzflash.py](https://github.com/freifunk-darmstadt/fritz-tools) mit
[Anleitung](https://fritz-tools.readthedocs.io/de/latest/). Es braucht
Python 3 (Windows, macOS, Linux), sucht die Box, wählt das Image passend zum
Gerät und schreibt es.

```
python3 fritzflash.py --image <Freifunk-Image>
```

Das Programm sagt dann, was zu tun ist: Enter drücken, Strom an der Box
ziehen und wieder einstecken. Während des Schreibens leuchtet die rote
Info-LED. Das ist normal; jetzt nicht den Strom ziehen.

## Von Hand per FTP (Referenz)

Unter Linux oder macOS mit dem Kommandozeilen-`ftp`, direkt nach dem
Einschalten:

```
ftp 192.168.178.1
```

Benutzer `adam2`, Passwort `adam2`. Danach die Befehle aus der
Geräteanleitung, zum Beispiel:

```
binary
passive
quote MEDIA FLSH
put <Datei> mtd1
quote REBOOT
```

Nützliche Abfragen:

- `quote GETENV HWRevision`: die Hardware-Kennung, an der man Varianten
  unterscheidet
- `quote GETENV urlader-version`: die Version des Bootloaders
- `quote SETENV linux_fs_start 0`: welcher der beiden Firmware-Speicher
  beim nächsten Start benutzt wird (siehe Geräteanleitung)

Das `ftp` von Windows kann kein "passive" und taugt deshalb nicht zum
Hochladen; unter Windows nimm fritzflash.py.

## Einen einzelnen Befehl schicken

Wo nur ein Befehl nötig ist, geht es auch mit Python, auf jedem System
gleich:

```
python3 -c "from ftplib import FTP; f=FTP('192.168.178.1','adam2','adam2'); print(f.sendcmd('SETENV linux_fs_start 0'))"
```

Kommt eine Antwort mit `200`, hat es geklappt.
