# Population-Based Incremental Learning in the Ruby Programming Language

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
  return candidate
end

def update_vector(vector, current, lrate)
  vector.each_with_index do |p, i|
    vector[i] = p * (1.0-lrate) + current[:bitstring][i] * lrate
  end
end

def mutate_vector(vector, current, p_mutate, mutate_factor)
  vector.each_with_index do |p, i|
    if rand() < p_mutate
      vector[i] = p * (1.0-mutate_factor) + rand() * mutate_factor
    end
  end
end

def search(num_bits, max_iterations, num_samples, p_mutate, mutate_factor, learn_rate)
  vector = Array.new(num_bits){rand()}
  best = nil
  max_iterations.times do |iter|
    current = nil
    num_samples.times do 
      candidate = generate_candidate(vector)
      candidate[:cost] = onemax(candidate[:bitstring])
      current = candidate if current.nil? or candidate[:cost]>current[:cost]
      best = candidate if best.nil? or candidate[:cost]>best[:cost]
    end
    update_vector(vector, current, learn_rate)
    mutate_vector(vector, current, p_mutate, mutate_factor)
    puts " >iteration=#{iter}, f=#{best[:cost]}, s=#{best[:bitstring]}"
  end
  return best
end

if __FILE__ == $0
  num_bits = 64
  max_iterations = 100
  num_samples = 100
  p_mutate = 1.0/num_bits
  mutate_factor = 0.05
  learn_rate = 0.1

  best = search(num_bits, max_iterations, num_samples, p_mutate, mutate_factor, learn_rate)
  puts "done! Solution: f=#{best[:cost]}/#{num_bits}, s=#{best[:bitstring]}"
end