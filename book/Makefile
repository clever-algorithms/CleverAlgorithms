# Makefile for the book

book : master.tex
	pdflatex master;true
	./make_bibtex.sh;true
	makeindex master;true
	pdflatex master;true
	pdflatex master;true
	pdflatex master;true
	grep -i "undefined" master.log;true

clean : 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc *.ilg *.ind

vl:
	acroread master.pdf
