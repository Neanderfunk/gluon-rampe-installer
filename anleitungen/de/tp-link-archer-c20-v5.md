---
gluon_name: tp-link-archer-c20-v5
modell: TP-Link Archer C20 v5
anzeige: TP-Link Archer C20 v5
familie: tplink-ubootteil-dd
gluon_broken: false
sprache: de
level: L5
level_text: Besondere Programme
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, tftp-server]
daten_stand: af10b830
vorlage_stand: 883c350d
---

# TP-Link Archer C20 v5: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20Archer%20C20%20v5)

> **Wichtig: Lade nie die Freifunk-Datei allein über die
> TP-Link-Oberfläche hoch.** Der Firmware-Selector bietet für dieses Gerät
> nur den Knopf **Upgrade** an. Genau diese Datei macht den Router
> unbrauchbar, wenn du sie unverändert bei TP-Link hochlädst. Sie muss
> vorher mit einem Stück der TP-Link-Firmware zusammengesetzt werden, wie
> unten beschrieben.

Der TP-Link Archer C20 v5 braucht beim Start ein kleines Programm aus der
TP-Link-Firmware, den sogenannten U-Boot-Teil. Die Freifunk-Firmware bringt
ihn nicht mit. Deshalb schneidest du ihn aus der TP-Link-Firmware heraus,
hängst die Freifunk-Firmware an und lädst das Ergebnis über die
TP-Link-Oberfläche hoch. Das Zusammensetzen ist ein einziger Befehl. Rechne
mit einer halben Stunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die **TP-Link-Firmware** für genau dieses Modell und diese Version, von der
  [Download-Seite bei TP-Link](https://www.tp-link.com/de/support/download/archer-c20/v5/). Nimm die TP-Link-Firmware für die Region auf dem Typenschild (in Europa: EU).
- die Freifunk-Firmware deiner Community für den TP-Link Archer C20 v5: im
  Firmware-Selector unter "Wähle Deine Installationsart" der Knopf
  **Upgrade** (die Datei endet auf `-sysupgrade.bin`). **Nicht allein
  hochladen**, siehe oben.
- zum Zusammensetzen: unter Linux und macOS die Befehle `dd` und `cat` (sind
  schon da), unter Windows **Python 3** (<https://www.python.org/downloads/>)

## Vorher prüfen

Der Archer C20 v5 sieht aus wie der v4, braucht aber diesen Weg. Die Version
steht auf dem Typenschild unten am Gerät ("Ver: 5.0"). Nimm die
TP-Link-Firmware für die Region auf dem Typenschild (in Europa: EU).

## Schritte

1. **Dateien bereitlegen.** Leg einen Ordner an. Pack die TP-Link-Firmware
   (ein ZIP-Archiv) dort aus und benenn die `.bin`-Datei darin in
   `tpl.bin` um. Leg die Freifunk-Datei daneben und benenn sie in
   `gluon.bin` um. Die Namen bei TP-Link enthalten oft Leerzeichen oder
   eckige Klammern, die im Terminal Ärger machen. Pack und benenn deshalb am
   besten im Dateimanager, dann musst du die langen Namen nie abtippen.

2. **Zusammensetzen.** Öffne ein Terminal in dem Ordner und gib ein:

   - Linux und macOS:

     ```
     dd if=tpl.bin of=boot.bin bs=131584 count=1
     cat gluon.bin >> boot.bin
     ```

   - Windows (PowerShell oder Eingabeaufforderung), geht auch unter Linux
     und macOS mit `python3` statt `py`:

     ```
     py -c "open('boot.bin','wb').write(open('tpl.bin','rb').read(131584)+open('gluon.bin','rb').read())"
     ```

   **Prüfen:** `boot.bin` ist genau **131.584 Bytes größer** als
   `gluon.bin`. Die Größe in Bytes zeigt unter Windows `dir`, unter Linux
   und macOS `ls -l`. Stimmt das nicht, hier aufhören.

3. **TP-Link-Oberfläche öffnen.** Verbinde den Rechner per Kabel mit einer
   LAN-Buchse des Routers und schalte ihn ein. Der Rechner bleibt auf
   "automatisch". Öffne `http://192.168.0.1` (oder
   `http://tplinkwifi.net`) und melde dich an.

4. **boot.bin hochladen.** Geh zum Firmware-Update (meist unter
   "Systemtools" bzw. "System Tools" → "Firmware-Upgrade"), wähl
   **`boot.bin`** aus, nicht `gluon.bin`, und starte das Update.

5. **Warten.** Mindestens **3 Minuten**, oder bis drei oder mehr LEDs
   leuchten. **Vorher auf keinen Fall den Strom ziehen.**

6. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je
   nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 2 ist `boot.bin` 131.584 Bytes größer als `gluon.bin`.
- In Schritt 4 nimmt die Oberfläche die Datei an.
- Nach Schritt 5 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt `boot.bin` ab.** Prüf, ob die TP-Link-Firmware
  genau zu Modell, Version und Region deines Routers passt (Typenschild),
  und ob du `boot.bin` gewählt hast.
- **Der Router startet nach dem Update nicht richtig**, oder er hängt im
  Notfall-Modus (nur die WPS-LED leuchtet): siehe "Notfall-Seite" unten.

## Notfall-Seite

Der Router hat eine Notfall-Seite im Bootloader. Sie öffnet sich, wenn ein
Firmware-Update abgebrochen wurde. So erreichst du sie absichtlich:

1. Starte in der TP-Link-Oberfläche ein Update mit der **TP-Link-Firmware**
   (`tpl.bin`). Sobald die Anzeige auf 0 % springt (nach etwa 3 Sekunden),
   zieh den Strom. Das ist ungefährlich: Der Router merkt sich nur, dass ein
   Update angefangen hat, bevor er etwas schreibt.
2. Stell deinen Rechner auf die feste Adresse `192.168.0.10`, Netzmaske
   `255.255.255.0` ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
   In diesem Modus verteilt der Router keine Adressen.
3. Strom wieder anschließen. Alle LEDs sind aus, nur die WPS-LED leuchtet.
4. Öffne `http://192.168.0.1`, lade dort `boot.bin` hoch und warte wie oben
   mindestens 3 Minuten.

Über dieselbe Seite kommt auch die TP-Link-Firmware wieder auf das Gerät,
wenn du zurück willst.

## Notweg über TFTP

Klappt auch die Notfall-Seite nicht, holt sich der Router beim Einschalten
mit gedrückter Reset-Taste eine Datei per TFTP
([TFTP-Server einrichten](grundlagen/tftp-server.md)). Diese Datei ist
anders aufgebaut als `boot.bin`:

- Linux und macOS:

  ```
  dd if=/dev/zero of=tp_recovery.bin bs=196608 count=1
  dd if=tpl.bin of=tmp.bin bs=131584 count=1
  dd if=tmp.bin of=teil.bin bs=512 skip=1
  cat teil.bin >> tp_recovery.bin
  cat gluon.bin >> tp_recovery.bin
  ```

- Windows (oder überall mit Python):

  ```
  py -c "open('tp_recovery.bin','wb').write(bytes(196608)+open('tpl.bin','rb').read(131584)[512:]+open('gluon.bin','rb').read())"
  ```

Dann den Rechner fest auf `192.168.0.66` stellen, Netzmaske
`255.255.255.0`, den TFTP-Server mit dem Ordner starten, in dem
`tp_recovery.bin` liegt, und den Router mit gedrückter Reset-Taste
einschalten. Laut OpenWrt-Wiki etwa 8 Sekunden halten, bis alle LEDs
aufhören zu blinken und die WPS-LED angeht. Der Router holt die Datei,
schreibt sie und startet nach etwa einer Minute neu.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Dauer)
- abgeleitet: Commit nutzt dd/cat (Programm)
- abgeleitet: Wiki C20 v5 (Typenschild/Verwechslung)
- abgeleitet: Wiki C50 (Warnung, Dauer, Notweg)
- abgeleitet: Wiki C50; abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk, Notweg)
- geprüft: Commit (Schritte (Normalweg), Taste und Zeitpunkt, Datei, Typenschild/Verwechslung, Notweg)
- geprüft: Commit "vendor-firmware ... can be written" (Rückweg zur Herstellerfirmware)
- geprüft: Commit; abgeleitet: Wiki C20 v5 "regional match" (Schritte (Normalweg), Datei)
- geprüft: Test Neanderfunk 15.10.2026, byte-gleich mit dd/cat aus Commit 01dcd574 (Programm)
- geprüft; abgeleitet: Commit nutzt dd/cat (Schritte (Normalweg))
- geprüft; geprüft: Commit (Schritte (Normalweg))
- Geräteeintrag: 86e7353bff2a5de257de8ec62e782f016eed143c
