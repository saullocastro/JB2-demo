# Makefile for building presentations from markdown
#
# USAGE:
#   make        - Build all presentation formats.
#   make all    - Same as 'make'.
#   make beamer - Build only the combined Beamer PDF.
#   make typst  - Build all individual Typst PDFs.
#   make clean  - Remove all generated files.

# --- Configuration ---
# Use bash for more predictable scripting in recipes
SHELL := /bin/bash

# Directories
CONTENT_DIR := content
OUTPUT_DIR := presentations
TEMPLATE_DIR := beamer-template

# Tooling
PANDOC := pandoc
TYPST := typst
PDFLATEX := pdflatex

# --- File Definitions ---
# Find all .md files in the content directory
MARKDOWN_FILES := $(wildcard $(CONTENT_DIR)/*.md)
# Create a list of base names, e.g., "Introduction", "Conclusion"
BASE_NAMES := $(patsubst $(CONTENT_DIR)/%.md,%,$(MARKDOWN_FILES))

# Typst target files
TYPST_PDF_FILES := $(patsubst %,$(OUTPUT_DIR)/%_typst.pdf,$(BASE_NAMES))

# Beamer target files
BEAMER_BUILD_DIR := $(OUTPUT_DIR)/beamer_build
BEAMER_FRAGMENTS := $(patsubst %,$(BEAMER_BUILD_DIR)/%.tex,$(BASE_NAMES))
BEAMER_PDF := $(OUTPUT_DIR)/combined_beamer_presentation.pdf

# --- Phony Targets (commands that don't produce a file with the same name) ---
.PHONY: all beamer typst clean

# --- Main Targets ---

# Default target: build everything
all: beamer typst

# Target to build all Typst presentations
typst: $(TYPST_PDF_FILES)

# Target to build the combined Beamer presentation
beamer: $(BEAMER_PDF)


# ==============================================================================
# --- Beamer Rules ---
# ==============================================================================

# The final Beamer PDF depends on all the .tex fragments being created first,
# and on the main template file. If any of these change, this rule will run.
$(BEAMER_PDF): $(BEAMER_FRAGMENTS) $(TEMPLATE_DIR)/presentation.tex
	@echo "--- Assembling Combined Beamer Presentation ---"
	@# 1. Prepare build directory and copy template assets
	@echo "  -> Preparing build directory..."
	@cp -r $(TEMPLATE_DIR)/* $(BEAMER_BUILD_DIR)/
	@cp -r figures $(BEAMER_BUILD_DIR)/
	@# 2. Inject the \input commands into the copied template
	@echo "  -> Injecting content into template..."
	@python3 inject_template.py $(BEAMER_BUILD_DIR)/presentation.tex $(BEAMER_BUILD_DIR)/presentation.tex $(BEAMER_FRAGMENTS)
	@# 3. Compile the final PDF from within the build directory
	@echo "  -> Compiling final PDF (this may take a moment)..."
	@( cd $(BEAMER_BUILD_DIR) && \
	   $(PDFLATEX) -interaction=batchmode "presentation.tex" > /dev/null 2>&1 ; \
	   $(PDFLATEX) -interaction=batchmode "presentation.tex" > /dev/null 2>&1 ; \
	   [ -f presentation.pdf ] ) \
	   || (echo "    - ERROR: pdflatex compilation failed or no PDF produced." && exit 1)
	@# 4. Move final PDF and cleanup
	@echo "  -> Finalizing PDF..."
	@mv $(BEAMER_BUILD_DIR)/presentation.pdf $@
	@rm -rf $(BEAMER_BUILD_DIR)
	@echo "--- Beamer Presentation Complete: $@"

# Pattern rule to create a .tex file for Beamer from a .md file.
# This will run for each fragment that is older than its source markdown file.
$(BEAMER_BUILD_DIR)/%.tex: $(CONTENT_DIR)/%.md
	@echo " PANDOC: $< -> $@"
	@mkdir -p $(@D)
	@python3 filter_content.py beamer $< /tmp/$*.md.filtered && \
	$(PANDOC) --lua-filter=pandoc-filter.lua --slide-level=2 /tmp/$*.md.filtered -t beamer -o $@


# ==============================================================================
# --- Typst Rules ---
# ==============================================================================

# Pattern rule to create a Typst PDF from a .typ file
$(OUTPUT_DIR)/%_typst.pdf: $(OUTPUT_DIR)/%.typ
	@echo "  TYPST: $< -> $@"
	@$(TYPST) compile --root . $< $@

# Pattern rule to create a .typ file from a .md file
$(OUTPUT_DIR)/%.typ: $(CONTENT_DIR)/%.md
	@echo " PANDOC: $< -> $@"
	@mkdir -p $(@D)
	@python3 filter_content.py typst $< /tmp/$*.md.filtered && \
	$(PANDOC) -M mainfont="Liberation Serif" -M monofont="Liberation Mono" --lua-filter=pandoc-filter.lua /tmp/$*.md.filtered -t typst -s -o $@


# ==============================================================================
# --- Cleanup Target ---
# ==============================================================================
clean:
	@echo "Cleaning up generated files..."
	@rm -rf $(OUTPUT_DIR)

.SILENT:
