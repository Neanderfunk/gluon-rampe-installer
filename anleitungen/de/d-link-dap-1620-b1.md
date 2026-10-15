---
gluon_name: d-link-dap-1620-b1
modell: "D-Link DAP-1620 B1 (Gluon: broken)"
anzeige: D-Link DAP-1620 B1
familie: dlink-recovery-web
gluon_broken: true
sprache: de
stufe: einfach
status: ungeprüft
grundlagen: [curl, feste-ip]
daten_stand: 8ee56d9
vorlage_stand: 85ca218
---

# D-Link DAP-1620 B1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Die Freifunk-Firmware für dieses Gerät gilt bei Gluon als nicht ausreichend
> getestet ("broken"); nicht jede Community bietet sie an.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20D-Link%20DAP-1620%20B1)

Der D-Link DAP-1620 B1 hat eine eingebaute Notfall-Seite von D-Link, die
**Recovery**. Sie nimmt eine Firmware-Datei an und schreibt sie in den
Speicher, auch wenn sonst nichts mehr geht. Über sie kommt die Freifunk-Firmware direkt auf den Router.

## Was du brauchst

- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- eine Büroklammer für die Reset-Taste
- die Freifunk-Firmware deiner Community für den D-Link DAP-1620 B1, und zwar das
  **factory**-Image
- das Programm **curl** zum Hochladen. Unter Linux und macOS ist es meist
  schon da, unter Windows 10 und 11 heißt es `curl.exe` und ist eingebaut
  ([curl benutzen](grundlagen/curl.md)).

WLAN am Rechner schaltest du für die Installation am besten aus, damit er
wirklich über das Kabel spricht.

## Schritte

1. **Dateien bereitlegen.** Lade das factory-Image herunter und leg sie in einen
   Ordner, den du wiederfindest, zum Beispiel "Downloads".

2. **Feste Adresse am Rechner.** Stell den Netzwerkanschluss deines Rechners
   auf die feste Adresse `192.168.0.65` mit der Netzmaske
   `255.255.255.0`. Ein Gateway brauchst du nicht. Wie das geht, steht unter
   [Feste IP-Adresse einstellen](grundlagen/feste-ip.md).

3. **Kabel stecken.** Verbinde den Rechner mit dem Router.
   Der Router hat noch keinen Strom.

4. **Router in die Recovery bringen.** Drück mit der Büroklammer die
   Reset-Taste und halte sie gedrückt. Steck jetzt den Strom ein und halte
   die Taste weiter gedrückt. Woran man bei diesem Gerät sieht, dass die
   Recovery bereit ist, wissen wir noch nicht. Lass nach etwa 10 Sekunden los
   und prüf in Schritt 5, ob die Recovery-Seite erscheint; wenn nicht, noch
   einmal und länger halten.

5. **Prüfen, ob die Recovery da ist.**
   Öffne im Browser `http://192.168.0.50`. Es erscheint die Recovery-Seite von D-Link.
   **Lade dort nichts hoch.** Ihr Fortschrittsbalken läuft nur nach der Uhr
   und sagt nichts darüber, ob die Datei ankam. Die Seite zeigt dir nur, dass
   die Recovery bereit ist.
   Ein `ping` hilft hier nicht, die Recovery antwortet nicht darauf.

6. **Datei mit curl hochladen.** Öffne ein Terminal (unter Windows die
   **PowerShell**), wechsle in den Ordner mit der Datei und gib ein:

   Linux und macOS:

   ```sh
   curl -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o /dev/null -F "firmware=@gluon-<community>-<release>-d-link-dap-1620-b1-factory.bin;type=application/octet-stream" http://192.168.0.50/upload.cgi
   ```

   Windows (PowerShell):

   ```
   curl.exe -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o antwort.bin -F "firmware=@gluon-<community>-<release>-d-link-dap-1620-b1-factory.bin;type=application/octet-stream" http://192.168.0.50/upload.cgi
   ```

   Den echten Dateinamen statt `gluon-<community>-<release>-d-link-dap-1620-b1-factory.bin` einsetzen. Unter
   Windows `curl.exe` genau so ausschreiben; `antwort.bin` nimmt nur die
   Antwort des Routers auf und kann danach weg. Mehr unter
   [curl benutzen](grundlagen/curl.md).

7. **Warten.** curl überträgt die Datei und wartet dann weiter, während die
   Recovery schreibt. Bis zum
   Neustart vergehen meist einige Minuten.
   **Nicht abbrechen, Strom nicht ziehen.**

8. **Fertig.** Nach dem Neustart startet die Freifunk-Firmware deiner
   Community: je nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb. Wie es weitergeht, beschreibt
   deine Community.

## Woran du erkennst, dass es geklappt hat

- Nach dem Neustart meldet sich die Freifunk-Firmware.
- Die Erfolgsmeldung der D-Link-Seite zählt nicht, sie erscheint immer.

## Wenn etwas schiefgeht

- **curl meldet "Failed to connect", HTTP 000 und 0 Bytes.** Die Recovery war
  nicht erreichbar. Prüf die feste Adresse (Schritt 2) und das Kabel, dann
  Router noch einmal in die Recovery bringen (Schritt 4).
- **Nach dem Upload startet wieder die normale D-Link-Firmware.** Die Datei
  ist nicht vollständig angekommen, zum Beispiel wegen eines Tippfehlers im
  Dateinamen. Das ist harmlos: noch einmal ab Schritt 4.
- **Der Browser-Upload war nach einer Sekunde "fertig".** Dann ist nichts
  übertragen worden. Das passiert auch in Chromium-Browsern. Nimm curl.
- **Aus der WSL unter Windows kommt keine Verbindung zustande.** Nimm curl.exe
  direkt in Windows, nicht in der WSL.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Adresse geprüft: Commit e4c7703; Rechner-IP abgeleitet: Schwestergerät (Schritte (Normalweg), Adressen)
- für dieses Gerät abgeleitet: gleiche D-Link-Recovery (Schritte (Normalweg), Sichtbare Zeichen)
- geprüft (Weg ab Werk)
- geprüft: Commit (Schritte (Normalweg), Programm, Datei)
- geprüft: Commit e4c7703 (Schritte (Normalweg), Taste und Zeitpunkt, Rückweg zur Herstellerfirmware)
- geprüft: Commits 'Chromium based'; Firefox abgeleitet: Forum Darmstadt laut Notiz (Programm)
- geprüft: Neanderfunk-Notiz (Schritte (Normalweg), Sichtbare Zeichen, Adressen)
- geprüft: Neanderfunk-Notiz, am M60 erprobt (Programm)
- Geräteeintrag: e4c7703d2a62b8914e4723adae3f67c68a57532c
