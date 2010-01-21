# Genetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_GENERATIONS = 100
NUM_BOUTS = 3
POP_SIZE = 100
NUM_BITS = 64
P_CROSSOVER = 0.98
P_MUTATION = 1.0/NUM_BITS
HALF = 0.5

def onemax(bitstring)
  sum = 0
  bitstring.each_char {|x| sum+=1 if x=='1'}
  return sum
end

def tournament(population)
  best = nil
  NUM_BOUTS.times do    
    other = population[rand(population.size)]
    best = other if best.nil? or other[:fitness]>best[:fitness]
  end
  return best
end

def mutation(source)
  string = ""
  source.each_char do |bit|
    if rand<P_MUTATION
      string << ((bit=='1') ? "0" : "1")
    else 
      string << "#{bit}"
    end
  end
  return string
end

def crossover(parent1, parent2)
  if rand < P_CROSSOVER
    cut = rand(NUM_BITS-2) + 1
    return parent1[:bitstring][0...cut]+parent2[:bitstring][cut...NUM_BITS], parent2[:bitstring][0...cut]+parent1[:bitstring][cut...NUM_BITS]
  end
  return ""+parent1[:bitstring], ""+parent2[:bitstring]
end

def random_bitstring
  return (0...NUM_BITS).inject(""){|s,i| s<<((rand<HALF) ? "1" : "0")}
end

def evolve
  population = Array.new(POP_SIZE) do |i|
    {:bitstring=>random_bitstring, :fitness=>0}
  end
  population.each{|c| c[:fitness] = onemax(c[:bitstring])}
  gen, best = 0, population.sort{|x,y| y[:fitness] <=> x[:fitness]}.first  
  while best[:fitness]!=NUM_BITS and gen<NUM_GENERATIONS
    children = []
    while children.size < POP_SIZE
      s1, s2 = crossover(tournament(population), tournament(population))
      children << {:bitstring=>mutation(s1), :fitness=>0}
      children << {:bitstring=>mutation(s2), :fitness=>0} if children.size < POP_SIZE
    end
    children.each{|c| c[:fitness] = onemax(c[:bitstring])}
    children.sort!{|x,y| y[:fitness] <=> x[:fitness]}
    best = children.first if children.first[:fitness] > best[:fitness]
    population = children
    gen += 1
    puts " > gen #{gen}, best: #{best[:fitness]}, #{best[:bitstring]}"
  end  
  return best
end

best = evolve()
puts "done! Solution: f=#{best[:fitness]}, s=#{best[:bitstring]}"