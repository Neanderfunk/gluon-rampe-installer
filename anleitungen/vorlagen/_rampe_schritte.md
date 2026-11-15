{#-
Gemeinsame Schritte "RAMpe-Seite öffnen" und "Freifunk-Firmware hochladen"
für Vorlagen, in denen die RAMpe die frühere OpenWrt-Zwischenstufe ersetzt
(adorfer 15.11.2026: "bitte alles auf RAMpe umstellen"). Keine Familie.

Einbinden mit
  {%- import "_rampe_schritte.md" as rs with context %}
und aufrufen als {{ rs.seite(5) }} (erzeugt Schritt 5 und 6). Läuft die
RAMpe nur im Arbeitsspeicher (initramfs), mit {{ rs.seite(8, ram=5) }}: Dann
steht statt "bleibt auf dem Router" der Hinweis, dass sie nach einem
Neustart weg ist und es ab Schritt 5 (dem Laden der RAMpe) neu losgeht.

Nutzt aus dem Kontext: bilder (rampe-seite, rampe-pruefsumme,
rampe-flash-laeuft, gesucht wie üblich je Gerät, dann allgemein).
Wie der Rechner zur Adresse kommt, sagt die aufrufende Vorlage vorher
selbst (fest oder automatisch).

Die RAMpe leitet von http://192.168.1.1 selbst auf ihre Seite weiter
(adorfer 12.11.2026).
-#}
{%- macro seite(n, ram=none) -%}
{%- set br = bilder if bilder is defined else {} -%}
{{ n }}. **Die RAMpe-Seite öffnen.** Öffne `http://192.168.1.1`. Die RAMpe
   leitet von selbst auf ihre Seite "Firmware aktualisieren" weiter. Kommt
   stattdessen "Not Found", hat sich der Browser eine Weiterleitung von
   früher gemerkt, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
   Kommt gar nichts, siehe [Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md).
   Zeigt der Browser eine Warnung vor einem unsicheren Zertifikat, hat er
   von sich aus `https://` vor die Adresse gesetzt, siehe
   [Browser macht https daraus](grundlagen/browser-https.md).
   {%- if ram %}
   Die RAMpe läuft nur im Arbeitsspeicher. Startet das Gerät zwischendurch
   neu oder fehlt der Strom, ist sie weg: dann noch einmal ab Schritt {{ ram }}.
   {%- else %}
   Die RAMpe bleibt auf dem Router, bis die Freifunk-Firmware sie ersetzt.
   Startet der Router zwischendurch neu, ist das harmlos: Seite einfach
   wieder aufrufen.
   {%- endif %}
   {%- if br.get("rampe-seite") %}

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"]({{ br["rampe-seite"] }})
   {%- endif %}

{{ n + 1 }}. **Freifunk-Firmware hochladen.** Wähl das **sysupgrade**-Image
   deiner Community aus und klick "Datei hochladen". Die RAMpe zeigt die
   Prüfsumme (SHA256) der Datei. Vergleich sie mit der Prüfsumme, die deine
   Community zur Datei angibt. Stimmt sie, klick "Fortfahren".
   {%- if br.get("rampe-pruefsumme") %}

   ![Die RAMpe zeigt Prüfsumme und Größe der Datei, darunter "Abbrechen" und "Fortfahren"]({{ br["rampe-pruefsumme"] }})
   {%- endif %}

   Danach erscheint der Hinweis, dass die Firmware jetzt geschrieben wird.
   Jetzt den Strom nicht unterbrechen.
   {%- if br.get("rampe-flash-laeuft") %}

   ![Hinweis der RAMpe: Die Firmware wird jetzt aktualisiert, Stromversorgung nicht unterbrechen]({{ br["rampe-flash-laeuft"] }})
   {%- endif %}
{%- endmacro %}
