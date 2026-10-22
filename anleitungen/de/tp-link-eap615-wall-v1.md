---
gluon_name: tp-link-eap615-wall-v1
modell: TP-Link EAP615-Wall v1
anzeige: TP-Link EAP615-Wall v1
familie: tplink-eap-ssh
gluon_broken: false
sprache: de
level: L4
level_text: Network-Tools
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip, router-antwortet-nicht, ssh-scp]
daten_stand: c6d8e279
vorlage_stand: 33a38da8
---

# TP-Link EAP615-Wall v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20EAP615-Wall%20v1)

Die Weboberfläche von TP-Link nimmt die Freifunk-Firmware an, aber erst,
nachdem du per SSH einen einzigen Befehl auf dem Gerät ausgeführt hast. Der
Weg hat also drei kurze Teile: SSH einschalten, den Befehl ausführen, die
Firmware hochladen. Rechne mit einer halben Stunde.

## Was du brauchst

- den Access Point und Strom über PoE, also
  einen PoE-Injektor oder PoE-Switch
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- `ssh` ([SSH und scp benutzen](grundlagen/ssh-scp.md))
- die Freifunk-Firmware deiner Community für den TP-Link EAP615-Wall v1, und zwar das
  **factory**-Image. Benenn es in **`factory.bin`** um. Manche dieser Geräte
  lehnen lange Dateinamen ab.

## Schritte

1. **Rechner anschließen.** Stell deinen Rechner auf die feste Adresse
   `192.168.0.10`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Verbinde ihn
   mit dem Access Point (bei PoE: mit dem LAN-Anschluss des Injektors) und
   schalte den Access Point ein. Warte zwei Minuten.

2. **Weboberfläche öffnen.** Öffne `http://192.168.0.254` und melde dich an.
   Im Werkszustand heißt der Benutzer `admin` mit Passwort `admin`; danach
   verlangt das Gerät einen neuen Benutzernamen und ein neues Passwort.
   Merk sie dir.

3. **SSH einschalten.** Such in der Weboberfläche den Punkt für SSH (je nach
   Firmware unter "Management" oder "System") und schalte SSH ein.
   Speichern.

4. **Den Befehl ausführen.** Im Terminal auf deinem Rechner, mit dem
   Benutzernamen aus Schritt 2 statt `admin`:

   ```
   ssh admin@192.168.0.254
   ```

   Meldet `ssh` "no matching host key type found" oder etwas Ähnliches,
   siehe [SSH und scp benutzen](grundlagen/ssh-scp.md). Auf dem Gerät gibst
   du dann ein:

   ```
   cliclientd stopcs
   ```

   Danach mit `exit` abmelden. Ohne diesen Befehl lehnt die Weboberfläche
   die Freifunk-Firmware ab.

5. **Freifunk-Firmware hochladen.** Geh in der Weboberfläche zum
   Firmware-Update, wähl `factory.bin` aus und starte das Update. Der Access
   Point schreibt die Freifunk-Firmware und startet neu, einige Minuten.
   **Strom nicht ziehen.**

6. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet
   die Freifunk-Firmware deiner Community: je nach Community zuerst mit
   einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im
   Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 nimmt das Gerät die SSH-Anmeldung an.
- In Schritt 5 nimmt die Weboberfläche `factory.bin` an und zeigt den
  Fortschritt.
- Nach Schritt 6 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **`http://192.168.0.254` antwortet nicht.** Prüf die feste Adresse am
  Rechner und ob der Access Point Strom hat. Wurde er schon einmal in ein
  Netz mit DHCP eingebunden, hat er dort vielleicht eine andere Adresse
  bekommen. Dann setz ihn auf Werkseinstellungen zurück (Reset-Taste, wie
  in der Anleitung von TP-Link beschrieben).
- **Die Weboberfläche lehnt `factory.bin` ab.** Lief Schritt 4 wirklich
  durch? Nach einem Neustart des Geräts musst du ihn vermutlich
  wiederholen.
- **Nach dem Update startet nichts mehr.** Zurück geht es bei diesen Geräten
  nur noch über die serielle Konsole im Gehäuse, und dafür muss man löten.
  Schreib uns.

## Zurück zur TP-Link-Firmware

Einen einfachen Weg zurück gibt es nicht. Laut OpenWrt geht es nur über die
serielle Konsole, für die man im Gehäuse an Lötpunkte muss.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Forum/Suchergebnis, nicht in Commit (Schritte (Normalweg), Adressen, Programm, Zugang)
- abgeleitet: Schwestergerät EAP613, gleiche Stock-Plattform (Schritte (Normalweg), Datei)
- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit a1b8a4d (Rückweg zur Herstellerfirmware)
- geprüft: Commits (Schritte (Normalweg), Taste und Zeitpunkt, Anschluss, Zugang, Datei)
- Geräteeintrag: a1b8a4d7b3ff3fa671623e2bccafd43a3c141e07
