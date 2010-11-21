# Harmony Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_variable(min, max)
  return min + ((max - min) * rand())
end

def random_vector(search_space)
  return Array.new(search_space.length) {|i| random_variable(search_space[i][0], search_space[i][1]) }
end

def create_random_harmony(search_space)
  harmony = {}
  harmony[:vector] = random_vector(search_space)
  harmony[:fitness] = objective_function(harmony[:vector])
  return harmony
end

def initialize_harmony_memory(search_space, memory_size)
  memory = Array.new(memory_size * 3){ create_random_harmony(search_space) }
  memory.sort!{|x,y| x[:fitness]<=>y[:fitness]}
  memory = memory[0...memory_size]
  return memory
end

def create_harmony(search_space, memory, consideration_rate, adjust_rate, range)
  vector = Array.new(search_space.length)
  search_space.length.times do |i|
    if rand() < consideration_rate
      value = memory[rand(memory.size)][:vector][i]
      value = value + range * random_variable(-1.0, 1.0) if rand() < adjust_rate
      vector[i] = value
    else
      vector[i] = random_variable(search_space[i][0], search_space[i][1])
    end
  end
  return {:vector=>vector}
end

def search(search_space, max_iter, memory_size, consideration_rate, adjust_rate, range)
  memory = initialize_harmony_memory(search_space, memory_size)
  best = memory.first
  max_iter.times do |iter|
    harmony = create_harmony(search_space, memory, consideration_rate, adjust_rate, range)
    harmony[:fitness] = objective_function(harmony[:vector])
    best = harmony if harmony[:fitness] < best[:fitness]
    memory << harmony
    memory.sort!{|x,y| x[:fitness]<=>y[:fitness]}
    memory.delete_at(memory.length-1)
    puts " > iteration=#{iter}, fitness=#{best[:fitness]}"
  end  
  return best
end

if __FILE__ == $0
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, 5]}
  memory_size = 20
  consideration_rate = 0.95
  adjust_rate = 0.7
  range = 0.05
  max_iter = 500

  best = search(search_space, max_iter, memory_size, consideration_rate, adjust_rate, range)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end