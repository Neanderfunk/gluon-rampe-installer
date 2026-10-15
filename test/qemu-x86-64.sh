#!/bin/bash
#
# qemu-x86-64.sh - Ende-zu-Ende-Test des Installers in QEMU (x86-64).
#
#   test/qemu-x86-64.sh <installer-initramfs-kernel.bin> <gluon-factory.img.gz> <gluon-sysupgrade.img.gz>
#
# Die Platte der VM ist das factory-Image einer beliebigen Gluon-Firmware (nur
# damit es ein Ziel mit Partitionstabelle gibt), hochgeladen wird das
# sysupgrade-Image einer ANDEREN Firmware. Stufen:
#   1. Installer per -kernel starten; Startseite = Upload-Seite?
#   2. sysupgrade hochladen und bestaetigen; sysupgrade -n laeuft?
#   3. von der Platte starten; laeuft jetzt die hochgeladene Firmware (Config-Mode)?
#
# Kniffe: "/" leitet per meta-refresh weiter - Einstieg ist /cgi-bin/config.
# gluon-web verlangt bei POST einen Origin-Header, der zum Host passt.
# Seit 15.10.2026 auch: gluon.css?v= und die Umleitung https (Port 443) -> http.
# Braucht qemu-system-x86_64 (mit KVM deutlich schneller), curl, sfdisk, openssl.

set -u
KERNEL=${1:?installer-initramfs-kernel.bin}; FACTORY=${2:?factory.img.gz}; UPLOAD=${3:?sysupgrade.img.gz}
WORK="$(cd "$(dirname "$0")" && pwd)/work"; mkdir -p "$WORK"; cd "$WORK"
PORT=${PORT:-18080}
TLSPORT=${TLSPORT:-18443}
NET="-netdev user,id=n0,net=192.168.1.0/24,host=192.168.1.2,dhcpstart=192.168.1.100,hostfwd=tcp:127.0.0.1:$PORT-192.168.1.1:80,hostfwd=tcp:127.0.0.1:$TLSPORT-192.168.1.1:443 -device e1000,netdev=n0"
KVM=$([ -w /dev/kvm ] && echo -enable-kvm)
URL="http://127.0.0.1:$PORT"

gunzip -c "$FACTORY" > disk.img 2>/dev/null
PARTUUID=$(sfdisk --part-uuid disk.img 2 2>/dev/null | tr 'A-Z' 'a-z')
[ -n "$PARTUUID" ] || { echo "PARTUUID der Root-Partition nicht lesbar"; exit 1; }

warte () { local i; for i in $(seq 1 "$1"); do curl -s -m 3 -o /dev/null "$URL/" && return 0; sleep 1; done; return 1; }
ende () { kill "$QPID" 2>/dev/null; wait "$QPID" 2>/dev/null; }

echo "== 1. Installer starten"
qemu-system-x86_64 $KVM -m 512 -display none -serial file:konsole-installer.log \
	-kernel "$KERNEL" -append "root=PARTUUID=$PARTUUID console=ttyS0,115200n8" \
	-drive file=disk.img,format=raw,if=ide $NET &
QPID=$!
warte 180 || { echo "FEHLER: Installer antwortet nicht"; ende; tail -20 konsole-installer.log; exit 1; }
curl -s -L "$URL/cgi-bin/config" -o seite1.html -w '   Startseite: %{url_effective}\n'
ACTION=$(grep -o 'action="[^"]*"' seite1.html | head -1 | sed 's/action="//; s/"$//')
grep -q 'name="image"' seite1.html && ! grep -q keepcfg seite1.html && echo "   Upload-Seite ohne 'Einstellungen behalten': ja" \
	|| { echo "FEHLER: keine Installer-Upload-Seite"; ende; exit 1; }
grep -q 'gluon.css?v=' seite1.html && echo "   gluon.css mit Versionsanhang: ja" \
	|| { echo "FEHLER: gluon.css ohne ?v= (Cache-Schutz fehlt)"; ende; exit 1; }
# Port 443: selbstsigniertes Zertifikat, jede Adresse leitet auf http:// um
for pfad in / /irgendwas; do
	curl -sk "https://127.0.0.1:$TLSPORT$pfad" -o seite-https.html -w "   https $pfad: %{http_code}\n"
	grep -q "location.replace('http://'" seite-https.html \
		|| { echo "FEHLER: https $pfad leitet nicht auf http um"; ende; exit 1; }
done
echo | openssl s_client -connect "127.0.0.1:$TLSPORT" 2>/dev/null | openssl x509 -noout -subject 2>/dev/null | sed 's/^/   Zertifikat: /'

echo "== 2. hochladen und bestaetigen"
curl -s -H "Origin: $URL" -F step=2 -F "image=@$UPLOAD" "$URL$ACTION" -o seite2.html -w '   Upload: %{http_code}\n'
grep -qi 'not valid' seite2.html && { echo "FEHLER: Image abgelehnt"; ende; exit 1; }
curl -s -H "Origin: $URL" -F step=3 "$URL$ACTION" -o seite3.html -w '   Bestaetigung: %{http_code}\n'
for i in $(seq 1 240); do grep -qE 'Upgrade completed|reboot: Restarting' konsole-installer.log && break; sleep 1; done
grep -E 'Performing system upgrade|Upgrade completed' konsole-installer.log | sed 's/^/   /'
sleep 2; ende

echo "== 3. von der Platte starten"
qemu-system-x86_64 $KVM -m 512 -display none -serial file:konsole-platte.log \
	-drive file=disk.img,format=raw,if=ide $NET &
QPID=$!
warte 240 || { echo "FEHLER: hochgeladene Firmware antwortet nicht"; ende; tail -20 konsole-platte.log; exit 1; }
sleep 5
curl -s -L "$URL/cgi-bin/config" -o seite4.html -w '   Config-Mode: %{url_effective}\n'
grep -o '<title>[^<]*' seite4.html | sed 's/<title>/   Titel: /'
grep -q 'Gluon-RAMpe' seite4.html && { echo "FEHLER: immer noch der Installer"; ende; exit 1; }
ende
echo "== bestanden"
