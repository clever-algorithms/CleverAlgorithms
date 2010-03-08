# Evolutionary Programming algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def random_solution(problem_size, search_space)
  return Array.new(problem_size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def search(max_generations, problem_size, search_space, population_size, num_bouts)
  population = Array.new(population_size) do |i|
    {:vector=>random_solution(problem_size, search_space)}
  end
  population.each{|c| c[:fitness] = objective_function(c[:vector])}
  gen, best = 0, population.sort{|x,y| y[:fitness] <=> x[:fitness]}.first  
  max_generations.times do |gen|
    
    
    puts " > gen #{gen}, fitness=#{best[:fitness]}"
  end  
  return best
end

max_generations = 100
population_size = 100
problem_size = 2
search_space = Array.new(problem_size) {|i| [-5, +5]}
num_bouts = 10

best = search(max_generations, problem_size, search_space, population_size, num_bouts)
puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"