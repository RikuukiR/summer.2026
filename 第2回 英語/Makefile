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

# Default target（main.pdf と main-book.pdf を同期）
all: $(PDF) $(BOOKLET)

# Compile PDF via DVI (for Japanese support)
$(PDF): $(TEX) preamble.tex $(SECTIONS)
	@echo "=== Compiling LaTeX document ($$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t')) ==="
	uplatex -synctex=1 -interaction=nonstopmode -file-line-error $(TEX)
	@echo "=== Running second pass for cross-references ==="
	uplatex -synctex=1 -interaction=nonstopmode -file-line-error $(TEX)
	@echo "=== Converting DVI to PDF ==="
	dvipdfmx $(MAIN).dvi
	@echo "=== Build completed successfully ==="

# \showanswer の状態を記録（変更時に main-book.pdf を再生成）
$(SHOWANSWER_STAMP): preamble.tex
	@grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' > $@

# Booklet PDF (A3 2-up, fold to A4 booklet)
# 共通: scripts/make-booklet-pdf.sh --pad（短辺とじ・偶数シート回転）
# 印刷: A3・両面・短辺とじ → 真ん中で二つ折り（プリンターの冊子印刷はオフ）
BOOKLET_SCRIPT = ../scripts/make-booklet-pdf.sh
$(BOOKLET): $(PDF) $(TEX) preamble.tex $(SECTIONS) $(SHOWANSWER_STAMP)
	@echo "=== Creating booklet PDF ($$(cat $(SHOWANSWER_STAMP))) ==="
	bash $(BOOKLET_SCRIPT) --pad $(PDF) $(BOOKLET)
	@python3 scripts/verify-pdf-sync.py

.PHONY: booklet booklet-only student teacher
booklet: $(BOOKLET)

booklet-only: $(BOOKLET)

# 解答表示を切り替えて PDF 2種を同期生成
student:
	@perl -i -pe 's/^\\showanswertrue/\\showanswerfalse/' preamble.tex
	@$(MAKE) -B all

teacher:
	@perl -i -pe 's/^\\showanswerfalse/\\showanswertrue/' preamble.tex
	@$(MAKE) -B all

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

# Clean auxiliary files
clean:
	rm -f *.aux *.log *.dvi *.toc *.out *.fdb_latexmk *.fls *.synctex.gz
	rm -f $(BOOKLET) $(SHOWANSWER_STAMP) .crop-tmp*.pdf

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
	@if [ -f $(BOOKLET) ]; then mv $(BOOKLET) $(MAIN)-book_answer.pdf; fi
	sed 's/\\showanswertrue/\\showanswerfalse/' preamble.tex > preamble_tmp.tex
	mv preamble_tmp.tex preamble.tex
	$(MAKE) all

# Help
help:
	@echo "Available targets:"
	@echo "  all         - Compile main.pdf and main-book.pdf (synced with \\showanswer)"
	@echo "  watch       - Auto-compile on file changes (using fswatch)"
	@echo "  watch-poll  - Auto-compile with polling (works everywhere)"
	@echo "  clean       - Remove auxiliary files"
	@echo "  cleanall    - Remove all generated files"
	@echo "  rebuild     - Clean and rebuild"
	@echo "  answer      - Create answer version"
	@echo "  booklet     - Create main-book.pdf (A3 面付け・短辺とじ)"
	@echo "  student     - 生徒用（\\showanswerfalse）で PDF 2種を生成"
	@echo "  teacher     - 先生用（\\showanswertrue）で PDF 2種を生成"
	@echo "  help        - Show this help"

.PHONY: all watch watch-inotify watch-poll clean cleanall rebuild answer booklet booklet-only student teacher help
