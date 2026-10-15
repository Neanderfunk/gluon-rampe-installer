{#-
Vorlage image-auf-datentraeger (Raspberry Pi, NanoPi, x86): Image auf
Speicherkarte oder Platte schreiben. Entwurf Content, 15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    datei_art            "factory" oder "sysupgrade" (NanoPi: Gluon baut kein factory)
    medium               z. B. "eine microSD-Karte" oder "eine Festplatte, SSD
                         oder einen USB-Stick"
    anschluss            wo das Netzwerkkabel für die Einrichtung hingehört,
                         nach "Steck das Kabel an …", z. B. "die Netzwerkbuchse"

  Optional
    led                  sichtbares Zeichen beim ersten Start, ganzer Satz
    karte_bleibt         true: Karte nicht tauschen (MAC hängt an der Karte)
    vm                   true: es gibt fertige Abbilder für VirtualBox/VMware
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Beim {{ modell }} gibt es keine Firmware, die man über eine Oberfläche
hochlädt. Die Freifunk-Firmware wird als fertiges Abbild direkt auf
{{ w.medium }} geschrieben, und das Gerät startet davon.

## Was du brauchst

- das Gerät und {{ w.medium }}
- einen Rechner, an dem du {{ w.medium }} beschreiben kannst
- ein Netzwerkkabel für die Einrichtung
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **{{ w.datei_art }}**-Image (Endung `.img.gz`)
{%- if w.datei_art == "sysupgrade" %}. Das ist hier richtig, auch für die
  erste Installation: Für dieses Gerät gibt es kein factory-Image.{% endif %}
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Datei bereitlegen.** Lade das {{ w.datei_art }}-Image herunter.

2. **Image schreiben.** Schreib das ausgepackte Image auf {{ w.medium }},
   und zwar auf den ganzen Datenträger. Wie das geht, steht unter
   [Image auf einen Datenträger schreiben](grundlagen/image-schreiben.md).
   **Alles, was vorher darauf war, ist danach weg.**

3. **Einsetzen.** Steck den frisch beschriebenen Datenträger in das Gerät
   bzw. schließ ihn an.

4. **Verbinden und einschalten.** Steck das Netzwerkkabel vom Rechner an
   {{ w.anschluss }}. Der Rechner holt sich seine Adresse automatisch. Dann
   das Gerät einschalten.
   {%- if w.led %} {{ w.led }}{% endif %}

5. **Fertig.** Die Freifunk-Firmware startet: je nach Community zuerst mit
   einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
{%- if w.karte_bleibt %}

**Karte nicht tauschen:** Das Gerät leitet seine Netzwerkadresse (MAC) aus
der Seriennummer der Speicherkarte ab. Mit einer anderen Karte bekommt es eine
andere Adresse und erscheint in der Freifunk-Karte als neuer Knoten.
{%- endif %}

## Woran du erkennst, dass es geklappt hat

- Nach einer Minute oder zwei meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Das Gerät startet nicht.** Meist wurde das Image in eine Partition oder
  als Datei geschrieben statt auf den ganzen Datenträger, oder es wurde nicht
  ausgepackt. Noch einmal nach
  [Image auf einen Datenträger schreiben](grundlagen/image-schreiben.md).
- **Beim Auspacken kommt "trailing garbage ignored".** Das ist harmlos.
{{ zusatz.fehler }}
{%- if w.vm %}

## In einer virtuellen Maschine

Für VirtualBox und VMware gibt es die Firmware auch als fertige virtuelle
Festplatte (`.vdi` bzw. `.vmdk`). Die bindest du als Festplatte einer neuen
virtuellen Maschine ein, statt ein Image zu schreiben.
{%- endif %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
