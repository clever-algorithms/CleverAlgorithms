# Adaptive Random Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def rand_in_bounds(min, max)
  return min + ((max-min) * rand()) 
end

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    rand_in_bounds(minmax[i][0], minmax[i][1])
  end
end

def take_step(minmax, current, step_size)
  position = Array.new(current.size)
  position.size.times do |i|
    min = [minmax[i][0], current[i]-step_size].max
    max = [minmax[i][1], current[i]+step_size].min
    position[i] = rand_in_bounds(min, max)
  end
  return position
end

def large_step_size(iter, step_size, s_factor, l_factor, iter_mult)
  return step_size * l_factor if iter>0 and iter.modulo(iter_mult) == 0
  return step_size * s_factor
end

def take_steps(bounds, current, step_size, big_stepsize)
  step, big_step = {}, {}
  step[:vector] = take_step(bounds, current[:vector], step_size)
  step[:cost] = objective_function(step[:vector])
  big_step[:vector] = take_step(bounds,current[:vector],big_stepsize)
  big_step[:cost] = objective_function(big_step[:vector])    
  return step, big_step
end

def search(max_iter, bounds, init_factor, s_factor, l_factor, iter_mult, max_no_impr)
  step_size = (bounds[0][1]-bounds[0][0]) * init_factor
  current, count = {}, 0
  current[:vector] = random_vector(bounds)
  current[:cost] = objective_function(current[:vector])
  max_iter.times do |iter|
    big_stepsize = large_step_size(iter, step_size, s_factor, l_factor, iter_mult)
    step, big_step = take_steps(bounds, current, step_size, big_stepsize)
    if step[:cost] <= current[:cost] or big_step[:cost] <= current[:cost]
      if big_step[:cost] <= step[:cost]
        step_size, current = big_stepsize, big_step
      else
        current = step
      end
      count = 0
    else
      count += 1
      count, step_size = 0, (step_size/s_factor) if count >= max_no_impr
    end
    puts " > iteration #{(iter+1)}, best=#{current[:cost]}"
  end
  return current
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  bounds = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_iter = 1000
  init_factor = 0.05
  s_factor = 1.3
  l_factor = 3.0
  iter_mult = 10
  max_no_impr = 30
  # execute the algorithm
  best = search(max_iter, bounds, init_factor, s_factor, l_factor, iter_mult, max_no_impr)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
