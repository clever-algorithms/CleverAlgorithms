# Genetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def onemax(bitstring)
  sum = 0
  bitstring.each_char {|x| sum+=1 if x=='1'}
  return sum
end

def tournament(population, num_bouts)
  best = nil
  num_bouts.times do    
    other = population[rand(population.size)]
    best = other if best.nil? or other[:fitness]>best[:fitness]
  end
  return best
end

def mutation(bitstring, prob_mutation)
  string = ""
  bitstring.each_char do |bit|
    if rand<prob_mutation
      string << ((bit=='1') ? "0" : "1")
    else 
      string << "#{bit}"
    end
  end
  return string
end

def crossover(parent1, parent2, prob_crossover)
  num_bits = parent1[:bitstring].length
  if rand < prob_crossover
    cut = rand(num_bits-2) + 1
    return parent1[:bitstring][0...cut]+parent2[:bitstring][cut...num_bits], parent2[:bitstring][0...cut]+parent1[:bitstring][cut...num_bits]
  end
  return ""+parent1[:bitstring], ""+parent2[:bitstring]
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def reproduce(population, population_size, p_crossover, p_mutation, num_bouts)
  children = []
  while children.size < population_size
    p1, p2 = tournament(population, num_bouts), tournament(population, num_bouts)
    c1, c2 = crossover(p1, p2, p_crossover)
    m1, m2 = mutation(c1, p_mutation), mutation(c2, p_mutation)
    children << {:bitstring=>m1, :fitness=>0}
    children << {:bitstring=>m2, :fitness=>0} if children.size < population_size
  end
  return children
end

def search(max_generations, num_bits, population_size, p_crossover, p_mutation, num_bouts)
  population = Array.new(population_size) do |i|
    {:bitstring=>random_bitstring(num_bits), :fitness=>0}
  end
  population.each{|c| c[:fitness] = onemax(c[:bitstring])}
  gen, best = 0, population.sort{|x,y| y[:fitness] <=> x[:fitness]}.first  
  while best[:fitness]!=num_bits and gen<max_generations
    children = reproduce(population, population_size, p_crossover, p_mutation, num_bouts)    
    children.each{|c| c[:fitness] = onemax(c[:bitstring])}
    children.sort!{|x,y| y[:fitness] <=> x[:fitness]}
    best = children.first if children.first[:fitness] > best[:fitness]
    population = children
    gen += 1
    puts " > gen #{gen}, best: #{best[:fitness]}, #{best[:bitstring]}"
  end  
  return best
end

max_generations = 100
population_size = 100
num_bits = 64
p_crossover = 0.98
p_mutation = 1.0/num_bits
num_bouts = 2

best = search(max_generations, num_bits, population_size, p_crossover, p_mutation, num_bouts)
puts "done! Solution: f=#{best[:fitness]}, s=#{best[:bitstring]}"