# Evolution Strategies algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
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

def mutate_problem(vector, stdevs, search_space)
  child = Array(vector.size)
  vector.each_with_index do |v, i|
    child[i] = v + stdevs[i] * random_gaussian()
    child[i] = search_space[i][0] if child[i] < search_space[i][0]
    child[i] = search_space[i][1] if child[i] > search_space[i][1]
  end
  return child
end

def mutate_strategy(stdevs)
  tau = Math.sqrt(2.0*stdevs.size.to_f)**-1.0
  tau_p = Math.sqrt(2.0*Math.sqrt(stdevs.size.to_f))**-1.0
  child = Array.new(stdevs.size) do |i|
    stdevs[i] * Math.exp(tau_p*random_gaussian() + tau*random_gaussian())
  end
  return child
end

def mutate(par, minmax)
  child = {}
  child[:vector] = mutate_problem(par[:vector], par[:strategy], minmax)
  child[:strategy] = mutate_strategy(par[:strategy])
  return child
end

def init_population(minmax, pop_size)
  strategy = Array.new(minmax.size) do |i| 
    [0,  (minmax[i][1]-minmax[i][0]) * 0.05]
  end
  pop = Array.new(pop_size) { Hash.new }
  pop.each_index do |i|
    pop[i][:vector] = random_vector(minmax)
    pop[i][:strategy] = random_vector(strategy)
  end
  pop.each{|c| c[:fitness] = objective_function(c[:vector])}
  return pop
end

def search(max_gens, search_space, pop_size, num_children)
  population = init_population(search_space, pop_size)
  best = population.sort{|x,y| x[:fitness] <=> y[:fitness]}.first  
  max_gens.times do |gen|
    children = Array.new(num_children) do |i| 
      mutate(population[i], search_space)
    end
    children.each{|c| c[:fitness] = objective_function(c[:vector])}
    union = children+population
    union.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = union.first if union.first[:fitness] < best[:fitness]
    population = union.first(pop_size)
    puts " > gen #{gen}, fitness=#{best[:fitness]}"
  end  
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_gens = 100
  pop_size = 30
  num_children = 20  
  # execute the algorithm
  best = search(max_gens, search_space, pop_size, num_children)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end
