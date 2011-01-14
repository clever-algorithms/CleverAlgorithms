# Strength Pareto Evolutionary Algorithm 2 (SPEA2) in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective1(vector)
  return vector.inject(0.0) {|sum, x| sum + (x**2.0)}
end

def objective2(vector)
  return vector.inject(0.0) {|sum, x| sum + ((x-2.0)**2.0)}
end

def decode(bitstring, search_space, bits_per_param)
  vector = []
  search_space.each_with_index do |bounds, i|
    off, sum = i*bits_per_param, 0.0
    param = bitstring[off...(off+bits_per_param)].reverse
    param.size.times do |j|
      sum += ((param[j].chr=='1') ? 1.0 : 0.0) * (2.0 ** j.to_f)
    end
    min, max = bounds
    vector << min + ((max-min)/((2.0**bits_per_param.to_f)-1.0)) * sum
  end
  return vector
end

def point_mutation(bitstring, rate=1.0/bitstring.size)
  child = ""
   bitstring.size.times do |i|
     bit = bitstring[i].chr
     child << ((rand()<rate) ? ((bit=='1') ? "0" : "1") : bit)
  end
  return child
end

def binary_tournament(pop)
  i, j = rand(pop.size), rand(pop.size)
  j = rand(pop.size) while j==i
  return (pop[i][:fitness] < pop[j][:fitness]) ? pop[i] : pop[j]
end

def crossover(parent1, parent2, rate)
  return ""+parent1 if rand()>=rate
  child = ""
  parent1.size.times do |i| 
    child << ((rand()<0.5) ? parent1[i].chr : parent2[i].chr)
  end
  return child
end

def reproduce(selected, pop_size, p_cross)
  children = []  
  selected.each_with_index do |p1, i|
    p2 = (i.modulo(2)==0) ? selected[i+1] : selected[i-1]
    p2 = selected[0] if i == selected.size-1
    child = {}
    child[:bitstring] = crossover(p1[:bitstring], p2[:bitstring], p_cross)
    child[:bitstring] = point_mutation(child[:bitstring])
    children << child
    break if children.size >= pop_size
  end
  return children
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def calculate_objectives(pop, search_space, bits_per_param)
  pop.each do |p|
    p[:vector] = decode(p[:bitstring], search_space, bits_per_param)
    p[:objectives] = []
    p[:objectives] << objective1(p[:vector])
    p[:objectives] << objective2(p[:vector])
  end
end

def dominates?(p1, p2)
  p1[:objectives].each_index do |i|
    return false if p1[:objectives][i] > p2[:objectives][i]
  end
  return true
end

def weighted_sum(x)
  return x[:objectives].inject(0.0) {|sum, x| sum+x}
end

def euclidean_distance(c1, c2)
  sum = 0.0
  c1.each_index {|i| sum += (c1[i]-c2[i])**2.0}  
  return Math.sqrt(sum)
end

def calculate_dominated(pop)
  pop.each do |p1|
    p1[:dom_set] = pop.select {|p2| p1!=p2 and dominates?(p1, p2) }
  end  
end

def calculate_raw_fitness(p1, pop)
  return pop.inject(0.0) do |sum, p2| 
    (dominates?(p2, p1)) ? sum + p2[:dom_set].size.to_f : sum
  end
end

def calculate_density(p1, pop)
  pop.each do |p2| 
    p2[:dist] = euclidean_distance(p1[:objectives], p2[:objectives])
  end
  list = pop.sort{|x,y| x[:dist]<=>y[:dist]}
  k = Math.sqrt(pop.size).to_i
  return 1.0 / (list[k][:dist] + 2.0)
end

def calculate_fitness(pop, archive, search_space, bits_per_param)
  calculate_objectives(pop, search_space, bits_per_param)
  union = archive + pop
  calculate_dominated(union)
  union.each do |p|
    p[:raw_fitness] = calculate_raw_fitness(p, union)
    p[:density] = calculate_density(p, union)
    p[:fitness] = p[:raw_fitness] + p[:density]
  end
end

def environmental_selection(pop, archive, archive_size)
  union = archive + pop
  environment = union.select {|p| p[:fitness]<1.0}
  if environment.size < archive_size
    union.sort!{|x,y| x[:fitness]<=>y[:fitness]}
    union.each do |p|
      environment << p if p[:fitness] >= 1.0
      break if environment.size >= archive_size
    end
  elsif environment.size > archive_size
    begin
      k = Math.sqrt(environment.size).to_i
      environment.each do |p1|
        environment.each do |p2| 
          p2[:dist] = euclidean_distance(p1[:objectives], p2[:objectives])
        end
        list = environment.sort{|x,y| x[:dist]<=>y[:dist]}
        p1[:density] = list[k][:dist]
      end
      environment.sort!{|x,y| x[:density]<=>y[:density]}
      environment.shift
    end until environment.size <= archive_size
  end  
  return environment
end

def search(search_space, max_gens, pop_size, archive_size, p_cross, bits_per_param=16)
  pop = Array.new(pop_size) do |i|
    {:bitstring=>random_bitstring(search_space.size*bits_per_param)}
  end
  gen, archive = 0, []
  begin    
    calculate_fitness(pop, archive, search_space, bits_per_param)    
    archive = environmental_selection(pop, archive, archive_size)    
    best = archive.sort{|x,y| weighted_sum(x)<=>weighted_sum(y)}.first
    puts ">gen=#{gen}, objs=#{best[:objectives].join(', ')}"
    break if gen >= max_gens
    selected = Array.new(pop_size){binary_tournament(archive)}
    pop = reproduce(selected, pop_size, p_cross)
    gen += 1
  end while true
  return archive
end

if __FILE__ == $0
  # problem configuration
  problem_size = 1
  search_space = Array.new(problem_size) {|i| [-10, 10]}
  # algorithm configuration
  max_gens = 50
  pop_size = 80
  archive_size = 40
  p_cross = 0.90
  # execute the algorithm
  pop = search(search_space, max_gens, pop_size, archive_size, p_cross)
  puts "done!"
end
