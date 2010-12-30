# Memetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

BITS_PER_PARAM = 16

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def decode(bitstring, search_space)
  vector = []
  search_space.each_with_index do |bounds, i|
    off, sum, j = i*BITS_PER_PARAM, 0.0, 0    
    bitstring[off...(off+BITS_PER_PARAM)].reverse.each_char do |c|
      sum += ((c=='1') ? 1.0 : 0.0) * (2.0 ** j.to_f)
      j += 1
    end
    min, max = bounds
    vector << min + ((max-min)/((2.0**BITS_PER_PARAM.to_f)-1.0)) * sum
  end
  return vector
end

def fitness(candidate, search_space)
  candidate[:vector] = decode(candidate[:bitstring], search_space)
  candidate[:fitness] = objective_function(candidate[:vector])
end

def binary_tournament(pop)
  i, j = rand(pop.size), rand(pop.size)
  j = rand(pop.size) while j==i
  return (pop[i][:fitness] < pop[j][:fitness]) ? pop[i] : pop[j]
end

def point_mutation(bitstring, rate=1.0/bitstring.size)
  child = ""
   bitstring.size.times do |i|
     bit = bitstring[i].chr
     child << ((rand()<rate) ? ((bit=='1') ? "0" : "1") : bit)
  end
  return child
end

def uniform_crossover(parent1, parent2, rate)
  return ""+parent1 if rand()>=rate
  child = ""
  parent1.size.times do |i| 
    child << ((rand()<0.5) ? parent1[i].chr : parent2[i].chr)
  end
  return child
end

def reproduce(selected, population_size, p_crossover, p_mutation)
  children = []  
  selected.each_with_index do |p1, i|    
    p2 = (i.even?) ? selected[i+1] : selected[i-1]
    child = {}
    child[:bitstring] = uniform_crossover(p1[:bitstring], p2[:bitstring], p_crossover)
    child[:bitstring] = point_mutation(child[:bitstring], p_mutation)
    children << child
    break if children.size >= population_size
  end
  return children
end

def bitclimber(child, search_space, p_mutation, max_local_gens)
  current = child
  max_local_gens.times do
    candidate = {}
    candidate[:bitstring] = point_mutation(current[:bitstring], p_mutation)
    fitness(candidate, search_space)
    current = candidate if candidate[:fitness] <= current[:fitness]
  end
  return current
end

def search(max_gens, search_space, pop_size, p_crossover, p_mutation, max_local_gens, p_local)
  pop = Array.new(pop_size) do |i|
    {:bitstring=>random_bitstring(search_space.size*BITS_PER_PARAM)}
  end
  pop.each{|candidate| fitness(candidate, search_space) }
  gen, best = 0, pop.sort{|x,y| x[:fitness] <=> y[:fitness]}.first  
  max_gens.times do |gen|
    selected = Array.new(pop_size){|i| binary_tournament(pop)}
    children = reproduce(selected, pop_size, p_crossover, p_mutation) 
    children.each{|candidate| fitness(candidate, search_space) }
    pop = []    
    children.each do |child|
      child = bitclimber(child, search_space, p_mutation, max_local_gens) if rand() < p_local
      pop << child
    end    
    pop.sort!{|x,y| x[:fitness] <=> y[:fitness]}    
    best = pop.first if pop.first[:fitness] <= best[:fitness]    
    puts ">gen=#{gen}, f=#{best[:fitness]}, b=#{best[:bitstring]}, v=#{best[:vector].inspect}"
  end  
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_gens = 100
  pop_size = 100  
  p_crossover = 0.98
  p_mutation = 1.0/(problem_size*BITS_PER_PARAM).to_f
  max_local_gens = 20
  p_local = 0.5
  # execute the algorithm
  best = search(max_gens, search_space, pop_size, p_crossover, p_mutation, max_local_gens, p_local)
  puts "done! Solution: f=#{best[:fitness]}, b=#{best[:bitstring]}, v=#{best[:vector].inspect}"
end
