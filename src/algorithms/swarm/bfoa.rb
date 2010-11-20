# Bacterial Foraging Optimization Algorithm in the Ruby Programming Language

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

def search(max_gens, problem_size, search_space, pop_size)
  pop = Array.new(pop_size) { {:vector=>random_vector(problem_size, search_space)} }
  pop.each{|c| c[:fitness] = objective_function(c[:vector])}
  best = pop.sort{|x,y| x[:fitness]<=>y[:fitness]}.first
  max_gens.times do |iter|

    puts " >iteration=#{iter}, f=#{best[:fitness]}, v=#{best[:vector]}"
  end  
  return best
end

if __FILE__ == $0
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, 5]}
  max_generations = 100
  pop_size = 50

  best = search(max_generations, problem_size, search_space, pop_size)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector]}"
end