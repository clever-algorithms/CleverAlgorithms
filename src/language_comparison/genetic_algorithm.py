# Genetic Algorithm in the Python Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

import random
import sys

NUM_GENERATIONS = 100
NUM_BOUTS = 3
POP_SIZE = 100
NUM_BITS = 64
P_CROSSOVER = 0.98
P_MUTATION = 1.0/NUM_BITS
HALF = 0.5

def onemax(bitstring):
	sum = 0
	for c in bitstring:
		if(c=='1'):
			sum += 1
	return sum
			

def mutation(bitstring):
	string = ''
	for c in bitstring:
		if random.random()<P_MUTATION:
			if c=='1':
				string += '0'
			else:
				string += '1'
		else:
			string += c
	return string




print onemax('0000')

