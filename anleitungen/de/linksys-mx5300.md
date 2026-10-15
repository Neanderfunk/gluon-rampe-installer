---
gluon_name: linksys-mx5300
modell: Linksys MX5300
anzeige: Linksys MX5300
familie: sonderweg-linksys-mx5300
gluon_broken: false
sprache: de
level: L0.1
risiko: normal
status: ungeprüft
grundlagen: [ssh-scp]
daten_stand: 3b96298
vorlage_stand: 393f161
---

# Linksys MX5300: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
> Laut OpenWrt zuletzt geprüft mit Linksys-Firmware 1.1.12.210066 (April 2022); spätere Linksys-Updates könnten den Weg verbauen.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Linksys%20MX5300)

Der MX5300 hat in seiner Linksys-Firmware eine versteckte Seite, über die
sich die Freifunk-Firmware direkt hochladen lässt. Du brauchst nur einen
Browser.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Linksys MX5300, und zwar das
  **factory**-Image

## Schritte

1. **Werkseinstellungen.** OpenWrt empfiehlt, den Router vorher auf
   Werkseinstellungen zurückzusetzen; im Speicher bleiben sonst persönliche
   Einstellungen liegen.

2. **Verbinden.** Kabel vom Rechner an eine LAN-Buchse, Router einschalten.
   Der Rechner holt sich seine Adresse automatisch.

3. **Update-Seite öffnen.** Im Browser
   `http://192.168.1.1/fwupdate.html`. Benutzer `admin`, Passwort `admin`.

4. **Hochladen.** Das factory-Image wählen und auf **"Update"** klicken.
   **Es kommt keine Rückfrage**, prüf vorher, dass es die richtige Datei
   ist.

5. **Warten.** Ist alles gutgegangen, antwortet die Seite mit

   ```
   {
   "result": "OK"
   }
   ```

   Danach startet der Router von selbst mit der Freifunk-Firmware: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- Die Update-Seite antwortet mit `"result": "OK"`.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Update-Seite geht nicht.** Laut OpenWrt geht es auch über die normale
  Oberfläche: anmelden (Passwort `admin`), unten rechts auf **"CA"**, dann
  **Connectivity → Basic**, beim manuellen Firmware-Update das factory-Image
  wählen, **"Start"** und die Rückfragen bestätigen.

## Für Erfahrene: auch den zweiten Speicher beschreiben

Der MX5300 hat zwei Firmware-Speicher. Die Freifunk-Firmware liegt nach
Schritt 5 nur in einem; im anderen bleibt die Linksys-Firmware. Startet die
Freifunk-Firmware mehrmals nicht, fällt der Router auf die Linksys-Firmware
zurück. Die Entwickler von OpenWrt empfehlen deshalb, dasselbe factory-Image
auch in den zweiten Speicher zu schreiben. Dafür brauchst du SSH-Zugang zur
laufenden Freifunk-Firmware ([SSH und scp benutzen](grundlagen/ssh-scp.md)).
Das factory-Image nach `/tmp/factory.bin` kopieren, dann:

```
fw_printenv -n boot_part
```

- Antwort `2`: `mtd -r -e kernel -n write /tmp/factory.bin kernel`
- Antwort `1`: `mtd -r -e alt_kernel -n write /tmp/factory.bin alt_kernel`

Damit ist allerdings auch die Linksys-Firmware weg.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk, Schritte (Normalweg), Notweg)
- geprüft: Commit 70fd815e (Schritte (Normalweg), Programm, Datei, Rückweg zur Herstellerfirmware)
- geprüft: Wiki toh:linksys:mx5300 (Sichtbare Zeichen, Adressen, Zugang, Typenschild/Verwechslung, Bedingung an die Herstellerfirmware)
- Geräteeintrag: OpenWrt 70fd815e57dc98cef88828faa5ce71717540e99e
