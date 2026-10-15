---
thema: ssh-scp
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# SSH und scp benutzen

Mit **SSH** meldest du dich über das Netzwerk auf einem Gerät an und tippst
dort Befehle ein, als säßest du davor. Mit **scp** kopierst du eine Datei
auf das Gerät. Beides läuft im Terminal.

## Wo du das Terminal findest

- **Windows 10 und 11:** `ssh` und `scp` sind eingebaut. Win + R, `cmd`
  eingeben, Enter. Mit `cd %USERPROFILE%\Downloads` wechselst du in den
  Download-Ordner.
- **macOS:** Programm "Terminal". `cd ~/Downloads`.
- **Linux:** ein beliebiges Terminal. `cd ~/Downloads`.

## Datei kopieren

```
scp -O firmware.bin ubnt@192.168.1.20:/tmp/firmware.bin
```

Links steht die Datei auf deinem Rechner, rechts Benutzer, Adresse und Pfad
auf dem Gerät. Das `-O` lässt scp das alte Übertragungsverfahren nehmen, das
viele Router nur kennen. Ohne `-O` kommt bei ihnen ein Fehler wie
"subsystem request failed".

## Anmelden

```
ssh ubnt@192.168.1.20
```

Danach stehen die Eingaben auf dem Gerät. Mit `exit` meldest du dich ab.

## Was beim ersten Mal kommt

- **"Are you sure you want to continue connecting (yes/no)?"** Beim ersten
  Kontakt mit einem Gerät fragt SSH, ob du ihm vertraust. `yes` eintippen,
  Enter.
- **Das Passwort erscheint beim Tippen nicht.** Weder Zeichen noch Sternchen.
  Einfach tippen und Enter drücken.

## Typische Fehler

- **"no matching host key type found"**: Das Gerät nutzt ein altes
  Verschlüsselungsverfahren, das neuere SSH-Programme abgeschaltet haben.
  Erlaube es für diesen einen Aufruf:

  ```
  ssh -o HostKeyAlgorithms=+ssh-rsa ubnt@192.168.1.20
  scp -O -o HostKeyAlgorithms=+ssh-rsa firmware.bin ubnt@192.168.1.20:/tmp/firmware.bin
  ```

- **"REMOTE HOST IDENTIFICATION HAS CHANGED"**: Unter dieser Adresse war
  vorher ein anderes Gerät, oder dasselbe Gerät mit anderer Firmware. SSH
  schützt dich hier vor einer Verwechslung. Wenn du sicher bist, dass das so
  sein soll, lösch den alten Eintrag und versuch es noch einmal:

  ```
  ssh-keygen -R 192.168.1.20
  ```

- **"Connection refused" oder Zeitüberschreitung**: Das Gerät ist nicht
  erreichbar. Prüf die feste Adresse am Rechner
  ([Feste IP-Adresse einstellen](feste-ip.md)), das Kabel und ob das Gerät
  fertig gestartet ist.
- **"Permission denied"**: Benutzer oder Passwort stimmen nicht. Bei vielen
  Geräten heißt das, dass sie nicht im Werkszustand sind.

## Befehle abschreiben

Geräteanleitungen enthalten oft Befehle, die direkt in den Speicher des
Geräts schreiben. Kopier sie Zeile für Zeile, statt sie abzutippen. Im
Windows-Terminal fügt ein Rechtsklick ein. Achte darauf, dass keine
Leerzeichen am Anfang oder Ende fehlen oder hinzukommen.
