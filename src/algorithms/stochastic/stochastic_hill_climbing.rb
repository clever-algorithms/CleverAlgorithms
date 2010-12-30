# Stochastic Hill Climbing algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def onemax(vector)
  return vector.inject(0.0){|sum, v| sum + ((v=="1") ? 1 : 0)}
end

def random_bitstring(num_bits)
  return Array.new(num_bits){|i| (rand<0.5) ? "1" : "0"}
end

def random_neighbor(bitstring)  
  mutant = Array.new(bitstring)
  pos = rand(bitstring.size)
  mutant[pos] = (mutant[pos]=='1') ? '0' : '1'
  return mutant
end

def search(max_iterations, num_bits)
  candidate = {}
  candidate[:vector] = random_bitstring(num_bits)
  candidate[:cost] = onemax(candidate[:vector])
  max_iterations.times do |iter|
    neighbor = {}
    neighbor[:vector] = random_neighbor(candidate[:vector])
    neighbor[:cost] = onemax(neighbor[:vector])
    candidate = neighbor if neighbor[:cost] >= candidate[:cost]
    puts " > iteration #{(iter+1)}, best=#{candidate[:cost]}"
    break if candidate[:cost] == num_bits
  end 
  return candidate
end

if __FILE__ == $0
  # problem configuration
  num_bits = 64
  # algorithm configuration
  max_iterations = 1000
  # execute the algorithm
  best = search(max_iterations, num_bits)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].join}"
end
