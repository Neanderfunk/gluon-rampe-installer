#!/bin/bash
#
# run.sh - fuehrt einen Befehl in der Bauumgebung aus, im Projektverzeichnis.
#
#   contrib/docker/run.sh ./build.sh mediatek-filogic d-link-aquila-pro-ai-m30-a1
#
# Das Projekt wird unter DEMSELBEN absoluten Pfad eingehaengt wie auf dem Host:
# OpenWrt legt absolute Pfade in seine Stempeldateien, ein Baum unter anderem
# Pfad wuerde von vorn gebaut. Das Bild wird beim ersten Aufruf gebaut.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE="${IMAGE:-gluon-rampe-build}"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
	docker build -t "$IMAGE" "$ROOT/contrib/docker"
fi

exec docker run --rm -i \
	-u "$(id -u):$(id -g)" \
	--network=host \
	-v "$ROOT:$ROOT" \
	-w "$ROOT" \
	-e HOME=/tmp \
	${GLUON_REF:+-e GLUON_REF="$GLUON_REF"} \
	${JOBS:+-e JOBS="$JOBS"} \
	${RAMPE_HW_PATCHES:+-e RAMPE_HW_PATCHES="$RAMPE_HW_PATCHES" -v "$RAMPE_HW_PATCHES:$RAMPE_HW_PATCHES:ro"} \
	"$IMAGE" "$@"
