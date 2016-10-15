PREFIX = /usr/local
BIN_DIR = $(PREFIX)/bin
SHARE_DIR = $(PREFIX)/share

INSTALL = /usr/bin/install
MKDIR = /usr/bin/mkdir
SED = /usr/bin/sed
SHELLCHECK = /usr/bin/shellcheck

name = $(notdir $(CURDIR))
script = $(name).sh
installed_script = $(BIN_DIR)/$(name)
include_path = $(SHARE_DIR)/$(name)

.PHONY: default
default: test

.PHONY: test
test: lint

.PHONY: lint
lint:
	$(SHELLCHECK) --external-sources $(script)

.PHONY: install
install: $(include_path)
	$(INSTALL) --mode 755 $(script) $(installed_script)
	$(SED) --in-place 's#\(\./\)\?$(script)#$(name)#g' $(installed_script)
	$(INSTALL) --mode 644 shell-includes/error.sh shell-includes/usage.sh shell-includes/variables.sh $(include_path)
	$(SED) --in-place 's#^\(includes=\).*#\1"$(include_path)"#g' $(installed_script)

$(include_path):
	$(MKDIR) $(include_path)
