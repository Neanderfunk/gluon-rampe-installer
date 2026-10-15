{#-
Vorlage netgear-nmrp (Netgear: Firmware per nmrpflash an den Bootloader).
Entwurf Content, 15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    (keine)

  Optional (leer = allgemeiner Satz)
    anschluss            Buchse, nach "Steck das Kabel an …", z. B. "die LAN-Buchse 1"
    nach_neustart        was nach "Reboot your device now." zu tun ist, ganzer Satz
    web_moeglich         true: die Netgear-Oberfläche nimmt das factory-Image auch;
                         dann ist sie der Hauptweg und nmrpflash der andere Weg
                         (adorfer 15.10.2026: Level nach dem leichtesten Weg)
    web_nicht            true: die Netgear-Oberfläche nimmt es nicht, nur nmrpflash
    zwischen_datei       OpenWrt-factory als Zwischenschritt (wenn Gluon keins baut)
    zwischen_url         Download-Adresse dazu

  RAMpe als zweiter Weg (siehe _rampe.md, alles optional)
    rampe_url            Direktlink auf die RAMpe-Datei für dieses Gerät
    rampe_datei          Dateiname dazu
    rampe_weg            ganzer Satz, wie die RAMpe statt OpenWrt aufs Gerät kommt
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

{%- macro nmrp_schritte() %}
1. **nmrpflash bereitlegen.** Lade nmrpflash herunter und richte es ein, wie
   unter [nmrpflash benutzen](grundlagen/nmrpflash.md) beschrieben. Leg
   {%- if w.zwischen_datei %} die OpenWrt-Datei{% else %} das factory-Image{% endif %}
   in denselben Ordner und benenne es in `firmware.img` um.

2. **Verbinden.** Das Gerät ist **aus**. Steck das Kabel vom Rechner an
   {%- if w.anschluss %} {{ w.anschluss }}{% else %} die LAN-Buchse (bei
   Netgear oft blau; bei mehreren die mit "1"){% endif %}. Schalte die
   Firewall am Rechner für die Dauer aus.

3. **Anschluss finden.** Im Terminal (als Administrator bzw. mit `sudo`):

   ```
   nmrpflash -L
   ```

   Merk dir den Namen des Anschlusses, an dem das Kabel steckt, zum Beispiel
   `eth0` oder `net1`.

4. **nmrpflash starten.** Mit diesem Namen statt `eth0`:

   ```
   nmrpflash -i eth0 -f firmware.img
   ```

5. **Gerät einschalten,** sobald `Waiting for Ethernet connection` erscheint.

6. **Warten.** nmrpflash meldet `Uploading … OK` und dann `Waiting for remote
   to respond.` Jetzt schreibt das Gerät, das dauert meist wenige Minuten,
   manchmal 15 Minuten und mehr. **Strom nicht ziehen,** bis
   `Reboot your device now.` erscheint.

7. **Neu starten.**
   {%- if w.nach_neustart %} {{ w.nach_neustart }}
   {%- else %} Schalte das Gerät aus und wieder ein.{% endif %}
{%- if w.zwischen_datei %}

8. **Freifunk-Firmware über OpenWrt.** Stell den Rechner auf
   "automatisch", öffne `http://192.168.1.1` und melde dich an
   (Passwort-Feld leer). Unter **System → Backup / Flash Firmware**,
   "Flash image…", das Freifunk-sysupgrade-Image wählen, **den Haken bei
   "Keep settings" entfernen** und **Continue**. Einige Minuten warten.

9. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
{%- else %}

8. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
{%- endif %}
{%- endmacro %}
{%- macro nmrp_fehler() %}
- **"No response after 60 seconds."** Reihenfolge einhalten: erst nmrpflash
  starten, dann das Gerät einschalten. Manche Netgear-Geräte brauchen beim
  Einschalten zusätzlich die gedrückte Reset-Taste. Eine andere LAN-Buchse
  probieren.
- **"Timeout while waiting for ACK(0)/OACK."** Meist die Firewall am Rechner.
- Weitere Meldungen erklärt [nmrpflash benutzen](grundlagen/nmrpflash.md).
{%- endmacro %}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}
{%- if w.web_moeglich %}

