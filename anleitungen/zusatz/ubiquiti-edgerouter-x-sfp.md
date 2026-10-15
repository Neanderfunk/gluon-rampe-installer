## Vorher prüfen

- Diese Anleitung ist für den **EdgeRouter X-SFP** (mit SFP-Anschluss). Für
  den [EdgeRouter X](ubiquiti-edgerouter-x.md) ohne SFP gibt es eigene
  Dateien.
- Das factory-Image aus Teil 1 gibt es nur für den EdgeRouter X. Laut
  OpenWrt-Wiki läuft es auch auf dem X-SFP; in Teil 1 läuft auf deinem
  Router also kurz das OpenWrt des Schwestergeräts. **Wichtig ist, dass du in
  Teil 2 die OpenWrt-Datei für den X-SFP nimmst** (mit `-sfp` im Namen),
  sonst passt danach die Freifunk-Firmware nicht.
- Bei manchen Communities trägt die Freifunk-Firmware für dieses Gerät einen
  Zusatz im Namen, bei Neanderfunk zum Beispiel
  `…-ubiquiti-edgerouter-x-sfp-ka-sysupgrade.bin`. Das `ka` steht für das
  neue Speicherlayout und ist hier genau richtig.
