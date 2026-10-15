#!/usr/bin/env python3
#
# anleitungen.py - erzeugt die Installationsanleitung je Geraet aus
# data/geraete-2025.1.json und den Vorlagen der Anleitungsfamilien.
#
#   scripts/anleitungen.py                    Markdown je Geraet schreiben
#   scripts/anleitungen.py --html             dazu je Geraet eine HTML-Seite (markdown-it-py)
#   scripts/anleitungen.py --html             schreibt auch html/index.json fuer den
#                                             Selector (Basis-URL: Default unten)
#   scripts/anleitungen.py --check [--html]   nur pruefen, ob alles aktuell ist
#   scripts/anleitungen.py --verlinken        Feld "anleitung" im JSON auf die Seite setzen
#
# Quelle (--quelle, Default anleitungen/):
#   vorlagen/<familie>.md           Jinja2-Vorlage je Anleitungsfamilie (Content)
#   zusatz/<gluon_name>.md          optional: was nur ein Geraet braucht (Content)
#   <sprache>/grundlagen/<thema>.md von Hand: feste IP, curl, Konsole ... (Content)
# Ausgabe (--ausgabe, Default anleitungen/):
#   <sprache>/<gluon_name>.md       erzeugt, nicht von Hand aendern
#   html/<sprache>/<gluon_name>.html, html/<sprache>/grundlagen/<thema>.html,
#   html/<sprache>/index.html, html/anleitung.css, html/index.json
#
# Format und Regeln: anleitungen/README.md. Kurz:
# - Eine Seite entsteht fuer jedes Geraet, dessen Familie eine Vorlage hat und
#   dessen Block "werte" gefuellt ist. Die Vorlage bekommt die Felder des
#   Geraets, "werte", dazu status, erprobt_am, erprobt_mit,
#   erprobt_mit_aelter, zusatz.fehler, zusatz.vorher, zusatz.text, bilder
#   (Name -> relativer Pfad) und herkunft. bilder/ wird nach html/bilder kopiert.
# - StrictUndefined: ein fehlender Wert laesst die Erzeugung scheitern, statt
#   eine Luecke in den Text zu schreiben. Werte, die eine Vorlage in ihrem Kopf
#   unter "optional" fuehrt, sind leer vorbelegt.
# - status "erprobt" nur aus dem Feld "erprobt" (am, mit), nie aus Fliesstext.
# - Die HTML-Seiten laden nichts von fremden Hosts.
#
# SPDX-License-Identifier: BSD-3-Clause

import argparse
import html
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATEN = ROOT / "data" / "geraete-2025.1.json"
SPRACHE = "de"

sys.path.insert(0, str(Path(__file__).resolve().parent))
from erstinstallation import FELDER  # noqa: E402  (Feld -> Beschriftung)

# Kategorie -> Stufe fuer Lesende (Tabelle "Kategorien" in ERSTINSTALLATION)
STUFE = {"K0": "einfach", "K0+": "mit Werkzeug", "K1": "mit Werkzeug",
         "K1d": "mit Werkzeug", "K2": "fortgeschritten", "K3": "Werkstatt",
         "K4": "Werkstatt", "K5": "Werkstatt", "offen": "Werkstatt"}

# Belegmarken: [geprueft: ...], [abgeleitet ...], [Wiki-Zusammenfassung: ...] ...
MARKE = re.compile(r"\[([^\[\]]*(?:geprüft|abgeleitet|Zusammenfassung|ungeprüft|Forum:|Neanderfunk-Notiz:|Wiki-Rohtext:)[^\[\]]*)\]")


def git_stand(repo, pfad):
    """Kurzer Commit, der pfad zuletzt geaendert hat; 'lokal' bei Aenderungen."""
    try:
        if subprocess.run(["git", "-C", str(repo), "diff", "--quiet", "HEAD", "--", str(pfad)],
                          capture_output=True).returncode != 0:
            return "lokal"
        r = subprocess.run(["git", "-C", str(repo), "log", "-1", "--format=%h", "--", str(pfad)],
                           capture_output=True, text=True)
        return r.stdout.strip() or "lokal"
    except OSError:
        return "lokal"


def optionale_werte(vorlage_text):
    """Namen der optionalen Werte aus dem Kopfkommentar der Vorlage. Pflicht
    sind die Werte unter einer Abschnittsueberschrift "Pflicht ..." oder
    "bei ..." (bedingt Pflicht, z. B. "bei datei_art = rampe"); alle anderen
    aufgefuehrten Werte gelten als optional und werden leer vorbelegt."""
    kopf = re.match(r"\{#-?(.*?)-?#\}", vorlage_text, re.S)
    if not kopf:
        return []
    namen, drin = [], False
    for zeile in kopf.group(1).splitlines():
        if re.match(r"^\s{2}\S", zeile):          # Abschnittsueberschrift (2 Leerzeichen)
            ueber = zeile.strip()
            drin = not ueber.startswith(("Pflicht", "bei "))
            continue
        m = re.match(r"^\s{4}([a-z_]+)\s", zeile)
        if drin and m:
            namen.append(m.group(1))
    return namen


