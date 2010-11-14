# Ant System in the Ruby Programming Language

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

def initialise_pheromone_matrix(num_cities, naive_score)
  v = num_cities.to_f / naive_score
  return Array.new(num_cities){|i| Array.new(num_cities, v)}
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

def calculate_choices(cities, last_city, exclude, pheromone, c_heuristic, c_history)
  choices = []
  cities.each_with_index do |coord, i|
    next if exclude.include?(i)
    prob = {:city=>i}
    prob[:history] = pheromone[last_city][i] ** c_history
    prob[:distance] = euc_2d(cities[last_city], coord)
    prob[:heuristic] = (1.0/prob[:distance]) ** c_heuristic
    prob[:prob] = prob[:history] * prob[:heuristic]
    choices << prob
  end
  choices
end

def select_next_city(choices)
  sum = choices.inject(0.0){|sum,element| sum + element[:prob]}
  return choices[rand(choices.length)][:city] if sum == 0.0
  v, next_city = rand(), -1
  choices.each_with_index do |choice, i|
    if i==choices.length-1
      next_city = choice[:city] 
    else
      v -= (choice[:prob]/sum)
      if v <= 0.0 
        next_city = choice[:city] 
        break
      end
    end
  end
  return next_city
end

def stepwise_construction(cities, pheromone, c_heuristic, c_history)
  perm = []
  perm << rand(cities.length)
  begin
    choices = calculate_choices(cities, perm.last, perm, pheromone, c_heuristic, c_history)
    next_city = select_next_city(choices)
    perm << next_city
  end until perm.length == cities.length
  return perm
end

def decay_pheromone(pheromone, decay_factor)
  pheromone.each do |array|
    array.each_with_index do |p, i|
      array[i] = (1.0 - decay_factor) * p
    end
  end
end

def update_pheromone(pheromone, solutions)
  solutions.each do |candidate|
    update = 1.0 / candidate[:cost]
    candidate[:vector].each_with_index do |x, i|
      y = (i==candidate[:vector].length-1) ? candidate[:vector][0] : candidate[:vector][i+1]
      pheromone[x][y] += d
      pheromone[y][x] += d
    end
  end
end

def search(cities, max_iterations, num_ants, decay_factor, c_heuristic, c_history)
  best = nearest_neighbor_solution(cities)
  puts "Nearest Neighbor heuristic solution: cost=#{best[:cost]}"
  pheromone = initialise_pheromone_matrix(cities.length, best[:cost])
  max_iterations.times do |iter|
    solutions = []
    num_ants.times do
      candidate = {}
      candidate[:vector] = stepwise_construction(cities, pheromone, c_heuristic, c_history)
      candidate[:cost] = cost(candidate[:vector], cities)
      best = candidate if candidate[:cost] < best[:cost]
    end
    decay_pheromone(pheromone, decay_factor)
    update_pheromone(pheromone, solutions)
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
  max_iterations = 50
  num_ants = berlin52.length
  decay_factor = 0.5
  c_heuristic = 2.5
  c_history = 1.0

  best = search(berlin52, max_iterations, num_ants, decay_factor, c_heuristic, c_history)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end