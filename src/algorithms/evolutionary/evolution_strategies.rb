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

def random_gaussian
  u1 = u2 = w = g1 = g2 = 0
  begin
    u1 = 2 * rand() - 1
    u2 = 2 * rand() - 1
    w = u1 * u1 + u2 * u2
  end while w >= 1
  w = Math::sqrt((-2 * Math::log(w)) / w)
  g2 = u1 * w;
  g1 = u2 * w;
  return g1
end

def mutate(candidate, search_space)
  child = {}
  tau = search_space.length.to_f**-0.5
  child[:strategy] = []
  candidate[:strategy].each do |s_old|
    child[:strategy] << s_old * Math::exp(tau * random_gaussian())
  end
  child[:vector] = []
  candidate[:vector].each_with_index do |v_old,i|
    v = v_old + child[:strategy][i] * random_gaussian()
    v = search_space[i][0] if v < search_space[i][0]
    v = search_space[i][1] if v > search_space[i][1]
    child[:vector] << v
  end
  return child
end

def search(max_generations, problem_size, search_space, pop_size, num_children)
  strategy_space = Array.new(problem_size) do |i| 
    [0, (search_space[i][1]-search_space[i][0])*0.02]
  end
  population = Array.new(pop_size) do |i|
    {:vector=>random_vector(problem_size, search_space), 
      :strategy=>random_vector(problem_size, strategy_space)}
  end
  population.each{|c| c[:fitness] = objective_function(c[:vector])}
  gen, best = 0, population.sort{|x,y| x[:fitness] <=> y[:fitness]}.first  
  max_generations.times do |gen|
    children = Array.new(num_children) {|i| mutate(population[i], search_space)}
    children.each{|c| c[:fitness] = objective_function(c[:vector])}
    union = children+population
    union.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = union.first if union.first[:fitness] < best[:fitness]
    population = union[0...pop_size]
    puts " > gen #{gen}, fitness=#{best[:fitness]}"
  end  
  return best
end

max_generations = 200
pop_size = 30
num_children = 20
problem_size = 2
search_space = Array.new(problem_size) {|i| [-5, +5]}

best = search(max_generations, problem_size, search_space, pop_size, num_children)
puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"