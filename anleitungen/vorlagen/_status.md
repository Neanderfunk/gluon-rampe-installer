{#-
Gemeinsamer Statusblock für alle Vorlagen, eingebunden per include
(Dateiname _status.md). Keine eigene Familie.

Nutzt: status, erprobt_am, erprobt_mit, erprobt_mit_aelter, modell, broken
(optional, vom Skript: Gluon führt das Gerät als broken) und aus
den Werten (alle optional):
  sicherheit           "praxis" (wir haben den Weg an Geräten dieses Typs schon gemacht,
                       Datum/Image aber nicht mehr bekannt, also kein status "erprobt"),
                       "quelle" (der Weg steht so in einer Primärquelle: OpenWrt-Commit,
                       Herstellerdoku), "abgeleitet" (wichtige Schritte von ähnlichen
                       Geräten oder aus dem Wiki übernommen) oder "unsicher" (einzelne
                       Schritte nur vermutet oder aus einem Einzelbericht)
  sicherheit_hinweis   ganzer Satz, was genau unsicher ist
Dazu risiko (vom Skript, optional): bei "bootloader" ein fester Warnkasten.
Dazu zusatz.achtung (Abschnitt "## Achtung" der Zusatzdatei): erscheint als
Warnkasten direkt unter dem Statusblock, für Dinge, die das Gerät unbrauchbar
machen können.
-#}
{%- set ws = werte -%}
{#- Ob und wie weit wir einen Weg selbst erprobt haben, ist eine interne Notiz
    und steht nicht auf der Seite (adorfer 21.11.2026), ebenso Herkunft und
    Gluon-"broken". status, erprobt_*, broken und herkunft bleiben im JSON.
    Sichtbar bleiben nur Warnungen, die beim Installieren helfen. -#}
{%- set praxis = status == "erprobt" or ws.get("sicherheit") == "praxis" %}
{%- if not praxis and ws.get("sicherheit") == "abgeleitet" %}
> Sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
{%- elif not praxis and ws.get("sicherheit") == "unsicher" %}
> **Vorsicht:** Einzelne Schritte sind bei diesem Gerät nicht sicher belegt.
> Probier es nur, wenn du notfalls einen Weg zurück kennst.
{%- endif %}
{%- if ws.get("sicherheit_hinweis") %}
> {{ ws.get("sicherheit_hinweis") }}
{%- endif %}
{%- if (not praxis and ws.get("sicherheit") in ("abgeleitet", "unsicher")) or ws.get("sicherheit_hinweis") %}
>
{%- endif %}
> Schreib uns, ob es geklappt hat. Und wenn es irgendwo hakt: Melde dich,
> wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject={{ ("Anleitung " ~ modell) | urlencode }})
{%- if risiko is defined and risiko == "bootloader" %}

> **Achtung, Bootloader:** Bei diesem Gerät wird der Bootloader verändert,
> also das kleine Programm, das vor jeder Firmware startet. Geht dabei etwas
> schief, etwa durch einen Stromausfall oder eine falsche Datei, startet das
> Gerät womöglich nicht mehr. Ohne Flash-Programmer gibt es dann meist kein
> Zurück. Lies die Anleitung vorher einmal ganz durch und halte dich genau an
> die Befehle.
{%- endif %}
{%- set za = zusatz.get("achtung") if zusatz is defined else "" %}
{%- if za %}

> **Achtung:** {{ za | replace("\n", "\n> ") }}
{%- endif %}
