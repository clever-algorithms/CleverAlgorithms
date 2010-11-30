#!/bin/sh

FILES=./bu*.aux 

for f in $FILES 
do
	bibtex $f
done
