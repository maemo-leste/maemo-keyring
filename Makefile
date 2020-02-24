.POSIX:

all:

clean:
	rm -f keyrings/*.gpg~

install:
	mkdir -p $(DESTDIR)/usr/share/keyrings
	mkdir -p $(DESTDIR)/etc/apt/trusted.gpg.d
	cp keyrings/*.gpg $(DESTDIR)/usr/share/keyrings
	cp keyrings/*.gpg $(DESTDIR)/etc/apt/trusted.gpg.d

.PHONY: clean install
