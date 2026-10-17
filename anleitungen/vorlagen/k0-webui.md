{#-
Vorlage k0-webui (factory-Image über die Weboberfläche der Hersteller-
firmware hochladen). Gilt für alle Hersteller dieser Familie; Besonderheiten
einzelner Geräte stehen in zusatz/<gluon_name>.md. Entwurf Content,
15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken), alle optional
(leer = Satz entfällt bzw. allgemeiner Satz):

  Oberfläche
    stock_url            Adresse der Herstelleroberfläche, z. B. http://192.168.0.1;
                         mehrere getrennt durch " oder ": "http://192.168.0.1 oder http://192.168.1.1"
    zugang               z. B. "Benutzer `admin`, Passwort `admin`"
    rechner_ip           feste Adresse für den Rechner, z. B. 192.168.0.10
                         (leer = Rechner holt die Adresse automatisch)
    zertifikat           true: Oberfläche nur über https mit eigenem Zertifikat
    tls_alt              true: Oberfläche nur mit TLS 1.0 (Pharos)
    menue                Menüpfad zum Firmware-Update, z. B. "System Tools → Firmware Upgrade"
    strom                wenn nicht das Netzteil, z. B. "über den mitgelieferten PoE-Injektor"
    anschluss            Buchse am Gerät oder Injektor, nach "Steck das Kabel an …",
                         z. B. "die LAN-Buchse des PoE-Injektors"

  Datei
    datei_art            "factory" (leer = factory) oder "sysupgrade", wenn ab Werk
                         schon OpenWrt läuft (z. B. OpenWrt One)
    einstellungen_abwaehlen  true: die Oberfläche bietet an, Einstellungen zu
                         behalten (OpenWrt/LuCI); der Haken muss weg
    datei_hinweis        Zusatz zur Image-Auswahl, z. B. "mit „-eu“ im Namen"
    dateiname            Name, in den das Image vorher umbenannt werden muss,
                         z. B. factory.bin (genau so)
    nach_upload          was nach dem Hochladen normal ist, z. B. "eine Seite
                         „page not found“"
    dauer                z. B. "etwa zwei Minuten" (leer = "einige Minuten")

  Notfall über TFTP (nur wenn tftp_datei gesetzt)
    tftp_datei           Dateiname, den der Router abholt, z. B. ArcherC7v5_tp_recovery.bin
    tftp_inhalt          was unter diesem Namen liegen muss, z. B. "das factory-Image"
    tftp_server_ip       feste Adresse des Rechners, z. B. 192.168.0.66
    tftp_taste           nach "Halte sie gedrückt:", z. B. "etwa 5 Sekunden" oder
                         "bis die WPS-LED leuchtet"
    tftp_dauer           z. B. "etwa 150 Sekunden"
    tftp_hinweis         z. B. "Steck einen Switch zwischen Router und Rechner …"
  oder
    notweg_keiner        Satz, warum es keinen einfachen Notweg gibt
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set art = w.datei_art if w.datei_art else "factory" -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Beim {{ modell }} geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und
  {%- if w.strom %} Strom {{ w.strom }}{% else %} sein Netzteil{% endif %}
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
{%- if w.tls_alt %}
- den Browser **Firefox**; mit anderen Browsern lässt sich die Oberfläche
  dieses Geräts nicht öffnen (siehe Schritt 3)
{%- endif %}
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  {%- if art == "factory" %}
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"
  {%- else %}
  **{{ art }}**-Image
  {%- endif %}
  {%- if w.datei_hinweis %} ({{ w.datei_hinweis }}){% endif %}

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "{{ modell }}", bevor du anfängst.
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Datei bereitlegen.** Lade das {{ art }}-Image herunter.
   {%- if w.dateiname %} Benenne es danach in `{{ w.dateiname }}` um, genau
   so. Die Oberfläche lehnt den langen Originalnamen sonst ab. Achtung:
   Windows blendet Dateiendungen gern aus; schalte sie im Explorer unter
   "Ansicht" ein, damit nicht `{{ w.dateiname }}.bin` daraus wird.
   {%- endif %}

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an
   {%- if w.anschluss %} {{ w.anschluss }}{% else %} eine LAN-Buchse des
   Geräts (nicht WAN oder Internet){% endif %}.
   {%- if w.rechner_ip %}
   Stell deinen Rechner auf die feste Adresse `{{ w.rechner_ip }}` mit der
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).
   {%- else %}
   Der Rechner holt sich seine Adresse automatisch, so wie er normalerweise
   eingestellt ist.
   {%- endif %}

