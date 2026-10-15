{#-
Vorlage sonderweg-linksys-mx5300 (nur Linksys MX5300): factory über die
Update-Seite der Linksys-Firmware; zweite Partition optional per mtd.
ENTWURF Content, 15.10.2026, zur Durchsicht durch adorfer. Quellen:
OpenWrt-Wiki toh:linksys:mx5300 (Rohtext 15.10.2026) und der dort zitierte
OpenWrt-Commit.

Werte: sicherheit, sicherheit_hinweis (siehe _status.md), sonst keine.
-#}
{%- set w = werte -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Der MX5300 hat in seiner Linksys-Firmware eine versteckte Seite, über die
sich die Freifunk-Firmware direkt hochladen lässt. Du brauchst nur einen
Browser.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **factory**-Image
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

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
{{ zusatz.fehler }}

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

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
