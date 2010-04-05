# Learning Classifier System in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def onemax(bitstring)
  sum = 0
  bitstring.each_char {|x| sum+=1 if x=='1'}
  return sum
end

def binary_tournament(population)
  s1, s2 = population[rand(population.size)], population[rand(population.size)]
  return (s1[:fitness] > s2[:fitness]) ? s1 : s2
end

def point_mutation(bitstring, prob_mutation)
  child = ""
  bitstring.size.times do |i|
    bit = bitstring[i]
    child << ((rand()<prob_mutation) ? ((bit=='1') ? "0" : "1") : bit)
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

def reproduce(selected, population_size, p_crossover, p_mutation)
  children = []  
  selected.each_with_index do |p1, i|    
    p2 = (i.even?) ? selected[i+1] : selected[i-1]
    child = {}
    child[:bitstring] = uniform_crossover(p1, p2, p_crossover)
    child[:bitstring] = point_mutation(child[:bitstring], p_mutation)
    children << child
  end
  return children
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def search(max_generations, num_bits, population_size, p_crossover, p_mutation)
  population = Array.new(population_size) do |i|
    {:bitstring=>random_bitstring(num_bits)}
  end
  population.each{|c| c[:fitness] = onemax(c[:bitstring])}
  gen, best = 0, population.sort{|x,y| y[:fitness] <=> x[:fitness]}.first  
  while best[:fitness]!=num_bits and gen<max_generations
    selected = Array.new(population_size){|i| binary_tournament(population)}
    children = reproduce(selected, population_size, p_crossover, p_mutation)    
    children.each{|c| c[:fitness] = onemax(c[:bitstring])}
    children.sort!{|x,y| y[:fitness] <=> x[:fitness]}
    best = children.first if children.first[:fitness] >= best[:fitness]
    population = children
    gen += 1
    puts " > gen #{gen}, best: #{best[:fitness]}, #{best[:bitstring]}"
  end  
  return best
end


def neg(bit) 
  return (bit==1) ? 0 : 1 
end
  
def target_function(bitstring)
  v = []
  bitstring.each_char {|c| v<<c.to_i}
  x0,x1,x2,x3,x4,x5 = v
  return neg(x0)*neg(x1)*x2 + neg(x0)*x1*x3 + x0*neg(x1)*x4 + x0*x1*x5
end

# puts target_function("100010")

def all_permutations(length)
  # requires ruby 1.8.7+
  return [0,1].combination(length).to_a
end

puts "total permutations: #{all_permutations(6).length}"


max_generations = 100
population_size = 100
learning_rate = 0
discount_factor = 0
ga_frequency = 0
problem_size = 6
num_bits = problem_size+2**problem_size
p_crossover = 0.98
p_mutation = 1.0/num_bits
p_deletion = 0

# lots of others....

num_rules = 50
num_bits = 64

# best = search(max_generations, num_bits, population_size, p_crossover, p_mutation)
# puts "done! Solution: f=#{best[:fitness]}, s=#{best[:bitstring]}"


