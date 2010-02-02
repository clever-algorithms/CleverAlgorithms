# Guided Local Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_ITERATIONS = 100
BERLIN52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],
 [525,1000],[580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],
 [845,680],[725,370],[145,665],[415,635],[510,875],[560,365],[300,465],
 [520,585],[480,415],[835,625],[975,580],[1215,245],[1320,315],[1250,400],
 [660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
 [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],[875,920],
 [700,500],[555,815],[830,485],[1170,65],[830,610],[605,625],[595,360],
 [1340,725],[1740,245]]
 
# 7542
OPTIMAL_TOUR = [1,49,32,45,19,41,8,9,10,43,33,51,11,52,14,13,47,26,
     27,28,12,25,4,6,15,5,24,48,38,37,40,39,36,35,34,44,46,16,29,50,20,
     23,30,2,7,42,21,17,3,18,31,22]
     
def euc_2d(c1, c2)
  Math::sqrt((c1[0] - c2[0])**2 + (c1[1] - c2[1])**2).round
end

def cost(permutation, cities)
  distance = 0
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    distance += euc_2d(cities[c1], cities[c2])
  end
  return distance
end

def shuffle!(array)
  for i in 0...array.length
    r = rand(array.length-i) + i
    array[r], array[i] = array[i], array[r]
  end
  return array
end

def random_permutation(cities)
  return shuffle!(Array.new(cities.length){|i|i})
end

def two_opt(permutation)
  perm = Array.new(permutation)
  c1, c2 = rand(perm.length), rand(perm.length)
  c2 = rand(perm.length) while c1 == c2
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm
end

def search(numIterations, cities)
  best = {}
  best[:vector] = random_permutation(cities)
  # best[:vector] = OPTIMAL_TOUR
  # best[:vector] = Array.new(best[:vector].length){|x|best[:vector][x]-1}
  
  best[:cost] = cost(best[:vector], cities)
  numIterations.times do |iter|
    candidate = {}
    candidate[:vector] = two_opt(best[:vector])
    candidate[:cost] = cost(candidate[:vector], cities)
    best = candidate if best.nil? or candidate[:cost] < best[:cost]
    puts " > iteration #{(iter+1)}, best: c=#{best[:cost]}, v=#{best[:vector].inspect}"
  end
  return best
end

best = search(NUM_ITERATIONS, BERLIN52)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"