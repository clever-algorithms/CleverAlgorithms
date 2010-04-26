# Non-dominated Sorting Genetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

BITS_PER_PARAM = 16

def objective1(vector)
  return vector.inject(0.0) {|sum, x| sum + (x**2.0)}
end

def objective2(vector)
  return vector.inject(0.0) {|sum, x| sum + ((x-2.0)**2.0)}
end

def decode(bitstring, search_space)
  vector = []
  search_space.each_with_index do |bounds, i|
    off, sum, j = i*BITS_PER_PARAM, 0.0, 0    
    bitstring[off...(off+BITS_PER_PARAM)].each_char do |c|
      sum += ((c=='1') ? 1.0 : 0.0) * (2.0 ** j.to_f)
      j += 1
    end
    min, max = bounds
    vector << min + ((max-min)/((2**BITS_PER_PARAM)-1)) * sum
  end
  return vector
end

def binary_tournament(pop)
  s1, s2 = pop[rand(pop.size)], pop[rand(pop.size)]
  return (s1[:fitness] > s2[:fitness]) ? s1 : s2
end

def point_mutation(bitstring)
  child = ""
  bitstring.size.times do |i|
    bit = bitstring[i]
    child << ((rand()<1.0/bitstring.length.to_f) ? ((bit=='1') ? "0" : "1") : bit)
  end
  return child
end

def uniform_crossover(parent1, parent2, p_crossover)
  return ""+parent1[:bitstring] if rand()>=p_crossover
  child = ""
  parent1[:bitstring].size.times do |i| 
    child << ((rand()<0.5) ? parent1[:bitstring][i] : parent2[:bitstring][i])
  end
  return child
end

def reproduce(selected, population_size, p_crossover)
  children = []  
  selected.each_with_index do |p1, i|    
    p2 = (i.even?) ? selected[i+1] : selected[i-1]
    child = {}
    child[:bitstring] = uniform_crossover(p1, p2, p_crossover)
    child[:bitstring] = point_mutation(child[:bitstring])
    children << child
  end
  return children
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def calculate_objectives(pop, search_space)
  pop.each do |p|
    p[:vector] = decode(p[:bitstring], search_space)
    p[:objectives] = []
    p[:objectives] << objective1(p[:vector])
    p[:objectives] << objective2(p[:vector])
  end
end

def dominates(p1, p2)
  min = false
  p1[:objectives].each_with_index do |x,i|
    min = true if x <  p2[:objectives][i]
  end
  return false if !min  
  p1[:objectives].each_with_index do |x,i|
    return false if x > p2[:objectives][i]
  end
  return true
end

def fast_nondominated_sort(pop)
  sets = {}
  fronts = [[]]
  pop.each do |p1|
    sets[p1] = []
    p1[:dominated] = 0
    pop.each do |p2|
      if dominates(p1, p2)
        sets[p1] << p2
      elsif dominates(p2, p1)
        p1[:dominated] += 1
      end
    end
    if p1[:dominated] == 0 
      p1[:rank] = 1
      fronts[0] << p1
    end
  end
  curr = 0
  begin
    next_front = []
    fronts[curr].each do |p1|
      sets[p1].each do |p2|
        p2[:dominated] -= 1
        if 
          p2[:dominated] == 0
          p2[:rank] = (curr+1)
          next_front << p2
        end
      end      
    end
    curr += 1
    fronts[curr] = next_front    
  end until fronts[curr] == 0  
end

def crowding_distance(pop)
  # TODO
end

def fitness(pop)
  # TODO
end

def search(problem_size, search_space, max_gens, pop_size, p_crossover)
  # first run
  population = Array.new(pop_size) do |i|
    {:bitstring=>random_bitstring(problem_size*BITS_PER_PARAM)}
  end
  fast_nondominated_sort(population)
  fitness(population)
  #population.sort!{|x,y| x[:fitness] <=> y[:fitness]}
  selected = Array.new(population_size){|i| binary_tournament(population)}
  children = reproduce(selected, pop_size, p_crossover)
  max_gens.times do |gen|
    union = population + children
    f = fast_nondominated_sort(union)
    
    offspring = []
    begin
      crowding_distance(union)
    end until offspring.length == pop_size
    
    selected = Array.new(population_size){|i| binary_tournament(population)}
    children = reproduce(selected, pop_size, p_crossover)
    
    puts " > gen #{gen}"
  end  
  return population
end

max_gens = 500
pop_size = 100
p_crossover = 0.98
problem_size = 1
search_space = Array.new(problem_size) {|i| [-10**3, 10**3]}

pop = search(problem_size, search_space, max_gens, pop_size, p_crossover)
puts "done!"