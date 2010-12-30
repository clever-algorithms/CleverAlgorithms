# Bayesian Optimization Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# CURRENTLY, THIS IMPLEMENTATION IS NOT COMPLETE

def onemax(vector)
  return vector.inject(0){|sum, value| sum + value}
end

def random_bitstring(size)
  return Array.new(size){ ((rand()<0.5) ? 1 : 0) }
end

def calculate_bit_probabilities(num_bits, pop)
  vector= Array.new(num_bits, 0.0)
  pop.each do |member|
    member[:bitstring].each_with_index {|v, i| vector[i] += v}
  end
  vector.each_with_index {|f,i| vector[i] = (f.to_f/pop.size.to_f)}
  return vector
end

def count_edges(network)
  return network.inject(0) {|sum, node| sum + node[:edges].size}
end

def copy_network(network)
  return Array.new(network.size){|i| {:edges=>Array.new(network[i][:edges])}}
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

def dfs_has_double_visit?(network, node, visited=[])
  return true if visited.include?(node)
  visited << node
  node[:edges].each do |i|
    return true if dfs_has_double_visit?(network, network[i], visited)
  end
  return false
end

def has_cycle?(network)
  network.each {|node| return true if dfs_has_double_visit?(network, node) }
  return false
end

def conditional_probability(x, y, probs)
  # independant? 
  return (probs[x] * probs[y]) / probs[y]
end

def conditional_entropy(index, parents, probs)
  sum = 0.0  
  parents.each do |parent|
    jp = probs[index] * probs[parent]
    cp = conditional_probability(index, parent, probs)
    sum += jp * Math.log(cp)
  end
  return -sum
end

def bayesian_information_criterion(network, samples, probs)
  n = samples.size.to_f
  sum = 0.0
  network.each_with_index do |node, index|
    parents = []
    network.each_with_index {|other,i| parents << i if other[:edges].include?(index) }
    p_parents = parents.inject(0.0){|prod,j| prod * probs[parents[j]]}
    h = conditional_entropy(index, parents, probs)
    sum += -h * n - (2.0**p_parents) * (Math.log(n) / 2.0)
  end
  return sum
end

def assess_network(network, samples, probs)
  # return -999999.99 if has_cycle?(network)
  bic = bayesian_information_criterion(network, samples, probs)
  puts " > network=#{bic}"
  return bic
end

def construct_nework(num_bits, max_non_improving, samples, probs)
  network = Array.new(num_bits) { {:edges=>[]} }
  f = assess_network(network, samples, probs)
  non_improving = 0
  begin
    no_edges = count_edges(network)
    # operation = (no_edges==0) ? 0 : rand(3)
    operation = 0
    copy = copy_network(network)
    case operation
      when 0 
        add_network_edge!(copy)
      when 1 
        remove_network_edge!(copy, no_edges)
      when 2 
        reverse_network_edge!(copy, no_edges)
      else raise "error"
    end
    cf = assess_network(copy, samples, probs)
    if cf <= f
      network, f = copy, cf
      non_improving = 0
    else
      non_improving += 1
    end
  end until non_improving >= max_non_improving and count_edges(network) > 0
  puts "edges=#{count_edges(network)}"
  exit
  return network
end

def binary_tournament(pop)
  i, j = rand(pop.size), rand(pop.size)
  return (pop[i][:fitness] > pop[j][:fitness]) ? pop[i] : pop[j]
end

def sample_from_network(network, prob)
  vector = []
  prob.size.times do |index|
    parents = []
    network.each_with_index {|other,i| parents << i if other[:edges].include?(index) }
    s = parents.inject(0.0){|s,i| s+conditional_probability(index, i, probs)}
    puts s
  end
  
  return {:vector=>vector}
end

def search(num_bits, max_iterations, pop_size, selection_size, max_non_improving)
  pop = Array.new(pop_size) { {:bitstring=>random_bitstring(num_bits)} }
  pop.each{|c| c[:fitness] = onemax(c[:bitstring])}
  best = pop.sort{|x,y| y[:fitness] <=> x[:fitness]}.first
  max_iterations.times do |iter|
    selected = Array.new(selection_size) { binary_tournament(pop) }
    probs = calculate_bit_probabilities(num_bits, selected)
    network = construct_nework(num_bits, max_non_improving, selected, probs)
    samples = Array.new(pop_size) { sample_from_network(network, probs) }
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
  max_non_improving = 10
  # execute the algorithm
  best = search(num_bits, max_iterations, population_size, selection_size, max_non_improving)
  puts "done! Solution: f=#{best[:fitness]}/#{num_bits}, s=#{best[:bitstring]}"
end