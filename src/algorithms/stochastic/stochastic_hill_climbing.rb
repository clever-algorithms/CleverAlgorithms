# Stochastic Hill Climbing algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def cost(bitstring)
  return bitstring.inject(0) {|sum,x| sum = sum + ((x=='1') ? 1 : 0)}
end

def random_solution(problem_size)
  return Array.new(problem_size){|i| (rand<0.5) ? "1" : "0"}
end

def random_neighbor(bitstring)  
  mutant = Array.new(bitstring)
  pos = rand(bitstring.size)
  mutant[pos] = (mutant[pos]=='1') ? '0' : '1'
  return mutant
end

def search(max_iterations, problem_size)
  candidate = {}
  candidate[:vector] = random_solution(problem_size)
  candidate[:cost] = cost(candidate[:vector])
  max_iterations.times do |iter|
    neighbor = {}
    neighbor[:vector] = random_neighbor(candidate[:vector])
    neighbor[:cost] = cost(neighbor[:vector])
    candidate = neighbor if neighbor[:cost] >= candidate[:cost]
    puts " > iteration #{(iter+1)}, best=#{candidate[:cost]}"
    break if candidate[:cost] == problem_size
  end 
  return candidate
end

if __FILE__ == $0
  # problem configuration
  problem_size = 64
  # algorithm configuration
  max_iterations = 1000
  # execute the algorithm
  best = search(max_iterations, problem_size)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].join}"
end