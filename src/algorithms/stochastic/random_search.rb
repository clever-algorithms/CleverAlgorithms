# Random Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def cost(candidate_vector)
  return candidate_vector.inject(0) {|sum, x| sum + (x ** 2.0)}
end

def random_vector(search_space)
  return Array.new(search_space.size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def search(search_space, max_iter)
  best = nil
  max_iter.times do |iter|
    candidate = {}
    candidate[:vector] = random_vector(search_space)
    candidate[:cost] = cost(candidate[:vector])
    best = candidate if best.nil? or candidate[:cost] < best[:cost]
    puts " > iteration #{(iter+1)}, best=#{best[:cost]}"
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_iter = 100
  # execute the algorithm
  best = search(search_space, max_iter)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
