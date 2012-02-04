# Memetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
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

def fitness(candidate, search_space, param_bits)
  candidate[:vector]=decode(candidate[:bitstring], search_space, param_bits)
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

def crossover(parent1, parent2, rate)
  return ""+parent1 if rand()>=rate
  child = ""
  parent1.size.times do |i| 
    child << ((rand()<0.5) ? parent1[i].chr : parent2[i].chr)
  end
  return child
end

def reproduce(selected, pop_size, p_cross, p_mut)
  children = []  
  selected.each_with_index do |p1, i|
    p2 = (i.modulo(2)==0) ? selected[i+1] : selected[i-1]
    p2 = selected[0] if i == selected.size-1
    child = {}
    child[:bitstring] = crossover(p1[:bitstring], p2[:bitstring], p_cross)
    child[:bitstring] = point_mutation(child[:bitstring], p_mut)
    children << child
    break if children.size >= pop_size
  end
  return children
end

def bitclimber(child, search_space, p_mut, max_local_gens, bits_per_param)
  current = child
  max_local_gens.times do
    candidate = {}
    candidate[:bitstring] = point_mutation(current[:bitstring], p_mut)
    fitness(candidate, search_space, bits_per_param)
    current = candidate if candidate[:fitness] <= current[:fitness]
  end
  return current
end

def search(max_gens, search_space, pop_size, p_cross, p_mut, max_local_gens, 
    p_local, bits_per_param=16)
  pop = Array.new(pop_size) do |i|
    {:bitstring=>random_bitstring(search_space.size*bits_per_param)}
  end
  pop.each{|candidate| fitness(candidate, search_space, bits_per_param) }
  gen, best = 0, pop.sort{|x,y| x[:fitness] <=> y[:fitness]}.first  
  max_gens.times do |gen|
    selected = Array.new(pop_size){|i| binary_tournament(pop)}
    children = reproduce(selected, pop_size, p_cross, p_mut) 
    children.each{|cand| fitness(cand, search_space, bits_per_param)}
    pop = []    
    children.each do |child|
      if rand() < p_local
        child = bitclimber(child, search_space, p_mut, max_local_gens, 
          bits_per_param) 
      end
      pop << child
    end    
    pop.sort!{|x,y| x[:fitness] <=> y[:fitness]}    
    best = pop.first if pop.first[:fitness] <= best[:fitness]    
    puts ">gen=#{gen}, f=#{best[:fitness]}, b=#{best[:bitstring]}"
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
  p_cross = 0.98
  p_mut = 1.0/(problem_size*16).to_f
  max_local_gens = 20
  p_local = 0.5
  # execute the algorithm
  best = search(max_gens, search_space, pop_size, p_cross, p_mut, max_local_gens, p_local)
  puts "done! Solution: f=#{best[:fitness]}, b=#{best[:bitstring]}, v=#{best[:vector].inspect}"
end
