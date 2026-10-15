#!/usr/bin/env python3
#
# erstinstallation.py - erzeugt die Datenteile von docs/ERSTINSTALLATION-2025.1.md
# und die Rezept-Tabelle in docs/GERAETE.md aus data/geraete-2025.1.json.
#
#   scripts/erstinstallation.py          Markdown neu schreiben
#   scripts/erstinstallation.py --check  nur pruefen, ob es aktuell ist (Exit 1, wenn nicht)
#
# Gepflegt wird nur die JSON-Datei. Im Markdown ersetzt das Skript den Text
# zwischen den Markierungen <!-- BEGIN erzeugt:NAME --> und
# <!-- END erzeugt:NAME -->; alles andere (Einleitung, Kategorien, Befunde,
# Anhang) bleibt Handarbeit.
#
# SPDX-License-Identifier: BSD-3-Clause

import json
import re
import sys
from collections import Counter, OrderedDict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATEN = ROOT / "data" / "geraete-2025.1.json"
DOKU = ROOT / "docs" / "ERSTINSTALLATION-2025.1.md"
GERAETE = ROOT / "docs" / "GERAETE.md"

# Feld -> Beschriftung, in der Reihenfolge der Einzelheiten
FELDER = OrderedDict([
    ("gluon_name", "Gluon-Name"),
    ("modell", "Modell"),
    ("anzeige", "Anzeigename (überschreibt den bereinigten Modellnamen)"),
    ("target", "Target"),
    ("gluon_broken", "Gluon führt es als broken"),
    ("kat", "Kat."),
    ("familie", "Anleitungsfamilie"),
    ("weg", "Weg ab Werk"),
    ("schritte", "Schritte (Normalweg)"),
    ("warnung", "Warnung"),
    ("taste", "Taste und Zeitpunkt"),
    ("zeichen", "Sichtbare Zeichen"),
    ("uebertragung", "Übertragung"),
    ("anschluss", "Anschluss"),
    ("adressen", "Adressen"),
    ("programm", "Programm"),
    ("zugang", "Zugang"),
    ("datei", "Datei"),
    ("seriell", "seriell nötig"),
    ("gehaeuse", "Gehäuse öffnen"),
    ("werkzeug", "Werkzeug/Spezial"),
    ("verwechslung", "Typenschild/Verwechslung"),
    ("stock_bedingung", "Bedingung an die Herstellerfirmware"),
    ("initramfs", "initramfs-Link"),
    ("factory", "Factory-/Stock-Image-Link"),
    ("stock_teile", "Stock-Teile"),
    ("ram", "RAM"),
    ("dauer", "Dauer"),
    ("fehlerbild", "Fehlerbild"),
    ("notweg", "Notweg"),
    ("rueckweg", "Rückweg zur Herstellerfirmware"),
    ("hw_test", "Hardware-Test"),
    ("rampe", "Gluon-RAMpe passt"),
    ("rampe_rezept", "Gluon-RAMpe-Rezept"),
    ("quelle", "Quelle (OpenWrt-Commit)"),
    ("anleitung", "Detail-Anleitung"),
    ("erprobt", "Am Gerät erprobt (für die Anleitung)"),
    ("werte", "Werte für die Anleitung"),
])
# In den Einzelheiten nicht wiederholt (stehen in der Kopfzeile des Geraets)
KOPF = {"gluon_name", "modell", "target", "kat", "familie"}
KATEGORIEN = ["K0", "K0+", "K1", "K1d", "K2", "K3", "K4", "K5", "offen"]


def kurz(text):
    """Erstes Wort eines Feldes: 'nein (Notweg ...)' -> 'nein'."""
    m = re.match(r"[^\s;:,(/\[]+", text)
    return m.group(0) if m else text


def zelle(text):
    return text.replace("|", "\\|").replace("\n", " ")


def rampe_wort(g):
    w = kurz(g["rampe"]).lower()
    return {"nicht": "nein"}.get(w, w)


def rezept_wort(g):
    r = g["rampe_rezept"]
    if r.startswith("devices/"):
        return "ja"
    return "Alias" if r.startswith("Alias") else ""


def anleitung_zelle(a):
    """Verweis auf eine erzeugte Anleitung (anleitungen/...) als Link aus docs/."""
    teile = []
    for t in a.split("; "):
        teile.append(f"[Anleitung](../{t})" if t.startswith("anleitungen/") else zelle(t))
    return "; ".join(teile)


def uebersicht(geraete):
    z = ["Sortiert nach Target, dann Gluon-Name. Der Gluon-Name führt zu den "
         "Einzelheiten des Geräts.", "",
         "| Gluon-Name | Modell | Target | Kat. | Anleitungsfamilie | Übertragung "
         "| seriell nötig | Gehäuse öffnen | Gluon-RAMpe | RAMpe-Rezept | Detail-Anleitung |",
         "|---|---|---|---|---|---|---|---|---|---|---|"]
    for g in geraete:
        fam = f"[`{g['familie']}`](#familie-{g['familie']})" if g["familie"] else ""
        z.append("| " + " | ".join([
            f"[{g['gluon_name']}](#{g['gluon_name']})",
            zelle(g["modell"]), g["target"], g["kat"], fam,
            zelle(kurz(g["uebertragung"])), zelle(kurz(g["seriell"])),
            zelle(kurz(g["gehaeuse"])), rampe_wort(g), rezept_wort(g),
            anleitung_zelle(g["anleitung"]),
        ]) + " |")
    return z


