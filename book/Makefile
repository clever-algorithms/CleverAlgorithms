# Makefile for the book

EBOOK=master
PAPERBACK=paperback

# Build the PDF for the paperback
paperback : ${PAPERBACK}.tex
	pdflatex ${PAPERBACK};true
	./make_bibtex.sh;true	
	pdflatex ${PAPERBACK};true
	pdflatex ${PAPERBACK};true
	makeindex ${PAPERBACK};true
	pdflatex ${PAPERBACK};true
	grep -i "undefined" ${PAPERBACK}.log;true
#	ps2pdf13 -dPDFSETTINGS=/prepress paperback.pdf paperback1.pdf
	

# Build the PDF of the ebook
ebook : ${EBOOK}.tex
	pdflatex ${EBOOK};true
	./make_bibtex.sh;true
	makeindex ${EBOOK};true
	pdflatex ${EBOOK};true
	pdflatex ${EBOOK};true
	pdflatex ${EBOOK};true
	grep -i "undefined" ${EBOOK}.log;true


# Delete all the guff and build matter
clean : 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc *.ilg *.ind

# View the PDF on Linux
vl:
	acroread paperback.pdf

# View the PDF on Mac
vm:
	open -a Preview paperback.pdf
