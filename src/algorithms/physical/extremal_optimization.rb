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

def nearest_neighbor_solution(cities)
  candidate = {}
  candidate[:vector] = [rand(cities.length)]
  all_cities = Array.new(cities.length) {|i| i}
  while candidate[:vector].length < cities.length
    next_city = {:city=>nil,:dist=>nil}
    candidates = all_cities - candidate[:vector]
    candidates.each do |city|
      dist = euc_2d(cities[candidate[:vector].last], city)
      if next_city[:city].nil? or next_city[:dist] < dist
        next_city[:city] = city
        next_city[:dist] = dist
      end
    end
    candidate[:vector] << next_city[:city]
  end
  candidate[:cost] = cost(candidate[:vector], cities)  
  return candidate
end

def calculate_neighbour_order(city_number, cities)
  city_distances = []
  cities.each_with_index do |city, i|
    next if i == city_number
    c = {}
    c[:number] = i
    c[:distance] = euc_2d(cities[city_number], cities[i])
    city_distances << c
  end
  city_distances.sort!{|x,y| x[:distance] <=> y[:distance]}
  return city_distances
end

def get_edges_for_city(city_number, permutation)
  c1, c2 = -1, -1
  permutation.each_with_index do |c, i|
    if c == city_number
      c1 = (i==0) ? permutation.last : permutation[i-1]
      c2 = (c==permutation.length-1) ? permutation[0] : permutation[i+1]
      break
    end
  end
  raise "error" if c1==-1 or c2==-1
  return [c1, c2]
end

def calculate_city_fitness(permutation, city_number, cities)
  c1, c2 = get_edges_for_city(city_number, permutation)
  neighbors = calculate_neighbour_order(city_number, cities)
  n1, n2 = -1, -1
  neighbors.each_with_index do |neighbor,i|
    n1 = i+1 if neighbor[:number] == c1
    n2 = i+1 if neighbor[:number] == c2
  end
  raise "error" if n1==-1 or n2==-1
  return 3.0 / (n1.to_f + n2.to_f)
end

def probabilistically_select_city_number(ordered_choices, tau, ignore=[])
  sum = 0.0
  ordered_choices.each_with_index do |city, i|
    sum += (i.to_f + 1.0)**-tau if !ignore.include?(i)
  end
  choice, city_number = rand(), -1
  ordered_choices.each_with_index do |city, i|
    next if ignore.include?(i)
    choice -= ((i.to_f + 1.0)**-tau) / sum
    if choice <= 0
      city_number = city[:number]
      break
    end
  end
  city_number = ordered_choices.last[:number] if city_number == -1
  return city_number
end

def create_candidate(permutation, cities, selected_city, tau)
  c1, c2 = get_edges_for_city(selected_city, permutation)
  d1 = euc_2d(cities[selected_city], cities[c1])
  d2 = euc_2d(cities[selected_city], cities[c2])
  p1 = (d1 < d2) ? c2 : c1  
  neighbors = calculate_neighbour_order(selected_city, cities)
  p2 = probabilistically_select_city_number(neighbors, tau, [selected_city, p1])
  perm = Array.new(permutation)
  puts ">before: #{perm.inspect}, selected_city=#{selected_city}, p1=#{p1}, p2=#{p2}"
  perm[p1...p2] = perm[p1...p2].reverse
  puts ">after: #{perm.inspect}"
  return perm
end

def calculate_city_fitnesses(cities, permutation)
  city_fitness = []
  cities.each_with_index do |city, i|
    c = {}
    c[:number] = i
    c[:fitness] = calculate_city_fitness(permutation, i, cities)
    city_fitness << c
  end
  city_fitness.sort!{|x,y| x[:fitness] <=> y[:fitness]}
  return city_fitness
end

def search(cities, max_iter, tau)
  current = nearest_neighbor_solution(cities)
  best = current
  puts "Nearest Neighbor heuristic solution: cost=#{current[:cost]}"  
  max_iter.times do |iter|
    city_fitnesses = calculate_city_fitnesses(cities, current[:vector])
    selected_city = probabilistically_select_city_number(city_fitnesses, tau)
    candidate = {}
    candidate[:vector] = create_candidate(current[:vector], cities, selected_city, tau)
    candidate[:cost] = cost(candidate[:vector], cities)    
    current = candidate
    best = candidate if candidate[:cost] < best[:cost]    
    puts " > iteration #{(iter+1)}, best=#{best[:cost]}"
  end
  return best
end

if __FILE__ == $0
  berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],
   [525,1000],[580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],
   [845,680],[725,370],[145,665],[415,635],[510,875],[560,365],[300,465],
   [520,585],[480,415],[835,625],[975,580],[1215,245],[1320,315],[1250,400],
   [660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
   [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],
   [875,920],[700,500],[555,815],[830,485],[1170,65],[830,610],[605,625],
   [595,360],[1340,725],[1740,245]]
  max_iterations = 3
  tau = 4.0
  
  best = search(berlin52, max_iterations, tau)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end