-- Nur das Noetigste: batman-adv verlangt Gluon als Mesh-Protokoll, die
-- Upload-Seite kommt aus gluon-web-admin (bringt den Config-Mode mit).
features {
	'mesh-batman-adv-15',
}

packages {
	'gluon-web-admin',
	-- TLS fuer die Umleitung https -> http (S51rampe-https)
	'libustream-mbedtls',
}
