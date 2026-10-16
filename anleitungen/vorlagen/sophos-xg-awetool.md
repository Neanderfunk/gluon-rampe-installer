{#-
Vorlage sophos-xg-awetool (Sophos AP15C, AP55, AP55C, AP100, AP100C): Weg 1
über die serielle Konsole im Gehäuse (U-Boot: tftpboot, cp.b in den Flash,
boot), Weg 2 über eine Sophos-SG/XG-Firewall (awetool, mtd write).

Weg: OpenWrt-Commits 6f1efb2 (AP100/AP100C/AP55/AP55C) und a7abc7e (AP15C),
beide mit denselben Befehlen. Die Gluon-Datei ist das sysupgrade-Image
(Gluon baut für diese Geräte kein factory). Der TFTP-Name heißt im Commit
"uImage_AP100C" bzw. "uImage_AP15C"; für AP100, AP55 und AP55C ist er nach
diesem Muster abgeleitet, deshalb der Hinweis auf die Zeile "Filename".

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    tftp_name            Dateiname, den der Bootloader per TFTP holt, z. B.
                         "uImage_AP100C"

  optional
    uart_ort             ganzer Satz, wie man an die Stiftleiste kommt
    strom                Stromversorgung, z. B. "über PoE (802.3af) oder ein
                         12-V-Netzteil (Hohlstecker 5,5 × 2,1 mm)"
    sicherheit, sicherheit_hinweis   siehe _status.md
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Die Access Points von Sophos nehmen keine fremde Firmware über eine
Weboberfläche an. Es gibt zwei Wege:

- **Über die serielle Konsole** (hier beschrieben): Du öffnest das Gehäuse,
  schließt einen USB-Seriell-Adapter an und schreibst die Freifunk-Firmware
  mit drei Befehlen im Bootloader direkt in den Speicher.
- **Über eine Sophos-Firewall** (SG oder XG), wenn du ohnehin eine hast;
  dann musst du das Gehäuse nicht öffnen. Siehe "Anderer Weg" unten.

Für den ersten Weg brauchst du zwei Werkzeuge, die auf eigenen Seiten
erklärt sind: [Serielle Konsole benutzen](grundlagen/serielle-konsole.md) und
[TFTP-Server einrichten](grundlagen/tftp-server.md). Rechne mit einer
Stunde.

## Was du brauchst

- den Access Point und Strom
  {%- if w.get("strom") %} {{ w.get("strom") }}{% else %} über PoE (802.3af)
  oder ein 12-V-Netzteil{% endif %}
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- einen **USB-Seriell-Adapter für 3,3 V** mit drei Steckkabeln und einen
  Schraubendreher
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **sysupgrade**-Image (ein factory-Image gibt es für dieses Gerät nicht).
  Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
  **`{{ w.tftp_name }}`** um, ohne Endung.
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.99.8`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Access Point den TFTP-Server.

2. **TFTP-Server starten** mit dem Ordner, in dem `{{ w.tftp_name }}` liegt
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Gehäuse öffnen und Adapter anschließen.**
   {%- if w.get("uart_ort") %} {{ w.get("uart_ort") }}{% endif %}
   Auf der Platine sitzt eine Stiftleiste mit vier Stiften; Stift 1 ist
   markiert. Von Stift 1 an: **3,3 V, GND, TX, RX**. Verbinde GND mit GND
   des Adapters, TX des Access Points mit RX des Adapters und RX mit TX.
   **Stift 1 (3,3 V) nicht anschließen.**

4. **Netzwerk und Terminal.** Netzwerkkabel vom Rechner an die
   Netzwerkbuchse des Access Points. Starte das Terminalprogramm mit
   **115200** Baud, 8N1, ohne Flusssteuerung
   ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).

5. **Bootloader anhalten.** Schließ jetzt den Strom an. Sobald im Terminal
   die Aufforderung erscheint, den automatischen Start abzubrechen, drück
   eine Taste. **Prüfen:** Es erscheint eine Eingabeaufforderung des
   Bootloaders. Sonst Strom ziehen und noch einmal.

6. **Datei holen.** Gib ein:

   ```
   tftpboot
   ```

   **Prüfen:** Der Bootloader zeigt `Filename '{{ w.tftp_name }}'`, eine
   Reihe `#` und am Ende `done` bzw. `Bytes transferred`. Sucht er einen
   anderen Dateinamen, benenn die Datei auf dem Rechner genau so um und gib
   `tftpboot` noch einmal ein. Kommt die Datei nicht an, hier aufhören.

7. **In den Speicher schreiben.** Gib ein, genau so:

   ```
   cp.b $fileaddr 0x9f070000 $filesize
   ```

   Das dauert eine Weile. **Strom nicht ziehen**, bis die
   Eingabeaufforderung wieder erscheint.

8. **Starten.** Gib ein:

   ```
   boot
   ```

   Der Access Point startet mit der Freifunk-Firmware. Der erste Start
   dauert einige Minuten.

9. **Fertig.** Strom ziehen, Adapter abnehmen, Gehäuse schließen, wieder
   einschalten. Stell den Rechner wieder auf "automatisch". Je nach
   Community startet die Freifunk-Firmware zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 6 zeigt der Bootloader `done` bzw. `Bytes transferred`.
- Nach Schritt 8 zeigt das Terminal den Start von Linux, und die
  Freifunk-Firmware meldet sich.

## Wenn etwas schiefgeht

- **Im Terminal erscheint nichts oder nur wirre Zeichen.** Prüf die
  Geschwindigkeit (115200), GND und die Leitungen; TX und RX tauschen
  ([Serielle Konsole benutzen](grundlagen/serielle-konsole.md)).
- **In Schritt 6 kommt die Datei nicht an.** Prüf die feste Adresse
  `192.168.99.8`, die Firewall deines Rechners und den Dateinamen.
- **Schritt 7 meldet einen Fehler.** Nicht `boot` eingeben, sondern die
  Ausgabe abschreiben (oder die Mitschrift des Terminals nehmen) und uns
  schreiben.
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

## Anderer Weg: über eine Sophos-Firewall

Hast du eine Sophos-Firewall (SG oder XG), geht es ohne Öffnen des
Gehäuses. Laut OpenWrt (2021) gab es dafür von Sophos eine kostenlose
Lizenz für den Hausgebrauch; die Firewall läuft dann auf einem eigenen
Rechner oder in einer virtuellen Maschine. So beschreiben es die
Entwickler von OpenWrt:

1. Firewall einrichten und den SSH-Zugang zu ihrer Konsole einschalten.
2. Den Access Point an die LAN-Schnittstelle der Firewall anschließen, in
   ihrer Weboberfläche freigeben ("Approve") und warten, bis er als
   "Active" erscheint (3 bis 5 Minuten).
3. Per SSH auf die Firewall, die "Advanced Console" öffnen (Menüpunkt 5,
   dann Menüpunkt 3) und `sudo awetool` starten. Dort den Menüpunkt wählen,
   mit dem man sich per SSH auf einen Access Point verbindet, und die Frage,
   ob SSH auf dem Access Point eingeschaltet werden soll, mit "Yes"
   beantworten.
4. 2 bis 3 Minuten warten und den Access Point im awetool-Menü noch einmal
   wählen. Jetzt bist du als root auf dem Access Point angemeldet.
5. Das sysupgrade-Image als `/tmp/openwrt.bin` auf den Access Point kopieren
   und dort eingeben:

   ```
   mtd -r write /tmp/openwrt.bin astaro_image
   ```

   Danach startet der Access Point mit der Freifunk-Firmware neu.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
