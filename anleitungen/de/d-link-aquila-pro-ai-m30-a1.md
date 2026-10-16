---
gluon_name: d-link-aquila-pro-ai-m30-a1
modell: D-Link AQUILA PRO AI M30 A1
anzeige: D-Link AQUILA PRO AI M30 A1
familie: dlink-recovery-web
gluon_broken: false
sprache: de
level: L4
level_text: Netzwerkwerkzeuge
risiko: normal
status: ungeprüft
rampe_image: gluon-rampe-*-d-link-aquila-pro-ai-m30-a1-recovery.bin
grundlagen: [browser-https, curl, feste-ip]
daten_stand: 9936ce50
vorlage_stand: 398ce57c
---

# D-Link AQUILA PRO AI M30 A1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20D-Link%20AQUILA%20PRO%20AI%20M30%20A1)

Der D-Link AQUILA PRO AI M30 A1 hat eine eingebaute Notfall-Seite von D-Link, die
**Recovery**. Sie nimmt eine Firmware-Datei an und schreibt sie in den
Speicher, auch wenn sonst nichts mehr geht. Über sie kommt zuerst die
**Gluon-RAMpe** auf den Router: eine kleine Seite, die nur eins kann, die
Freifunk-Firmware deiner Community annehmen. Du brauchst dafür kein SSH und
kein Passwort.

## Was du brauchst

- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- eine Büroklammer für die Reset-Taste
- die RAMpe-Datei für dieses Gerät: `gluon-rampe-<Datum>-d-link-aquila-pro-ai-m30-a1-recovery.bin` ([herunterladen](https://download.ffnef.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261015-d-link-aquila-pro-ai-m30-a1-recovery.bin))
- die Freifunk-Firmware deiner Community für den D-Link AQUILA PRO AI M30 A1, und zwar das
  **sysupgrade**-Image
- das Programm **curl** zum Hochladen. Unter Linux und macOS ist es meist
  schon da, unter Windows 10 und 11 heißt es `curl.exe` und ist eingebaut
  ([curl benutzen](grundlagen/curl.md)).

WLAN am Rechner schaltest du für die Installation am besten aus, damit er
wirklich über das Kabel spricht.

## Schritte

1. **Dateien bereitlegen.** Lade die RAMpe-Datei und das sysupgrade-Image herunter und leg sie in einen
   Ordner, den du wiederfindest, zum Beispiel "Downloads".

2. **Feste Adresse am Rechner.** Stell den Netzwerkanschluss deines Rechners
   auf die feste Adresse `192.168.200.10` mit der Netzmaske
   `255.255.255.0`. Ein Gateway brauchst du nicht. Wie das geht, steht unter
   [Feste IP-Adresse einstellen](grundlagen/feste-ip.md).

3. **Kabel stecken.** Verbinde den Rechner mit dem Router.
   Der Router hat noch keinen Strom.

4. **Router in die Recovery bringen.** Drück mit der Büroklammer die
   Reset-Taste und halte sie gedrückt. Steck jetzt den Strom ein und halte
   die Taste weiter, bis die LED **rot blinkt**. Dann loslassen.

5. **Prüfen, ob die Recovery da ist.**
   Öffne im Browser `http://192.168.200.1`. Es erscheint die Recovery-Seite von D-Link.
   **Lade dort nichts hoch.** Ihr Fortschrittsbalken läuft nur nach der Uhr
   und sagt nichts darüber, ob die Datei ankam. Die Seite zeigt dir nur, dass
   die Recovery bereit ist.
   Ein `ping` hilft hier nicht, die Recovery antwortet nicht darauf.

6. **Datei mit curl hochladen.** Öffne ein Terminal (unter Windows die
   **PowerShell**), wechsle in den Ordner mit der Datei und gib ein:

   Linux und macOS:

   ```sh
   curl -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o /dev/null -F "firmware=@gluon-rampe-20261015-d-link-aquila-pro-ai-m30-a1-recovery.bin;type=application/octet-stream" http://192.168.200.1/upload.cgi
   ```

   Windows (PowerShell):

   ```
   curl.exe -H "Expect:" -w "HTTP %{http_code}, hochgeladen %{size_upload} Bytes\n" -o antwort.bin -F "firmware=@gluon-rampe-20261015-d-link-aquila-pro-ai-m30-a1-recovery.bin;type=application/octet-stream" http://192.168.200.1/upload.cgi
   ```

   Den echten Dateinamen statt `gluon-rampe-20261015-d-link-aquila-pro-ai-m30-a1-recovery.bin` einsetzen. Unter
   Windows `curl.exe` genau so ausschreiben; `antwort.bin` nimmt nur die
   Antwort des Routers auf und kann danach weg. Mehr unter
   [curl benutzen](grundlagen/curl.md).

7. **Warten.** curl zeigt beim Hochladen eine Fortschrittsanzeige. Bei 100 %
   ist die Datei drüben, das dauert meist nur Sekunden. Danach schreibt die
   Recovery sie in den Speicher.
   Bis zum Neustart vergehen meist einige Minuten, es kann aber auch über 10 Minuten dauern.
   **Strom nicht ziehen.**
   Oft kommt curl danach nicht von selbst zurück, obwohl alles geklappt hat.
   Dann beende es mit **Strg+C** (am Mac ctrl+C), aber erst, wenn der Router
   neu startet.
   Wartest du stattdessen, kommt curl nach einiger Zeit (bei uns gut 10
   Minuten) von selbst zurück, meist mit "Recv failure: Connection timed
   out". Das ist in Ordnung. Entscheidend ist die letzte Zeile, sie
   zeigt, wie viel ankam. Geklappt hat es bei **etwa 52,4 Millionen Bytes**.
   Steht da 0, kam nichts an (siehe "Wenn etwas schiefgeht").

8. **Die RAMpe.** Nach dem Neustart blinkt die LED gleichmäßig, etwa einmal pro Sekunde. Stell den Rechner
   wieder auf "automatisch" (DHCP) und öffne
   `http://192.168.1.1/cgi-bin/config`. Es erscheint die Seite "Firmware
   aktualisieren". Kommt "Not Found", hat sich der Browser eine Seite von
   früher gemerkt: Tipp die Adresse vollständig ein, mit `/cgi-bin/config` am
   Ende.
   Die RAMpe bleibt auf dem Router, bis die Freifunk-Firmware sie ersetzt.
   Startet der Router zwischendurch neu, ist das harmlos: Seite einfach
   wieder aufrufen.
   Zeigt der Browser stattdessen eine Warnung vor einem unsicheren
   Zertifikat, hat er von sich aus `https://` vor die Adresse gesetzt. Klick
   auf "Erweitert" und "Trotzdem fortfahren" (je nach Browser etwas anders
   benannt), dann kommt die Seite. Mehr dazu unter
   [Browser macht https daraus](grundlagen/browser-https.md).

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"](../bilder/allgemein/rampe-seite.png)

9. **Freifunk-Firmware hochladen.** Wähl das sysupgrade-Image deiner
   Community aus und klick "Datei hochladen". Die RAMpe zeigt die Prüfsumme
   (SHA256) der Datei. Vergleich sie mit der Prüfsumme, die deine Community
   zur Datei angibt. Stimmt sie, klick "Fortfahren".

   ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"](../bilder/allgemein/rampe-pruefsumme.png)

   Danach erscheint der Hinweis, dass die Firmware jetzt geschrieben wird.
   Jetzt den Strom nicht unterbrechen.

   ![Hinweis der RAMpe: Die Firmware wird jetzt aktualisiert, Stromversorgung nicht unterbrechen](../bilder/allgemein/rampe-flash-laeuft.png)

10. **Fertig.** Nach wenige Minuten startet die Freifunk-Firmware
    deiner Community: je nach Community zuerst mit einer Einrichtungsseite
    unter `http://192.168.1.1` oder gleich im Betrieb. Wie es weitergeht,
    beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- curl hat beim Hochladen 100 % erreicht. Kommt es von selbst zurück,
  meldet es **etwa 52,4 Millionen Bytes**. Wie lange das gedauert hat, ist
  egal, es zählt die Menge.
- Nach dem Neustart blinkt die LED gleichmäßig, etwa einmal pro Sekunde, und unter
  `http://192.168.1.1/cgi-bin/config` steht "Firmware aktualisieren".
- Die Erfolgsmeldung der D-Link-Seite zählt nicht, sie erscheint immer.

## Wenn etwas schiefgeht

- **curl meldet "Failed to connect", HTTP 000 und 0 Bytes.** Die Recovery war
  nicht erreichbar. Prüf die feste Adresse (Schritt 2) und das Kabel, dann
  Router noch einmal in die Recovery bringen (Schritt 4).
- **curl steht bei 100 % und kommt nicht zurück, oder meldet nach langer
  Zeit "Recv failure: Connection timed out".** Das ist normal: Der Router hat
  neu gestartet, ohne curl Bescheid zu geben. curl darf mit Strg+C beendet
  werden, sobald der Router neu startet (Schritt 7).
- **Nach dem Upload startet wieder die normale D-Link-Firmware.** Die Datei
  ist nicht vollständig angekommen, zum Beispiel wegen eines Tippfehlers im
  Dateinamen. Das ist harmlos: noch einmal ab Schritt 4.
- **Der Browser-Upload war nach einer Sekunde "fertig".** Dann ist nichts
  übertragen worden. Das passiert auch in Chromium-Browsern. Nimm curl.
- **Aus der WSL unter Windows kommt keine Verbindung zustande.** Nimm curl.exe
  direkt in Windows, nicht in der WSL.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- geprüft (Weg ab Werk, Datei, Stock-Teile)
- geprüft: Commit (Sichtbare Zeichen)
- geprüft: Commit 29cca6c (Schritte (Normalweg), Sichtbare Zeichen, Adressen, Bedingung an die Herstellerfirmware, Fehlerbild, Rückweg zur Herstellerfirmware)
- geprüft: Commits 'Chromium based'; Firefox abgeleitet: Forum Darmstadt laut Notiz (Programm)
- geprüft: Commits 29cca6c, 7271ee5; Neanderfunk-Notiz (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Neanderfunk-Notiz (Schritte (Normalweg), Sichtbare Zeichen, Adressen, Datei)
- geprüft: Neanderfunk-Notiz, M60: 10-11 min gemessen (Schritte (Normalweg), Dauer)
- geprüft: Neanderfunk-Notiz, am Gerät bestätigt (Typenschild/Verwechslung)
- geprüft: Neanderfunk-Notiz, am M60 erprobt (Schritte (Normalweg), Programm)
- geprüft: gluon-rampe-installer docs/NOTIZEN.md (Gluon-RAMpe passt)
- Geräteeintrag: OpenWrt 29cca6cfee4bc732f9bf7eca0cae9e56cd3c0f2f
