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
 
-- DONE THIS ONE
function onemax(bitstring)
  local sum = 0
	for i=1, bitstring:len() do
		if(bitstring:sub(i,i) == "1") then 
			sum = sum+1 
		end
	end
  return sum
end

-- DONE THIS ONE
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

-- DONE THIS ONE
function mutation(source)
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

-- DONE THIS ONE
function crossover(parent1, parent2)
  if math.random() < P_CROSSOVER then
    return ""..parent1.bitstring, ""..parent2.bitstring
  end
  local cut = math.random(NUM_BITS-2) + 1
  return parent1.bitstring:sub(0,cut)..parent2.bitstring:sub(cut,NUM_BITS),
    parent2.bitstring:sub(0,cut)..parent1.bitstring:sub(cut,NUM_BITS)
end

-- todo
def evolve
  population = Array.new(POP_SIZE) do |i|
    Solution.new((0...NUM_BITS).inject(""){|s,i| s<<((rand<HALF) ? "1" : "0")})
  end
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

io.write(string.format("done! Solution: %s\n", evolve()))





 
function reproduce(selected)
	local pop = {}
	for i, p1 in ipairs(selected) do
		local p2 = nil
		if (i%2)==0 then p2=selected[i-1] else p2=selected[i+1] end
		child = crossover(p1, p2)
		mutantChild = mutation(child)
		table.insert(pop, mutantChild);
	end
	return pop
end
 

 
function random_bitstring(length)
	local s = ""
	while s:len() < length do
		if math.random() < 0.5
		then s = s.."0"
		else s = s.."1" end
	end 
	return s
end
 
function getBest(currentBest, population, fitnesses) 	
	local bestScore = currentBest==nil and 0 or fitness(currentBest)
	local best = currentBest
	for i,f in ipairs(fitnesses) do
		if(f > bestScore) then
			bestScore = f
			best = population[i]
		end
	end
	return best
end
 
function evolve()
	local population = {}
	local bestString = nil
	-- initialize the popuation random pool
	for i=1, populationSize do
		table.insert(population, random_bitstring(problemSize))
	end
	-- optimize the population (fixed duration)
	for i=1, maxGenerations do
		-- evaluate
		fitnesses = {}
		for i,v in ipairs(population) do
			table.insert(fitnesses, fitness(v))
		end
		-- update best
		bestString = getBest(bestString, population, fitnesses)
		-- select
		tmpPop = selection(population, fitnesses)		
		-- reproduce
		population = reproduce(tmpPop)
		io.write(string.format(">gen %d, best cost=%d [%s]\n", i, fitness(bestString), bestString))
	end	
	return bestString
end
 

