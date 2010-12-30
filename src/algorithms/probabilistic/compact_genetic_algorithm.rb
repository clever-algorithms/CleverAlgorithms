# Compact Genetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def onemax(vector)
  return vector.inject(0){|sum, value| sum + value}
end

def generate_candidate(vector)
  candidate = {}
  candidate[:bitstring] = Array.new(vector.size)
  vector.each_with_index do |p, i|
    candidate[:bitstring][i] = (rand()<p) ? 1 : 0
  end
  candidate[:cost] = onemax(candidate[:bitstring])
  return candidate
end

def update_vector(vector, winner, loser, pop_size)
  vector.size.times do |i|  
    if winner[:bitstring][i] != loser[:bitstring][i]
      if winner[:bitstring][i] == 1
        vector[i] += 1.0/pop_size.to_f
      else 
        vector[i] -= 1.0/pop_size.to_f
      end
    end
  end
end

def search(num_bits, max_iterations, pop_size)
  vector = Array.new(num_bits){0.5}
  best = nil
  max_iterations.times do |iter|
    c1 = generate_candidate(vector)
    c2 = generate_candidate(vector)
    winner, loser = (c1[:cost] > c2[:cost] ? [c1,c2] : [c2,c1])
    best = winner if best.nil? or winner[:cost]>best[:cost]
    update_vector(vector, winner, loser, pop_size)
    puts " >iteration=#{iter}, f=#{best[:cost]}, s=#{best[:bitstring]}"
    break if best[:cost] == num_bits
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  num_bits = 32
  # algorithm configuration
  max_iterations = 200
  pop_size = 20
  # execute the algorithm
  best = search(num_bits, max_iterations, pop_size)
  puts "done! Solution: f=#{best[:cost]}/#{num_bits}, s=#{best[:bitstring]}"
end