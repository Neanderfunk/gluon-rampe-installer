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
Dazu zusatz.achtung (Abschnitt "## Achtung" der Zusatzdatei): erscheint als
Warnkasten direkt unter dem Statusblock, für Dinge, die das Gerät unbrauchbar
machen können.
-#}
{%- set ws = werte -%}
{%- if status == "erprobt" %}
> **Am Gerät erprobt** am {{ erprobt_am }} mit `{{ erprobt_mit }}`.
{%- if erprobt_mit_aelter %} Das aktuelle Image ist neuer und in dieser Form
> noch nicht am Gerät gelaufen.{% endif %}
{%- elif ws.get("sicherheit") == "praxis" %}
> **Bei uns in der Praxis erprobt.** Wir haben Geräte dieses Typs schon so
> umgestellt, nur noch nicht mit der aktuellen Version der
> Freifunk-Firmware.
{%- if broken is defined and broken %}
> Die Freifunk-Firmware für dieses Gerät gilt bei Gluon als nicht ausreichend
> getestet ("broken"); nicht jede Community bietet sie an.
{%- endif %}
{%- if ws.get("sicherheit_hinweis") %}
> {{ ws.get("sicherheit_hinweis") }}
{%- endif %}
{%- else %}
> **Noch nicht am Gerät erprobt.**
{%- if ws.get("sicherheit") == "quelle" %} So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
{%- elif ws.get("sicherheit") == "abgeleitet" %} Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
{%- elif ws.get("sicherheit") == "unsicher" %} Einzelne Schritte beruhen nur auf
> Vermutungen oder auf einem einzelnen Bericht. Probier es nur, wenn du
> notfalls einen Weg zurück kennst.
{%- else %} Die Anleitung ist aus Quellen zusammengestellt. Wie gut jede
> Angabe belegt ist, steht unten unter "Herkunft der Angaben".
{%- endif %}
{%- if broken is defined and broken %}
> Die Freifunk-Firmware für dieses Gerät gilt bei Gluon als nicht ausreichend
> getestet ("broken"); nicht jede Community bietet sie an.
{%- endif %}
{%- if ws.get("sicherheit_hinweis") %}
> {{ ws.get("sicherheit_hinweis") }}
{%- endif %}
{%- endif %}
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject={{ ("Anleitung " ~ modell) | urlencode }})
{%- set za = zusatz.get("achtung") if zusatz is defined else "" %}
{%- if za %}

> **Achtung:** {{ za | replace("\n", "\n> ") }}
{%- endif %}
