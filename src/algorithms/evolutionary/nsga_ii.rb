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
    vector << min + ((max-min)/((2.0**BITS_PER_PARAM.to_f)-1.0)) * sum
  end
  return vector
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
  p1[:objectives].each_with_index do |x,i|
    return false if x > p2[:objectives][i]
  end
  return true
end

def fast_nondominated_sort(pop)
  fronts = Array.new(1){[]}
  pop.each do |p1|
    p1[:dom_count], p1[:dom_set] = 0, []
    pop.each do |p2|      
      if dominates(p1, p2)        
        p1[:dom_set] << p2
      elsif dominates(p2, p1)
        p1[:dom_count] += 1
      end
    end
    if p1[:dom_count] == 0 
      p1[:rank] = 0
      fronts.first << p1
    end
  end  
  curr = 0
  begin
    next_front = []
    fronts[curr].each do |p1|
      p1[:dom_set].each do |p2|
        p2[:dom_count] -= 1
        if p2[:dom_count] == 0          
          p2[:rank] = (curr+1)
          next_front << p2
        end
      end      
    end
    curr += 1
    fronts << next_front if !next_front.empty?
  end while curr < fronts.length
  return fronts
end

def calculate_crowding_distance(pop)
  pop.each {|p| p[:distance] = 0.0}
  num_obs = pop.first[:objectives].length
  num_obs.times do |i|
    pop.sort!{|x,y| x[:objectives][i]<=>y[:objectives][i]}
    min, max = pop.first[:objectives][i], pop.last[:objectives][i]
    range, inf = max-min, 1.0/0.0
    pop.first[:distance], pop.last[:distance] = inf, inf
    next if range == 0
    (1...(pop.length-2)).each do |j|
      pop[j][:distance] += (pop[j+1][:objectives][i] - pop[j-1][:objectives][i]) / range
    end  
  end
end

def crowded_comparison_operator(x,y)
  return y[:distance]<=>x[:distance] if x[:rank] == y[:rank]
  return x[:rank]<=>y[:rank]
end

def better(x,y)
  if !x[:distance].nil? and x[:rank] == y[:rank]
    return (x[:distance]>y[:distance]) ? x : y
  end
  return (x[:rank]<y[:rank]) ? x : y
end

def select_parents(fronts, pop_size)  
  fronts.each {|f| calculate_crowding_distance(f)}
  offspring = []
  last_front = 0
  fronts.each do |front|
    break if (offspring.length+front.length) > pop_size
    front.each {|p| offspring << p}
    last_front += 1
  end  
  if (remaining = pop_size-offspring.length) > 0
    fronts[last_front].sort! {|x,y| crowded_comparison_operator(x,y)}
    offspring += fronts[last_front][0...remaining]
  end
  return offspring
end

def weighted_sum(x)
  return x[:objectives].inject(0.0) {|sum, x| sum+x}
end

def search(problem_size, search_space, max_gens, pop_size, p_crossover)
  pop = Array.new(pop_size) do |i|
    {:bitstring=>random_bitstring(problem_size*BITS_PER_PARAM)}
  end
  calculate_objectives(pop, search_space)
  fast_nondominated_sort(pop)
  selected = Array.new(pop_size){better(pop[rand(pop_size)], pop[rand(pop_size)])}
  children = reproduce(selected, pop_size, p_crossover)  
  calculate_objectives(children, search_space)    
  max_gens.times do |gen|  
    union = pop + children  
    fronts = fast_nondominated_sort(union)  
    offspring = select_parents(fronts, pop_size)
    selected = Array.new(pop_size){better(offspring[rand(pop_size)], offspring[rand(pop_size)])}
    pop = children
    children = reproduce(selected, pop_size, p_crossover)    
    calculate_objectives(children, search_space)
    best = children.sort!{|x,y| weighted_sum(x)<=>weighted_sum(y)}.first    
    best_s = "[x=#{best[:vector]}, objs=#{best[:objectives].join(', ')}]"
    puts " > gen=#{gen+1}, fronts=#{fronts.length}, best=#{best_s}"
  end  
  return children
end

max_gens = 50
pop_size = 100
p_crossover = 0.98
problem_size = 1
search_space = Array.new(problem_size) {|i| [-1000, 1000]}

pop = search(problem_size, search_space, max_gens, pop_size, p_crossover)
puts "done!"