{#-
Gemeinsamer Abschnitt "Anderer Weg: mit der Gluon-RAMpe", eingebunden per
include in Vorlagen, deren Familie sonst eine OpenWrt-Zwischenstufe braucht.
Erscheint nur, wenn werte.rampe_url gesetzt ist.

Nutzt: modell, bilder (b), werte.rampe_url, werte.rampe_datei (optional,
Dateiname für den Text), werte.rampe_weg (ganzer Satz, wie die RAMpe statt
OpenWrt auf das Gerät kommt, z. B. "Lade in Schritt 5 statt der
OpenWrt-Datei die RAMpe hoch.").
-#}
{%- set wr = werte -%}
{%- set br = bilder if bilder is defined else {} -%}
{%- if wr.get("rampe_url") %}

## Anderer Weg: mit der Gluon-RAMpe (ungetestet)

Statt erst OpenWrt und dann die Freifunk-Firmware aufzuspielen, geht es auch
mit der **Gluon-RAMpe**: einer kleinen Firmware, die nur eins kann, nämlich
die Freifunk-Firmware deiner Community annehmen. Das spart die
OpenWrt-Etappe. Für den {{ modell }} ist dieser Weg **noch von niemandem
ausprobiert**; die RAMpe selbst läuft auf anderen Geräten.

1. Lade die RAMpe für den {{ modell }} herunter:
   [{{ wr.get("rampe_datei") or "RAMpe-Datei" }}]({{ wr.get("rampe_url") }}).
2. {{ wr.get("rampe_weg") or "Spiel sie auf demselben Weg auf wie oben die OpenWrt-Datei." }}
3. Nach dem Neustart öffne `http://192.168.1.1/cgi-bin/config`. Es erscheint
   die Seite "Firmware aktualisieren" der RAMpe. Kommt "Not Found", hat sich
   der Browser eine Seite von früher gemerkt: Tipp die Adresse vollständig
   ein, mit `/cgi-bin/config` am Ende. Hilft das nicht, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Kommt gar nichts, siehe [Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md). Startet der Router zwischendurch neu,
   einfach die Seite wieder aufrufen.
   {%- if br.get("rampe-seite") %}

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"]({{ br["rampe-seite"] }})
   {%- endif %}
4. Wähl das **sysupgrade**-Image deiner Community und klick "Datei
   hochladen". Die RAMpe zeigt die Prüfsumme (SHA256); vergleich sie mit der
   Angabe deiner Community und klick "Fortfahren".
5. Nach wenigen Minuten startet die Freifunk-Firmware.

Zeigt der Browser beim Aufruf eine Warnung vor dem Zertifikat, siehe
[Browser macht https daraus](grundlagen/browser-https.md).
{%- endif %}
