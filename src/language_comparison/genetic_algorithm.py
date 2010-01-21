# Genetic Algorithm in the Python Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

import random

NUM_GENERATIONS = 100
NUM_BOUTS = 3
POP_SIZE = 100
NUM_BITS = 64
P_CROSSOVER = 1
# 0.98
P_MUTATION = 1.0/NUM_BITS
HALF = 0.5

def onemax(bitstring):
	sum = 0
	for c in bitstring:
		if(c=='1'):
			sum += 1
	return sum

def tournament(population):
	best = None
	for i in range(NUM_BOUTS):
		other = population[random.randint(0, population.len)]
		if best==None or other['fitness']>best['fitness']:
			best = other
	return best

def mutation(bitstring):
	string = ''
	for c in bitstring:
		if random.random<P_MUTATION:
			if c=='1':
				string += '0'
			else:
				string += '1'
		else:
			string += c
	return string

def crossover(parent1, parent2):
	if random.random < P_CROSSOVER:
		cut = random.randint(1, NUM_BITS-1)
		return parent1['bitstring'][0:cut]+parent2['bitstring'][cut:NUM_BITS], parent2['bitstring'][0:cut]+parent1['bitstring'][cut:NUM_BITS]
	return {'bitstring': ''+parent1['bitstring'], 'fitness': 0}, {'bitstring': ''+parent2['bitstring'], 'fitness': 0}

