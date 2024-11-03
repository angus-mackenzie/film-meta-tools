# Configuration and overridable variables
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
TEST_FIXTURES = tests/fixtures
VERSION = 1.0.0

# Tool configuration (allows override from environment)
EXIFTOOL ?= exiftool
MAGICK ?= magick
SHELL := /bin/bash

# Colors for output
BLUE := \033[1;34m
GREEN := \033[1;32m
RED := \033[1;31m
NC := \033[0m

# Phony targets (targets that don't create files)
.PHONY: all install uninstall test clean setup-fixtures check-deps setup-tests help lint

# Default target
all: help

# Help target for documentation
help:
	@echo -e "${BLUE}Film Meta Tools ${VERSION}${NC}"
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@echo "  install      Install the tools to $(BINDIR)"
	@echo "  uninstall    Remove the installed tools"
	@echo "  test         Run all tests"
	@echo "  lint         Check shell scripts for issues"
	@echo "  clean        Remove generated files"
	@echo "  help         Show this help message"

# Installation targets
install: check-deps
	@echo -e "${BLUE}Installing to $(BINDIR)...${NC}"
	@install -d $(BINDIR)
	@install -m 755 bin/film-scan-fix $(BINDIR)/film-scan-fix
	@install -m 755 bin/film-scan-audit $(BINDIR)/film-scan-audit
	@echo -e "${GREEN}Installation complete!${NC}"

uninstall:
	@echo -e "${BLUE}Uninstalling...${NC}"
	@rm -f $(BINDIR)/film-scan-fix
	@rm -f $(BINDIR)/film-scan-audit
	@echo -e "${GREEN}Uninstallation complete!${NC}"

# Development and testing targets
check-deps:
	@command -v $(EXIFTOOL) >/dev/null 2>&1 || { echo -e "${RED}Error: exiftool is required.${NC}"; exit 1; }
	@command -v $(MAGICK) >/dev/null 2>&1 || { echo -e "${RED}Error: ImageMagick is required.${NC}"; exit 1; }

setup-tests:
	@echo -e "${BLUE}Setting up test environment...${NC}"
	@chmod +x tests/test-*.sh tests/test-utils.sh
	@mkdir -p $(TEST_FIXTURES)

setup-fixtures: check-deps setup-tests
	@echo -e "${BLUE}Creating test fixtures...${NC}"
	@$(MAGICK) -size 100x100 xc:white $(TEST_FIXTURES)/normal-scan.JPG 2>/dev/null
	@$(MAGICK) -size 100x100 xc:white $(TEST_FIXTURES)/frontier-1988.JPG 2>/dev/null
	@$(EXIFTOOL) -q -overwrite_original \
		"-CreateDate=2024:01:01 12:00:00" \
		"-DateTimeOriginal=2024:01:01 12:00:00" \
		"-ISO=400" \
		$(TEST_FIXTURES)/normal-scan.JPG
	@$(EXIFTOOL) -q -overwrite_original \
		"-CreateDate=1988:01:01 01:07:02" \
		"-DateTimeOriginal=1988:01:01 01:07:02" \
		"-Make=FUJI PHOTO FILM CO., LTD." \
		"-Model=SP-3000" \
		"-Software=FDi V4.5 / FRONTIER355/375-1.8-0E-016" \
		$(TEST_FIXTURES)/frontier-1988.JPG

lint:
	@echo -e "${BLUE}Checking shell scripts...${NC}"
	@command -v shellcheck >/dev/null 2>&1 || { echo -e "${RED}Error: shellcheck is required for linting.${NC}"; exit 1; }
	@shellcheck bin/* tests/*.sh

test: setup-fixtures
	@echo -e "\n${BLUE}Running all tests...${NC}"
	@failed=0; \
	for test in tests/test-*.sh; do \
		if ! ./$${test}; then \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo -e "\n${BLUE}=== Final Test Summary ===${NC}"; \
	echo "Total test files: $$(ls tests/test-*.sh | wc -l)"; \
	echo "Failed test files: $$failed"; \
	test $$failed -eq 0

clean:
	@rm -rf $(TEST_FIXTURES)