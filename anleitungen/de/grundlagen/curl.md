---
thema: curl
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf. Die
> Befehle für Windows sind am D-Link M60 benutzt worden.

# Dateien mit curl hochladen

Manche Notfallseiten von Routern nehmen Dateien im Browser nicht zuverlässig
an: Der Upload ist nach einer Sekunde "fertig", aber nichts ist angekommen.
Das Kommandozeilenprogramm **curl** lädt die Datei sicher hoch und zeigt am
Ende, wie viel angekommen ist.

Den genauen Befehl für dein Gerät findest du in dessen Anleitung. Hier steht,
wie du ihn ausführst.

## Windows 10 und 11

curl ist eingebaut und heißt `curl.exe`. Nimm dafür die **PowerShell**.

1. PowerShell öffnen: im Startmenü "PowerShell" suchen, oder im Explorer im
   Ordner mit der Datei Rechtsklick auf eine freie Stelle, "Im Terminal
   öffnen" (Windows 11) bzw. mit gedrückter Umschalttaste
   "PowerShell-Fenster hier öffnen" (Windows 10). Vorne in der Zeile steht
   dann `PS`.
2. In den Ordner mit der Datei wechseln, zum Beispiel:

   ```
   cd $env:USERPROFILE\Downloads
   ```

3. Befehl aus der Geräteanleitung einfügen (Rechtsklick fügt ein), Enter.

Worauf es in der PowerShell ankommt:

- `curl.exe` immer ausschreiben. `curl` allein ist dort ein anderes Programm.
- `-o antwort.bin` nimmt die Antwort des Routers auf; die Datei ist unwichtig
  und kann danach weg.

In der alten Eingabeaufforderung "cmd" ist der Upload bei uns schon nach
wenigen Sekunden abgebrochen; nimm deshalb die PowerShell.

**Nicht aus der WSL** (Linux unter Windows): Von dort kam bei uns keine
Verbindung zur Recovery zustande, aus Windows selbst schon.

## Linux und macOS

curl ist meist installiert, sonst über die Paketverwaltung (`apt install
curl`). Terminal öffnen, mit `cd` in den Ordner wechseln, Befehl ausführen.

## Was die Ausgabe bedeutet

Die Geräteanleitungen lassen curl am Ende eine Zeile ausgeben:

```
HTTP <Code>, hochgeladen <Anzahl> Bytes
```

- **hochgeladen …** ist das, worauf es ankommt. Die Geräteanleitung sagt, wie
  viel es sein muss. Steht dort 0, ist nichts angekommen.
- **HTTP 000** heißt: keine Verbindung. Adresse, Kabel und feste IP prüfen.
- Wie lange es gedauert hat, sagt nichts. Manche Recovery schreibt erst und
  antwortet dann, curl wartet so lange still.
