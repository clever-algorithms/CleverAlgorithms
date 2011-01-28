# Reactive Tabu Search algorithm in the Ruby Programming Language

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

def is_tabu?(edge, tabu_list, iter, prohib_period)
  tabu_list.each do |entry|
    if entry[:edge] == edge
      return true if entry[:iter] >= iter-prohib_period
      return false
    end
  end
  return false
end

def make_tabu(tabu_list, edge, iter)
  tabu_list.each do |entry|
    if entry[:edge] == edge
      entry[:iter] = iter
      return entry
    end
  end
  entry = {:edge=>edge, :iter=>iter}
  tabu_list.push(entry)
  return entry
end

def to_edge_list(perm)
  list = []
  perm.each_with_index do |c1, i|
    c2 = (i==perm.size-1) ? perm[0] : perm[i+1]
    c1, c2 = c2, c1 if c1 > c2
    list << [c1, c2]
  end
  return list
end

def equivalent?(el1, el2)
  el1.each {|e| return false if !el2.include?(e) }
  return true
end

def generate_candidate(best, cities)
  candidate = {}
  candidate[:vector], edges = stochastic_two_opt(best[:vector])
  candidate[:cost] = cost(candidate[:vector], cities)
  return candidate, edges
end

def get_candidate_entry(visited_list, permutation)
  edgeList = to_edge_list(permutation)
  visited_list.each do |entry|
    return entry if equivalent?(edgeList, entry[:edgelist])
  end
  return nil
end

def store_permutation(visited_list, permutation, iteration)
  entry = {}
  entry[:edgelist] = to_edge_list(permutation)
  entry[:iter] = iteration
  entry[:visits] = 1
  visited_list.push(entry)
  return entry
end

def sort_neighborhood(candidates, tabu_list, prohib_period, iteration)
  tabu, admissable = [], []
  candidates.each do |a|
    if is_tabu?(a[1][0], tabu_list, iteration, prohib_period) or
       is_tabu?(a[1][1], tabu_list, iteration, prohib_period)
      tabu << a
    else
      admissable << a
    end
  end
  return [tabu, admissable]
end

def search(cities, max_cand, max_iter, increase, decrease)
  current = {:vector=>random_permutation(cities)}
  current[:cost] = cost(current[:vector], cities)
  best = current
  tabu_list, prohib_period = [], 1
  visited_list, avg_size, last_change = [], 1, 0
  max_iter.times do |iter|
    candidate_entry = get_candidate_entry(visited_list, current[:vector])
    if !candidate_entry.nil?
      repetition_interval = iter - candidate_entry[:iter]
      candidate_entry[:iter] = iter
      candidate_entry[:visits] += 1
      if repetition_interval < 2*(cities.size-1)
        avg_size = 0.1*(iter-candidate_entry[:iter]) + 0.9*avg_size
        prohib_period = (prohib_period.to_f * increase)
        last_change = iter
      end
    else
      store_permutation(visited_list, current[:vector], iter)
    end
    if iter-last_change > avg_size
      prohib_period = [prohib_period*decrease,1].max
      last_change = iter
    end
    candidates = Array.new(max_cand) do |i| 
      generate_candidate(current, cities)
    end
    candidates.sort! {|x,y| x.first[:cost] <=> y.first[:cost]}        
    tabu,admis = sort_neighborhood(candidates,tabu_list,prohib_period,iter)
    if admis.size < 2
      prohib_period = cities.size-2
      last_change = iter
    end
    current,best_move_edges = (admis.empty?) ? tabu.first : admis.first
    if !tabu.empty? 
      tf = tabu.first[0]
      if tf[:cost]<best[:cost] and tf[:cost]<current[:cost]
        current, best_move_edges = tabu.first
      end
    end
    best_move_edges.each {|edge| make_tabu(tabu_list, edge, iter)}
    best = candidates.first[0] if candidates.first[0][:cost] < best[:cost]
    puts " > it=#{iter}, tenure=#{prohib_period.round}, best=#{best[:cost]}"
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
  max_candidates = 50
  increase = 1.3
  decrease = 0.9
  # execute the algorithm
  best = search(berlin52, max_candidates, max_iter, increase, decrease)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
