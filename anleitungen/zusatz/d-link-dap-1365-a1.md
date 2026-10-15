## Vorher prüfen

DAP-1330 (Steckergehäuse) und DAP-1365 (Zwischenstecker mit Steckdose) haben
dieselbe Herstellerfirmware, aber je ihr eigenes Image. Nimm das Image zu dem
Modell, das auf dem Gerät steht, hier also **DAP-1365** (nicht
[DAP-1330](d-link-dap-1330-a1.md)). Ab Werk gibt es kein Passwort.

## Wenn etwas schiefgeht

- **Der Browser macht beim Hochladen Probleme.** Dann geht es über die
  Notfall-Seite (unten) mit curl.

## Notfall: Web-Recovery

Reset-Taste drücken und halten, Strom einstecken, halten, bis die LED rot
blinkt. Die Notfall-Seite ist dann unter `http://192.168.0.50` erreichbar
(oder unter der Adresse, die das Gerät per DHCP vergibt). Hochladen mit curl
([curl benutzen](grundlagen/curl.md)):

```
curl -F files=@factory.bin http://192.168.0.50/cgi/index
```

Dafür das factory-Image vorher in `factory.bin` umbenennen.
