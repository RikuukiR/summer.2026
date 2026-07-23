# Makefile for LaTeX document compilation with auto-watch

PROJECTS := 作図 式の計算の利用
SHOWANSWER_STAMP = .showanswer-stamp
BOOKLET_SCRIPT = ../../scripts/make-booklet-pdf.sh

PDFS := $(addsuffix /main.pdf,$(PROJECTS))
BOOKLETS := $(addsuffix /main-book.pdf,$(PROJECTS))

# Default target（各教材 PDF / 冊子 PDF / テスト PDF を同期）
all: $(PDFS) $(BOOKLETS) test-3

test-3: preamble.tex $(SHOWANSWER_STAMP)
	@bash scripts/build-test-3.sh

$(SHOWANSWER_STAMP): preamble.tex
	@grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t' > $@

define compile_project
	@echo "=== Compiling $(1)/main.tex ($$(grep -E '^\\showanswer(true|false)' preamble.tex | tail -1 | tr -d ' \t')) ==="
	cd "$(1)" && uplatex -synctex=1 -interaction=nonstopmode -file-line-error main.tex
	cd "$(1)" && uplatex -synctex=1 -interaction=nonstopmode -file-line-error main.tex
	cd "$(1)" && dvipdfmx main.dvi
	@echo "=== Build completed: $(1)/main.pdf ==="
endef

%/main.pdf: %/main.tex preamble.tex %/sections $(SHOWANSWER_STAMP)
	$(call compile_project,$*)

%/main-book.pdf: %/main.pdf %/main.tex preamble.tex %/sections $(SHOWANSWER_STAMP)
	@echo "=== Creating booklet PDF: $(@) ($$(cat $(SHOWANSWER_STAMP))) ==="
	bash $(BOOKLET_SCRIPT) $*/main.pdf $@
	@python3 scripts/verify-pdf-sync.py $*

.PHONY: booklet booklet-only student teacher test-3
booklet: $(BOOKLETS)

booklet-only: $(BOOKLETS)

student:
	@perl -i -pe 's/^\\showanswertrue/\\showanswerfalse/' preamble.tex
	@$(MAKE) -B all

teacher:
	@perl -i -pe 's/^\\showanswerfalse/\\showanswertrue/' preamble.tex
	@$(MAKE) -B all

watch:
	@echo "Watching for changes in preamble.tex and project sections/..."
	@echo "Press Ctrl+C to stop"
	@while true; do \
		$(MAKE) all; \
		echo "Compiled at $$(date)"; \
		fswatch -1 preamble.tex 作図 式の計算の利用 > /dev/null 2>&1; \
	done

watch-inotify:
	@echo "Watching for changes using inotifywait..."
	@while inotifywait -e modify preamble.tex 作図 式の計算の利用; do \
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
	rm -f $(SHOWANSWER_STAMP) .crop-tmp*.pdf
	@for d in $(PROJECTS); do \
		rm -f $$d/*.aux $$d/*.log $$d/*.dvi $$d/*.toc $$d/*.out $$d/*.fdb_latexmk $$d/*.fls $$d/*.synctex.gz $$d/main-book.pdf; \
	done

cleanall: clean
	@for d in $(PROJECTS); do rm -f $$d/main.pdf; done

rebuild: cleanall all

answer:
	sed 's/\\showanswerfalse/\\showanswertrue/' preamble.tex > preamble_tmp.tex
	mv preamble_tmp.tex preamble.tex
	$(MAKE) all
	@for d in $(PROJECTS); do \
		mv $$d/main.pdf $$d/main_answer.pdf; \
		if [ -f $$d/main-book.pdf ]; then mv $$d/main-book.pdf $$d/main-book_answer.pdf; fi; \
	done
	sed 's/\\showanswertrue/\\showanswerfalse/' preamble.tex > preamble_tmp.tex
	mv preamble_tmp.tex preamble.tex
	$(MAKE) all

help:
	@echo "Available targets:"
	@echo "  all         - Compile all project PDFs and booklets"
	@echo "  watch       - Auto-compile on file changes (using fswatch)"
	@echo "  watch-poll  - Auto-compile with polling (works everywhere)"
	@echo "  clean       - Remove auxiliary files"
	@echo "  cleanall    - Remove all generated files"
	@echo "  rebuild     - Clean and rebuild"
	@echo "  answer      - Create answer version"
	@echo "  booklet     - Create all booklet PDFs"
	@echo "  student     - 生徒用（\\showanswerfalse）で PDF を生成"
	@echo "  teacher     - 先生用（\\showanswertrue）で PDF を生成"
	@echo "  test-3      - Create sections/test3/ の確認・復習テスト PDF"
	@echo "  help        - Show this help"
	@echo ""
	@echo "Projects: $(PROJECTS)"

.PHONY: all watch watch-inotify watch-poll clean cleanall rebuild answer booklet booklet-only student teacher test-3 help
