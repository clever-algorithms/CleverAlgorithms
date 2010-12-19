# Makefile for the book

EBOOK=master
PAPERBACK=paperback

# function build {
# 	pdflatex ${1};true
# 	./make_bibtex.sh;true
# 	makeindex ${1};true
# 	pdflatex ${1};true
# 	pdflatex ${1};true
# 	pdflatex ${1};true
# 	grep -i "undefined" ${1}.log;true
# }

# Build the PDF of the ebook
ebook : ${EBOOK}.tex
	pdflatex ${EBOOK};true
	./make_bibtex.sh;true
	makeindex ${EBOOK};true
	pdflatex ${EBOOK};true
	pdflatex ${EBOOK};true
	pdflatex ${EBOOK};true
	grep -i "undefined" ${EBOOK}.log;true

# Build the PDF for the paperback
paperback : master.tex
	pdflatex ${PAPERBACK};true
	./make_bibtex.sh;true
	makeindex ${PAPERBACK};true
	pdflatex ${PAPERBACK};true
	pdflatex ${PAPERBACK};true
	pdflatex ${PAPERBACK};true
	grep -i "undefined" ${PAPERBACK}.log;true

# Delete all the guff and build matter
clean : 
	rm *.pdf *.out *.bbl *.blg *.aux *.idx *.log *.toc *.ilg *.ind

# View the PDF on Linux
vl:
	acroread master.pdf

# View the PDF on Mac
vm:
	open -a Preview master.pdf
