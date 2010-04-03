# Genetic Programming in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def binary_tournament(population)
  s1, s2 = population[rand(population.size)], population[rand(population.size)]
  return (s1[:fitness] > s2[:fitness]) ? s1 : s2
end

def point_mutation(bitstring)
  rate = 1.0/bitstring.to_f
  child = ""
  bitstring.size.times do |i|
    bit = bitstring[i]
    child << ((rand()<rate) ? ((bit=='1') ? "0" : "1") : bit)
  end
  return child
end

def uniform_crossover(parent1, parent2, p_crossover)
  return ""+parent1[:bitstring] if rand()<p_crossover
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
    # TODO addition's
    children << child
  end
  return children
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def decode_integers(bitstring, codon_bits)
  ints = []
  (bitstring.size/codon_bits).times do |block|
    codon = bitstring[block, codon_bits]
    sum, i = 0, 0
    codon.each_char {|x| sum+=((x=='1') ? 1 : 0) * (2 ** i);i+=1}
    ints << sum
  end
  return ints
end

def evaluate(candidate, codon_bits)
  # map to integer
  candidate[:mapping] = decode_integers(candidate[:bitstring], codon_bits)
  # map to program
  
  
  # cost
  
  return 0
end

def search(generations, pop_size, codon_bits, initial_bits, p_crossover)
  pop = Array.new(pop_size) {|i| {:bitstring=>random_bitstring(initial_bits)}}
  pop.each{|c| c[:fitness] = evaluate(c,codon_bits)}
  gen, best = 0, pop.sort{|x,y| y[:fitness] <=> x[:fitness]}.first  
  generations.times do |gen|
    selected = Array.new(pop_size){|i| binary_tournament(pop)}
    children = reproduce(selected, pop_size, p_crossover)    
    children.each{|c| c[:fitness] = evaluate(c,codon_bits)}
    children.sort!{|x,y| y[:fitness] <=> x[:fitness]}
    best = children.first if children.first[:fitness] >= best[:fitness]
    pop = children
    puts " > gen #{gen}, best: #{best[:fitness]}, #{best[:bitstring]}"
  end  
  return best
end

generations = 300
pop_size = 100
codon_bits = 8
initial_bits = 10*codon_bits
p_crossover = 0.98

best = search(generations, pop_size, codon_bits, initial_bits, p_crossover)
puts "done! Solution: f=#{best[:fitness]}, s=#{best[:bitstring]}"