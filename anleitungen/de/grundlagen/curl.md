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

curl ist eingebaut und heißt `curl.exe`.

1. Win + R, `cmd` eingeben, Enter. Es öffnet sich die Eingabeaufforderung.
2. In den Ordner mit der Datei wechseln, zum Beispiel:

   ```
   cd %USERPROFILE%\Downloads
   ```

3. Befehl aus der Geräteanleitung einfügen (Rechtsklick fügt ein), Enter.

**In der PowerShell** (blaues oder schwarzes Fenster mit `PS` vorn) gelten
andere Regeln:

- `curl.exe` immer ausschreiben. `curl` allein ist dort ein anderes Programm.
- Der Ordner heißt `$env:USERPROFILE\Downloads` statt
  `%USERPROFILE%\Downloads`.
- Statt `-o NUL` schreibst du `-o antwort.bin`. Die Antwort des Routers
  landet dann in dieser Datei; sie ist unwichtig und kann weg.

Einfacher ist meist, gleich die Eingabeaufforderung "cmd" zu nehmen.

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
