---
gluon_name: netgear-srs60
modell: NETGEAR Orbi Pro SRS60
anzeige: NETGEAR Orbi Pro SRS60
familie: netgear-nmrp
gluon_broken: false
sprache: de
stufe: mit Werkzeug
status: ungeprüft
grundlagen: [nmrpflash]
daten_stand: def09e4
vorlage_stand: 393f161
---

# NETGEAR Orbi Pro SRS60: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20NETGEAR%20Orbi%20Pro%20SRS60)

Viele Netgear-Geräte fragen direkt nach dem Einschalten im Netzwerk, ob
jemand eine Firmware für sie hat. Das Programm **nmrpflash** auf deinem
Rechner antwortet darauf und schickt die Freifunk-Firmware. Das geht auch
dann, wenn die Netgear-Oberfläche fremde Firmware nicht annimmt.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- das Programm nmrpflash ([nmrpflash benutzen](grundlagen/nmrpflash.md))
- die Freifunk-Firmware deiner Community für den NETGEAR Orbi Pro SRS60, und zwar das
  **factory**-Image

## Vorher prüfen

SRS60 und [SRR60](netgear-srr60.md) (Set SRK60) sind fast gleich, brauchen aber je ihr eigenes Image. Der SRR60 hat einen mit "wan" beschrifteten Anschluss, der SRS60 nicht.

Beim Orbi ist nmrpflash der einfachste Weg; die Netgear-Oberfläche schreibt die Firmware an die falsche Stelle (siehe unten).

## Schritte

1. **nmrpflash bereitlegen.** Lade nmrpflash herunter und richte es ein, wie
   unter [nmrpflash benutzen](grundlagen/nmrpflash.md) beschrieben. Leg das factory-Image
   in denselben Ordner und benenne es in `firmware.img` um.

2. **Verbinden.** Das Gerät ist **aus**. Steck das Kabel vom Rechner an die Buchse nahe der Ein/Aus-Taste. Schalte die
   Firewall am Rechner für die Dauer aus.

3. **Anschluss finden.** Im Terminal (als Administrator bzw. mit `sudo`):

   ```
   nmrpflash -L
   ```

   Merk dir den Namen des Anschlusses, an dem das Kabel steckt, zum Beispiel
   `eth0` oder `net1`.

4. **nmrpflash starten.** Mit diesem Namen statt `eth0`:

   ```
   nmrpflash -i eth0 -f firmware.img
   ```

5. **Gerät einschalten,** sobald `Waiting for Ethernet connection` erscheint.

6. **Warten.** nmrpflash meldet `Uploading … OK` und dann `Waiting for remote
   to respond.` Jetzt schreibt das Gerät, das dauert meist wenige Minuten,
   manchmal 15 Minuten und mehr. **Strom nicht ziehen,** bis
   `Reboot your device now.` erscheint.

7. **Neu starten.** Nach etwa einer Minute startet das Gerät von selbst mit der neuen Firmware; tut es das nicht, einmal aus- und einschalten.

8. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- nmrpflash endet mit `Reboot your device now.`
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **"No response after 60 seconds."** Reihenfolge einhalten: erst nmrpflash
  starten, dann das Gerät einschalten. Manche Netgear-Geräte brauchen beim
  Einschalten zusätzlich die gedrückte Reset-Taste. Eine andere LAN-Buchse
  probieren.
- **"Timeout while waiting for ACK(0)/OACK."** Meist die Firewall am Rechner.
- Weitere Meldungen erklärt [nmrpflash benutzen](grundlagen/nmrpflash.md).

## Für Erfahrene: über die Netgear-Oberfläche

Die Freifunk-Firmware läuft nur vom ersten der beiden Firmware-Speicher, die
Netgear-Oberfläche schreibt aber immer in den gerade nicht benutzten. Laut
OpenWrt geht es trotzdem: Über `http://192.168.1.250/debug.htm`
(Benutzer `admin`, Passwort `password`) Telnet einschalten, per Telnet
`artmtd -w boot_part 02` setzen, neu starten, dann das factory-Image über die
Oberfläche hochladen.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- geprüft (Weg ab Werk, Datei)
- geprüft: Commit (Fehlerbild)
- geprüft: Commit 2cb24b3 (Schritte (Normalweg), Sichtbare Zeichen, Anschluss, Datei, Typenschild/Verwechslung, Dauer, Fehlerbild, Notweg, Rückweg zur Herstellerfirmware)
- geprüft: nmrpflash-README (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Anschluss, Adressen, Programm, Dauer)
- Geräteeintrag: OpenWrt 2cb24b3f3cd89692f3c0bd137f3f560ada359bfa