{% set adresse -%}
{%- if w.stock_url -%}
{%- for u in w.stock_url.split(" oder ") %}`{{ u }}`{% if not loop.last %} oder {% endif %}{% endfor -%}
{%- else -%}
die Adresse der Oberfläche (sie steht meist auf dem Aufkleber unter dem Gerät)
{%- endif -%}
{%- endset %}
3. **Oberfläche öffnen.**
   {%- if w.tls_alt %} Diese Oberfläche nutzt noch eine alte Verschlüsselung
   (TLS 1.0). Aktuelle Browser lehnen sie ab, und **nur Firefox** lässt sich
   so umstellen, dass er sie für die Installation doch annimmt. Mit Chrome,
   Edge oder Safari geht es nicht. Stell Firefox deshalb zuerst um:

   1. In die Adresszeile `about:config` eingeben, Enter. Die Warnung mit
      "Risiko akzeptieren und fortfahren" bestätigen.
   2. Oben im Suchfeld `security.tls.version.min` eingeben.
   3. Auf den Stift rechts klicken, den Wert `3` durch `1` ersetzen und mit
      dem Haken rechts speichern.

   **Nach der Installation zurückstellen:** genauso, Wert wieder auf `3`.
   Sonst bleibt dein Firefox auch bei anderen Seiten unnötig unsicher.

   Öffne dann in Firefox {{ adresse }}.
   {%- else %} Öffne im Browser {{ adresse }}.
   {%- endif %}
   {%- if w.zertifikat %}
   Der Browser warnt vor dem Zertifikat. Das ist hier normal: auf
   "Erweitert" und dann auf "Weiter" bzw. "Risiko akzeptieren" klicken.
   {%- endif %}
   {%- if w.zugang %}
   Melde dich an: {{ w.zugang }}.{% else %}
   Melde dich mit den Zugangsdaten vom Aufkleber an, oder leg beim ersten
   Aufruf ein Passwort fest.{% endif %}

4. **Firmware-Update aufrufen.**
   {%- if w.menue %} Geh zu **{{ w.menue }}**.
   {%- else %} Such den Menüpunkt für das Firmware-Update. Er heißt je nach
   Hersteller etwa "Firmware Upgrade", "Firmware-Update" oder "Firmware
   aktualisieren" und liegt oft unter "System", "System Tools" oder
   "Verwaltung".
   {%- endif %}
   {%- if b.get("stock-firmware-seite") %}

   ![Die Firmware-Seite der Herstelleroberfläche]({{ b["stock-firmware-seite"] }})
   {%- endif %}

5. **Hochladen.** Wähl das {{ art }}-Image aus, starte das Update und
   bestätige die Rückfragen.
   {%- if w.einstellungen_abwaehlen %} Bietet die Seite an, die Einstellungen
   zu behalten ("Keep settings"), **entfern diesen Haken**.{% endif %}
   {%- if w.nach_upload %} Danach zeigt der Browser {{ w.nach_upload }}. Das
   ist normal.{% endif %}

6. **Warten.** Das Gerät schreibt die Firmware und startet neu. Das dauert
   {% if w.dauer %}{{ w.dauer }}{% else %}einige Minuten{% endif %}.
   **Nicht ausschalten, Strom nicht ziehen und die Seite nicht neu laden.**
   Manche Geräte löschen zuerst den ganzen Speicher; ein Abbruch in dieser
   Zeit kann sie unbrauchbar machen.

7. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).
   {%- if w.rechner_ip %} Stell den Rechner vorher wieder auf "automatisch".{% endif %}
   Wie es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- Das Gerät startet nach einigen Minuten von selbst neu.
- Die Herstelleroberfläche ist weg. Stattdessen meldet sich die
  Freifunk-Firmware, oft zuerst mit der Einrichtungsseite unter
  `http://192.168.1.1`.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Häufige Gründe: Das Image ist für
  eine andere Hardware-Version oder Region (Aufkleber prüfen)
  {%- if art == "factory" %}, es ist das sysupgrade- statt des factory-Images{% endif %}, der Dateiname
  ist zu lang (kurz umbenennen, z. B. in `factory.bin`), oder die
  Herstellerfirmware ist zu neu und sperrt fremde Firmware (siehe "Vorher
  prüfen", falls vorhanden).
- **Nach dem Neustart ist unter `http://192.168.1.1` nichts.** Stell den
  Rechner auf "automatisch" und zieh das Kabel kurz ab und wieder an
  ([Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md)).
  Je nach Community startet die Firmware auch gleich im Betrieb ohne
  Einrichtungsseite.
{{ zusatz.fehler }}
{%- if w.tftp_datei %}

## Notfall: Firmware per TFTP

Startet das Gerät nicht mehr richtig, etwa nach einem abgebrochenen Update
oder weil es in einer Startschleife hängt, kann es sich eine Firmware selbst
von deinem Rechner holen. Dafür brauchst du einen
TFTP-Server ([TFTP-Server einrichten](grundlagen/tftp-server.md)) und eine
feste Adresse am Rechner ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

1. Leg {{ w.tftp_inhalt }} unter dem Namen `{{ w.tftp_datei }}` in den
   Ordner des TFTP-Servers. Genau dieser Name, Groß- und Kleinschreibung
   zählt.
2. Stell deinen Rechner fest auf `{{ w.tftp_server_ip }}`, Netzmaske
   `255.255.255.0`, und starte den TFTP-Server.
   {%- if w.tftp_hinweis %}
   {{ w.tftp_hinweis }}
   {%- endif %}
3. Kabel an eine LAN-Buchse, Strom aus. Drück die Reset-Taste, halte sie
   gedrückt und schalte den Strom ein. Halte sie gedrückt:
   {% if w.tftp_taste %}{{ w.tftp_taste }}{% else %}bis der TFTP-Server
   zeigt, dass die Datei abgeholt wird{% endif %}.
4. Warten{% if w.tftp_dauer %}, {{ w.tftp_dauer }}{% endif %}. Das Gerät
   schreibt die Datei und startet neu.
{%- elif w.notweg_keiner %}

## Notfall

{{ w.notweg_keiner }}
{%- endif %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
