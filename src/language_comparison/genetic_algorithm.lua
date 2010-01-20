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
 
function printf(...)
	io.write(string.format(...))
end
 
function crossover(a, b) 
	if math.random() > crossoverRate then
		return ""..a
	end
	local cut = math.random(a:len()-1)
	local s = ""
	for i=1, cut do
		s = s..a:sub(i,i)
	end
	for i=cut+1, b:len() do
		s = s..b:sub(i,i)
	end		
	return s
end
 
function mutation(bitstring)
	local s = ""
	for i=1, bitstring:len() do
		local c = bitstring:sub(i,i)
		if math.random() < mutationRate then		 
			if c == "0" 
			then s = s.."1"
			else s = s.."0" end
		else s = s..c end
	end
	return s
end
 
function selection(population, fitnesses)
	local pop = {}
	repeat
		local bestString = nil
		local bestFitness = 0
		for i=1, selectionTournamentSize do
			local selection = math.random(#fitnesses)
			if fitnesses[selection] > bestFitness then
				bestFitness = fitnesses[selection]
				bestString = population[selection]
			end
		end
		table.insert(pop, bestString)
	until #pop == #population
	return pop
end
 
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
 
function fitness(bitstring)
	local cost = 0
	for i=1, bitstring:len() do
		local c = bitstring:sub(i,i)
		if(c == "1") then cost = cost + 1 end
	end
	return cost
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
		printf(">gen %d, best cost=%d [%s]\n", i, fitness(bestString), bestString)
	end	
	return bestString
end
 
printf("done! Solution: %s\n", evolve())
