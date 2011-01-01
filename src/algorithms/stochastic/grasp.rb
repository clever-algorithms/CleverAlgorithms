# Greedy Randomized Adaptive Search Procedure in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def euc_2d(c1, c2)
  Math.sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def cost(perm, cities)
  distance =0
  perm.each_with_index do |c1, i|
    c2 = (i==perm.size-1) ? perm[0] : perm[i+1]
    distance += euc_2d(cities[c1], cities[c2])
  end
  return distance
end

def stochastic_two_opt(permutation)
  perm = Array.new(permutation)
  c1, c2 = rand(perm.size), rand(perm.size)
  exclude = [c1]
  exclude << ((c1==0) ? perm.size-1 : c1-1)
  exclude << ((c1==perm.size-1) ? 0 : c1+1)
  c2 = rand(perm.size) while exclude.include?(c2)
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm
end

def local_search(best, cities, max_no_improv)
  count = 0
  begin
    candidate = {:vector=>stochastic_two_opt(best[:vector])}
    candidate[:cost] = cost(candidate[:vector], cities)    
    count = (candidate[:cost] < best[:cost]) ? 0 : count+1
    best = candidate if candidate[:cost] < best[:cost]    
  end until count >= max_no_improv
  return best
end

def construct_randomized_greedy_solution(cities, alpha)
  candidate = {}
  candidate[:vector] = [rand(cities.size)]
  allCities = Array.new(cities.size) {|i| i}
  while candidate[:vector].size < cities.size
    candidates = allCities - candidate[:vector]
    costs = Array.new(candidates.size) do |i| 
      euc_2d(cities[candidate[:vector].last], cities[i])
    end
    rcl, max, min = [], costs.max, costs.min
    costs.each_with_index do |c,i| 
      rcl << candidates[i] if c <= (min + alpha*(max-min))
    end
    candidate[:vector] << rcl[rand(rcl.size)]
  end
  candidate[:cost] = cost(candidate[:vector], cities)
  return candidate
end

def search(cities, max_iter, max_no_improv, alpha)
  best = nil
  max_iter.times do |iter|
    candidate = construct_randomized_greedy_solution(cities, alpha);
    candidate = local_search(candidate, cities, max_no_improv)
    best = candidate if best.nil? or candidate[:cost] < best[:cost]
    puts " > iteration #{(iter+1)}, best=#{best[:cost]}"
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],
   [880,660],[25,230],[525,1000],[580,1175],[650,1130],[1605,620],
   [1220,580],[1465,200],[1530,5],[845,680],[725,370],[145,665],
   [415,635],[510,875],[560,365],[300,465],[520,585],[480,415],
   [835,625],[975,580],[1215,245],[1320,315],[1250,400],[660,180],
   [410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
   [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],
   [95,260],[875,920],[700,500],[555,815],[830,485],[1170,65],
   [830,610],[605,625],[595,360],[1340,725],[1740,245]]
  # algorithm configuration
  max_iter = 50
  max_no_improv = 50
  greediness_factor = 0.3
  # execute the algorithm
  best = search(berlin52, max_iter, max_no_improv, greediness_factor)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
