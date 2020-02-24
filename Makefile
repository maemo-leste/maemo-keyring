TRUSTED-LIST := $(patsubst active-keys/add-%,trusted.gpg/maemo-leste-archive-%.gpg,$(wildcard active-keys/add-*))
TMPRING := trusted.gpg/build-area

GPG_OPTIONS := --no-options --no-default-keyring --no-auto-check-trustdb --trustdb-name ./trustdb.gpg

build: verify-indices keyrings/maemo-leste-archive-keyring.gpg verify-results $(TRUSTED-LIST)

verify-indices: keyrings/team-members.gpg
	gpg $(GPG_OPTIONS) \
		--keyring keyrings/team-members.gpg \
		--verify active-keys/index.gpg active-keys/index

verify-results: keyrings/team-members.gpg keyrings/maemo-leste-archive-keyring.gpg
	gpg $(GPG_OPTIONS) \
		--keyring keyrings/team-members.gpg --verify \
		keyrings/maemo-leste-archive-keyring.gpg.asc \
		keyrings/maemo-leste-archive-keyring.gpg

keyrings/maemo-leste-archive-keyring.gpg: active-keys/index
	jetring-build -I $@ active-keys
	gpg $(GPG_OPTIONS) --no-keyring --import-options import-export --import < $@ > $@.tmp
	mv -f $@.tmp $@

keyrings/team-members.gpg: team-members/index
	jetring-build -I $@ team-members
	gpg $(GPG_OPTIONS) --no-keyring --import-options import-export --import < $@ > $@.tmp
	mv -f $@.tmp $@

$(TRUSTED-LIST) :: trusted.gpg/maemo-leste-archive-%.gpg : active-keys/add-% active-keys/index
	mkdir -p $(TMPRING) trusted.gpg
	grep -F $(shell basename $<) -- active-keys/index > $(TMPRING)/index
	cp $< $(TMPRING)
	jetring-build -I $@ $(TMPRING)
	rm -rf $(TMPRING)
	gpg $(GPG_OPTIONS) --no-keyring --import-options import-export --import < $@ > $@.tmp
	mv -f $@.tmp $@

clean:
	rm -f keyrings/maemo-leste-archive-keyring.gpg \
		keyrings/maemo-leste/archive-keyring.gpg~ \
		keyrings/maemo-leste-archive-keyring.gpg.lastchangeset
	rm -f keyrings/team-members.gpg \
		keyrings/team-members.gpg~ \
		keyrings/team-members.gpg.lastchangeset
	rm -rf $(TMPRING) trusted.gpg trustdb.gpg
	rm -f keyrings/*.cache

install: build
	install -d $(DESTDIR)/usr/share/keyrings/
	cp trusted.gpg/maemo-leste-archive-*.gpg $(DESTDIR)/usr/share/keyrings/
	cp keyrings/maemo-leste-archive-keyring.gpg $(DESTDIR)/usr/share/keyrings/
	install -d $(DESTDIR)/etc/apt/trusted.gpg.d/
	cp $(shell find trusted.gpg/ -name '*.gpg' -type f) $(DESTDIR)/etc/apt/trusted.gpg.d/

.PHONY: verify-indices verify-results clean build install
