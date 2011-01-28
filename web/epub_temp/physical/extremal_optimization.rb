# Extremal Optimization in the Ruby Programming Language

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

def calculate_neighbor_rank(city_number, cities, ignore=[])
  neighbors = []
  cities.each_with_index do |city, i|
    next if i==city_number or ignore.include?(i)
    neighbor = {:number=>i}
    neighbor[:distance] = euc_2d(cities[city_number], city)
    neighbors << neighbor
  end
  return neighbors.sort!{|x,y| x[:distance] <=> y[:distance]}
end

def get_edges_for_city(city_number, permutation)
  c1, c2 = nil, nil
  permutation.each_with_index do |c, i|
    if c == city_number
      c1 = (i==0) ? permutation.last : permutation[i-1]
      c2 = (i==permutation.size-1) ? permutation.first : permutation[i+1]
      break
    end
  end
  return [c1, c2]
end

def calculate_city_fitness(permutation, city_number, cities)
  c1, c2 = get_edges_for_city(city_number, permutation)
  neighbors = calculate_neighbor_rank(city_number, cities)
  n1, n2 = -1, -1
  neighbors.each_with_index do |neighbor,i|
    n1 = i+1 if neighbor[:number] == c1
    n2 = i+1 if neighbor[:number] == c2
    break if n1!=-1 and n2!=-1
  end
  return 3.0 / (n1.to_f + n2.to_f)
end

def calculate_city_fitnesses(cities, permutation)
  city_fitnesses = []
  cities.each_with_index do |city, i|
    city_fitness = {:number=>i}
    city_fitness[:fitness] = calculate_city_fitness(permutation, i, cities)
    city_fitnesses << city_fitness
  end
  return city_fitnesses.sort!{|x,y| y[:fitness] <=> x[:fitness]}
end

def calculate_component_probabilities(ordered_components, tau)
  sum = 0.0
  ordered_components.each_with_index do |component, i|
    component[:prob] = (i+1.0)**(-tau)
    sum += component[:prob]    
  end
  return sum
end

def make_selection(components, sum_probability)
  selection = rand()
  components.each_with_index do |component, i|
    selection -= (component[:prob] / sum_probability)
    return component[:number] if selection <= 0.0
  end
  return components.last[:number]
end

def probabilistic_selection(ordered_components, tau, exclude=[])
  sum = calculate_component_probabilities(ordered_components, tau)  
  selected_city = nil
  begin
    selected_city = make_selection(ordered_components, sum) 
  end while exclude.include?(selected_city)
  return selected_city
end

def vary_permutation(permutation, selected, new, long_edge)
  perm = Array.new(permutation)
  c1, c2 = perm.rindex(selected), perm.rindex(new)
  p1,p2 = (c1<c2) ? [c1,c2] : [c2,c1]
  right = (c1==perm.size-1) ? 0 : c1+1
  if perm[right] == long_edge
    perm[p1+1..p2] = perm[p1+1..p2].reverse
  else 
    perm[p1...p2] = perm[p1...p2].reverse
  end
  return perm
end

def get_long_edge(edges, neighbor_distances)
  n1 = neighbor_distances.find {|x| x[:number]==edges[0]}
  n2 = neighbor_distances.find {|x| x[:number]==edges[1]}
  return (n1[:distance] > n2[:distance]) ? n1[:number] : n2[:number]
end

def create_new_perm(cities, tau, perm)
  city_fitnesses = calculate_city_fitnesses(cities, perm)
  selected_city = probabilistic_selection(city_fitnesses.reverse, tau)
  edges = get_edges_for_city(selected_city, perm)
  neighbors = calculate_neighbor_rank(selected_city, cities)
  new_neighbor = probabilistic_selection(neighbors, tau, edges)
  long_edge = get_long_edge(edges, neighbors)
  return vary_permutation(perm, selected_city, new_neighbor, long_edge)
end

def search(cities, max_iterations, tau)
  current = {:vector=>random_permutation(cities)}
  current[:cost] = cost(current[:vector], cities)
  best = current
  max_iterations.times do |iter|
    candidate = {}
    candidate[:vector] = create_new_perm(cities, tau, current[:vector])
    candidate[:cost] = cost(candidate[:vector], cities)
    current = candidate
    best = candidate if candidate[:cost] < best[:cost]
    puts " > iter #{(iter+1)}, curr=#{current[:cost]}, best=#{best[:cost]}"
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
  max_iterations = 250
  tau = 1.8
  # execute the algorithm
  best = search(berlin52, max_iterations, tau)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
