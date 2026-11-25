---
gluon_name: d-link-dap-x1860-a1
modell: D-Link DAP-X1860 A1
anzeige: D-Link DAP-X1860 A1
familie: dlink-recovery-web
gluon_broken: false
sprache: de
level: L3
level_text: Feste Adresse am Rechner
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, curl, feste-ip, router-antwortet-nicht]
daten_stand: 2f0580ec4
vorlage_stand: 6eca9a4ce
---

# D-Link DAP-X1860 A1: Freifunk-Firmware installieren

> Nimmt die Herstellerfirmware die factory-Datei nicht an, melde dich bei uns.
>
> Schreib uns, ob es geklappt hat. Und wenn es irgendwo hakt: Melde dich,
> wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20D-Link%20DAP-X1860%20A1)

Der D-Link DAP-X1860 A1 hat eine eingebaute Notfall-Seite von D-Link, die
**Recovery**. Sie nimmt eine Firmware-Datei an und schreibt sie in den
Speicher, auch wenn sonst nichts mehr geht. Über sie kommt die Freifunk-Firmware direkt auf den Router.

## Was du brauchst

- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- eine Büroklammer für die Reset-Taste
- die Freifunk-Firmware deiner Community für den D-Link DAP-X1860 A1, und zwar das
  **factory**-Image
- zum Hochladen den Browser **Chrome oder Chromium**

WLAN am Rechner schaltest du für die Installation am besten aus, damit er
wirklich über das Kabel spricht.

## Schritte

1. **Dateien bereitlegen.** Lade das factory-Image herunter und leg es in einen
   Ordner, den du wiederfindest, zum Beispiel "Downloads".

2. **Feste Adresse am Rechner.** Stell den Netzwerkanschluss deines Rechners
   auf die feste Adresse `192.168.0.65` mit der Netzmaske
   `255.255.255.0`. Ein Gateway brauchst du nicht. Wie das geht, steht unter
   [Feste IP-Adresse einstellen](grundlagen/feste-ip.md).

3. **Kabel stecken.** Verbinde den Rechner mit dem Router.
   Der Router hat noch keinen Strom.

4. **Router in die Recovery bringen.** Drück mit der Büroklammer die
   Reset-Taste und halte sie gedrückt. Steck jetzt den Strom ein und halte
   die Taste weiter, bis die LED **rot blinkt**. Dann loslassen.

5. **Recovery-Seite öffnen.**
   Öffne in Chrome oder Chromium `http://192.168.0.50`. Es erscheint die Recovery-Seite von D-Link.
   Kommt gar nichts, prüf die feste Adresse (Schritt 2) und das Kabel
   (Schritt 3). Ein `ping` hilft hier nicht, die Recovery antwortet nicht
   darauf.

6. **Datei im Browser hochladen.** Klick auf "Datei auswählen", wähl das factory-Image und klick den Knopf daneben.
   Die Seite zeigt jetzt den Fortschritt in Prozent. Lass die Seite in Ruhe, bis die Erfolgsmeldung erscheint.

7. **Warten.** Danach schreibt die Recovery die Datei in den Speicher, und
   der Router startet neu.
   **Strom nicht ziehen.** Die Erfolgsmeldung allein heißt noch nicht,
   dass es geklappt hat.
   Nicht geklappt hat es, wenn

   - gar nichts passiert: Der Router bleibt in der Recovery, die LED blinkt
     weiter wie in Schritt 4, oder
   - der Router mit der normalen D-Link-Firmware startet.

   Dann ist die Datei nicht angekommen. Das ist harmlos: noch einmal ab
   Schritt 4 mit Chrome oder Chromium. Klappt es auch dann nicht, nimm den Notweg
   weiter unten ("Notweg: Hochladen mit curl").

8. **Fertig.** Nach dem Neustart startet die Freifunk-Firmware deiner
   Community: je nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Wie es weitergeht, beschreibt
   deine Community.

## Woran du erkennst, dass es geklappt hat

- Nach dem Neustart meldet sich die Freifunk-Firmware.
- Die Erfolgsmeldung der D-Link-Seite zählt nicht, sie erscheint immer.

## Wenn etwas schiefgeht

- **Der Router bleibt in der Recovery (die LED blinkt weiter wie in
  Schritt 4), oder er startet mit der normalen D-Link-Firmware.**
  Dann ist die Datei nicht angekommen.
  Noch einmal ab Schritt 4 mit Chrome oder Chromium, sonst den Notweg mit curl
  (unten). Im Notweg ist die häufigste Ursache ein Tippfehler im
  Dateinamen.
- **Im Notweg: curl meldet "Failed to connect", HTTP 000 und 0 Bytes.** Die Recovery war
  nicht erreichbar. Prüf die feste Adresse (Schritt 2) und das Kabel (Schritt 3), dann
  Router noch einmal in die Recovery bringen (Schritt 4).
- **Im Notweg: curl steht bei 100 % und kommt nicht zurück, oder meldet nach langer
  Zeit "Recv failure: Connection timed out".** Das ist normal: Der Router hat
  neu gestartet, ohne curl Bescheid zu geben. curl darf mit Strg+C beendet
  werden, sobald der Router neu startet.
- **Im Notweg: Aus der WSL unter Windows kommt keine Verbindung zustande.** Nimm curl.exe
  direkt in Windows, nicht in der WSL.

## Notweg: Hochladen mit curl

Nur wenn das Hochladen im Browser nicht klappt. Du brauchst dafür das
Programm **curl**. Unter Linux und macOS ist es meist schon da, unter
Windows 10 und 11 heißt es `curl.exe` und ist eingebaut
([curl benutzen](grundlagen/curl.md)).

1. **Router wieder in die Recovery bringen** wie in Schritt 4 und 5, aber
   dort nichts hochladen.
2. **Datei mit curl hochladen.** Öffne ein Terminal (unter Windows die
   **PowerShell**), wechsle in den Ordner mit der Datei und gib ein:

   Linux und macOS:

   ```sh
   curl -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o /dev/null -F "firmware=@gluon-<community>-<release>-d-link-dap-x1860-a1-factory.bin;type=application/octet-stream" http://192.168.0.50/upload.cgi
   ```

   Windows (PowerShell):

   ```
   curl.exe -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o antwort.bin -F "firmware=@gluon-<community>-<release>-d-link-dap-x1860-a1-factory.bin;type=application/octet-stream" http://192.168.0.50/upload.cgi
   ```

   Den echten Dateinamen statt `gluon-<community>-<release>-d-link-dap-x1860-a1-factory.bin` einsetzen. Unter
   Windows `curl.exe` genau so ausschreiben; `antwort.bin` nimmt nur die
   Antwort des Routers auf und kann danach weg. Mehr unter
   [curl benutzen](grundlagen/curl.md).

3. **Warten.** curl zeigt beim Hochladen eine Fortschrittsanzeige. Bei 100 %
   ist die Datei drüben, das dauert meist nur Sekunden. Danach schreibt die
   Recovery sie in den Speicher.
   Bis zum Neustart vergehen meist einige Minuten.
   **Strom nicht ziehen.**
   Oft kommt curl danach nicht von selbst zurück, obwohl alles geklappt hat.
   Dann beende es mit **Strg+C** (am Mac ctrl+C), aber erst, wenn der Router
   neu startet.
   Wartest du stattdessen, kommt curl nach einiger Zeit (gut 10
   Minuten) von selbst zurück, meist mit "Recv failure: Connection timed
   out". Das ist in Ordnung.

Danach weiter mit Schritt 8 ("Fertig") oben.