def einzelheiten(geraete):
    familien = OrderedDict()
    for g in sorted(geraete, key=lambda g: (g["familie"] or "~", g["target"], g["gluon_name"])):
        familien.setdefault(g["familie"] or "", []).append(g)
    z = []
    for fam, liste in familien.items():
        if fam:
            z += [f"### Familie `{fam}`", ""]
        else:
            z += ["### Noch ohne Anleitungsfamilie", ""]
        z += [f"{len(liste)} Gerät(e).", ""]
        for g in liste:
            z += [f"#### {g['gluon_name']}", "",
                  f"{g['modell']} · {g['target']} · {g['kat']}", ""]
            for k, label in FELDER.items():
                if k in KOPF or not g[k]:
                    continue
                if isinstance(g[k], dict):
                    z.append(f"- **{label}:** " + "; ".join(
                        f"{a} = {b}" for a, b in g[k].items() if b not in ("", None)))
                elif isinstance(g[k], bool):
                    z.append(f"- **{label}:** ja")
                elif isinstance(g[k], list):
                    z.append(f"- **{label}:**")
                    z += [f"  {i}. {schritt}" for i, schritt in enumerate(g[k], 1)]
                else:
                    z.append(f"- **{label}:** {g[k]}")
            z.append("")
    return z


def zahlen(geraete):
    c = Counter(g["kat"] for g in geraete)
    z = ["| Kat. | Geräte |", "|---|---:|"]
    z += [f"| {k} | {c.get(k, 0)} |" for k in KATEGORIEN]
    z += [f"| **gesamt** | **{len(geraete)}** |", ""]
    r = Counter(rampe_wort(g) for g in geraete)
    ja = [g["gluon_name"] for g in geraete if rampe_wort(g) == "ja"]
    z += [f"Gluon-RAMpe passt: **ja {r['ja']}**, teilweise {r['teilweise']}, "
          f"nein/unnötig {len(geraete) - r['ja'] - r['teilweise']}.", "",
          "Gluon-RAMpe passt \"ja\": " + ", ".join(f"`{n}`" for n in ja) + "."]
    return z


def rezepte(geraete):
    z = ["| Gerät | Gluon-Name | Target | Kat. | Rezept und Stand |", "|---|---|---|---|---|"]
    for g in geraete:
        if g["rampe_rezept"]:
            z.append(f"| {zelle(g['modell'])} | `{g['gluon_name']}` | {g['target']} | {g['kat']} "
                     f"| {zelle(g['rampe_rezept'])} |")
    return z


def ersetze(text, name, zeilen, doku=DOKU):
    a, e = f"<!-- BEGIN erzeugt:{name} -->", f"<!-- END erzeugt:{name} -->"
    muster = re.compile(re.escape(a) + r".*?" + re.escape(e), re.S)
    if not muster.search(text):
        sys.exit(f"Markierung {a} fehlt in {doku}")
    hinweis = ("<!-- erzeugt von scripts/erstinstallation.py aus "
               "data/geraete-2025.1.json, nicht von Hand ändern -->")
    return muster.sub(lambda _: "\n".join([a, hinweis, ""] + zeilen + ["", e]), text)


def main():
    daten = json.loads(DATEN.read_text(encoding="utf-8"))
    geraete = daten["geraete"]
    for g in geraete:
        fehlt = set(FELDER) - set(g)
        if fehlt:
            sys.exit(f"{g.get('gluon_name')}: Felder fehlen: {sorted(fehlt)}")
        if set(g) - set(FELDER):
            sys.exit(f"{g['gluon_name']}: unbekannte Felder: {sorted(set(g) - set(FELDER))}")
        if not isinstance(g["schritte"], list):
            sys.exit(f"{g['gluon_name']}: schritte muss eine Liste sein")
        if not isinstance(g["gluon_broken"], bool):
            sys.exit(f"{g['gluon_name']}: gluon_broken muss true oder false sein")
        for k in ("werte", "erprobt"):
            if not isinstance(g[k], dict):
                sys.exit(f"{g['gluon_name']}: {k} muss ein Objekt sein")
    namen = Counter(g["gluon_name"] for g in geraete)
    doppelt = [n for n, k in namen.items() if k > 1]
    if doppelt:
        sys.exit(f"doppelte Gluon-Namen: {doppelt}")
    geraete.sort(key=lambda g: (g["target"], g["gluon_name"]))

    alt = DOKU.read_text(encoding="utf-8")
    neu = ersetze(alt, "zahlen", zahlen(geraete))
    neu = ersetze(neu, "uebersicht", uebersicht(geraete))
    neu = ersetze(neu, "einzelheiten", einzelheiten(geraete))
    galt = GERAETE.read_text(encoding="utf-8")
    gneu = ersetze(galt, "rezepte", rezepte(geraete), GERAETE)
    for pfad, a, n in ((DOKU, alt, neu), (GERAETE, galt, gneu)):
        if "--check" in sys.argv[1:]:
            if n != a:
                sys.exit(f"{pfad.name} ist nicht aktuell: scripts/erstinstallation.py laufen lassen")
        else:
            pfad.write_text(n, encoding="utf-8")


if __name__ == "__main__":
    main()
