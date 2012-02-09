#!/bin/bash
SLIDES=CMake-tutorial
LATEX=pdflatex
BIBTEX=bibtex
${LATEX} ${SLIDES}
${BIBTEX} CMake-tutorial.aux
for f in bu*.aux;
do
  ${BIBTEX} $f
done
${LATEX} ${SLIDES}
