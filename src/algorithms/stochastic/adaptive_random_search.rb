# Adaptive Random Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def cost(candidate_vector)
  return candidate_vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def random_solution(problem_size, search_space)
  return Array.new(problem_size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def take_step(problem_size, search_space, current, step_size)
  step = []
  problem_size.times do |i|
    max, min = current[i]+step_size, current[i]-step_size
    max = search_space[i][1] if max > search_space[i][1]
    min = search_space[i][0] if min < search_space[i][0]
    step << min + ((max - min) * rand)
  end
  return step
end

def large_step_size(iteration, step_size, small_factor, large_factor, factor_multiple)
  if iteration.modulo(factor_multiple)
    return step_size * large_factor
  end
  return  step_size * small_factor
end

def search(max_iterations, problem_size, search_space, init_factor, small_factor, large_factor, factor_multiple, max_no_improvements)
  step_size = (search_space[0][1]-search_space[0][0]) * init_factor
  current, count = {}, 0
  current[:vector] = random_solution(problem_size, search_space)
  current[:cost] = cost(current[:vector])
  max_iterations.times do |iter|
    step, bigger_step = {}, {}
    step[:vector] = take_step(problem_size, search_space, current[:vector], step_size)
    step[:cost] = cost(step[:vector])
    bigger_step_size = large_step_size(iter, step_size, small_factor, large_factor, factor_multiple)
    bigger_step[:vector] = take_step(problem_size, search_space, current[:vector], bigger_step_size)
    bigger_step[:cost] = cost(bigger_step[:vector])    
    if step[:cost] <= current[:cost] or bigger_step[:cost] <= current[:cost]
      if bigger_step[:cost] < step[:cost]
        step_size, current = bigger_step_size, bigger_step
      else
        current = step
      end
      count = 0
    else
      count += 1
      count, stepSize = 0, (step_size/small_factor) if count >= max_no_improvements
    end
    puts " > iteration #{(iter+1)}, best=#{current[:cost]}"
  end
  return current
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_iterations = 1000
  init_factor = 0.05
  small_factor = 1.3
  large_factor = 3.0
  factor_multiple = 10
  max_no_improvements = 30
  # execute the algorithm
  best = search(max_iterations, problem_size, search_space, init_factor, small_factor, large_factor, factor_multiple, max_no_improvements)
  puts "Done. Best Solution: cost=#{best[:cost]}, v=#{best[:vector].inspect}"
end