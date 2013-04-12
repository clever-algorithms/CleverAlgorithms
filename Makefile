# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2011 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# Project Makefile

# constants
BOOK=$(CURDIR)/book
WEB=$(CURDIR)/web

# Build the PDF for the paperback for development
r:
	pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BOOK} book.tex 1> ${BOOK}/book.log 2>&1;true 
	makeindex ${BOOK}/book;true	
	pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BOOK} book.tex 1> ${BOOK}/book.log 2>&1;true 
	pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BOOK} book.tex 1> ${BOOK}/book.log 2>&1;true 
	for file in ${BOOK}/bu*.aux ; do \
		bibtex $$file 2>&1 1>${BOOK}/book.log ; \
	done
	pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BOOK} book.tex 1> ${BOOK}/book.log 2>&1;true 
	pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BOOK} book.tex 1> ${BOOK}/book.log 2>&1;true 
	grep -i "undefined" ${BOOK}/book.log;true 
	# grep -i "warning" ${BOOK}/book.log;true 
	grep -i "error" ${BOOK}/book.log;true

# Build the PDF for lulu
lulu: r
	ps2pdf13 -dPDFSETTINGS=/prepress ${BOOK}/book.pdf ${BOOK}/book-lulu.pdf

# clean the project
clean: 
	rm -rf ${BOOK}/*.pdf ${BOOK}/*.aux ${BOOK}/*.log ${BOOK}/*.out ${BOOK}/*.toc \
		${BOOK}/*.idx ${BOOK}/*.ilg ${BOOK}/*.ind ${BOOK}/*.bak ${BOOK}/*.bbl ${BOOK}/*.blg
	rm -rf ${WEB}/docs

# View the development PDF on Linux
vl:
	acroread ${BOOK}/book.pdf 2>&1 1>/dev/null &

# View the development PDF on Mac
vm:
	open -a Preview ${BOOK}/book.pdf

# run jabref on my linux workstation
jl:
	java -jar /opt/jabref/JabRef-2.7.2.jar 2>1 1>/dev/null &

# create the webpage version
web: web/generate.rb
	ruby web/generate.rb
