# Particle Swarm Optimization in the Ruby Programming Language

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

def create_particle(search_space, vel_space)
  particle = {}
  particle[:position] = random_vector(search_space)
  particle[:cost] = objective_function(particle[:position])
  particle[:b_position] = Array.new(particle[:position])
  particle[:b_cost] = particle[:cost]
  particle[:velocity] = random_vector(vel_space)
  return particle
end

def get_global_best(population, current_best=nil)
  population.sort!{|x,y| x[:cost] <=> y[:cost]}
  best = population.first
  if current_best.nil? or best[:cost] <= current_best[:cost]
    current_best = {}
    current_best[:position] = Array.new(best[:position])
    current_best[:cost] = best[:cost]
  end
  return current_best
end

def update_velocity(particle, gbest, max_v, c1, c2)
  particle[:velocity].each_with_index do |v,i|
    v1 = c1 * rand() * (particle[:b_position][i] - particle[:position][i])
    v2 = c2 * rand() * (gbest[:position][i] - particle[:position][i])
    particle[:velocity][i] = v + v1 + v2
    particle[:velocity][i] = max_v if particle[:velocity][i] > max_v
    particle[:velocity][i] = -max_v if particle[:velocity][i] < -max_v
  end
end

def update_position(part, bounds)
  part[:position].each_with_index do |v,i|
    part[:position][i] = v + part[:velocity][i]
    if part[:position][i] > bounds[i][1] 
      part[:position][i]=bounds[i][1]-(part[:position][i]-bounds[i][1]).abs
      part[:velocity][i] *= -1.0
    elsif part[:position][i] < bounds[i][0] 
      part[:position][i]=bounds[i][0]+(part[:position][i]-bounds[i][0]).abs
      part[:velocity][i] *= -1.0
    end
  end
end

def update_best_position(particle)
  return if particle[:cost] > particle[:b_cost]
  particle[:b_cost] = particle[:cost]
  particle[:b_position] = Array.new(particle[:position])
end

def search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
  pop = Array.new(pop_size) {create_particle(search_space, vel_space)}
  gbest = get_global_best(pop)
  max_gens.times do |gen|
    pop.each do |particle|
      update_velocity(particle, gbest, max_vel, c1, c2)
      update_position(particle, search_space)
      particle[:cost] = objective_function(particle[:position])
      update_best_position(particle)
    end
    gbest = get_global_best(pop, gbest)
    puts " > gen #{gen+1}, fitness=#{gbest[:cost]}"
  end  
  return gbest
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, 5]}
  # algorithm configuration
  vel_space = Array.new(problem_size) {|i| [-1, 1]}
  max_gens = 100
  pop_size = 50
  max_vel = 100.0
  c1, c2 = 2.0, 2.0
  # execute the algorithm
  best = search(max_gens, search_space, vel_space, pop_size, max_vel, c1,c2)
  puts "done! Solution: f=#{best[:cost]}, s=#{best[:position].inspect}"
end
