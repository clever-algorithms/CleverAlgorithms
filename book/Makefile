# Makefile for the book

# Build the PDF of the ebook
build_ebook : master.tex
	pdflatex master;true
	./make_bibtex.sh;true
	makeindex master;true
	pdflatex master;true
	pdflatex master;true
	pdflatex master;true
	grep -i "undefined" master.log;true

# Build the PDF for the paperback
build_paperback: master.tex
	echo "N/A"

# Delete all the guff and build matter
clean : 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc *.ilg *.ind

# View the PDF on Linux
vl:
	acroread master.pdf

# View the PDF on Mac
vm:
	open -a Preview master.pdf
