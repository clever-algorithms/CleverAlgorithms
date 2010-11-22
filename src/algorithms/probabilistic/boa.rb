# Bayesian Optimization Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def onemax(vector)
  return vector.inject(0){|sum, value| sum + value}
end

def random_bitstring(length)
  return Array.new(length){ ((rand()<0.5) ? 1 : 0) }
end

def calculate_bit_probabilities(num_bits, pop)
  vector= Array.new(num_bits, 0.0)
  pop.each do |member|
    member[:bitstring].each_with_index {|v, i| vector[i] += v}
  end
  vector.each_with_index {|f,i| vector[i] = (f.to_f/pop.length.to_f)}
  return vector
end

def count_edges(network)
  return network.inject(0) {|sum, node| sum + node[:edges].size}
end

def copy_network(network)
  return Array.new(num_bits){|i| {:edges=>Array.new(network[i][:edges])}}
end

def add_network_edge!(network)
  n1 = rand(network.size)
  n2 = rand(network.size) while n2==n1 and network[n1][:edges].include?(n2)
  network[n1][:edges] << n2
end

def remove_network_edge!(network, no_edges)
  r = rand(no_edges)
  offset = -1
  network.each do |node|
    node[:edges].each_with_index do |e, i|
      r -= 1
      if r <= 0 
        offset = i; break
      end
    end
    if r<=0 
      node[:edges].delete_at(offset); break
    end
  end
  raise "error" if offset == -1
end

def reverse_network_edge!(network, no_edges)
  r = rand(no_edges)
  offset = -1
  network.each_with_index do |node, j|
    node[:edges].each_with_index do |e, i|
      r -= 1
      if r <= 0 
        offset = i; break
      end
    end
    if r <= 0 
      other = node[:edges].delete_at(offset)      
      network[other][:edges] = j
     break
    end
  end
  raise "error" if offset == -1  
end

def is_cycle?(network)
  # TODO
end

def assess_network(network)
  return -1 if is_cycle?(network)
  
  # TODO
end

def construct_nework(num_bits, max_non_improving)
  network = Array.new(num_bits) { {:edges=>[]} }
  network[:fitness] = assess_network(network)
  non_improving = 0
  begin
    no_edges = count_edges(network)
    operation = (no_edges==0) ? 0 : rand(3)
    copy = copy_network(network)
    case operation
      when 0 add_network_edge!(copy)
      when 1 remove_network_edge!(copy, no_edges)
      when 2 reverse_network_edge!(copy, no_edges)
      else raise "error"
    end
    copy[:fitness] = assess_network(copy)
    network,non_improving = copy,0 if copy[:fitness] <= network[:fitness]
    non_improving += 1 if copy[:fitness] > network[:fitness]
  end until non_improving >=  max_non_improving
  network
end

def binary_tournament(population)
  s1, s2 = population[rand(population.size)], population[rand(population.size)]
  return (s1[:fitness] > s2[:fitness]) ? s1 : s2
end

def sample_from_network(network)
  # TODO
end

def search(num_bits, max_iterations, pop_size, selection_size, max_non_improving)
  pop = Array.new(pop_size) { {:bitstring=>random_bitstring(num_bits)} }
  pop.each{|c| c[:fitness] = onemax(c[:bitstring])}
  best = pop.sort{|x,y| y[:fitness] <=> x[:fitness]}.first
  max_iterations.times do |iter|
    selected = Array.new(selection_size) { binary_tournament(pop) }
    network = construct_nework(num_bits, max_non_improving)
    samples = Array.new(pop_size) { sample_from_network(network) }
    samples.each{|c| c[:fitness] = onemax(c[:bitstring])}
    samples.sort{|x,y| y[:fitness] <=> x[:fitness]}
    best = samples.first if samples.first[:fitness] > best[:fitness]
    pop = samples
    puts " >iteration=#{iter}, f=#{best[:fitness]}, s=#{best[:bitstring]}"
  end
  return best
end

if __FILE__ == $0
  num_bits = 64
  max_iterations = 100
  population_size = 50
  selection_size = 30
  max_non_improving = 50
  
  best = search(num_bits, max_iterations, population_size, selection_size, max_non_improving)
  puts "done! Solution: f=#{best[:fitness]}/#{num_bits}, s=#{best[:bitstring]}"
end