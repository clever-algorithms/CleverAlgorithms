# Simulated Annealing in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def euc_2d(c1, c2)
  Math.sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def cost(permutation, cities)
  distance =0
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.size-1) ? permutation[0] : permutation[i+1]
    distance += euc_2d(cities[c1], cities[c2])
  end
  return distance
end

def random_permutation(cities)
  perm = Array.new(cities.size){|i| i}
  perm.each_index do |i|
    r = rand(perm.size-i) + i
    perm[r], perm[i] = perm[i], perm[r]
  end
  return perm
end

def stochastic_two_opt!(perm)
  c1, c2 = rand(perm.size), rand(perm.size)
  exclude = [c1]
  exclude << ((c1==0) ? perm.size-1 : c1-1)
  exclude << ((c1==perm.size-1) ? 0 : c1+1)
  c2 = rand(perm.size) while exclude.include?(c2)
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm
end

def create_neighbor(current, cities)
  candidate = {}
  candidate[:vector] = Array.new(current[:vector])
  stochastic_two_opt!(candidate[:vector])
  candidate[:cost] = cost(candidate[:vector], cities)
  return candidate
end

def should_accept?(candidate, current, temp)
  return true if candidate[:cost] <= current[:cost]
  return Math.exp((current[:cost] - candidate[:cost]) / temp) > rand()
end

def search(cities, max_iter, max_temp, temp_change)
  current = {:vector=>random_permutation(cities)}
  current[:cost] = cost(current[:vector], cities)
  temp, best = max_temp, current
  max_iter.times do |iter|
    candidate = create_neighbor(current, cities)
    temp = temp * temp_change
    current = candidate if should_accept?(candidate, current, temp)
    best = candidate if candidate[:cost] < best[:cost]
    if (iter+1).modulo(10) == 0
      puts " > iteration #{(iter+1)}, temp=#{temp}, best=#{best[:cost]}"
    end
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
  max_iterations = 2000
  max_temp = 100000.0
  temp_change = 0.98
  # execute the algorithm
  best = search(berlin52, max_iterations, max_temp, temp_change)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
