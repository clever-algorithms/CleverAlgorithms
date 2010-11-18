# Compact Genetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def onemax(vector)
  return vector.inject(0){|sum, value| sum + value}
end

def generate_candidate(vector)
  candidate = {}
  candidate[:bitstring] = Array.new(vector.length)
  vector.each_with_index do |p, i|
    candidate[:bitstring][i] = (rand()<p) ? 1 : 0
  end
  candidate[:cost] = onemax(candidate[:bitstring])
  return candidate
end

def update_vector(num_bits, vector, winner, loser)
  num_bits.times do |i|  
    if winner[:bitstring][i] != loser[:bitstring][i]
      if winner[:bitstring][i] == 1
        vector[i] = vector[i] + 1.0/num_bits.to_f
      else 
        vector[i] = vector[i] - 1.0/num_bits.to_f
      end
    end
  end
end

def search(num_bits, max_iterations)
  vector = Array.new(num_bits){0.5}
  best = nil
  max_iterations.times do |iter|
    c1 = generate_candidate(vector)
    c2 = generate_candidate(vector)
    winner, loser = (c1[:cost] > c2[:cost] ? [c1,c2] : [c2,c1])
    best = winner if best.nil? or winner[:cost]>best[:cost]
    update_vector(num_bits, vector, winner, loser)
    puts " >iteration=#{iter}, f=#{best[:cost]}, s=#{best[:bitstring]}"
  end
  return best
end

if __FILE__ == $0
  num_bits = 32
  max_iterations = 200
  
  best = search(num_bits, max_iterations)
  puts "done! Solution: f=#{best[:cost]}/#{num_bits}, s=#{best[:bitstring]}"
end