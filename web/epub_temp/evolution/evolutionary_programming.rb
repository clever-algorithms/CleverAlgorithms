# Evolutionary Programming algorithm in the Ruby Programming Language

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

def mutate(candidate, search_space)
  child = {:vector=>[], :strategy=>[]}
  candidate[:vector].each_with_index do |v_old, i|
    s_old = candidate[:strategy][i]
    v = v_old + s_old * random_gaussian()
    v = search_space[i][0] if v < search_space[i][0]
    v = search_space[i][1] if v > search_space[i][1]
    child[:vector] << v
    child[:strategy] << s_old + random_gaussian() * s_old.abs**0.5
  end
  return child
end

def tournament(candidate, population, bout_size)
  candidate[:wins] = 0
  bout_size.times do |i|
    other = population[rand(population.size)]
    candidate[:wins] += 1 if candidate[:fitness] < other[:fitness]
  end  
end

def init_population(minmax, pop_size)
  strategy = Array.new(minmax.size) do |i| 
    [0,  (minmax[i][1]-minmax[i][0]) * 0.05]
  end
  pop = Array.new(pop_size, {})
  pop.each_index do |i|
    pop[i][:vector] = random_vector(minmax)
    pop[i][:strategy] = random_vector(strategy)
  end
  pop.each{|c| c[:fitness] = objective_function(c[:vector])}
  return pop
end

def search(max_gens, search_space, pop_size, bout_size)
  population = init_population(search_space, pop_size)
  population.each{|c| c[:fitness] = objective_function(c[:vector])}
  best = population.sort{|x,y| x[:fitness] <=> y[:fitness]}.first  
  max_gens.times do |gen|
    children = Array.new(pop_size) {|i| mutate(population[i], search_space)}
    children.each{|c| c[:fitness] = objective_function(c[:vector])}
    children.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = children.first if children.first[:fitness] < best[:fitness]
    union = children+population
    union.each{|c| tournament(c, union, bout_size)}
    union.sort!{|x,y| y[:wins] <=> x[:wins]}
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
  max_gens = 200
  pop_size = 100
  bout_size = 5
  # execute the algorithm
  best = search(max_gens, search_space, pop_size, bout_size)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end
