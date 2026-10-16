{#-
Vorlage tplink-tftp-recovery (TP-Link mit MT76x8, deren Weboberfläche ein
fremdes Image beim Schreiben beschädigt: Archer C20 v4, Archer C50 v3,
TL-MR3020 v3, TL-MR3420 v5, TL-MR6400 v5, TL-WA801ND v5, TL-WR841N v13,
TL-WR902AC v3/v4): Der Bootloader holt per TFTP "tp_recovery.bin" vom
Rechner und schreibt sie selbst. Gluon liefert dafür das Image
"-bootloader.bin" (aus -squashfs-tftp-recovery, Gluon targets/ramips-mt76x8),
im Firmware-Selector unter dem Knopf "Bootloader-Image".

Weg: OpenWrt-Commits der Geräte, z. B. 24043a0 (TL-WR841N v13: Weboberfläche
beschädigt das factory, "the only way … is to use tftp recovery mode in
U-Boot", 192.168.0.66/24, tp_recovery.bin, Reset beim Einschalten).

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    rechner_ip           feste Adresse des Rechners, "192.168.0.66" oder
                         "192.168.0.225"
    taste                ganzer Satz, wie man die Recovery startet, z. B.
                         "Halt die Reset-Taste gedrückt, schalte den Router
                         ein und halt sie noch etwa 7 Sekunden weiter."

  optional
    tftp_name            Dateiname, Vorgabe "tp_recovery.bin"
    tftp_name2           zweiter Name, wenn die Quellen sich widersprechen
                         (dann beide Dateien ablegen)
    zeichen              ganzer Satz, woran man die Recovery bzw. das
                         Schreiben an den LEDs erkennt
    strom                wenn nicht Netzteil, z. B. "über USB"
    sicherheit, sicherheit_hinweis   siehe _status.md
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set name = w.get("tftp_name") or "tp_recovery.bin" -%}
{%- set name2 = w.get("tftp_name2") -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Bei diesem Router nimmt die Weboberfläche von TP-Link die Freifunk-Firmware
zwar an, beschädigt sie aber beim Schreiben. **Lade sie dort also nicht
hoch.** Der Weg führt stattdessen über den Notfall-Modus des Bootloaders:
Beim Einschalten mit gedrückter Reset-Taste holt sich der Router eine Datei
von deinem Rechner und schreibt sie selbst. Dein Rechner spielt dafür den
TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)). Rechne
mit einer halben Stunde.

## Was du brauchst

- den Router{% if w.get("strom") %} und Strom {{ w.get("strom") }}{% else %} mit Netzteil{% endif %}
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- einen TFTP-Server auf dem Rechner
  ([TFTP-Server einrichten](grundlagen/tftp-server.md))
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  Image, das auf **`-bootloader.bin`** endet. Im Firmware-Selector wählst du
  dafür unter "Wähle Deine Installationsart" den Knopf
  **Bootloader-Image**. Benenn die Datei in **`{{ name }}`** um
  {%- if name2 %} und leg zusätzlich eine Kopie mit dem Namen
  **`{{ name2 }}`** daneben. Die Quellen nennen beide Namen; so passt es in
  jedem Fall{% endif %}.
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `{{ w.rechner_ip }}`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Unter dieser
   Adresse sucht der Router den TFTP-Server.

2. **TFTP-Server starten** mit dem Ordner, in dem `{{ name }}` liegt.
   Erlaube ihm in der Firewall den Zugriff.

3. **Kabel anschließen.** Netzwerkkabel vom Rechner an eine LAN-Buchse des
   Routers. Strom noch nicht anschließen.

4. **Notfall-Modus starten.** {{ w.taste }}
   {%- if w.get("zeichen") %} {{ w.get("zeichen") }}{% endif %}
   **Prüfen:** Im Protokoll des TFTP-Servers erscheint, dass
   `{{ name }}`{% if name2 %} oder `{{ name2 }}`{% endif %} abgeholt wird.
   Sonst Strom ziehen und noch einmal.

5. **Warten.** Der Router schreibt die Freifunk-Firmware und startet von
   selbst neu. Das dauert einige Minuten. **Strom nicht ziehen.**

6. **Fertig.** Stell den Rechner wieder auf "automatisch". Je nach Community
   kommt zuerst eine Einrichtungsseite unter `http://192.168.1.1`, oder der
   Router geht gleich in Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 zeigt der TFTP-Server den Abruf der Datei.
- Nach Schritt 5 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Der Router holt die Datei nicht.** Prüf der Reihe nach: feste Adresse
  `{{ w.rechner_ip }}`, Kabel an einer LAN-Buchse (nicht WAN), Firewall,
  Dateiname. Windows blendet Dateiendungen gern aus; heißt die Datei im
  Explorer `{{ name }}`, kann sie in Wirklichkeit
  `{{ name }}.bin` heißen. Dann den Notfall-Modus noch einmal starten und
  die Taste diesmal etwas kürzer oder länger halten.
- **Du hast die Datei schon über die Weboberfläche hochgeladen** und der
  Router startet nicht mehr richtig: Kein Problem, genau dafür ist dieser
  Weg. Fang bei Schritt 1 an.
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

## Zurück zur TP-Link-Firmware

Über denselben Notfall-Modus nimmt der Router auch eine TP-Link-Firmware an.
Je nach Modell muss die Datei dafür vorher angepasst werden; das steht im
OpenWrt-Wiki zu deinem Gerät.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
