# Makefile for the book

# build the book
book :
	pdflatex master 
	bibtex master 
	makeindex master 
	pdflatex master 
	pdflatex master 

# delete all created files
clean : 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc *.ilg *.ind
