# Makefile for the book

ebook : master.tex
	pdflatex master;true
	./make_bibtex.sh;true
	makeindex master;true
	pdflatex master;true
	pdflatex master;true
	pdflatex master;true
	grep -i "undefined" master.log;true

ebook_draft : master.tex
	echo "N/A"

physical_book: master.tex
	echo "N/A"

clean : 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc *.ilg *.ind

vl:
	acroread master.pdf
	
vm:
	open -a Preview master.pdf
