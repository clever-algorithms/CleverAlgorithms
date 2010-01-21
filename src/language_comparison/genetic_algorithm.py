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
		other = population[random.randint(0, len(population))]
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
	return {'bitstring':''+parent1['bitstring'],'fitness':0}, {'bitstring':''+parent2['bitstring'],'fitness':0}

def random_bitstring():
	s = ''
	for 0 in range(NUM_BITS):
		if random.random < HALF:
			s += '0'
		else
			s += '1' 
	return s
end

def evolve():
	population = []
	for 0 in range(POP_SIZE):
		population.append({'bitstring':random_bitstring(), 'fitness'=0})


  population.each{|c| c.fitness = onemax(c.bitstring)}
  gen, best = 0, population.sort{|x,y| y.fitness <=> x.fitness}.first  
  while best.fitness!=NUM_BITS and (gen+=1)<NUM_GENERATIONS
    children = []
    while children.size < POP_SIZE
      s1, s2 = crossover(tournament(population), tournament(population))
      children << Solution.new(mutation(s1))
      children << Solution.new(mutation(s2)) if children.size < POP_SIZE
    end
    children.each{|c| c.fitness = onemax(c.bitstring)}
    children.sort!{|x,y| y.fitness <=> x.fitness}
    best = children.first if children.first.fitness > best.fitness
    population = children
    puts " > gen #{gen}, best: #{best}"
  end  
  return best
end

best = evolve()
print 'done! Solution: f='+best['fitness']+', s='+best['bitstring']'