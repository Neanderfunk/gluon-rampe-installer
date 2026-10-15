## Vorher prüfen

Der NWA50AX ist ein anderes Gerät als der [NWA50AX Pro](zyxel-nwa50ax-pro.md), mit eigenem Image.

**Zwei Firmware-Speicher:** Diese Geräte haben zwei Plätze für die Firmware.
Die Freifunk-Firmware läuft nur vom ersten. Damit die Zyxel-Oberfläche sie
dorthin schreibt, muss vorher der zweite aktiv sein. Startet die
Freifunk-Firmware nur einmal und danach wieder die Zyxel-Firmware, war das
nicht so: dann zuerst ein beliebiges Zyxel-Update einspielen und noch einmal
von vorn.

**Gebrauchte Geräte und die Zyxel-Cloud (Nebula):** War das Gerät beim
Vorbesitz in der Zyxel-Cloud "Nebula" angemeldet, holt es sich nach einem
Werksreset innerhalb von etwa 30 Minuten wieder die Cloud-Einstellungen, und
die Oberfläche verlangt das Nebula-Passwort ("This device is managed by
Nebula"). Herauslösen lässt es sich, indem man es mit einem anderen
Nebula-Konto übernimmt (force adopt, QR-Code in der Nebula-App) und dort
wieder abmeldet. Das haben wir nicht selbst ausprobiert. In einem Forumsfall
half stattdessen: Werksreset und sofort die Nebula-Erkennung mit dem
Zyxel-Werkzeug ZON abschalten.

## Wenn etwas schiefgeht

- **"ULCGI unable to parse CGI query".** Der Dateiname ist zu lang. Benenne
  die Datei kurz um, zum Beispiel in `factory.bin`.
