SHELL := /bin/bash

.PHONY: help setup-ssh set-remote push bootstrap sync archive archive-zip archive-tar clean-dist

	help:
	@echo "Neovim config helper targets:"
	@echo "  make setup-ssh EMAIL=you@example.com   # Generate SSH key + config for GitHub"
	@echo "  make set-remote USER=<github-username>  # Set origin to SSH git@github.com:USER/nvim.git"
	@echo "  make push M=\"commit message\"        # Add, commit, and push to origin main"
	@echo "  make bootstrap REPO=git@github.com:USER/nvim.git [TARGET=~/.config/nvim]"
	@echo "  make sync                               # Run :Lazy sync headless"
	@echo "  make archive                            # Create tar.gz and zip snapshots under ./dist"
	@echo "  make archive-zip                        # Create a zip snapshot under ./dist"
	@echo "  make archive-tar                        # Create a tar.gz snapshot under ./dist"
	@echo "  make clean-dist                         # Remove ./dist archives"

setup-ssh:
	@if [ -z "$(EMAIL)" ]; then echo "EMAIL is required: make setup-ssh EMAIL=you@example.com"; exit 1; fi
	@./scripts/setup_github_ssh.sh "$(EMAIL)"

set-remote:
	@if [ -z "$(USER)" ]; then echo "USER is required: make set-remote USER=<github-username>"; exit 1; fi
	@git remote remove origin 2>/dev/null || true
	@git remote add origin git@github.com:$(USER)/nvim.git
	@echo "Origin set to git@github.com:$(USER)/nvim.git"

push:
	@msg="$(if $(M),$(M),update: $$(date +%Y-%m-%d_%H-%M-%S))"; \
	git add -A && git commit -m "$$msg" || true; \
	git branch -M main; \
	git push -u origin main

bootstrap:
	@if [ -z "$(REPO)" ]; then echo "REPO is required: make bootstrap REPO=git@github.com:USER/nvim.git [TARGET=~/.config/nvim]"; exit 1; fi
	@TARGET_DIR="$(if $(TARGET),$(TARGET),$(HOME)/.config/nvim)"; \
	./scripts/bootstrap.sh "$(REPO)" "$$TARGET_DIR"

sync:
	@nvim --headless "+Lazy! sync" +qa || true

# Archives of the tracked repo content (excludes untracked files)
TS := $(shell date +%Y%m%d-%H%M%S)
DIST := dist

archive: archive-tar archive-zip

archive-zip:
	@mkdir -p $(DIST)
	@git archive --format=zip -o $(DIST)/nvim-$(TS).zip HEAD
	@echo "Created $(DIST)/nvim-$(TS).zip"

archive-tar:
	@mkdir -p $(DIST)
	@git archive --format=tar.gz -o $(DIST)/nvim-$(TS).tar.gz HEAD
	@echo "Created $(DIST)/nvim-$(TS).tar.gz"

clean-dist:
	@rm -rf $(DIST)
	@echo "Removed $(DIST)/"
