---
thema: browser-not-found
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# Der Browser zeigt "Not Found"

Du öffnest `http://192.168.1.1`, aber statt der erwarteten Seite kommt
"Not Found" oder "PAGE NOT FOUND". In der Adresszeile steht dann meist etwas
mit `cgi-bin/luci`.

Das passiert, wenn du im selben Browser vorher schon eine
OpenWrt-Oberfläche unter dieser Adresse offen hattest, zum Beispiel eine
Zwischenfirmware. Der Browser merkt sich die alte Seite und springt von
selbst dorthin, obwohl auf dem Router jetzt etwas anderes läuft. Am Router
liegt es nicht.

## Was hilft

Neu laden, Strg+F5 und ein privates Fenster helfen meist **nicht**. Diese
Wege gehen:

- **Gluon-RAMpe und Einrichtungsseite der Freifunk-Firmware:** Tipp die
  Adresse vollständig ein, mit `/cgi-bin/config` am Ende:
  `http://192.168.1.1/cgi-bin/config`.
- **Notfall-Seite im Bootloader:** Versuch `http://192.168.1.1/index.html`.
  Beim TOTOLINK X5000R hat das geklappt.
- **Immer:** Nimm einen anderen Browser, zum Beispiel Edge unter Windows
  oder Safari am Mac, wenn du sonst Firefox oder Chrome benutzt. Wer nur
  Firefox hat: Unter `about:profiles` lässt sich ein neues, leeres Profil
  anlegen und starten. Damit ist der Browser wieder frisch.
