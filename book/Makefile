# Makefile for the book

book : master.tex
	pdflatex master;true
	bibtex master;true
	makeindex master;true
	pdflatex master;true
	pdflatex master;true
	grep -i "undefined" master.log;true
clean : 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc *.ilg *.ind
