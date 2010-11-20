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

def create_random_bee(problem_size, search_space)
  bee = {}
  bee[:vector] = random_vector(problem_size, search_space)
  return bee
end

def create_neighborhood_bee(site, patch_size, search_space)
  vector = []
  site.each_with_index do |v,i|
    v = (rand()<0.5) ? v+rand()*patch_size : v-rand()*patch_size
    v = search_space[i][0] if v < search_space[i][0]
    v = search_space[i][1] if v > search_space[i][1]
    vector << v
  end
  bee = {}
  bee[:vector] = vector
  return bee
end

def search_neighborhood(site, neighborhood_size, patch_size, search_space)
  neighborhood = []
  neighborhood_size.times do 
    neighborhood << create_neighborhood_bee(site[:vector], patch_size, search_space)
  end
  neighborhood.each{|bee| bee[:fitness] = objective_function(bee[:vector])}
  return neighborhood.sort{|x,y| x[:fitness]<=>y[:fitness]}.first
end

def search(max_gens, problem_size, search_space, num_bees, num_sites, elite_sites, patch_size, e_bees, o_bees)
  best = nil
  pop = Array.new(num_bees){ create_random_bee(problem_size, search_space) }
  max_gens.times do |gen|
    pop.each{|bee| bee[:fitness] = objective_function(bee[:vector])}
    pop.sort!{|x,y| x[:fitness]<=>y[:fitness]}
    best = pop.first if best.nil? or pop.first[:fitness] < best[:fitness]
    next_generation = []
    pop[0...num_sites].each_with_index do |site, i|
      neighborhood_size = (i<elite_sites) ? e_bees : o_bees
      next_generation << search_neighborhood(site, neighborhood_size, patch_size, search_space)
    end
    (num_bees-num_sites).times do
      next_generation << create_random_bee(problem_size, search_space)
    end
    pop = next_generation
    patch_size = patch_size * 0.95
    puts " > iteration=#{gen+1}, patch_size=#{patch_size}, fitness=#{best[:fitness]}"
  end  
  return best
end

if __FILE__ == $0
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, 5]}
  max_gens = 500
  num_bees = 45
  num_sites = 3
  elite_sites = 1
  patch_size = 3.0
  e_bees = 7
  o_bees = 2

  best = search(max_gens, problem_size, search_space, num_bees, num_sites, elite_sites, patch_size, e_bees, o_bees)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end