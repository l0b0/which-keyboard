PREFIX = /usr/local
BIN_DIR = $(PREFIX)/bin

INSTALL = /usr/bin/install
SED = /usr/bin/sed
SHELLCHECK = /usr/bin/shellcheck

name = $(notdir $(CURDIR))
script = $(name).sh
installed_script = $(BIN_DIR)/$(name)

.PHONY: default
default: test

.PHONY: test
test: lint

.PHONY: lint
lint:
	$(SHELLCHECK) $(script)

.PHONY: install
install:
	$(INSTALL) $(script) $(installed_script)
	$(SED) --in-place 's#\(\./\)\?$(script)#$(name)#g' $(installed_script)
