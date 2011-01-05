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

def path_exists?(i, j, graph)
  visited, stack = [], [i]
  while !stack.empty?
    k = stack.shift
    return true if k == j
    next if visited.include?(k)
    visited << k
    graph[k][:out].each {|m| stack.unshift(m) if !visited.include?(m)}
  end
  return false
end

def connected?(i, j, graph)
  return graph[i][:out].include?(j)
end

def can_add_edge?(i, j, graph)
  return !path_exists?(j, i, graph) && !connected?(i, j, graph)
end

def get_viable_parents(node, graph)
  viable = []
  graph.size.times do |i|
    if node!=i and can_add_edge?(i, node, graph)
      viable << i
    end
  end
  return viable
end

def compute_count_for_list(node, pop, viable)
  counts = [Array.new(viable.size){[0,0]}, Array.new(viable.size){[0,0]}]
  pop.each do |p|
    i = (p[:bitstring][node].chr == '0') ? 0 : 1
    viable.each_with_index do |v, j|
      k = (p[:bitstring][v].chr == '0') ? 0 : 1
      counts[i][j][k] += 1
    end
  end  
  return counts
end

def fact(v)
  return v <= 1 ? 1 : v*fact(v-1)
end

# assumes no existing in connections
def k2equation1(node, pop)
  a1 = pop.inject(0) {|s,x| s+((x[:bitstring][node].chr=='1') ? 1 : 0) }
  a2 = pop.inject(0) {|s,x| s+((x[:bitstring][node].chr=='0') ? 0 : 1) }
  n = a1 + a2
  return (1.0/fact(n+1).to_f) * fact(a1).to_f * fact(a2).to_f
end

# assume node has an in connection from parent
def k2equation2(node, parent, pop)
  counts = compute_count_for_list(node, pop, [parent])
  n1 = counts[0][0][0] + counts[0][0][1]
  n2 = counts[1][0][0] + counts[1][0][1]
  p1 = (1.0/fact(n1+1).to_f) * fact(counts[0][0][0]).to_f * fact(counts[0][0][1]).to_f
  p2 = (1.0/fact(n2+1).to_f) * fact(counts[1][0][0]).to_f * fact(counts[1][0][1]).to_f
  return p1 * p2
end

# K2.cc => computeLogGains
def compute_log_gains(node, viable, pop, gain)
  # compute counts for list
  counts = compute_count_for_list(node, pop, viable)
  # for each element of the nodes to be updated update the gain
  viable.each_index do |i|
    
    result = 0
    
    gain[viable[i]][node] = result
  end
  
  # compute the resulting gain for the addition of an edge from updateIdx[l] to i
  
end

# recomputeGains.cc => recomputeGains
def recompute_gains(node, graph, gains, pop)
  # check if the node is full ?  
  if graph[node][:full]
    gains[node].each {|i| gains[node][i] = -1}
    return 
  end  
  # prepare a list of viable parents for the node
  viable = get_viable_parents(node, graph)
  # mark all unviable edges
  gains[node].each {|i| gains[node][i] = -1 if !viable.include?(i)}
  # compute log gains for viable edges
#  compute_log_gains(node, viable, pop, gain)
end

# bayesian.cc => constructTheNetwork
def construct_network(pop, prob_size, max_incoming_edges=5*pop.size)
  return [] # delete this
  
  # create a new graph
  graph = Array.new(prob_size) { {:full=>false, :out=>[], :in=>[]} }
  
  # recompute the gains for edges into all nodes and set each node as not full yet
  gains = Array.new(prob_size) {Array.new(prob_size, 0.0)}
  prob_size.times do |i|
    recompute_gains(i, graph, gains, pop)
  end
  
  # build up network with the best edge first, recomputing gains as we go
  # cycles are avoided
  # there is a maximum number of edges that can be added
  
end

# bayesian.cc => generateNewInstances
def sample_from_network(pop, graph)
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
    network = construct_network(selected, num_bits)
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
