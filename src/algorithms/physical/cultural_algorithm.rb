# Cultural Algorithm in the Ruby Programming Language

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

def random_gaussian
  u1 = u2 = w = g1 = g2 = 0
  begin
    u1 = 2 * rand() - 1
    u2 = 2 * rand() - 1
    w = u1 * u1 + u2 * u2
  end while w >= 1
  w = Math.sqrt((-2 * Math.log(w)) / w)
  g2, g1 = u1 * w, u2 * w
  return g1
end

def mutate(candidate, search_space, lrate)
  vector = Array.new(candidate.size)
  candidate[:vector].each_with_index do |v,i|
    value =  v + (lrate * random_gaussian())
    value = search_space[i][0] if value < search_space[i][0]
    value = search_space[i][1] if value > search_space[i][1]
    vector[i] = value
  end
  return {:vector=>vector}  
end
  
def binary_tournament(population)
  s1, s2 = population[rand(population.size)], population[rand(population.size)]
  return (s1[:fitness] > s2[:fitness]) ? s1 : s2
end

def search(max_gens, problem_size, search_space, pop_size, lrate)
  pop = Array.new(pop_size) { {:vector=>random_vector(problem_size, search_space)} }
  pop.each{|c| c[:fitness] = objective_function(c[:vector])}
  best = pop.sort{|x,y| x[:fitness] <=> y[:fitness]}.first
  max_gens.times do |gen|    
    children = Array.new(pop_size) {|i| mutate(pop[i], search_space, lrate)}
    children.each{|c| c[:fitness] = objective_function(c[:vector])}    
    union = children + pop
    union.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = union.first if union.first[:fitness] < best[:fitness]
    pop = union[0...pop_size]
    puts " > generation=#{gen}, f=#{best[:fitness]}"
  end  
  return best
end

if __FILE__ == $0
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  max_generations = 200
  population_size = 100
  lrate = 0.005

  best = search(max_generations, problem_size, search_space, population_size, lrate)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end