# Bauumgebung fuer die Gluon-RAMpe: Debian Bookworm mit den
# Abhaengigkeiten aus Gluons docs/user/getting_started.rst (Gluon 2025.1,
# OpenWrt 24.10 - samt clang/llvm fuer die BPF-Pakete).
#
# Bookworm (GCC 12) statt eines aktuellen Hosts: OpenWrt baut dort zuverlaessig,
# neuere GCC brechen in einigen Host-Werkzeugen ab.
#
#   docker build -t gluon-rampe-build contrib/docker
#   contrib/docker/run.sh ./build.sh <target> <geraet>

FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates file git \
    clang llvm \
    python3 python3-dev python3-pyelftools python3-setuptools python3-distutils \
    build-essential gawk unzip libncurses5-dev zlib1g-dev libssl-dev libelf-dev \
    wget rsync time qemu-utils ecdsautils swig lua5.1 libnss-unknown \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
