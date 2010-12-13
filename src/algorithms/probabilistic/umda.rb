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

def binary_tournament(population)
  s1, s2 = population[rand(population.size)], population[rand(population.size)]
  return (s1[:fitness] > s2[:fitness]) ? s1 : s2
end

def calculate_bit_probabilities(num_bits, pop)
  vector = Array.new(num_bits, 0.0)
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

def search(num_bits, max_iterations, population_size, selection_size)
  pop = Array.new(population_size) do
    {:bitstring=>random_bitstring(num_bits)}
  end
  pop.each{|c| c[:fitness] = onemax(c[:bitstring])}
  best = pop.sort{|x,y| y[:fitness] <=> x[:fitness]}.first
  max_iterations.times do |iter|
    selected = Array.new(selection_size) { binary_tournament(pop) }
    vector = calculate_bit_probabilities(num_bits, selected)
    samples = Array.new(population_size) { generate_candidate(vector) }
    samples.each{|c| c[:fitness] = onemax(c[:bitstring])}
    samples.sort{|x,y| y[:fitness] <=> x[:fitness]}
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
  max_iterations = 100
  population_size = 50
  selection_size = 30
  # execute the algorithm
  best = search(num_bits, max_iterations, population_size, selection_size)
  puts "done! Solution: f=#{best[:fitness]}/#{num_bits}, s=#{best[:bitstring]}"
end