def herkunft(g):
    """Belegmarken aller Felder, nach Marke gruppiert, als Markdown-Liste."""
    marken = {}
    for k, label in FELDER.items():
        v = g.get(k)
        texte = v if isinstance(v, list) else [v] if isinstance(v, str) else []
        for t in texte:
            for m in MARKE.findall(t):
                marken.setdefault(m.strip(), [])
                if label not in marken[m.strip()]:
                    marken[m.strip()].append(label)
    if not marken and not g.get("quelle"):
        return "Für dieses Gerät sind noch keine Quellen eingetragen."
    zeilen = ["Die Angaben stammen aus diesen Quellen (in Klammern, wofür):", ""]
    for m in sorted(marken):
        zeilen.append(f"- {m} ({', '.join(marken[m])})")
    if g.get("quelle"):
        zeilen.append(f"- Geräteeintrag: {g['quelle']}")
    return "\n".join(zeilen)


def zusatz(quelle, name):
    """zusatz/<name>.md aufteilen: Abschnitt '## Wenn etwas schiefgeht' -> fehler,
    '## Vorher prüfen' -> vorher (jeweils ohne Ueberschrift), alles andere -> text."""
    leer = {"fehler": "", "vorher": "", "text": ""}
    p = quelle / "zusatz" / f"{name}.md"
    if not p.exists():
        return leer
    teile, teil = {k: [] for k in leer}, "text"
    eigene = {"## Wenn etwas schiefgeht": "fehler", "## Vorher prüfen": "vorher"}
    for zeile in p.read_text(encoding="utf-8").splitlines():
        if zeile.startswith("## "):
            teil = eigene.get(zeile.strip(), "text")
            if teil != "text":
                continue
        teile[teil].append(zeile)
    return {k: "\n".join(v).strip() for k, v in teile.items()}


def bilder(quelle, name):
    """Name -> Pfad relativ zur erzeugten Seite (de/<g>.md und html/de/<g>.html
    liegen gleich tief): erst bilder/<gluon_name>/, dann bilder/allgemein/."""
    b = {}
    for ordner in ("allgemein", name):          # geraeteeigene ueberschreiben
        for p in sorted((quelle / "bilder" / ordner).glob("*.png")):
            b[p.stem] = f"../bilder/{ordner}/{p.name}"
    return b


def datum8(text):
    m = re.search(r"(20\d{6})", text or "")
    return m.group(1) if m else ""


def kopf_yaml(k):
    zeilen = ["---"]
    for a, b in k.items():
        if isinstance(b, list):
            b = "[" + ", ".join(b) + "]"
        zeilen.append(f"{a}: {b}")
    zeilen.append("---")
    return "\n".join(zeilen)


def seiten_erzeugen(geraete, quelle, jinja2):
    """Liefert {gluon_name: (kopf, markdown_body)} fuer alle Geraete mit Vorlage und Werten."""
    env = jinja2.Environment(undefined=jinja2.StrictUndefined, keep_trailing_newline=True,
                             autoescape=False)
    daten_stand = git_stand(ROOT, DATEN)
    seiten, ohne = {}, []
    for g in geraete:
        vp = quelle / "vorlagen" / f"{g['familie']}.md"
        if not vp.exists() or not g["werte"]:
            ohne.append(g["gluon_name"])
            continue
        vtext = vp.read_text(encoding="utf-8")
        werte = {n: "" for n in optionale_werte(vtext)}
        werte.update(g["werte"])
        erprobt = g["erprobt"]
        status = "erprobt" if erprobt.get("am") else "ungeprüft"
        aktuell = datum8(werte.get("datei_beispiel", ""))
        ctx = dict(g)
        am = erprobt.get("am", "")
        am_de = ".".join(reversed(am.split("-"))) if re.fullmatch(r"\d{4}-\d\d-\d\d", am) else am
        ctx.update(werte=werte, status=status, erprobt_am=am_de,
                   erprobt_mit=erprobt.get("mit", ""),
                   erprobt_mit_aelter=bool(status == "erprobt" and aktuell
                                           and datum8(erprobt.get("mit")) < aktuell),
                   zusatz=zusatz(quelle, g["gluon_name"]), bilder=bilder(quelle, g["gluon_name"]),
                   herkunft=herkunft(g))
        try:
            body = env.from_string(vtext).render(**ctx)
        except jinja2.UndefinedError as e:
            sys.exit(f"{g['gluon_name']} (Vorlage {g['familie']}): {e}")
        body = re.sub(r"\n{3,}", "\n\n", body).strip() + "\n"
        kopf = {"gluon_name": g["gluon_name"], "modell": g["modell"], "familie": g["familie"],
                "sprache": SPRACHE, "stufe": STUFE.get(g["kat"], "Werkstatt"), "status": status}
        if status == "erprobt":
            kopf.update(erprobt_am=erprobt["am"], erprobt_mit=erprobt.get("mit", ""))
        if werte.get("rampe_datei"):
            kopf["rampe_image"] = werte["rampe_datei"].replace("<Datum>", "*")
        kopf["grundlagen"] = sorted(set(re.findall(r"\(grundlagen/([\w-]+)\.md\)", body)))
        kopf["daten_stand"] = daten_stand
        kopf["vorlage_stand"] = git_stand(quelle, vp)
        seiten[g["gluon_name"]] = (kopf, body)
    return seiten, ohne


