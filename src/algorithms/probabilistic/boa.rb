# Bayesian Optimization Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "enumerator"

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
    # return true if k == j
    next if visited.include?(k)
    visited << k
    graph[k][:out].each {|m| stack.unshift(m) if !visited.include?(m)}
    return true if stack.include?(j)
  end
  return false
end

def can_add_edge?(i, j, graph)
  return !graph[i][:out].include?(j) && !path_exists?(j, i, graph)
end

def get_viable_parents(node, graph)
  viable = []
  graph.size.times do |i|
    if node!=i and can_add_edge?(node, i, graph)
      viable << i
    end
  end
  return viable
end

def compute_count_for_edges(node, pop, parents)
  counts = Array.new(2**(1+parents.size)){0}
  pop.each do |p|
    index = 0
    ([node]+parents).reverse.each_with_index do |v,i|
      index += ((p[:bitstring][v].chr=='1') ? 1 : 0) * (2**i)
    end
    counts[index] += 1
  end
 return counts
end

def fact(v)
  return v <= 1 ? 1 : v*fact(v-1)
end

def k2equation(node, candidates, pop)
  counts = compute_count_for_edges(node, pop, candidates)
  total = nil
  counts.each_slice(2) do |a1,a2|
    rs = (1.0/fact((a1+a2)+1).to_f) * fact(a1).to_f * fact(a2).to_f
    total = (total.nil? ? rs : total*rs)
  end
  return total
end

def compute_gains(node, graph, pop)
  viable = get_viable_parents(node[:num], graph)
  gains = Array.new(graph.size) {-1}
  gains.each_index do |i|
    if viable.include?(i)
      gains[i] = k2equation(node[:num], node[:in]+[i], pop)
    end
  end  
  return gains
end

def construct_network(pop, prob_size, max_edges=5*pop.size)
  graph = Array.new(prob_size) {|i| {:out=>[], :in=>[], :num=>i} }
  gains = Array.new(prob_size)  
  max_edges.times do
    max, from, to = -1, nil, nil
    graph.each_with_index do |node, i|
      gains[i] = compute_gains(node, graph, pop)
      gains[i].each_with_index {|v,j| from,to,max = i,j,v if v>max}
    end
    break if max <= 0.0
    graph[from][:out] << to
    graph[to][:in] << from
  end
  return graph
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
  num_bits = 30
  # algorithm configuration
  max_iter = 40
  pop_size = 50
  # execute the algorithm
  best = search(num_bits, max_iter, pop_size)
  puts "done! Solution: f=#{best[:fitness]}/#{num_bits}, s=#{best[:bitstring]}"
end
