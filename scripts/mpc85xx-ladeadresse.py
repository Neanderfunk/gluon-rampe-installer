#!/usr/bin/env python3
# mpc85xx-ladeadresse.py - prueft mpc85xx-Images (uImage oder FIT): Die
# Ladeadresse im Kopf muss gleich der Linkadresse des powerpc-simpleImage-
# Loaders sein. Sonst springt U-Boot an die falsche Stelle (OpenWrt #25302,
# AP3825i-initramfs bis RAMpe 20261114: Kopf 0x1500000, Loader 0x1600000).
#
#   python3 -I scripts/mpc85xx-ladeadresse.py out/images/gluon-rampe-*-<geraet>-*.bin
#
# Die Linkadresse steht im entpackten Loader als p_start (crt0.S: p_start,
# p_etext, p_bss_start, p_end hintereinander). Geraete ohne simpleImage
# (Ladeadresse 0 im Kopf, z. B. Ocedo Panda, Sophos RED 15w) entfallen.
# Exit-Code 1, wenn ein Image FALSCH oder unklar ist.
#
# SPDX-License-Identifier: BSD-3-Clause

import sys, struct, lzma, gzip
def fit_kernel(b):
    _, total, os_, ostr = struct.unpack('>IIII', b[:16]); st = b[ostr:]
    s = lambda o: st[o:st.index(b'\0', o)].decode()
    p = os_; path = []; nodes = {}
    while True:
        t, = struct.unpack('>I', b[p:p+4]); p += 4
        if t == 1:
            e = b.index(b'\0', p); path.append(b[p:e].decode()); p = (e + 4) & ~3; nodes['/'.join(path)] = {}
        elif t == 2: path.pop()
        elif t == 3:
            ln, no = struct.unpack('>II', b[p:p+8]); p += 8; nodes['/'.join(path)][s(no)] = b[p:p+ln]; p = (p + ln + 3) & ~3
        elif t == 9: break
    for n, pr in nodes.items():
        if pr.get('type', b'').rstrip(b'\0') == b'kernel':
            return struct.unpack('>I', pr['load'])[0], pr.get('compression', b'none').rstrip(b'\0').decode(), pr['data']
def uimage(b):
    load = struct.unpack('>I', b[16:20])[0]; comp = {0: 'none', 1: 'gzip', 3: 'lzma'}[b[31]]
    return load, comp, b[64:64 + struct.unpack('>I', b[12:16])[0]]
rc = 0
for f in sys.argv[1:]:
    b = open(f, 'rb').read()
    load, comp, data = fit_kernel(b) if b[:4] == b'\xd0\x0d\xfe\xed' else uimage(b)
    if load == 0:
        print('%-40s Kopf 0x00000000  kein simpleImage, entfaellt' % f.split('/')[-1])
        continue
    if comp == 'lzma': data = lzma.decompress(data, format=lzma.FORMAT_ALONE)
    elif comp == 'gzip': data = gzip.decompress(data)
    kand = set()
    for i in range(0, len(data) - 16, 4):
        a, e, c, d = struct.unpack('>IIII', data[i:i+16])
        if a and a % 0x10000 == 0 and a < e < c <= d and e - a < len(data) and d - a < 4 * len(data) and a < 0x10000000:
            kand.add(a)
    erg = 'OK' if kand == {load} else ('FALSCH' if kand else 'unklar')
    rc |= erg != 'OK'
    print('%-40s Kopf 0x%08x  Loader %s  %s (%s, %d Byte entpackt)' % (f.split('/')[-1], load, ','.join('0x%08x' % k for k in sorted(kand)) or '-', erg, comp, len(data)))
sys.exit(rc)
