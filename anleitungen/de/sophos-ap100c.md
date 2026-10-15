---
gluon_name: sophos-ap100c
modell: Sophos AP100C
anzeige: Sophos AP100C
familie: sophos-xg-awetool
gluon_broken: false
sprache: de
stufe: mit scripts/Netzwerktools
status: ungeprüft
grundlagen: [feste-ip, serielle-konsole, tftp-server]
daten_stand: 440a725
vorlage_stand: f350b7d
---

# Sophos AP100C: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Sophos%20AP100C)

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

- den Access Point und Strom über PoE (802.3af)
  oder ein 12-V-Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- einen **USB-Seriell-Adapter für 3,3 V** mit drei Steckkabeln und einen
  Schraubendreher
- die Freifunk-Firmware deiner Community für den Sophos AP100C, und zwar das
  **sysupgrade**-Image (ein factory-Image gibt es für dieses Gerät nicht).
  Leg es in den Ordner deines TFTP-Servers und benenn es dort genau in
  **`uImage_AP100C`** um, ohne Endung.

## Vorher prüfen

Der AP100C und der AP55C sind von außen kaum zu unterscheiden, brauchen aber
verschiedene Freifunk-Firmware. Schau auf das Typenschild; steht dort AP55C,
nimm die [Anleitung für den AP55C](sophos-ap55c.md).

## Schritte

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.99.8`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Access Point den TFTP-Server.

2. **TFTP-Server starten** mit dem Ordner, in dem `uImage_AP100C` liegt
   ([TFTP-Server einrichten](grundlagen/tftp-server.md)).

3. **Gehäuse öffnen und Adapter anschließen.** Die Platine muss dafür aus dem Gehäuse; sie ist mit drei Schrauben befestigt.
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

   **Prüfen:** Der Bootloader zeigt `Filename 'uImage_AP100C'`, eine
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

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Forum-Zusammenfassung: Sophos-Community-Blog "EOL Extension: AP Series", nur über Websuche gelesen (Bedingung an die Herstellerfirmware)
- Forum-Zusammenfassung: avanet.com End-of-Sale-Artikel (Bedingung an die Herstellerfirmware)
- abgeleitet (Anschluss, Adressen, Bedingung an die Herstellerfirmware, Dauer)
- abgeleitet: Partitionstabelle im DTS am Pin, Flash ab 0x9f000000 (Warnung)
- abgeleitet: Sophos-EOL-Angaben, siehe stock_bedingung (Fehlerbild)
- abgeleitet: better safe than sorry (Notweg)
- geprüft (Weg ab Werk, Quelle (OpenWrt-Commit))
- geprüft: Commit 6f1efb2 (Schritte (Normalweg), Warnung, Taste und Zeitpunkt, Sichtbare Zeichen, Anschluss, Adressen, Programm, Zugang, Datei, Typenschild/Verwechslung, Bedingung an die Herstellerfirmware, Dauer, Notweg)
- geprüft: Commit 6f1efb2, Image-Rezepte am Pin (Typenschild/Verwechslung)
- geprüft: Commit 6f1efb2; 3.3V-Hinweis abgeleitet (Notweg)
- geprüft: DTS-Aliase am Pin, qca9558_sophos_ap.dtsi (Sichtbare Zeichen)
- geprüft: Image-Rezept am Pin, Inventar (Datei)
- geprüft: OpenWrt-Commit 6f1efb2, Fußnote 4 (Programm)
- Geräteeintrag: 6f1efb28983758116a8ecaf9c93e1d875bb70af7 [geprüft]
