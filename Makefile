LATEX=latexmk
LATEX_COMPILE_OPTS=-pdf -bibtex -dvi-
LATEX_CLEAN_OPTS=-c
LATEX_VERYCLEAN_OPTS=-C
LATEX_MAIN_FILE=CMake-tutorial.tex
PDF_FILE_TOVIEW=CMake-tutorial-view.pdf

all: $(PDF_FILE_TOVIEW)

$(PDF_FILE_TOVIEW) : CMake-tutorial.pdf
	@\cp $< $@

CMake-tutorial.pdf : $(LATEX_MAIN_FILE)
	@$(LATEX) $(LATEX_COMPILE_OPTS) $<

rebuild: clean
	@$(LATEX) $(LATEX_VERYCLEAN_OPTS) $(LATEX_COMPILE_OPTS) $(LATEX_MAIN_FILE) 2> /dev/null
	@echo "You may now rebuild with 'make'"
clean:
	@$(LATEX) $(LATEX_CLEAN_OPTS) $(LATEX_COMPILE_OPTS) $(LATEX_MAIN_FILE) 2> /dev/null
	@-\rm -f *.vrb *.snm *.nav
