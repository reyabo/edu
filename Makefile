TEXMFHOME ?= $(shell kpsewhich -var-value TEXMFHOME)
TEXMFMAIN ?= $(shell kpsewhich -var-value TEXMFMAIN)

.PHONY: all clean distclean install dist test clean-test # targets which should always be created

all: edu.pdf

clean:
	rm -f *.gl? *.id? *.aux
	rm -f *.bbl *.bcf *.bib *.blg *.xdy
	rm -f *.fls *.log *.out *.run.xml *.toc
	rm -f *.cod *.gnuplot *.table
	rm -f *.log

distclean: clean
	rm -f *.cls *.pdf *.clo *.tar.gz *.tds.zip

cls: edu.cls

%.cls: %.tex
	pdflatex -interaction=nonstopmode -halt-on-error $<

%.pdf: %.tex %.cls
	pdflatex -interaction=nonstopmode -halt-on-error "\providecommand\locale{de}\input{$<}"
	makeglossaries $*
	biber $*
	pdflatex -interaction=nonstopmode -halt-on-error "\providecommand\locale{de}\input{$<}"
	makeglossaries $*
	pdflatex -interaction=nonstopmode -halt-on-error "\providecommand\locale{de}\input{$<}"
	mv $*.pdf $*-de.pdf
	pdflatex -interaction=nonstopmode -halt-on-error $<
	makeglossaries $*
	biber $*
	pdflatex -interaction=nonstopmode -halt-on-error $<
	makeglossaries $*
	pdflatex -interaction=nonstopmode -halt-on-error $<


install: install-local

install-local: all
	mkdir -p $(TEXMFHOME)/tex/latex/edu
	mkdir -p $(TEXMFHOME)/source/latex/edu
	mkdir -p $(TEXMFHOME)/doc/latex/edu
	install -m 0644 edu.cls $(TEXMFHOME)/tex/latex/edu/edu.cls
	install -m 0644 edu-styles-wu.sty $(TEXMFHOME)/tex/latex/edu/edu-styles-wu.sty
	install -m 0644 edu-colors-wu.sty $(TEXMFHOME)/tex/latex/edu/edu-colors-wu.sty
	install -m 0644 edu.tex $(TEXMFHOME)/source/latex/edu/edu.tex
	install -m 0644 edu.pdf $(TEXMFHOME)/doc/latex/edu/edu.pdf
	install -m 0644 edu.pdf $(TEXMFHOME)/doc/latex/edu/edu-de.pdf
	install -m 0644 README $(TEXMFHOME)/doc/latex/edu/README
	mktexlsr

install-global: all
	mkdir -p $(TEXMFMAIN)/tex/latex/edu
	mkdir -p $(TEXMFMAIN)/source/latex/edu
	mkdir -p $(TEXMFMAIN)/doc/latex/edu
	sudo install -m 0644 edu.cls $(TEXMFMAIN)/tex/latex/edu/edu.cls
	sudo install -m 0644 edu-styles-wu.sty $(TEXMFMAIN)/tex/latex/edu/edu-styles-wu.sty
	sudo install -m 0644 edu-colors-wu.sty $(TEXMFMAIN)/tex/latex/edu/edu-colors-wu.sty
	sudo install -m 0644 edu.tex $(TEXMFMAIN)/source/latex/edu/edu.tex
	sudo install -m 0644 edu.pdf $(TEXMFMAIN)/doc/latex/edu/edu.pdf
	sudo install -m 0644 edu.pdf $(TEXMFMAIN)/doc/latex/edu/edu-de.pdf
	sudo install -m 0644 README $(TEXMFMAIN)/doc/latex/edu/README
	sudo mktexlsr

edu.tds.zip: edu.tex edu.pdf edu.cls
	mkdir -p edu/tex/latex/edu
	cp edu.cls edu/tex/latex/edu/edu.cls
	cp edu.cls edu/tex/latex/edu/edu-styles-wu.sty
	cp edu.cls edu/tex/latex/edu/edu-colors-wu.sty
	mkdir -p edu/doc/latex/edu
	cp edu.pdf edu/doc/latex/edu/edu.pdf
	cp edu-de.pdf edu/doc/latex/edu/edu-de.pdf
	mkdir -p edu/source/latex/edu
	cp edu.tex edu/source/latex/edu/edu.tex
	cp README edu/doc/latex/edu/README
	cd edu && zip -r ../edu.tds.zip *
	rm -rf edu

edu.tar.gz: edu.tds.zip edu.tex edu.pdf
	mkdir -p edu
	cp edu.tex edu/edu.tex
	cp edu.cls edu/edu-styles-wu.sty
	cp edu.cls edu/edu-colors-wu.sty
	cp edu.pdf edu/edu.pdf
	cp edu-de.pdf edu/edu-de.pdf
	cp README edu/README
	cp Makefile edu/Makefile
	tar -czf $@ edu edu.tds.zip
	rm -rf edu

dist: skdoc.tar.gz
