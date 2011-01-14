# Tabu Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def euc_2d(c1, c2)
  Math.sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def cost(perm, cities)
  distance = 0
  perm.each_with_index do |c1, i|
    c2 = (i==perm.size-1) ? perm[0] : perm[i+1]
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

def stochastic_two_opt(parent)
  perm = Array.new(parent)
  c1, c2 = rand(perm.size), rand(perm.size)
  exclude = [c1]
  exclude << ((c1==0) ? perm.size-1 : c1-1)
  exclude << ((c1==perm.size-1) ? 0 : c1+1)
  c2 = rand(perm.size) while exclude.include?(c2)
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm, [[parent[c1-1], parent[c1]], [parent[c2-1], parent[c2]]]
end

def is_tabu?(permutation, tabu_list)
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.size-1) ? permutation[0] : permutation[i+1]
    tabu_list.each do |forbidden_edge|
      return true if forbidden_edge == [c1, c2]
    end
  end
  return false
end

def generate_candidate(best, tabu_list, cities)
  perm, edges = nil, nil
  begin
    perm, edges = stochastic_two_opt(best[:vector])
  end while is_tabu?(perm, tabu_list)  
  candidate = {:vector=>perm}
  candidate[:cost] = cost(candidate[:vector], cities)
  return candidate, edges
end

def search(cities, tabu_list_size, candidate_list_size, max_iter)
  current = {:vector=>random_permutation(cities)}
  current[:cost] = cost(current[:vector], cities)
  best = current
  tabu_list = Array.new(tabu_list_size)
  max_iter.times do |iter|
    candidates = Array.new(candidate_list_size) do |i|
      generate_candidate(current, tabu_list, cities)
    end
    candidates.sort! {|x,y| x.first[:cost] <=> y.first[:cost]}
    best_candidate = candidates.first[0]
    best_candidate_edges = candidates.first[1]
    if best_candidate[:cost] < current[:cost]
      current = best_candidate
      best = best_candidate if best_candidate[:cost] < best[:cost]
      best_candidate_edges.each {|edge| tabu_list.push(edge)}
      tabu_list.pop while tabu_list.size > tabu_list_size
    end
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
  max_iter = 100
  tabu_list_size = 15
  max_candidates = 50
  # execute the algorithm
  best = search(berlin52, tabu_list_size, max_candidates, max_iter)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end