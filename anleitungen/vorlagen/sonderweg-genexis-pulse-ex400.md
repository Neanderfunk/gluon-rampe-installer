{#-
Vorlage sonderweg-genexis-pulse-ex400 (Genexis/Inteno Pulse EX400).

Hauptweg seit 12.11.2026: Recovery des Bootloaders nimmt die RAMpe als
factory.bin (nicht das initramfs-kernel.bin), nach dem Neustart auf der
RAMpe-Seite das Community-sysupgrade. Ohne ssh. adorfer hat am 11.11.2026
zehn Geräte so umgestellt: feste IP, Reset beim Einschalten halten, auf
192.168.1.1 die RAMpe hochladen, Neustart abwarten, bei Blinken im 1-Hz-Takt
das sysupgrade in die RAMpe.

Der frühere Weg über OpenWrt und scp/ssh ist gestrichen (adorfer 12.11.2026:
völlig überflüssig), ebenso der Rückweg zur Herstellerfirmware (adorfer
12.11.2026: beschreiben wir nicht). Quellen für Notfall-Modus und LEDs: OpenWrt-Commit dd0c283 (Recovery: Reset beim Einschalten,
Webserver 192.168.1.1, Reset im Recovery-Modus wechselt rootfs_0/rootfs_1;
Rückweg), Freifunk-Darmstadt-Wiki "Genexis EX400" (LEDs Status orange + WPS
grün, Bestätigungsseite, etwa 2 min, sysupgrade -n per ssh, harmlose Meldung
"Command failed ... (Connection failed)").

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    rampe_url            Download-Adresse der RAMpe-factory.bin
    rampe_datei          Dateiname dieser Datei

  optional
    rampe_sha256         SHA256 der RAMpe-Datei (aus LISTE.md)
    sicherheit, sicherheit_hinweis   siehe _status.md

Bilder (optional, bilder/<gerät>/): recovery-seite, bestaetigung, rampe-seite.
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Diese Anleitung ist für einen Pulse EX400 von **Genexis** oder **Inteno**
(Inteno heißt heute Genexis, die Geräte sind gleich). Der Router hat einen
eingebauten Notfall-Modus, über den du ohne Passwort eine neue Firmware
aufspielen kannst. Das geht in zwei Etappen, beide im Browser:

1. **Die Gluon-RAMpe aufspielen.** Über den Notfall-Modus lädst du die
   RAMpe hoch: eine kleine Firmware, die nur eins kann, nämlich die
   Freifunk-Firmware deiner Community annehmen.
2. **Die Freifunk-Firmware aufspielen.** Auf der Seite der RAMpe lädst du
   die Freifunk-Firmware deiner Community hoch.

Ein Terminal brauchst du nicht. Rechne mit einer Viertelstunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- diese zwei Dateien:
  1. die RAMpe für den EX400:
     [{{ w.rampe_datei }}]({{ w.rampe_url }})
     {%- if w.get("rampe_sha256") %}, SHA256 `{{ w.rampe_sha256 }}`{% endif %}.
     Nimm genau diese Datei (sie endet auf `-factory.bin`), nicht die
     RAMpe mit `initramfs` im Namen.
  2. die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar
     das **sysupgrade**-Image. Ein factory-Image gibt es für dieses Gerät
     nicht.

## Vorher prüfen

- Steht auf dem Gerät **DNA** (finnischer Anbieter, "DNA Valokuitu Plus
  EX400", mit einer LED "Update" statt "WPS")? Dann passt diese Anleitung
  nicht: Für diese Variante gibt es keine Freifunk-Firmware.
{%- if zusatz.vorher is defined and zusatz.vorher %}
{{ zusatz.vorher }}
{%- endif %}

## Schritte

### Teil 1: Die RAMpe über den Notfall-Modus aufspielen

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.10`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Nur
   `192.168.1.1` darf es nicht sein, die nimmt der Router.

2. **Kabel an LAN.** Steck das Kabel vom Rechner in eine **LAN**-Buchse des
   Routers (nicht in WAN).

3. **Notfall-Modus starten.** Zieh den Stecker des Netzteils. Halt die
   **Reset**-Taste gedrückt und steck das Netzteil wieder ein. Halt die
   Taste weiter, bis die **Status-LED orange** und die **WPS-LED grün**
   leuchtet. Dann loslassen. **Danach die Reset-Taste nicht noch einmal
   drücken:** Im Notfall-Modus schaltet ein Druck zwischen den beiden
   Systemen auf dem Router um.

4. **Notfall-Seite öffnen.** Öffne im Browser `http://192.168.1.1`. Es
   erscheint eine schlichte Seite mit einem Feld zum Hochladen einer
   Firmware. Je nach Version des Bootloaders sieht sie etwas anders aus.
   {%- if b.get("recovery-seite") %}

   ![Die Notfall-Seite des EX400 mit dem Feld zum Hochladen]({{ b["recovery-seite"] }})
   {%- endif %}

5. **RAMpe hochladen.** Wähl `{{ w.rampe_datei }}` aus und lad sie hoch.
   Warte, bis eine Bestätigungsseite erscheint.
   {%- if b.get("bestaetigung") %}

   ![Die Bestätigungsseite nach dem Hochladen]({{ b["bestaetigung"] }})
   {%- endif %}

6. **Neustart abwarten.** Der Router schreibt die RAMpe und startet neu.
   Strom nicht ziehen. Die RAMpe ist bereit, wenn der Router gleichmäßig
   blinkt, etwa einmal pro Sekunde.

### Teil 2: Freifunk-Firmware aufspielen

7. **Seite der RAMpe öffnen.** Öffne `http://192.168.1.1`. Die RAMpe leitet
   von selbst auf ihre Seite "Firmware aktualisieren" weiter. Kommt stattdessen "Not Found", hat sich der Browser eine Weiterleitung von früher gemerkt, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
   {%- if b.get("rampe-seite") %}

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"]({{ b["rampe-seite"] }})
   {%- endif %}

8. **Freifunk-Firmware hochladen.** Wähl das **sysupgrade**-Image deiner
   Community und klick "Datei hochladen". Die RAMpe zeigt die Prüfsumme
   (SHA256). Vergleich sie mit der Angabe deiner Community und klick
   "Fortfahren".

9. **Fertig.** Einige Minuten warten, Strom nicht ziehen. Stell den Rechner
   wieder auf "automatisch". Danach startet die Freifunk-Firmware deiner
   Community: je nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 leuchten Status-LED orange und WPS-LED grün.
- In Schritt 5 erscheint die Bestätigungsseite.
- In Schritt 6 blinkt der Router gleichmäßig, etwa einmal pro Sekunde.
- In Schritt 7 erscheint die Seite "Firmware aktualisieren".
- Nach Schritt 9 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die LEDs werden nicht orange und grün.** Netzteil ziehen und Schritt 3
  wiederholen. Die Reset-Taste muss schon gedrückt sein, bevor der Strom
  kommt.
- **Die Notfall-Seite erscheint nicht.** Prüf die feste Adresse am Rechner
  und ob das Kabel in einer LAN-Buchse steckt. Manche Browser machen aus
  `http` von selbst `https`, siehe
  [Browser macht https daraus](grundlagen/browser-https.md).
- **Die Seite der RAMpe erscheint nicht.** Noch eine Minute warten und die
  Seite neu laden. Startet der Router zwischendurch neu, die Seite einfach
  wieder aufrufen. Hilft das nicht: Der Notfall-Modus steckt im Bootloader
  und bleibt immer erhalten. Fang wieder bei Schritt 3 an.
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
