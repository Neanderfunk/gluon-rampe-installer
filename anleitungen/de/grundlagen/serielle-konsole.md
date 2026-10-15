---
thema: serielle-konsole
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# Serielle Konsole benutzen

Viele Router haben einen **seriellen Anschluss**: zwei Datenleitungen und
Masse, über die das Gerät beim Start alles ausgibt, was es tut. Dort erreichst
du auch den Bootloader, das kleine Programm, das vor der eigentlichen Firmware
läuft. Damit kann man ein Gerät oft noch einrichten, wenn nichts anderes geht.

Am Rechner brauchst du dafür einen **USB-Seriell-Adapter** und ein
**Terminalprogramm**.

## Der Adapter

Gemeint ist ein kleiner Adapter von USB auf "TTL" oder "UART", oft mit
FTDI-, CP2102- oder CH340-Chip. Wichtig:

- **3,3 Volt.** Viele Adapter lassen sich mit einem Steckbrücken-Schalter
  zwischen 5 V und 3,3 V umstellen. Stell ihn auf 3,3 V, bevor du ihn an den
  Router anschließt. 5 V können den Router beschädigen.
- **Drei Leitungen:** GND an GND, **TX des Adapters an RX des Routers**, **RX
  des Adapters an TX des Routers**. Was der eine sendet (TX), muss der andere
  empfangen (RX).
- **VCC (oder 3V3/5V) nie anschließen.** Der Router hat seine eigene
  Stromversorgung.

Erscheint später kein Text, sind TX und RX oft vertauscht. Tausch die beiden
Leitungen und versuch es noch einmal.

## Das Terminalprogramm

Die Geräteanleitung nennt die **Geschwindigkeit** (Baudrate), zum Beispiel
`9600` oder `115200`. Der Rest ist fast immer gleich: 8 Datenbits, keine
Parität, 1 Stoppbit ("8N1"), **keine Flusssteuerung**.

- **Linux:** Steck den Adapter ein. Er erscheint meist als `/dev/ttyUSB0`
  (mit `ls /dev/ttyUSB* /dev/ttyACM*` nachsehen). Dann:

  ```
  picocom -b 9600 /dev/ttyUSB0
  ```

  Beenden mit Strg+A, danach Strg+X. Kommt "Permission denied", starte es mit
  `sudo` davor.
- **macOS:** Mit `ls /dev/tty.*` vor und nach dem Einstecken findest du den
  Namen des Adapters, etwa `/dev/tty.usbserial-1410`. Dann:

  ```
  screen /dev/tty.usbserial-1410 9600
  ```

  Beenden mit Strg+A, dann K, dann y.
- **Windows:** Im Geräte-Manager unter "Anschlüsse (COM & LPT)" steht, welche
  COM-Nummer der Adapter bekommen hat. In PuTTY als Verbindungsart "Serial"
  wählen, die COM-Nummer und die Geschwindigkeit eintragen. Unter
  "Connection → Serial" die Flusssteuerung ("Flow control") auf **None**
  stellen.

## Den Bootloader anhalten

Schalte den Router erst ein, wenn das Terminal schon läuft. Beim Start zeigt
der Bootloader einige Sekunden lang so etwas wie
`Hit any key to stop autoboot`. Drück dann Enter (oder die Taste, die die
Geräteanleitung nennt). Bei manchen Geräten ist das Zeitfenster sehr kurz.
Dann drück schon während des Einschaltens immer wieder Enter. Danach wartet
der Bootloader auf Befehle, mit einer Eingabeaufforderung wie `=>` oder
`apboot>`.

## Befehle eingeben

- **Zeile für Zeile.** Kopier jeden Befehl aus der Geräteanleitung einzeln.
  Füg ihn ein und drück Enter. Warte, bis die Eingabeaufforderung wieder
  erscheint, bevor du den nächsten Befehl eingibst.
- **Nachsehen, was angekommen ist.** Der Bootloader zeigt jedes Zeichen,
  das er empfangen hat, wieder an. Vergleich die Zeile mit der Anleitung. Bei
  einem Tippfehler die Zeile einfach noch einmal richtig eingeben.
- **Mitschreiben.** Lass das Terminal alles in eine Datei schreiben (picocom:
  `--logfile konsole.txt`, PuTTY: "Session → Logging"). Wenn etwas schiefgeht
  und du Hilfe brauchst, ist diese Datei Gold wert.

## Typische Fehler

- **Nur wirre Zeichen:** Die Geschwindigkeit stimmt nicht. Prüf die Zahl in
  der Geräteanleitung.
- **Gar nichts:** TX und RX tauschen. GND prüfen. Unter Windows die
  COM-Nummer prüfen, unter Linux und macOS den Namen des Adapters.
- **Text erscheint, aber Tastendrücke kommen nicht an:** Die Leitung vom TX
  des Adapters zum RX des Routers hat keinen Kontakt, oder der Adapter ist zu
  schwach. Manche Geräte sind da wählerisch, dann hilft nur ein anderer
  Adapter.
