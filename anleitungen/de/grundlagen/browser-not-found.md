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

Kommt gar keine Seite, und der Browser wartet nur, siehe
[Die Router-Seite antwortet nicht](router-antwortet-nicht.md).

## Was nicht hilft

Bei uns hat in einigen Fällen nichts von dem geholfen, was man sonst bei
einer veralteten Seite macht: weder mehrfaches Drücken von Strg+F5 noch der
Knopf "Neu laden", nicht einmal ein neues privates Fenster. Der Browser
landete immer wieder auf `cgi-bin/luci`. Verlier damit keine Zeit.

## Was hilft

- **Gluon-RAMpe und Einrichtungsseite der Freifunk-Firmware:** Tipp die
  Adresse vollständig ein, mit `/cgi-bin/config` am Ende:
  `http://192.168.1.1/cgi-bin/config`.
- **Notfall-Seite im Bootloader:** Versuch `http://192.168.1.1/index.html`.
  Beim TOTOLINK X5000R hat das geklappt.
- **Sonst: ein anderer Browser oder ein leeres Browserprofil.** Das ist
  wirklich so gemeint, bei uns hat am Ende nur das geholfen. Nimm einen
  Browser, mit dem du die Router-Seite vorher noch nicht geöffnet hattest,
  zum Beispiel Edge unter Windows oder Safari am Mac, wenn du sonst Firefox
  oder Chrome benutzt. Wer nur Firefox hat, legt ein neues, leeres Profil
  an: `about:profiles` in die Adresszeile eingeben, ein neues Profil
  anlegen und es starten. Ein privates Fenster ist dafür kein Ersatz.
