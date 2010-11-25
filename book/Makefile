# build the book

book:
	pdflatex master
	makeindex master
	bibtex master 
	pdflatex master
	pdflatex master

clean: 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc 