Bei diesem Gerät nimmt die normale Weboberfläche von Netgear die
Freifunk-Firmware an. Das ist der einfache Weg. Klappt er nicht, gibt es
unten einen zweiten Weg mit dem Programm nmrpflash.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **factory**-Image (im Firmware-Selector unter "Wähle Deine
  Installationsart" der Knopf **Erstinstallation**)
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Anschließen.** Steck das Kabel vom Rechner an
   {%- if w.anschluss %} {{ w.anschluss }}{% else %} eine LAN-Buchse des
   Geräts{% endif %} und schalte es ein. Der Rechner bleibt auf "automatisch"
   (DHCP). Warte zwei Minuten.

2. **Netgear-Oberfläche öffnen.** Die Adresse steht auf dem Aufkleber des
   Geräts; bei Netgear-Routern ist es meist `http://routerlogin.net`, bei
   Repeatern `http://mywifiext.net`. Melde dich an; im Werkszustand fragt
   das Gerät zuerst nach einem neuen Passwort.

3. **Freifunk-Firmware hochladen.** Such den Menüpunkt für das
   Firmware-Update (meist unter "Erweitert" bzw. "Advanced" und dann
   "Verwaltung" bzw. "Administration"), wähl das factory-Image aus und
   starte das Update. Fragt die Oberfläche nach, ob sie wirklich diese
   Datei nehmen soll, bestätige.

4. **Warten.** Das Gerät schreibt die Freifunk-Firmware und startet neu,
   einige Minuten. **Strom nicht ziehen.**

5. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je
   nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 nimmt die Oberfläche die Datei an und zeigt den Fortschritt.
- Nach Schritt 4 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Prüf, ob du das factory-Image für
  genau dein Modell genommen hast. Sonst nimm den Weg mit nmrpflash unten.
- **Das Gerät startet nach dem Update nicht richtig.** Auch dann hilft der
  Weg mit nmrpflash: Der Bootloader nimmt die Firmware auch dann noch an.
{{ zusatz.fehler }}

## Anderer Weg: mit nmrpflash

Netgear-Geräte fragen direkt nach dem Einschalten im Netzwerk, ob jemand
eine Firmware für sie hat. Das Programm **nmrpflash** auf deinem Rechner
antwortet darauf und schickt die Freifunk-Firmware
([nmrpflash benutzen](grundlagen/nmrpflash.md)).
{{ nmrp_schritte() }}

Wenn nmrpflash Fehler meldet:
{{ nmrp_fehler() }}
{%- else %}

Viele Netgear-Geräte fragen direkt nach dem Einschalten im Netzwerk, ob
jemand eine Firmware für sie hat. Das Programm **nmrpflash** auf deinem
Rechner antwortet darauf und schickt die Freifunk-Firmware. Das geht auch
dann, wenn die Netgear-Oberfläche fremde Firmware nicht annimmt.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- das Programm nmrpflash ([nmrpflash benutzen](grundlagen/nmrpflash.md))
{%- if w.zwischen_datei %}
- OpenWrt für den {{ modell }}:
  [{{ w.zwischen_datei }}]({{ w.zwischen_url }}). Die Freifunk-Firmware
  gibt es für dieses Gerät nicht in der Form, die nmrpflash schickt; deshalb
  kommt erst OpenWrt drauf und darüber die Freifunk-Firmware.
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image
{%- else %}
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **factory**-Image
{%- endif %}
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte
{{ nmrp_schritte() }}

## Woran du erkennst, dass es geklappt hat

- nmrpflash endet mit `Reboot your device now.`
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht
{{ nmrp_fehler() }}
{{ zusatz.fehler }}
{%- if w.web_nicht %}

## Warum nicht über die Netgear-Oberfläche?

Bei diesem Gerät nimmt die Netgear-Oberfläche die Freifunk-Firmware nicht
an. nmrpflash ist der Weg.
{%- endif %}
{%- endif %}

{% include "_rampe.md" %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
