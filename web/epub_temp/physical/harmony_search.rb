# Harmony Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def rand_in_bounds(min, max)
  return min + ((max-min) * rand()) 
end

def random_vector(search_space)
  return Array.new(search_space.size) do |i| 
    rand_in_bounds(search_space[i][0], search_space[i][1]) 
  end
end

def create_random_harmony(search_space)
  harmony = {}
  harmony[:vector] = random_vector(search_space)
  harmony[:fitness] = objective_function(harmony[:vector])
  return harmony
end

def initialize_harmony_memory(search_space, mem_size, factor=3)
  memory = Array.new(mem_size*factor){create_random_harmony(search_space)}
  memory.sort!{|x,y| x[:fitness]<=>y[:fitness]}  
  return memory.first(mem_size)
end

def create_harmony(search_space, memory, consid_rate, adjust_rate, range)
  vector = Array.new(search_space.size)
  search_space.size.times do |i|
    if rand() < consid_rate
      value = memory[rand(memory.size)][:vector][i]
      value = value + range*rand_in_bounds(-1.0, 1.0) if rand()<adjust_rate
      value = search_space[i][0] if value < search_space[i][0]
      value = search_space[i][1] if value > search_space[i][1]
      vector[i] = value
    else
      vector[i] = rand_in_bounds(search_space[i][0], search_space[i][1])
    end
  end
  return {:vector=>vector}
end

def search(bounds, max_iter, mem_size, consid_rate, adjust_rate, range)
  memory = initialize_harmony_memory(bounds, mem_size)
  best = memory.first
  max_iter.times do |iter|
    harm = create_harmony(bounds, memory, consid_rate, adjust_rate, range)
    harm[:fitness] = objective_function(harm[:vector])
    best = harm if harm[:fitness] < best[:fitness]
    memory << harm
    memory.sort!{|x,y| x[:fitness]<=>y[:fitness]}
    memory.delete_at(memory.size-1)
    puts " > iteration=#{iter}, fitness=#{best[:fitness]}"
  end  
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 3
  bounds = Array.new(problem_size) {|i| [-5, 5]}
  # algorithm configuration
  mem_size = 20
  consid_rate = 0.95
  adjust_rate = 0.7
  range = 0.05
  max_iter = 500
  # execute the algorithm
  best = search(bounds, max_iter, mem_size, consid_rate, adjust_rate, range)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end