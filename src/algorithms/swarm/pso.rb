# Particle Swarm Optimization in the Ruby Programming Language

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

def create_particle(problem_size, search_space)
  particle = {}
  particle[:position] = random_vector(problem_size, search_space)
  particle[:cost] = objective_function(particle[:position])
  particle[:b_position] = particle[:position]
  particle[:b_cost] = particle[:cost]
  particle[:velocity] = Array.new(problem_size){rand() * 1.0}
  return particle
end

def search(max_gens, problem_size, search_space, pop_size)
  pop = Array.new(pop_size) {create_particle(problem_size, search_space)}
  best = pop.sort{|x,y| x[:cost] <=> y[:cost]}.first  
  max_gens.times do |gen|
    
    
    pop.sort!{|x,y| x[:cost] <=> y[:cost]}
    best = pop.first if pop.first[:cost] < best[:cost]
    puts " > gen #{gen+1}, fitness=#{best[:cost]}"
  end  
  return best
end

if __FILE__ == $0
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  max_generations = 200
  pop_size = 20
  

  best = search(max_generations, problem_size, search_space, pop_size)
  puts "done! Solution: f=#{best[:cost]}, s=#{best[:position].inspect}"
end