# Reactive Tabu Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

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

# def generate_initial_solution(cities)
#   best = {}
#   best[:vector] = random_permutation(cities)
#   best[:cost] = cost(best[:vector], cities)
#   return best
# end

def stochastic_two_opt(permutation)
  perm = Array.new(permutation)
  c1, c2 = rand(perm.length), rand(perm.length)
  c2 = rand(perm.length) while c1 == c2
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm, [[permutation[c1-1], permutation[c1]], [permutation[c2-1], permutation[c2]]]
end

def generate_initial_solution(cities, maxNoImprovements)
  best = {}
  best[:vector] = random_permutation(cities)
  best[:cost] = cost(best[:vector], cities)
  noImprovements = 0
  begin
    candidate = {}
    candidate[:vector] = stochastic_two_opt(best[:vector])[0]
    candidate[:cost] = cost(candidate[:vector], cities)
    if candidate[:cost] <= best[:cost]
      noImprovements, best = 0, candidate
    else
      noImprovements += 1      
    end
  end until noImprovements >= maxNoImprovements
  return best
end

def is_tabu?(edges, tabuList, iteration, prohibitionPeriod)
  tabuList.each do |entry|
    if entry[:edge] == edges
      if entry[:iteration] >= iteration-prohibitionPeriod
        return true
      else 
        return false
      end
    end
  end
  return false
end

def make_tabu(tabuList, edge, iteration)
  tabuList.each do |entry|
    if entry[:edge] == edge
      entry[:iteration] = iteration
      return entry
    end
  end
  entry = {}
  entry[:edge] = edge
  entry[:iteration] = iteration
  tabuList.push(entry)
  return entry
end

def to_edge_list(permutation)
  list = []
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    c1, c2 = c2, c1 if c1 > c2
    list << [c1, c2]
  end
  return list
end

def equivalent_permutations(edgelist1, edgelist2)
  edgelist1.each do |edge|
    return false if !edgelist2.include?(edge)
  end
  return true
end

def swap(permutation)
  perm = Array.new(permutation)
  c1, c2 = rand(perm.length), rand(perm.length)
  c2 = rand(perm.length) while c1 == c2
  perm[c1], perm[c2] = perm[c2], perm[c1]
  return permutation, [c1, c2]
end

def generate_candidate(best, cities)
  candidate = {}
  candidate[:vector], edges = swap(best[:vector])
  candidate[:cost] = cost(candidate[:vector], cities)
  return candidate, edges
end

def get_candidate_entry(visitedList, permutation)
  edgeList = to_edge_list(permutation)
  visitedList.each do |entry|
    return entry if equivalent_permutations(edgeList, entry[:edgelist])
  end
  return nil
end

def store_permutation(visitedList, permutation, iteration)
  entry = {}
  entry[:edgelist] = to_edge_list(permutation)
  entry[:iteration] = iteration
  entry[:visits] = 1
  visitedList.push(entry)
  return entry
end

def sort_neighbourhood(candidates, tabuList, prohibitionPeriod, iteration)
  tabu, admissable = [], []
  candidates.each do |a|
    if is_tabu?(a[1], tabuList, iteration, prohibitionPeriod)
      tabu << a
    else
      admissable << a
    end
  end
  return tabu, admissable
end

def search(cities, maxNoImprove, candidateListSize, maxIterations, increase, decrease)
  current = generate_initial_solution(cities, maxNoImprove)
  best = current
  tabuList, prohibitionPeriod = [], 10
  visitedList, avgLength, lastChange = [], 1, 0
  maxIterations.times do |iter|
    candidates = Array.new(candidateListSize) {|i| generate_candidate(current, cities)}
    candidates.sort! {|x,y| x.first[:cost] <=> y.first[:cost]}        
    # best move
    tabu, admissible = sort_neighbourhood(candidates, tabuList, prohibitionPeriod, iter)
    if admissible.length < 2
      prohibitionPeriod = cities.length-2
      lastChange = iter
    end
    # make move
    if !admissible.empty?
      current, bestMoveEdges = admissible.first
      # current, bestMoveEdges = tabu.first if !tabu.empty? and tabu.first[0][:cost]<current[:cost]
    else
      current, bestMoveEdges = tabu.first
    end
    # updates
    make_tabu(tabuList, bestMoveEdges, iter)
    puts "tabuList=#{tabuList.length}, prohibitionPeriod=#{prohibitionPeriod}"
    best = candidates.first[0] if candidates.first[0][:cost] < best[:cost]
    
    
    # dear self, i'm in the process of going back to 2opt for the moves, given swap is pox!
    
    #     # memory based reaction
    #     candidateEntry = get_candidate_entry(visitedList, current[:vector])
    #     if !candidateEntry.nil?
    #       repetitionInterval = iter - candidateEntry[:iteration]
    #       candidateEntry[:iteration] = iter
    #       candidateEntry[:visits] += 1
    #       if repetitionInterval < 2*(cities.length-1)
    #         avgLength = 0.1*(iter-candidateEntry[:iteration]) + 0.9*avgLength
    #         prohibitionPeriod = prohibitionPeriod*increase
    #         lastChange = iter
    #       end
    #     else
    #       store_permutation(visitedList, current[:vector], iter)
    #     end
    #     if iter-lastChange > avgLength
    #       prohibitionPeriod = [prohibitionPeriod*decrease,1].max
    #       lastChange = iter
    #     end
    puts " > iteration #{(iter+1)}, best: c=#{best[:cost]}"
  end
  return best
end

MAX_ITERATIONS = 100
MAX_NO_IMPROVE = 50
MAX_CANDIDATES = 50
INCREASE = 1.1
DECREASE = 0.9
BERLIN52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],[525,1000],
 [580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],[845,680],[725,370],[145,665],
 [415,635],[510,875],[560,365],[300,465],[520,585],[480,415],[835,625],[975,580],[1215,245],
 [1320,315],[1250,400],[660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
 [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],[875,920],[700,500],
 [555,815],[830,485],[1170,65],[830,610],[605,625],[595,360],[1340,725],[1740,245]]

best = search(BERLIN52, MAX_NO_IMPROVE, MAX_CANDIDATES, MAX_ITERATIONS, INCREASE, DECREASE)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"