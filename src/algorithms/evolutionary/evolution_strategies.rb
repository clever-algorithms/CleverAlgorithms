# Evolution Strategies algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_vector(problem_size, search_space)
  return Array.new(problem_size) do |i|      
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

def mutate_problem(vector, stdevs, search_space)
  child = Array(vector.length)
  vector.each_with_index do |v, i|
    child[i] = v + stdevs[i] * random_gaussian()
    child[i] = search_space[i][0] if child[i] < search_space[i][0]
    child[i] = search_space[i][1] if child[i] > search_space[i][1]
  end
  return child
end

def mutate_strategy(stdevs)
  tau = Math.sqrt(2.0*stdevs.length.to_f)**-1.0
  tau_prime = Math.sqrt(2.0*Math.sqrt(stdevs.length.to_f))**-1.0
  child = Array.new(stdevs.length) do |i|
    stdevs[i] * Math.exp(tau_prime*random_gaussian() + tau*random_gaussian())
  end
  return child
end

def mutate(parent, search_space)
  child = {}
  child[:vector] = mutate_problem(parent[:vector], parent[:strategy], search_space)
  child[:strategy] = mutate_strategy(parent[:strategy])
  return child
end

def search(max_generations, problem_size, search_space, pop_size, num_children)
  strategy_space = Array.new(problem_size) do |i| 
    [0, (search_space[i][1]-search_space[i][0])*0.05]
  end
  population = Array.new(pop_size) do |i|
    {:vector=>random_vector(problem_size, search_space), 
      :strategy=>random_vector(problem_size, strategy_space)}
  end
  population.each{|c| c[:fitness] = objective_function(c[:vector])}
  best = population.sort{|x,y| x[:fitness] <=> y[:fitness]}.first  
  max_generations.times do |gen|
    children = Array.new(num_children) {|i| mutate(population[i], search_space)}
    children.each{|c| c[:fitness] = objective_function(c[:vector])}
    union = children+population
    union.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = union.first
    population = union[0...pop_size]
    puts " > gen #{gen}, fitness=#{best[:fitness]}"
  end  
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_generations = 100
  pop_size = 30
  num_children = 20  
  # execute the algorithm
  best = search(max_generations, problem_size, search_space, pop_size, num_children)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end