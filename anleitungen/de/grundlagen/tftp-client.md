---
thema: tftp-client
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# TFTP-Client benutzen

Manche Geräte werden im Notfall-Modus selbst zum TFTP-Server: Sie warten
darauf, dass du ihnen eine Firmware-Datei schickst. Dafür brauchst du auf dem
Rechner einen **TFTP-Client**. (Umgekehrt, wenn das Gerät sich die Datei
selbst holt, brauchst du einen TFTP-Server, siehe
[TFTP-Server einrichten](tftp-server.md).)

Vorher: Rechner auf die feste Adresse aus der Geräteanleitung stellen
([Feste IP-Adresse einstellen](feste-ip.md)).

## Windows

Windows hat einen TFTP-Client, er ist aber ab Werk ausgeschaltet.

1. Win + R, `optionalfeatures` eingeben, Enter.
2. In der Liste "TFTP-Client" anhaken, OK. Windows richtet ihn ein.
3. Eingabeaufforderung öffnen (Win + R, `cmd`), in den Ordner mit der Datei
   wechseln und schicken:

   ```
   tftp -i 192.168.1.20 PUT factory.bin
   ```

   `-i` heißt: als Binärdatei übertragen. Ohne `-i` kommt die Datei kaputt an.

Die **Windows-Firewall** kann TFTP blockieren. Kommt nur eine
Zeitüberschreitung, obwohl das Gerät bereit ist, schalte die Firewall für die
Dauer der Installation ab und danach wieder an.

## Linux und macOS

`tftp` ist auf macOS eingebaut; unter Linux meist über das Paket `tftp-hpa`
oder `tftp` zu installieren.

```
tftp 192.168.1.20
binary
put factory.bin
quit
```

`binary` ist wichtig, sonst kommt die Datei kaputt an.

## Woran du erkennst, dass es geklappt hat

- Windows: "Übertragung erfolgreich" bzw. "Transfer successful" mit der
  Größe der Datei.
- Linux/macOS: `tftp` meldet "Sent … bytes".

Kommt eine Zeitüberschreitung ("Timeout"), war das Gerät nicht bereit oder
die Adresse stimmt nicht. Gerät noch einmal in den Notfall-Modus bringen.
