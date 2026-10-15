#!/usr/bin/env python3
#
# rampe-liste.py - schreibt SHA256SUMS und LISTE.md fuer das Veroeffentlichungs-
# verzeichnis der Gluon-RAMpe (Default out/images).
#
#   scripts/rampe-liste.py [verzeichnis]
#
# Das Verzeichnis enthaelt nur, was auf den Download-Server gehoert (Images,
# uboot-fritz*.bin, SHA256SUMS, LISTE.md) und wird "as is" gespiegelt. build.sh
# ruft das Skript am Ende jedes Laufs auf.
#
# SPDX-License-Identifier: BSD-3-Clause

import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATEN = ROOT / "data" / "geraete-2025.1.json"
EIGENE = {"SHA256SUMS", "LISTE.md"}
BILD = re.compile(r"^gluon-rampe-(\d{8})-(.+)$")


def art(rest):
    if rest.endswith("-recovery.bin"):
        return "D-Link-Recovery"
    if "-kernel1.bin" in rest or "-rootfs0.bin" in rest:
        return "Xiaomi kernel1/rootfs0 (dauerhaft)"
    if rest.endswith("-initramfs-factory.ubi"):
        return "UBI-Image für die Herstellerfirmware"
    if rest.endswith(".trx"):
        return "ASUS-Weboberfläche (initramfs.trx)"
    if re.search(r"-(web-ui-)?factory\.(bin|img|fit)$", rest):
        return "Hersteller-Format (dauerhaft)"
    return "initramfs (RAM-Start per TFTP, UART, Netboot oder Recovery)"


def sha256(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def main():
    ziel = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "out" / "images"
    geraete = json.loads(DATEN.read_text(encoding="utf-8"))["geraete"]
    # laengste Namen zuerst, damit aruba-ap-303h nicht als aruba-ap-303 gilt
    namen = sorted((g["gluon_name"] for g in geraete), key=len, reverse=True)
    modell = {g["gluon_name"]: g["modell"] for g in geraete}

    dateien = sorted(p for p in ziel.iterdir() if p.is_file() and p.name not in EIGENE)
    summen = {p.name: sha256(p) for p in dateien}
    (ziel / "SHA256SUMS").write_text("".join(f"{h}  {n}\n" for n, h in summen.items()))

    zeilen, stände = [], set()
    for p in dateien:
        m = BILD.match(p.name)
        if not m:
            continue
        stand, rest = m.groups()
        stände.add(stand)
        geraet = next((n for n in namen if rest.startswith(n + "-")), "")
        groesse = f"{p.stat().st_size:,}".replace(",", ".")
        zeilen.append(f"| {modell.get(geraet, geraet or '?')} | `{p.name}` | {art(rest)} | "
                      f"{groesse} | `{summen[p.name]}` |")
    kopf = ["# Gluon-RAMpe-Images", "",
            f"Stand: {', '.join(sorted(stände)) or '-'}. Gebaut mit "
            "[gluon-rampe-installer](https://github.com/Neanderfunk/gluon-rampe-installer). "
            "Am Gerät erprobt ist bisher nur der Ablauf am D-Link M60; alles andere ist ungetestet.",
            "", "| Gerät | Datei | Art | Größe (Byte) | SHA256 |", "|---|---|---|---:|---|"]
    fuss = []
    fritz = [p.name for p in dateien if p.name.startswith("uboot-fritz")]
    if fritz:
        fuss = ["", "Dazu für die AVM-ipq40xx-Geräte (eva_ramboot.py): "
                + ", ".join(f"`{n}`" for n in fritz) + "."]
    fuss += ["", "Prüfsummen aller Dateien: `SHA256SUMS`.", ""]
    (ziel / "LISTE.md").write_text("\n".join(kopf + zeilen + fuss), encoding="utf-8")
    print(f"{ziel}: {len(dateien)} Datei(en), LISTE.md und SHA256SUMS geschrieben")


if __name__ == "__main__":
    main()
