# Guided Local Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_ITERATIONS = 100
MAX_NO_MPROVEMENTS = 15
ALPHA = 0.3
BERLIN52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],
 [525,1000],[580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],
 [845,680],[725,370],[145,665],[415,635],[510,875],[560,365],[300,465],
 [520,585],[480,415],[835,625],[975,580],[1215,245],[1320,315],[1250,400],
 [660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
 [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],[875,920],
 [700,500],[555,815],[830,485],[1170,65],[830,610],[605,625],[595,360],
 [1340,725],[1740,245]]

def euc_2d(c1, c2)
  Math::sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def random_permutation(cities)
  perm = Array.new(cities.length){|i|i}
  for i in 0...perm.length
    r = rand(perm.length-i) + i
    perm[r], perm[i] = perm[i], perm[r]
  end
  return perm
end

def two_opt(permutation)
  perm = Array.new(permutation)
  c1, c2 = rand(perm.length), rand(perm.length)
  c2 = rand(perm.length) while c1 == c2
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm
end

def augmented_cost(permutation, penalties, cities, lambda)
  distance, augmented = 0, 0
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    c1, c2 = c2, c1 if c2 < c1
    d = euc_2d(cities[c1], cities[c2])
    distance += d
    augmented += d + (lambda * (permutation[c1][c2]))
  end
  return distance, augmented
end

def local_search(current, cities, penalties, maxNoImprovements, lambda)
  current[:cost], current[:acost] = augmented_cost(current[:vector], penalties, cities, lambda)
  noImprovements = 0
  begin
    perm = {}
    perm[:vector] = two_opt(current[:vector])
    perm[:cost], perm[:acost] = augmented_cost(perm[:vector], penalties, cities, lambda)
    if perm[:acost] < current[:acost]
      noImprovements, current = 0, perm
    else
      noImprovements += 1      
    end
  end until noImprovements >= maxNoImprovements
  return current
end

def calculate_feature_utilities(penalties, cities, permutation)
  utilities = Array.new(permutation.length,0)
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    c1, c2 = c2, c1 if c2 < c1
    utilities[i] = euc_2d(cities[c1], cities[c2]) / (1.0 + penalties[c1][c2])
  end
  return utilities
end

def update_penalties!(penalties, cities, permutation, utilities)
  max = utilities.max()
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    c1, c2 = c2, c1 if c2 < c1
    penalties[c1][c2] += 1 if utilities[i] == max
  end
  return penalties
end

def search(numIterations, cities, maxNoImprovements, lambda)
  best, current = nil, {}  
  current[:vector] = random_permutation(cities)
  penalties = Array.new(cities.length){Array.new(cities.length,0)}
  numIterations.times do |iter|
    current = local_search(current, cities, penalties, maxNoImprovements, lambda)
    utilities = calculate_feature_utilities(penalties, cities, current[:vector])
    update_penalties!(penalties, cities, current[:vector], utilities)
    if(best.nil? or current[:cost] < best[:cost])
      best = current
    end
    puts " > iteration #{(iter+1)}, best: c=#{best[:cost]}"
  end
  return best
end

lambda = ALPHA * (15000.0/BERLIN52.length)
best = search(NUM_ITERATIONS, BERLIN52, MAX_NO_MPROVEMENTS, lambda)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"