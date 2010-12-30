# Bayesian Optimization Algorithm in the Ruby Programming Language

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
  j = rand(pop.size) while i==j
  return (pop[i][:fitness] > pop[j][:fitness]) ? pop[i] : pop[j]
end

def compute_log_gains(viable, network)
  
end

def can_add_edge?(i, j, network)
  return false # TODO
end

def recompute_gains(node, network)
  # check if the node is full ?
  
  # prepare a list of viable edges
  viable = []
  10.times do |i|
    viable << i if can_add_edge?(node, j, network)
  end
  
  # compute log gains for viable edges
  compute_log_gains(viable, network)
end

def construct_network(pop, max_edges=5*pop.size)  
  return [] # delete this
  
  # compute gains
  
  # build up network with the best edge first, recomputing gains as we go
  # cycles are avoided
  # there is a maximum number of edges that can be added
  
end

def sample_from_network(pop, network)  
  return {:bitstring=>random_bitstring(pop.first[:bitstring].size)} # delete this
  
  # a count of incoming edges or something
  
  # a topological ordering of nodes?
  
  # calculate marginal frequencies of nodes
  
  # generate a bitstring
  
end

def search(num_bits, max_iter, pop_size)
  pop = Array.new(pop_size) { {:bitstring=>random_bitstring(num_bits)} }
  pop.each{|c| c[:fitness] = onemax(c[:bitstring])}
  best = pop.sort{|x,y| y[:fitness] <=> x[:fitness]}.first
  max_iter.times do |iter|
    selected = Array.new(pop_size) { binary_tournament(pop) }
    network = construct_network(selected)
    samples = Array.new(pop_size) { sample_from_network(pop, network) }
    samples.each{|c| c[:fitness] = onemax(c[:bitstring])}
    pop = (samples+pop).sort{|x,y| y[:fitness]<=>x[:fitness]}.first(pop_size)
    best = pop.first if pop.first[:fitness] > best[:fitness]
    puts " >iter=#{iter}, f=#{best[:fitness]}, s=#{best[:bitstring]}"
    break if best[:fitness]==num_bits
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  num_bits = 64
  # algorithm configuration
  max_iter = 100
  pop_size = 50
  # execute the algorithm
  best = search(num_bits, max_iter, pop_size)
  puts "done! Solution: f=#{best[:fitness]}/#{num_bits}, s=#{best[:bitstring]}"
end