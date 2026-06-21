# Makefile for LaTeX document compilation with auto-watch

# Variables
MAIN = main
TEX = $(MAIN).tex
PDF = $(MAIN).pdf
BOOKLET = $(MAIN)-book.pdf
DVI = $(MAIN).dvi
AUX = $(MAIN).aux
LOG = $(MAIN).log
TOC = $(MAIN).toc
SECTIONS := $(wildcard sections/*.tex sections/*/*.tex)

# Default target
all: $(PDF)

# Compile PDF via DVI (for Japanese support)
$(PDF): $(TEX) preamble.tex $(SECTIONS)
	@echo "=== Compiling LaTeX document ==="
	uplatex -synctex=1 -interaction=nonstopmode -file-line-error $(TEX)
	@echo "=== Running second pass for cross-references ==="
	uplatex -synctex=1 -interaction=nonstopmode -file-line-error $(TEX)
	@echo "=== Converting DVI to PDF ==="
	dvipdfmx $(MAIN).dvi
	@echo "=== Build completed successfully ==="
	@$(MAKE) --no-print-directory booklet-only

# Auto-watch and compile on file changes
watch:
	@echo "Watching for changes in $(TEX), preamble.tex, and sections/..."
	@echo "Press Ctrl+C to stop"
	@while true; do \
		$(MAKE) all; \
		echo "Compiled at $$(date)"; \
		fswatch -1 $(TEX) preamble.tex sections > /dev/null 2>&1; \
	done

# Alternative watch using inotifywait (if available)
watch-inotify:
	@echo "Watching for changes using inotifywait..."
	@while inotifywait -e modify $(TEX) preamble.tex sections; do \
		$(MAKE) all; \
		echo "Compiled at $$(date)"; \
	done

# Simple polling watch (works on all systems)
watch-poll:
	@echo "Watching for changes (polling every 2 seconds)..."
	@echo "Press Ctrl+C to stop"
	@while true; do \
		$(MAKE) all; \
		echo "Compiled at $$(date)"; \
		sleep 2; \
	done

# Booklet PDF (A3 print, 2-up, fold to A4 booklet, short-edge binding)
# main.pdf の \showanswer 設定に連動（make all のたびに更新）
.PHONY: booklet booklet-only
booklet: $(PDF)
	@echo "=== Booklet ready: $(BOOKLET) ==="

booklet-only:
	@echo "=== Creating booklet PDF ($$(grep -E '^\\showanswer(true|false)' preamble.tex | tr -d ' ')) ==="
	pdfbook2 --paper=a3paper --short-edge $(PDF)

# Clean auxiliary files
clean:
	rm -f *.aux *.log *.dvi *.toc *.out *.fdb_latexmk *.fls *.synctex.gz
	rm -f $(BOOKLET) .crop-tmp*.pdf

# Clean all generated files
cleanall: clean
	rm -f $(PDF)

# Force rebuild
rebuild: cleanall all

# Show answer version
answer:
	sed 's/\\showanswerfalse/\\showanswertrue/' preamble.tex > preamble_tmp.tex
	mv preamble_tmp.tex preamble.tex
	$(MAKE) all
	mv $(PDF) $(MAIN)_answer.pdf
	sed 's/\\showanswertrue/\\showanswerfalse/' preamble.tex > preamble_tmp.tex
	mv preamble_tmp.tex preamble.tex

# Help
help:
	@echo "Available targets:"
	@echo "  all         - Compile the PDF (default)"
	@echo "  watch       - Auto-compile on file changes (using fswatch)"
	@echo "  watch-poll  - Auto-compile with polling (works everywhere)"
	@echo "  clean       - Remove auxiliary files"
	@echo "  cleanall    - Remove all generated files"
	@echo "  rebuild     - Clean and rebuild"
	@echo "  answer      - Create answer version"
	@echo "  booklet     - Create booklet PDF (synced with \\showanswer)"
	@echo "  help        - Show this help"

.PHONY: all watch watch-inotify watch-poll clean cleanall rebuild answer booklet booklet-only help
