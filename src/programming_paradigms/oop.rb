# Genetic Algorithm in the Ruby Programming Language: Object-Oriented Programming

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# A problem template
class Problem
  def assess(candidate_solution)
    raise "A problem has not been defined"
  end
  
  def is_optimal?(candidate_solution)
    raise "A problem has not been defined"
  end
end

# An strategy template 
class Strategy
  def execute(problem)
    raise "A strategy has not been defined!"
  end
end

# An implementation of the OneMax problem using the problem template
class OneMax < Problem
  
  attr_reader :num_bits
  
  def initialize(num_bits=64)
    @num_bits = num_bits
  end
  
  def assess(candidate_solution)
    if candidate_solution[:bitstring].length != @num_bits
      raise "Expected #{@num_bits} in candidate solution." 
    end
    sum = 0
    candidate_solution[:bitstring].size.times do |i| 
      sum += 1 if candidate_solution[:bitstring][i].chr =='1'
    end
    return sum
  end
  
  def is_optimal?(candidate_solution)
    return candidate_solution[:fitness] == @num_bits
  end
end

# An implementation of the Genetic algorithm using the strategy template
class GeneticAlgorithm < Strategy
  
  attr_reader :max_generations, :population_size, :p_crossover, :p_mutation
  
  def initialize(max_gens=100, pop_size=100, crossover=0.98, mutation=1.0/64.0)
    @max_generations = max_gens
    @population_size = pop_size
    @p_crossover = crossover
    @p_mutation = mutation
  end
  
  def random_bitstring(num_bits)
    return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
  end
  
  def binary_tournament(pop)
    i, j = rand(pop.size), rand(pop.size)
    j = rand(pop.size) while j==i
    return (pop[i][:fitness] > pop[j][:fitness]) ? pop[i] : pop[j]
  end

  def point_mutation(bitstring)
    child = ""
     bitstring.size.times do |i|
      bit = bitstring[i].chr
      child << ((rand()<@p_mutation) ? ((bit=='1') ? "0" : "1") : bit)
    end
    return child
  end

  def uniform_crossover(parent1, parent2)
    return ""+parent1 if rand()>=@p_crossover
    child = ""
    parent1.length.times do |i| 
      child << ((rand()<0.5) ? parent1[i].chr : parent2[i].chr)
    end
    return child
  end

  def reproduce(selected)
    children = []  
    selected.each_with_index do |p1, i|    
      p2 = (i.modulo(2)==0) ? selected[i+1] : selected[i-1]
      p2 = selected[0] if i == selected.size-1
      child = {}
      child[:bitstring] = uniform_crossover(p1[:bitstring], p2[:bitstring])
      child[:bitstring] = point_mutation(child[:bitstring])
      children << child
      break if children.size >= @population_size
    end
    return children
  end

  def execute(problem)
    population = Array.new(@population_size) do |i|
      {:bitstring=>random_bitstring(problem.num_bits)}
    end
    population.each{|c| c[:fitness] = problem.assess(c)}
    best = population.sort{|x,y| y[:fitness] <=> x[:fitness]}.first      
    @max_generations.times do |gen|
      selected = Array.new(population_size){|i| binary_tournament(population)}
      children = reproduce(selected)
      children.each{|c| c[:fitness] = problem.assess(c)}
      children.sort!{|x,y| y[:fitness] <=> x[:fitness]}
      best = children.first if children.first[:fitness] >= best[:fitness]
      population = children
      puts " > gen #{gen}, best: #{best[:fitness]}, #{best[:bitstring]}"
      break if problem.is_optimal?(best)
    end
    return best
  end
end

if __FILE__ == $0
  # problem configuration
  problem = OneMax.new
  # algorithm configuration
  strategy = GeneticAlgorithm.new
  # execute the algorithm
  best = strategy.execute(problem)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:bitstring]}"
end