CSS = """:root{--grund:#fbfaf7;--text:#1f2328;--leise:#59636e;--akzent:#1f6f5c;--rand:#d8d4cc;--hinweis:#fff4d6;--code:#f1efe9}
@media (prefers-color-scheme:dark){:root{--grund:#16181a;--text:#e6e3dd;--leise:#a3a09a;--akzent:#7cc4ae;--rand:#3a3d40;--hinweis:#3a3220;--code:#23262a}}
html{background:var(--grund);color:var(--text)}
body{font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;line-height:1.55;max-width:44rem;margin:0 auto;padding:1.5rem 1rem 4rem}
h1{font-size:1.6rem;line-height:1.25;text-wrap:balance}h2{font-size:1.2rem;margin-top:2rem;border-bottom:1px solid var(--rand);padding-bottom:.2rem}
a{color:var(--akzent)}code,pre{font-family:ui-monospace,Consolas,monospace;font-size:.92em;background:var(--code)}
code{padding:.05em .3em;border-radius:3px}pre{padding:.7rem .8rem;overflow-x:auto;border-radius:4px;white-space:pre-wrap;overflow-wrap:anywhere}pre code{padding:0;background:none}
blockquote{margin:1rem 0;padding:.6rem .9rem;background:var(--hinweis);border-left:4px solid #c9962b}
blockquote p{margin:.2rem 0}ol>li{margin:.5rem 0}.fuss{margin-top:3rem;color:var(--leise);font-size:.85rem}
table{border-collapse:collapse}td,th{border:1px solid var(--rand);padding:.25rem .5rem;text-align:left}
"""


def html_seite(titel, body_md, meta, md, tiefe):
    """tiefe: Verzeichnisebenen unter html/ (fuer den Pfad zu anleitung.css)."""
    inhalt = md.render(body_md)
    inhalt = re.sub(r'href="([^":]+)\.md(#[^"]*)?"', r'href="\1.html\2"', inhalt)
    metas = "\n".join(f'<meta name="anleitung:{html.escape(k)}" content="{html.escape(", ".join(v) if isinstance(v, list) else str(v))}">'
                      for k, v in meta.items())
    css = "../" * tiefe + "anleitung.css"
    return (f'<!DOCTYPE html>\n<html lang="{SPRACHE}">\n<head>\n<meta charset="utf-8">\n'
            f'<meta name="viewport" content="width=device-width, initial-scale=1">\n'
            f"<title>{html.escape(titel)}</title>\n{metas}\n"
            f'<link rel="stylesheet" href="{css}">\n</head>\n<body>\n{inhalt}\n'
            f'<p class="fuss">Freifunk-Installationsanleitung, erzeugt aus '
            f'<a href="https://github.com/Neanderfunk/gluon-rampe-installer">gluon-rampe-installer</a>.</p>\n'
            f"</body>\n</html>\n")


