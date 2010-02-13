# Scatter Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

MAX_ITERATIONS = 100
LOCAL_SEARCH_NO_IMPROVEMENTS = 50
BERLIN52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],[525,1000],
 [580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],[845,680],[725,370],[145,665],
 [415,635],[510,875],[560,365],[300,465],[520,585],[480,415],[835,625],[975,580],[1215,245],
 [1320,315],[1250,400],[660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
 [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],[875,920],[700,500],
 [555,815],[830,485],[1170,65],[830,610],[605,625],[595,360],[1340,725],[1740,245]]

def euc_2d(c1, c2)
  Math::sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def cost(permutation, cities)
  distance =0
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    distance += euc_2d(cities[c1], cities[c2])
  end
  return distance
end

def random_permutation(cities)
  all = Array.new(cities.length) {|i| i}
  return Array.new(all.length) {|i| all.delete_at(rand(all.length))}
end

def stochastic_two_opt(permutation)
  perm = Array.new(permutation)
  c1, c2 = rand(perm.length), rand(perm.length)
  c2 = rand(perm.length) while c1 == c2
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm
end

def local_search(best, cities, maxNoImprovements)
  noImprovements = 0
  begin
    candidate = {}
    candidate[:vector] = stochastic_two_opt(best[:vector])    
    candidate[:cost] = cost(candidate[:vector], cities)
    if candidate[:cost] < best[:cost]
      noImprovements, best = 0, candidate
    else
      noImprovements += 1      
    end
  end until noImprovements >= maxNoImprovements
  return best
end

def double_bridge_move(perm)
  pos1 = 1 + rand(perm.length / 4)
  pos2 = pos1 + 1 + rand(perm.length / 4)
  pos3 = pos2 + 1 + rand(perm.length / 4)
  return perm[0...pos1] + perm[pos3..perm.length] + perm[pos2...pos3] + perm[pos1...pos2]
end

def perturbation(cities, best)
  candidate = {}
  candidate[:vector] = double_bridge_move(best[:vector])
  candidate[:cost] = cost(candidate[:vector], cities)
  return candidate
end

def search(cities, maxIterations, maxNoImprovementsLS)
  best = {}
  best[:vector] = random_permutation(cities)
  best[:cost] = cost(best[:vector], cities)
  best = local_search(best, cities, maxNoImprovementsLS)
  maxIterations.times do |iter|
    candidate = perturbation(cities, best)
    candidate = local_search(candidate, cities, maxNoImprovementsLS)
    best = candidate if candidate[:cost] < best[:cost]
    puts " > iteration #{(iter+1)}, best: c=#{best[:cost]}"
  end
  return best
end

best = search(BERLIN52, MAX_ITERATIONS, LOCAL_SEARCH_NO_IMPROVEMENTS)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"