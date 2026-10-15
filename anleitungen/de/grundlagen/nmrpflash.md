---
thema: nmrpflash
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# nmrpflash benutzen

Viele Netgear-Geräte haben im Bootloader einen Notfall-Weg namens NMRP:
Direkt nach dem Einschalten fragen sie im Netzwerk, ob jemand eine Firmware
für sie hat. Das Programm **nmrpflash** antwortet darauf und schickt die
Datei. Das klappt auch, wenn die Netgear-Oberfläche fremde Firmware ablehnt
oder das Gerät nicht mehr startet.

## Besorgen

Fertige Programme für Linux, macOS und Windows gibt es auf der
[Download-Seite von nmrpflash](https://github.com/jclehner/nmrpflash/releases/latest).
ZIP-Datei herunterladen und auspacken.

- **Windows** braucht zusätzlich [Npcap](https://nmap.org/npcap/#download).
  Beim Installieren **"WinPcap API-compatible Mode"** anhaken. Fehlt das,
  meldet nmrpflash "wpcap.dll is missing".
- **Linux** braucht die Pakete `libpcap` und `libnl-3`; manche
  Distributionen haben nmrpflash auch selbst im Paketangebot (oft veraltet).
- **macOS:** Laut nmrpflash am besten über Homebrew (`brew install
  nmrpflash`).

nmrpflash braucht Administrator-Rechte: unter Linux und macOS mit `sudo`
davor, unter Windows die Eingabeaufforderung mit Rechtsklick "Als
Administrator ausführen" öffnen.

## Den richtigen Netzwerkanschluss finden

```
nmrpflash -L
```

zeigt alle Netzwerkanschlüsse des Rechners, zum Beispiel:

```
eth0      192.168.1.2  c0:de:fa:ce:01:23
eth2      0.0.0.0      ca:fe:ba:be:45:67
wifi0     10.0.10.138  de:ad:be:ef:89:ab
```

Gesucht ist der Anschluss, an dem das Kabel zum Netgear-Gerät steckt. Unter
Windows heißen sie `net0`, `net1` … Im Zweifel einmal ohne und einmal mit
eingestecktem Kabel aufrufen und vergleichen.

## Ablauf

1. Gerät **aus**. Kabel direkt vom Rechner an die LAN-Buchse des Geräts
   (bei Netgear oft blau; bei mehreren die mit "1").
2. Firewall am Rechner für die Dauer ausschalten.
3. Starten, mit dem Anschlussnamen von oben und der Firmware-Datei:

   ```
   nmrpflash -i eth2 -f firmware.img
   ```

4. Sobald `Waiting for Ethernet connection` erscheint: Gerät **einschalten**.
5. nmrpflash meldet dann der Reihe nach:

   ```
   Received upload request: filename 'firmware'.
   Uploading firmware.img ... OK
   Waiting for remote to respond.
   Received keep-alive request (11).
   Remote finished. Closing connection.
   Reboot your device now.
   ```

   Bei `Waiting for remote to respond.` schreibt das Gerät. Das kann dauern,
   es wurden 15 Minuten und mehr beobachtet. **Erst bei `Reboot your device
   now.` ist es fertig.** Vorher nicht den Strom ziehen.
6. Gerät neu starten (aus und wieder ein).

nmrpflash vergibt die Adressen selbst (`10.164.183.252` und `.253`); am
Rechner musst du nichts einstellen.

## Wenn etwas schiefgeht

- **"No response after 60 seconds."** Reihenfolge einhalten: erst nmrpflash
  starten, dann das Gerät einschalten. Manche Geräte brauchen beim
  Einschalten zusätzlich die gedrückte Reset-Taste. Eine andere LAN-Buchse
  probieren.
- **"Timeout while waiting for ACK(0)/OACK."** Meist die Firewall. Ausschalten
  und noch einmal.
- **"No suitable network interfaces found."** Der Netzwerkanschluss ist
  ausgeschaltet. Unter Windows hilft manchmal, den Npcap-Dienst neu zu
  starten (als Administrator: `net stop npcap`, dann `net start npcap`).
