# Makefile for LaTeX document compilation with auto-watch

# Variables
MAIN = main
TEX = $(MAIN).tex
PDF = $(MAIN).pdf
BOOKLET = $(MAIN)-book.pdf
SHOWANSWER_STAMP = .showanswer-stamp
DVI = $(MAIN).dvi
AUX = $(MAIN).aux
LOG = $(MAIN).log
TOC = $(MAIN).toc
SECTIONS := $(wildcard sections/*.tex sections/*/*.tex)

# Default target
all: $(PDF) $(BOOKLET)

# Compile PDF via DVI (for Japanese support)
$(PDF): $(TEX) preamble.tex $(SECTIONS)
	@echo "=== Compiling LaTeX document ==="
	uplatex -synctex=1 -interaction=nonstopmode -file-line-error $(TEX)
	@echo "=== Running second pass for cross-references ==="
	uplatex -synctex=1 -interaction=nonstopmode -file-line-error $(TEX)
	@echo "=== Converting DVI to PDF ==="
	dvipdfmx $(MAIN).dvi
	@echo "=== Build completed successfully ==="

# \showanswer の状態を記録（変更時に main-book.pdf を再生成）
$(SHOWANSWER_STAMP): preamble.tex
	@grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' > $@

# Booklet PDF (A3 print, 2-up, fold to A4 booklet)
BOOKLET_SCRIPT = ../../scripts/make-booklet-pdf.sh
$(BOOKLET): $(PDF) $(SHOWANSWER_STAMP)
	@echo "=== Creating booklet PDF ($$(cat $(SHOWANSWER_STAMP))) ==="
	bash $(BOOKLET_SCRIPT) $(PDF) $(BOOKLET)

.PHONY: booklet booklet-only
booklet: $(BOOKLET)

booklet-only: $(BOOKLET)

# Auto-watch and compile on file changes
watch:
	@echo "Watching for changes in $(TEX), preamble.tex, and sections/..."
	@echo "Press Ctrl+C to stop"
	@while true; do \
		$(MAKE) all; \
		echo "Compiled at $$(date)"; \
		fswatch -1 $(TEX) preamble.tex sections > /dev/null 2>&1; \
	done

watch-inotify:
	@echo "Watching for changes using inotifywait..."
	@while inotifywait -e modify $(TEX) preamble.tex sections; do \
		$(MAKE) all; \
		echo "Compiled at $$(date)"; \
	done

watch-poll:
	@echo "Watching for changes (polling every 2 seconds)..."
	@echo "Press Ctrl+C to stop"
	@while true; do \
		$(MAKE) all; \
		echo "Compiled at $$(date)"; \
		sleep 2; \
	done

clean:
	rm -f *.aux *.log *.dvi *.toc *.out *.fdb_latexmk *.fls *.synctex.gz
	rm -f $(BOOKLET) $(SHOWANSWER_STAMP) .crop-tmp*.pdf

cleanall: clean
	rm -f $(PDF)

rebuild: cleanall all

answer:
	sed 's/\\showanswerfalse/\\showanswertrue/' preamble.tex > preamble_tmp.tex
	mv preamble_tmp.tex preamble.tex
	$(MAKE) all
	mv $(PDF) $(MAIN)_answer.pdf
	@if [ -f $(BOOKLET) ]; then mv $(BOOKLET) $(MAIN)-book_answer.pdf; fi
	sed 's/\\showanswertrue/\\showanswerfalse/' preamble.tex > preamble_tmp.tex
	mv preamble_tmp.tex preamble.tex
	$(MAKE) all

help:
	@echo "Available targets:"
	@echo "  all         - Compile main.pdf and main-book.pdf (synced with \\showanswer)"
	@echo "  watch       - Auto-compile on file changes (using fswatch)"
	@echo "  watch-poll  - Auto-compile with polling (works everywhere)"
	@echo "  clean       - Remove auxiliary files"
	@echo "  cleanall    - Remove all generated files"
	@echo "  rebuild     - Clean and rebuild"
	@echo "  answer      - Create answer version"
	@echo "  booklet     - Create booklet PDF (synced with \\showanswer)"
	@echo "  help        - Show this help"

.PHONY: all watch watch-inotify watch-poll clean cleanall rebuild answer booklet booklet-only help
