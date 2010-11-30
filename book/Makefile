# Makefile for the book

book : master.tex
	pdflatex master;true
	bibtex c_introduction;true
	bibtex c_advanced;true
	bibtex b_appendix1;true		
	makeindex master;true
	pdflatex master;true
	pdflatex master;true
	grep -i "undefined" master.log;true

# one big bib at end - the old way
book_old : master.tex
	pdflatex master;true
	bibtex master;true
	makeindex master;true
	pdflatex master;true
	pdflatex master;true
	grep -i "undefined" master.log;true


clean : 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc *.ilg *.ind