def main():
    ap = argparse.ArgumentParser(description="Installationsanleitungen je Gerät erzeugen")
    ap.add_argument("--quelle", type=Path, default=ROOT / "anleitungen")
    ap.add_argument("--ausgabe", type=Path, default=ROOT / "anleitungen")
    ap.add_argument("--html", action="store_true")
    # Festgelegt von Supernode-Betrieb (15.10.2026): Der Downloader liefert
    # anleitungen/html/ per Symlink unter dieser Adresse aus.
    ap.add_argument("--basis-url", default="https://routersoftware.ffnef.de/anleitungen",
                    help="absolute Adresse, unter der html/ liegt (leer: keine index.json)")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--verlinken", action="store_true",
                    help="Feld anleitung im JSON auf die erzeugte Seite setzen")
    a = ap.parse_args()
    try:
        import jinja2
    except ImportError:
        sys.exit("python3-jinja2 fehlt")
    md = None
    if a.html:
        # CommonMark (markdown-it-py): Code-Bloecke und Absaetze innerhalb
        # nummerierter Schritte, wie sie die Vorlagen nutzen. python3-markdown
        # erkennt dort keine Code-Bloecke.
        try:
            from markdown_it import MarkdownIt
        except ImportError:
            sys.exit("python3-markdown-it fehlt (für --html)")
        md = MarkdownIt("commonmark", {"html": False}).enable("table")

    geraete = json.loads(DATEN.read_text(encoding="utf-8"))["geraete"]
    geraete.sort(key=lambda g: g["gluon_name"])
    seiten, ohne = seiten_erzeugen(geraete, a.quelle, jinja2)

    dateien = {}
    for name, (kopf, body) in seiten.items():
        dateien[a.ausgabe / SPRACHE / f"{name}.md"] = kopf_yaml(kopf) + "\n\n" + body
    if a.html:
        h = a.ausgabe / "html"
        dateien[h / "anleitung.css"] = CSS
        for name, (kopf, body) in seiten.items():
            dateien[h / SPRACHE / f"{name}.html"] = html_seite(
                f"{kopf['modell']}: Freifunk-Firmware installieren", body, kopf, md, 1)
        for p in sorted((a.quelle / SPRACHE / "grundlagen").glob("*.md")):
            t = p.read_text(encoding="utf-8")
            titel = (re.search(r"^# (.+)$", t, re.M) or [None, p.stem])[1]
            dateien[h / SPRACHE / "grundlagen" / f"{p.stem}.html"] = html_seite(
                titel, t, {"grundlage": p.stem}, md, 2)
        for p in sorted((a.quelle / "bilder").rglob("*")):
            if p.is_file():
                dateien[h / "bilder" / p.relative_to(a.quelle / "bilder")] = p.read_bytes()
        liste = ["# Freifunk-Firmware installieren", "",
                 "Anleitungen je Gerät. Ungeprüfte Anleitungen sind aus Quellen "
                 "zusammengestellt und noch nicht am Gerät nachvollzogen.", ""]
        liste += [f"- [{k['modell']}]({n}.md): {k['status']}, {k['stufe']}"
                  for n, (k, _) in seiten.items()]
        dateien[h / SPRACHE / "index.html"] = html_seite(
            "Freifunk-Firmware installieren", "\n".join(liste) + "\n", {"uebersicht": SPRACHE}, md, 1)
        if a.basis_url:
            basis = a.basis_url.rstrip("/")
            idx = [{"gluon_name": n, "url": f"{basis}/{SPRACHE}/{n}.html", "status": k["status"],
                    "stufe": k["stufe"], "sprache": SPRACHE} for n, (k, _) in seiten.items()]
            dateien[h / "index.json"] = json.dumps(idx, ensure_ascii=False, indent=1) + "\n"

    if a.verlinken and not a.check:
        roh = json.loads(DATEN.read_text(encoding="utf-8"))
        n = 0
        for g in roh["geraete"]:
            ziel = f"anleitungen/{SPRACHE}/{g['gluon_name']}.md"
            if g["gluon_name"] not in seiten or g["anleitung"].startswith(ziel):
                continue
            # vorhandene Verweise (fremde Anleitungen, Wiki, Commit) bleiben dahinter
            g["anleitung"] = ziel if g["anleitung"] in ("", "-") else f"{ziel}; {g['anleitung']}"
            n += 1
        if n:
            DATEN.write_text(json.dumps(roh, ensure_ascii=False, indent=1), encoding="utf-8")
            print(f"{n} Link(s) im Feld anleitung gesetzt; danach erstinstallation.py laufen lassen.")

    def inhalt(t):
        return t if isinstance(t, bytes) else t.encode("utf-8")

    veraltet = [p for p, t in dateien.items()
                if not p.exists() or p.read_bytes() != inhalt(t)]
    if a.check:
        if veraltet:
            sys.exit(f"{len(veraltet)} Datei(en) nicht aktuell, z. B. {veraltet[0]}: "
                     "scripts/anleitungen.py laufen lassen")
        return
    for p in veraltet:
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(inhalt(dateien[p]))
    print(f"{len(seiten)} Anleitung(en) erzeugt, {len(veraltet)} Datei(en) geschrieben; "
          f"{len(ohne)} Geräte noch ohne Vorlage oder Werte.")


if __name__ == "__main__":
    main()
