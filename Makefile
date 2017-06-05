# Project Makefile

# book directory
DIR_BOOK=$(CURDIR)/book
# build directory
BUILD=$(CURDIR)/build
# final output directory
DIST=$(CURDIR)/dist
# book latex filename without extension
BOOK_FILE=book
# web directory
WEB=$(CURDIR)/web
# code directory
SRC=$(CURDIR)/src
# build log file
LOG=${BUILD}/book.log
TESTS_LOG=${BUILD}/tests.log
# release filename without extension
RELEASE=clever_algorithms

.PHONY: init clean web

# initialize the project
init:
	mkdir -p ${BUILD}
	mkdir -p ${DIST}

# finalize the project
dist: build
	# screen copy
	cp ${BUILD}/${RELEASE}.pdf ${DIST}/
	# lulu copy
	ps2pdf13 -dPDFSETTINGS=/prepress ${BUILD}/book.pdf ${DIST}/${RELEASE}_lulu.pdf
	# zip package
	(cd ${BUILD}; zip -r ${RELEASE}.zip ${RELEASE}.pdf code)
	cp ${BUILD}/${RELEASE}.zip ${DIST}/

# build book pdf
build: init
	rm -rf ${BUILD}/*
	cp ${DIR_BOOK}/bibtex.bib ${BUILD}/
	cp -r ${SRC} ${BUILD}/code
	(cd ${DIR_BOOK};pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BUILD} ${BOOK_FILE}.tex 1>>${LOG} 2>&1)
	(cd ${BUILD};makeindex ${BOOK_FILE} 1>>${LOG} 2>&1)
	(cd ${DIR_BOOK};pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BUILD} ${BOOK_FILE}.tex 1>>${LOG} 2>&1)
	for file in ${BUILD}/bu*.aux ; do \
		(cd ${BUILD};bibtex $$(basename $$file) 1>>${LOG} 2>&1); \
	done
	(cd ${DIR_BOOK};pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BUILD} ${BOOK_FILE}.tex 1>>${LOG} 2>&1)
	rm ${LOG}
	(cd ${DIR_BOOK};pdflatex -halt-on-error -interaction=errorstopmode -output-directory ${BUILD} ${BOOK_FILE}.tex 1>>${LOG} 2>&1)
	grep -i "undefined" ${LOG};true
	grep -i "error" ${LOG};true
	cp ${BUILD}/book.pdf ${BUILD}/${RELEASE}.pdf

# clean the project
clean:
	rm -rf ${DIST}
	rm -rf ${BUILD}

# create the webpage version
web: init
	ruby ${WEB}/generate.rb

# unit test ruby source code
test: init
	rm -rf ${TESTS_LOG}
	echo "testing..."
	for file in src/algorithms/evolutionary/tests/* ; do \
		ruby $$file | tee -a ${TESTS_LOG} ; \
	done
	for file in src/algorithms/immune/tests/* ; do \
		ruby $$file | tee -a ${TESTS_LOG} ; \
	done
	for file in src/algorithms/neural/tests/* ; do \
		ruby $$file | tee -a ${TESTS_LOG} ; \
	done
	for file in src/algorithms/physical/tests/* ; do \
		ruby $$file | tee -a ${TESTS_LOG} ; \
	done
	for file in src/algorithms/probabilistic/tests/* ; do \
		ruby $$file | tee -a ${TESTS_LOG} ; \
	done
	for file in src/algorithms/stochastic/tests/* ; do \
		ruby $$file | tee -a ${TESTS_LOG} ; \
	done
	for file in src/algorithms/swarm/tests/* ; do \
		ruby $$file | tee -a ${TESTS_LOG} ; \
	done
	for file in src/programming_paradigms/tests/* ; do \
		ruby $$file | tee -a ${TESTS_LOG} ; \
	done
	echo "DONE"
	cat ${TESTS_LOG} | grep -E ' Error:| Failure:|No such file or directory'
