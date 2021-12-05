SHARE="/usr/share/skyfalls-manual-duplex"

install:
	install -m700 ./cups-backend.pl /usr/lib/cups/backend/smdu
	install -d $(SHARE)
	install -m644 ./empty.pdf $(SHARE)/empty.pdf