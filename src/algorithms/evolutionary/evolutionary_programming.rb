# Evolutionary Programming algorithm in the Ruby Programming Language

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

def mutate(candidate, search_space, variance)
  child = {}
  child[:vector] = []
  candidate[:vector].each_with_index do |v,i|
    d = v + variance * random_gaussian()  
    d = search_space[i][0] if d < search_space[i][0]
    d = search_space[i][1] if d > search_space[i][1]
    child[:vector] << d
  end
  return child
end

def distance(v1, v2)
  sum = 0.0
  v1.each_with_index {|v,i| sum += (v-v2[i])**2.0}
  return Math::sqrt(sum)
end

def calculate_mean_variance(population)
  sum = 0
  population.each do |c1|
    population.each do |c2|
      sum += distance(c1[:vector], c2[:vector])
    end
  end
  return sum / population.length**2
end

def tournament(candidate, population, bout_size)
  candidate[:wins] = 0
  bout_size.times do |i|
    other = population[rand(population.length)]
    candidate[:wins] += 1 if candidate[:fitness] < other[:fitness]
  end  
end

def search(max_generations, problem_size, search_space, pop_size, bout_size)
  population = Array.new(pop_size) do |i|
    {:vector=>random_vector(problem_size, search_space)}
  end
  population.each{|c| c[:fitness] = objective_function(c[:vector])}
  gen, best = 0, population.sort{|x,y| x[:fitness] <=> y[:fitness]}.first  
  max_generations.times do |gen|
    variance = calculate_mean_variance(population)
    children = Array.new(pop_size) do |i| 
      mutate(population[i], search_space, variance)
    end
    children.each{|c| c[:fitness] = objective_function(c[:vector])}
    children.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = children.first if children.first[:fitness] < best[:fitness]
    union = children+population
    union.each{|c| tournament(c, population, bout_size)}
    union.sort!{|x,y| y[:wins] <=> x[:wins]}
    population = union[0...pop_size]
    puts " > gen #{gen}, fitness=#{best[:fitness]}"
  end  
  return best
end

max_generations = 100
population_size = 100
problem_size = 2
search_space = Array.new(problem_size) {|i| [-5, +5]}
bout_size = 5

best = search(max_generations, problem_size, search_space, population_size, bout_size)
puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"