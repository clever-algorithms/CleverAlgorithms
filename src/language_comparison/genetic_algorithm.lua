-- Genetic Algorithm in the Lua Programming Language

-- The Clever Algorithms Project: http://www.CleverAlgorithms.com
-- (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
-- This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_GENERATIONS = 100
NUM_BOUTS = 3
POP_SIZE = 100
NUM_BITS = 64
P_CROSSOVER = 0.98
P_MUTATION = 1.0/NUM_BITS
HALF = 0.5

function onemax(bitstring)
  local sum = 0
	for i=1, bitstring:len() do
		if(bitstring:sub(i,i) == "1") then 
			sum = sum+1 
		end
	end
  return sum
end

function tournament(population)
  local best = nil
  for i=1, NUM_BOUTS do
    local other = population[math.random(#population)]
	if(best==nil or other.fitness > best.fitness) then
		best = other
	end
  end
  return best
end

function mutation(bitstring)
  local string = ""
  for i=1, bitstring:len() do
	local c = bitstring:sub(i,i)
    if math.random() < P_MUTATION then
		if c == "0" then 
			string = string.."1"
		else 
			string = string.."0" 
		end
    else 
      string = string..c
    end
  end
  return string
end

function crossover(parent1, parent2)
  if math.random() < P_CROSSOVER then
	local cut = math.random(NUM_BITS-2) + 2
	  return parent1.bitstring:sub(1,cut-1)..parent2.bitstring:sub(cut,NUM_BITS),
	    parent2.bitstring:sub(1,cut-1)..parent1.bitstring:sub(cut,NUM_BITS)  
  end
  return ""..parent1.bitstring, ""..parent2.bitstring
end

function random_bitstring()
	local s = ""
	for i=1, NUM_BITS do
		if math.random() < HALF then 
			s = s.."0"
		else 
			s = s.."1" 
		end
	end 
	return s
end

function evolve()
	local population = {}
	for i=1, POP_SIZE do
		table.insert(population, {bitstring=random_bitstring(),fitness=0})
	end
	for i,candidate in ipairs(population) do 
		candidate.fitness = onemax(candidate.bitstring)
	end
	table.sort(population, function(a,b) return a.fitness<b.fitness end)
  	local gen, best = 0, population[POP_SIZE]
	while best.fitness<NUM_BITS and gen<NUM_GENERATIONS do
		local children = {}
		while #children < POP_SIZE do
			local s1, s2 = crossover(tournament(population), tournament(population))
			table.insert(children, {bitstring=mutation(s1),fitness=0}) 
			if #children < POP_SIZE then
				table.insert(children, {bitstring=mutation(s2),fitness=0}) 
			end
		end
		for i,candidate in ipairs(children) do 
			candidate.fitness = onemax(candidate.bitstring)
		end
		table.sort(children, function(a,b) return a.fitness<b.fitness end)
		if(children[POP_SIZE].fitness > best.fitness) then
			best = children[POP_SIZE]
		end
		population = children
		io.write(" > gen "..gen..", best: "..best.bitstring.."\n")
		gen = gen + 1
	end
	return best
end

best = evolve()
io.write("done! Solution:f="..best.fitness..", s="..best.bitstring.."\n")