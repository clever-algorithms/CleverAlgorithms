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
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    distance += euc_2d(cities[c1], cities[c2])
  end
  return distance
end

def calculate_neighbour_rank(city_number, cities, ignore=[])
  neighbors = []
  cities.each_with_index do |city, i|
    next if i==city_number or ignore.include?(i)
    neighbor = {:number=>i}
    neighbor[:distance] = euc_2d(cities[city_number], city)
    neighbors << neighbor
  end
  neighbors.sort!{|x,y| x[:distance] <=> y[:distance]}
  return neighbors
end

def nearest_neighbor_solution(cities)
  perm = [rand(cities.length)]
  while perm.length < cities.length
    neighbors = calculate_neighbour_rank(perm.last, cities, perm)
    perm << neighbors.first[:number]
  end  
  return perm
end

def get_edges_for_city(city_number, permutation)
  c1, c2 = -1, -1
  permutation.each_with_index do |c, i|
    if c == city_number
      c1 = (i==0) ? permutation.last : permutation[i-1]
      c2 = (i==permutation.length-1) ? permutation.first : permutation[i+1]
      break
    end
  end
  raise "error" if c1==-1 or c2==-1
  return [c1, c2]
end

def calculate_city_fitness(permutation, city_number, cities)
  c1, c2 = get_edges_for_city(city_number, permutation)
  neighbors = calculate_neighbour_rank(city_number, cities)
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
  city_fitnesses.sort!{|x,y| x[:fitness] <=> y[:fitness]}
  return city_fitnesses
end

def probabilistic_selection(ordered_components, tau)
  sum = 0.0
  ordered_components.each_with_index do |component, i|
    component[:prob] = (i.to_f+1.0)**(-tau)
    sum += component[:prob]    
  end
  selected_city = -1
  selection = rand()
  ordered_components.each_with_index do |component, i|
    selection -= (component[:prob]/sum)
    if selection<=0.0 or i==ordered_components.length-1
      selected_city = component[:number]
      break
    end
  end
  return selected_city
end

def select_replacement_city(cities, weak_component, tau)
  neighbors = calculate_neighbour_rank(weak_component, cities)
  return probabilistic_selection(neighbors, tau)
end

def select_weak_city(city_fitnesses, tau)
  return probabilistic_selection(city_fitnesses, tau)
end

def update_permutation(permutation, p1, p2)
  perm = Array.new(permutation)
  perm[p1...p2] = perm[p1...p2].reverse
  return perm
end

def search(cities, max_iter, tau)
  current = {:vector=>nearest_neighbor_solution(cities)}
  current[:cost] = cost(current[:vector], cities)
  best = current
  max_iter.times do |iter|
    city_fitnesses = calculate_city_fitnesses(cities, current[:vector])
    weak_c = select_weak_city(city_fitnesses, tau)
    replacement_c = select_replacement_city(cities, weak_c, tau)
    candidate = {}
    candidate[:vector] = update_permutation(current[:vector], weak_c, replacement_c)
    candidate[:cost] = cost(candidate[:vector], cities)
    current = candidate
    best = candidate if candidate[:cost] < best[:cost]
    puts " > iteration #{(iter+1)}, current=#{current[:cost]}, best=#{best[:cost]}"
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],
   [525,1000],[580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],
   [845,680],[725,370],[145,665],[415,635],[510,875],[560,365],[300,465],
   [520,585],[480,415],[835,625],[975,580],[1215,245],[1320,315],[1250,400],
   [660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
   [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],
   [875,920],[700,500],[555,815],[830,485],[1170,65],[830,610],[605,625],
   [595,360],[1340,725],[1740,245]]
  # algorithm configuration
  max_iterations = 500
  tau = 1.2
  # execute the algorithm
  best = search(berlin52, max_iterations, tau)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end