# Bees Algorithm in the Ruby Programming Language

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



def search(max_gens, problem_size, search_space, pop_size, num_sites, elite_sites, init_patch_size, elite_bees)
  best = nil
  pop = Array.new(pop_size){{:vector=>random_vector(problem_size, search_space)}}
  pop.each{|bee| bee[:cost] = objective_function(bee[:vector])}
  best = pop.sort{|x,y| x[:cost]<=>y[:cost]}.first
  max_gens.times do |gen|
    

    puts " > gen #{gen+1}, fitness=#{best[:cost]}"
  end  
  return best
end

if __FILE__ == $0
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, 5]}
  max_gens = 200
  pop_size = 45
  num_sites = 3
  elite_sites = 1
  init_patch_size = 3
  elite_bees = 2

  best = search(max_gens, problem_size, search_space, pop_size, num_sites, elite_sites, init_patch_size, elite_bees)
  puts "done! Solution: f=#{best[:cost]}, s=#{best[:vector].inspect}"
end