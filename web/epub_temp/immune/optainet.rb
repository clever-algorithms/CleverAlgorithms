# Optimization Artificial Immune Network (opt-aiNet) in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum + (x**2.0)}
end

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
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

def mutation_rate(beta, normalized_cost)
  return (1.0/beta) * Math.exp(-normalized_cost)
end

def mutate(beta, child, normalized_cost)
  child[:vector].each_with_index do |v, i|
    alpha = mutation_rate(beta, normalized_cost)
    child[:vector][i] = v + alpha * random_gaussian()
  end
end

def clone_cell(beta, num_clones, parent)
  clones = Array.new(num_clones) {clone(parent)}
  clones.each {|clone| mutate(beta, clone, parent[:norm_cost])}
  clones.each{|c| c[:cost] = objective_function(c[:vector])}
  clones.sort!{|x,y| x[:cost] <=> y[:cost]}
  return clones.first
end

def calculate_normalized_cost(pop)
  pop.sort!{|x,y| x[:cost]<=>y[:cost]}
  range = pop.last[:cost] - pop.first[:cost]
  if range == 0.0
    pop.each {|p| p[:norm_cost] = 1.0}
  else
    pop.each {|p| p[:norm_cost] = 1.0-(p[:cost]/range)}
  end
end

def average_cost(pop)
  sum = pop.inject(0.0){|sum,x| sum + x[:cost]}
  return sum / pop.size.to_f
end

def distance(c1, c2)
  sum = 0.0
  c1.each_index {|i| sum += (c1[i]-c2[i])**2.0}
  return Math.sqrt(sum)
end

def get_neighborhood(cell, pop, aff_thresh)
  neighbors = []
  pop.each do |p|
    neighbors << p if distance(p[:vector], cell[:vector]) < aff_thresh
  end
  return neighbors
end

def affinity_supress(population, aff_thresh)
  pop = []
  population.each do |cell|
    neighbors = get_neighborhood(cell, population, aff_thresh)
    neighbors.sort!{|x,y| x[:cost] <=> y[:cost]}
    pop << cell if neighbors.empty? or cell.equal?(neighbors.first)
  end  
  return pop
end

def search(search_space, max_gens, pop_size, num_clones, beta, num_rand, aff_thresh)
  pop = Array.new(pop_size) {|i| {:vector=>random_vector(search_space)} }
  pop.each{|c| c[:cost] = objective_function(c[:vector])}
  best = nil
  max_gens.times do |gen|
    pop.each{|c| c[:cost] = objective_function(c[:vector])}
    calculate_normalized_cost(pop)
    pop.sort!{|x,y| x[:cost] <=> y[:cost]}
    best = pop.first if best.nil? or pop.first[:cost] < best[:cost]
    avgCost, progeny = average_cost(pop), nil
    begin
      progeny=Array.new(pop.size){|i| clone_cell(beta, num_clones, pop[i])}
    end until average_cost(progeny) < avgCost
    pop = affinity_supress(progeny, aff_thresh)
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
  max_gens = 150
  pop_size = 20
  num_clones = 10
  beta = 100
  num_rand = 2
  aff_thresh = (search_space[0][1]-search_space[0][0])*0.05
  # execute the algorithm
  best = search(search_space, max_gens, pop_size, num_clones, beta, num_rand, aff_thresh)
  puts "done! Solution: f=#{best[:cost]}, s=#{best[:vector].inspect}"
end