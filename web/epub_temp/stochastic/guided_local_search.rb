# Guided Local Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def euc_2d(c1, c2)
  Math.sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def random_permutation(cities)
  perm = Array.new(cities.size){|i| i}
  perm.each_index do |i|
    r = rand(perm.size-i) + i
    perm[r], perm[i] = perm[i], perm[r]
  end
  return perm
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

def augmented_cost(permutation, penalties, cities, lambda)
  distance, augmented = 0, 0
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.size-1) ? permutation[0] : permutation[i+1]
    c1, c2 = c2, c1 if c2 < c1
    d = euc_2d(cities[c1], cities[c2])
    distance += d
    augmented += d + (lambda * (penalties[c1][c2]))
  end
  return [distance, augmented]
end

def cost(cand, penalties, cities, lambda)
  cost, acost = augmented_cost(cand[:vector], penalties, cities, lambda)
  cand[:cost], cand[:aug_cost] = cost, acost
end

def local_search(current, cities, penalties, max_no_improv, lambda)
  cost(current, penalties, cities, lambda)
  count = 0
  begin
    candidate = {:vector=> stochastic_two_opt(current[:vector])}
    cost(candidate, penalties, cities, lambda)
    count = (candidate[:aug_cost] < current[:aug_cost]) ? 0 : count+1
    current = candidate if candidate[:aug_cost] < current[:aug_cost]
  end until count >= max_no_improv
  return current
end

def calculate_feature_utilities(penal, cities, permutation)
  utilities = Array.new(permutation.size,0)
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.size-1) ? permutation[0] : permutation[i+1]
    c1, c2 = c2, c1 if c2 < c1
    utilities[i] = euc_2d(cities[c1], cities[c2]) / (1.0 + penal[c1][c2])
  end
  return utilities
end

def update_penalties!(penalties, cities, permutation, utilities)
  max = utilities.max()
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.size-1) ? permutation[0] : permutation[i+1]
    c1, c2 = c2, c1 if c2 < c1
    penalties[c1][c2] += 1 if utilities[i] == max
  end
  return penalties
end

def search(max_iterations, cities, max_no_improv, lambda)
  current = {:vector=>random_permutation(cities)}
  best = nil
  penalties = Array.new(cities.size){ Array.new(cities.size, 0) }
  max_iterations.times do |iter|
    current=local_search(current, cities, penalties, max_no_improv, lambda)
    utilities=calculate_feature_utilities(penalties,cities,current[:vector])
    update_penalties!(penalties, cities, current[:vector], utilities)
    best = current if best.nil? or current[:cost] < best[:cost]
    puts " > iter=#{(iter+1)}, best=#{best[:cost]}, aug=#{best[:aug_cost]}"
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
  max_iterations = 150
  max_no_improv = 20
  alpha = 0.3
  local_search_optima = 12000.0
  lambda = alpha * (local_search_optima/berlin52.size.to_f)
  # execute the algorithm
  best = search(max_iterations, berlin52, max_no_improv, lambda)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
