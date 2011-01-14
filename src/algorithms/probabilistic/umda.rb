# Univariate Marginal Distribution Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def onemax(vector)
  return vector.inject(0){|sum, value| sum + value}
end

def random_bitstring(size)
  return Array.new(size){ ((rand()<0.5) ? 1 : 0) }
end

def binary_tournament(pop)
  i, j = rand(pop.size), rand(pop.size)
  j = rand(pop.size) while j==i
  return (pop[i][:fitness] > pop[j][:fitness]) ? pop[i] : pop[j]
end

def calculate_bit_probabilities(pop)
  vector = Array.new(pop.first[:bitstring].length, 0.0)
  pop.each do |member|
    member[:bitstring].each_with_index {|v, i| vector[i] += v}
  end
  vector.each_with_index {|f, i| vector[i] = (f.to_f/pop.size.to_f)}
  return vector
end

def generate_candidate(vector)
  candidate = {}
  candidate[:bitstring] = Array.new(vector.size)
  vector.each_with_index do |p, i|
    candidate[:bitstring][i] = (rand()<p) ? 1 : 0
  end
  return candidate
end

def search(num_bits, max_iter, pop_size, select_size)
  pop = Array.new(pop_size) do
    {:bitstring=>random_bitstring(num_bits)}
  end
  pop.each{|c| c[:fitness] = onemax(c[:bitstring])}
  best = pop.sort{|x,y| y[:fitness] <=> x[:fitness]}.first
  max_iter.times do |iter|
    selected = Array.new(select_size) { binary_tournament(pop) }
    vector = calculate_bit_probabilities(selected)
    samples = Array.new(pop_size) { generate_candidate(vector) }
    samples.each{|c| c[:fitness] = onemax(c[:bitstring])}
    samples.sort!{|x,y| y[:fitness] <=> x[:fitness]}
    best = samples.first if samples.first[:fitness] > best[:fitness]
    pop = samples
    puts " >iteration=#{iter}, f=#{best[:fitness]}, s=#{best[:bitstring]}"
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  num_bits = 64
  # algorithm configuration
  max_iter = 100
  pop_size = 50
  select_size = 30
  # execute the algorithm
  best = search(num_bits, max_iter, pop_size, select_size)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:bitstring]}"
end
