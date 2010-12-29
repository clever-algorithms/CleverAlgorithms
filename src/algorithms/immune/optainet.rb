# Optimization Artificial Immune Network (opt-aiNet) in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum + (x**2.0)}
end

def random_vector(search_space)
  return Array.new(search_space.size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def random_gaussian(mean=0.0, stdev=1.0)
  u1 = u2 = w = 0
  begin
    u1 = 2 * rand() - 1
    u2 = 2 * rand() - 1
    w = u1 * u1 + u2 * u2
  end while w >= 1
  w = Math.sqrt((-2.0 * Math.log(w)) / w)
  return mean + (u2 * w) * stdev
end

def clone(parent)
  v = Array.new(parent[:vector].size) {|i| parent[:vector][i]}
  return {:vector=>v}
end

def mutate(beta, child, rank)
  child[:vector].each_with_index do |v, i|
    alpha = (1.0/beta) * Math.exp(-rank)
    child[:vector][i] = v + alpha * random_gaussian 
  end
end

def clone_cell(beta, num_clones, parent, rank)
  clones = []
  num_clones.times {clones << clone(parent)}
  clones.each {|clone| mutate(beta, clone, rank)}
  clones.each{|c| c[:cost] = objective_function(c[:vector])}
  clones.sort!{|x,y| x[:cost] <=> y[:cost]}
  return clones.first
end

def average_cost(population)
  sum = 0.0
  population.each do |p| 
    sum += p[:cost]
  end
  return sum / population.size.to_f
end

def euclidean_distance(c1, c2)
  sum = 0.0
  c1.each_index {|i| sum += (c1[i]-c2[i])**2.0}  
  return Math.sqrt(sum)
end

def get_neighborhood(cell, pop, affinity_thresh)
  neighbors = []
  pop.each do |p|
    next if p.equal?(cell)
    neighbors << p if euclidean_distance(p[:vector], cell[:vector]) < affinity_thresh
  end
  return neighbors
end

def affinity_supress(population, affinity_thresh)
  pop = []
  population.each do |cell|
    neighbors = get_neighborhood(cell, population, affinity_thresh)
    neighbors.sort!{|x,y| x[:cost] <=> y[:cost]}
    pop << cell if neighbors.empty? or cell.equal?(neighbors.first)
  end  
  return pop
end

def search(search_space, max_gens, pop_size, num_clones, beta, num_rand, affinity_thresh)
  pop = Array.new(pop_size) {|i| {:vector=>random_vector(search_space)} }
  pop.each{|c| c[:cost] = objective_function(c[:vector])}
  best = nil
  max_gens.times do |gen|
    pop.each{|c| c[:cost] = objective_function(c[:vector])}
    pop.sort!{|x,y| x[:cost] <=> y[:cost]}
    best = pop.first if best.nil? or pop.first[:cost] < best[:cost]
    avgCost, progeny = average_cost(pop), nil
    begin
      progeny = []
      pop.each_with_index {|cell, i| progeny << clone_cell(beta, num_clones, cell, i+1)}
    end until average_cost(progeny) < avgCost
    pop = affinity_supress(progeny, affinity_thresh)
    num_rand.times {pop << {:vector=>random_vector(search_space)}} 
    puts " > gen #{gen+1}, popSize=#{pop.size}, fitness=#{best[:cost]}"
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_gens = 200
  pop_size = 20
  num_clones = 10
  beta = 100
  num_rand = 1
  affinity_thresh = 0.3
  # execute the algorithm
  best = search(search_space, max_gens, pop_size, num_clones, beta, num_rand, affinity_thresh)
  puts "done! Solution: f=#{best[:cost]}, s=#{best[:vector].inspect}"
end
