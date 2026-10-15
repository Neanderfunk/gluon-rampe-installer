---
thema: browser-https
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf. Das
> Verhalten der RAMpe ist bisher nur in einer Testumgebung geprüft.

# Der Browser macht https daraus

Router-Seiten während der Installation laufen meist über `http://`, ohne
Verschlüsselung. Neuere Browser setzen bei einer eingetippten Adresse wie
`192.168.1.1` aber gern von sich aus `https://` davor. Dann kommt statt der
Seite eine Fehlermeldung oder eine Warnung.

## Bei der Gluon-RAMpe

Die RAMpe antwortet auch auf `https://` und schickt den Browser weiter auf
die `http://`-Seite. Weil sie dafür nur ein selbst ausgestelltes Zertifikat
hat, warnt der Browser vorher:

- **Chrome, Edge:** "Dies ist keine sichere Verbindung". Auf "Erweitert",
  dann auf "Weiter zu 192.168.1.1 (unsicher)".
- **Firefox:** "Warnung: Mögliches Sicherheitsrisiko erkannt". Auf
  "Erweitert…", dann auf "Risiko akzeptieren und fortfahren".

Danach erscheint die Seite der RAMpe. Das ist hier unbedenklich: Die
Verbindung geht nur über das Kabel zwischen deinem Rechner und dem Router.

## Wenn es gar nicht geht

Tipp die Adresse vollständig mit `http://` ein, also `http://192.168.1.1`,
oder öffne ein privates Fenster. Bei Seiten ohne https-Weiterleitung (zum
Beispiel manchen Recovery-Seiten) hilft nur das.
