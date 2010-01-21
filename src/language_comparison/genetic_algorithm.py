# Genetic Algorithm in the Python Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

import random

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

def tournament(population):
	best = None
	for i in range(NUM_BOUTS):
		other = population[random.randint(0, len(population)-1)]
		if best==None or other['fitness']>best['fitness']:
			best = other
	return best

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

def crossover(parent1, parent2):
	if random.random() < P_CROSSOVER:
		cut = random.randint(1, NUM_BITS-1)
		return parent1['bitstring'][0:cut]+parent2['bitstring'][cut:NUM_BITS], parent2['bitstring'][0:cut]+parent1['bitstring'][cut:NUM_BITS]
	return {'bitstring':''+parent1['bitstring'],'fitness':0}, {'bitstring':''+parent2['bitstring'],'fitness':0}

def random_bitstring():
	s = ''
	for x in range(NUM_BITS):
		if random.random() < HALF:
			s += '0'
		else:
			s += '1' 
	return s

def evolve():
	population = []
	for x in range(POP_SIZE):
		population.append({'bitstring':random_bitstring(), 'fitness':0})
	for candidate in population:
		candidate['fitness'] = onemax(candidate['bitstring'])
	population.sort(lambda x, y: x['fitness']-y['fitness'])
	gen, best = 0, population[POP_SIZE-1]
	while best['fitness']!=NUM_BITS and gen<NUM_GENERATIONS:
		children = []
		while len(children) < POP_SIZE:
			s1, s2 = crossover(tournament(population), tournament(population))
			children.append({'bitstring':mutation(s1), 'fitness':0})
			if len(children) < POP_SIZE:
				children.append({'bitstring':mutation(s2), 'fitness':0})
		for candidate in children:
			candidate['fitness'] = onemax(candidate['bitstring'])
		children.sort(lambda x, y: x['fitness']-y['fitness'])
		if children[POP_SIZE-1]['fitness'] > best['fitness']:
			best = children[POP_SIZE-1]
		population = children
		gen += 1
		print "gen %d, best: %d, %s" % (gen, best['fitness'], best['bitstring'])
	return best

best = evolve()
print "done! Solution: f=%d, s=%s" % (best['fitness'], best['bitstring'])