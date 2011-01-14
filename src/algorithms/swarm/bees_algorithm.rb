# Bees Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def create_random_bee(search_space)
  return {:vector=>random_vector(search_space)}
end

def create_neigh_bee(site, patch_size, search_space)
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

def search_neigh(parent, neigh_size, patch_size, search_space)
  neigh = []
  neigh_size.times do 
    neigh << create_neigh_bee(parent[:vector], patch_size, search_space)
  end
  neigh.each{|bee| bee[:fitness] = objective_function(bee[:vector])}
  return neigh.sort{|x,y| x[:fitness]<=>y[:fitness]}.first
end

def create_scout_bees(search_space, num_scouts)
  return Array.new(num_scouts) do
    create_random_bee(search_space)
  end
end

def search(max_gens, search_space, num_bees, num_sites, elite_sites, patch_size, e_bees, o_bees)
  best = nil
  pop = Array.new(num_bees){ create_random_bee(search_space) }
  max_gens.times do |gen|
    pop.each{|bee| bee[:fitness] = objective_function(bee[:vector])}
    pop.sort!{|x,y| x[:fitness]<=>y[:fitness]}
    best = pop.first if best.nil? or pop.first[:fitness] < best[:fitness]
    next_gen = []
    pop[0...num_sites].each_with_index do |parent, i|
      neigh_size = (i<elite_sites) ? e_bees : o_bees
      next_gen << search_neigh(parent, neigh_size, patch_size, search_space)
    end
    scouts = create_scout_bees(search_space, (num_bees-num_sites))
    pop = next_gen + scouts
    patch_size = patch_size * 0.95
    puts " > it=#{gen+1}, patch_size=#{patch_size}, f=#{best[:fitness]}"
  end  
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, 5]}
  # algorithm configuration
  max_gens = 500
  num_bees = 45
  num_sites = 3
  elite_sites = 1
  patch_size = 3.0
  e_bees = 7
  o_bees = 2
  # execute the algorithm
  best = search(max_gens, search_space, num_bees, num_sites, elite_sites, patch_size, e_bees, o_bees)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end
