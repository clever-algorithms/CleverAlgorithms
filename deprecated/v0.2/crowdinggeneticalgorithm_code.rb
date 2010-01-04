# Crowding Genetic Algorithm in Ruby
# Copyright (C) 2008 Jason Brownlee
# 
# Change History
# 2008/12/12  JB  Created

require 'utils'


# a generic binary string solution
class BinarySolution
    
  attr_reader :genome
  attr_accessor :fitness
  
  def initialize(min, max)
    @min, @max = min, max
    @fitness = Numbers::NAN
    @decoded_value = Numbers::NAN
  end
  
  def initialize_random(length)    
    @genome = Array.new(length) {|i| Random.next_bool ? "1" : "0"}
  end
  
  def initialize_recombination(parent1, parent2)
    length = parent1.genome.length
    # select a cut position
    cut = Random.next_int(length - 2) + 1
    # recombine the genomes with copy errors
    @genome = Array.new(length) do |i| 
      (i<cut) ? transcribe(parent1.genome[i], length) : transcribe(parent2.genome[i], length) 
    end
  end

  def transcribe(value, length)
    if Random.next_float < heuristic_mutation_rate(length)
      return ((value == "1") ? "0" : "1" )
    end
    return value
  end
  
  def to_s
    "[#{@genome.collect{|x|x}}] fitness=(#{@fitness})"
  end
  
  def heuristic_mutation_rate(length)
    (1.0 / length.to_f)
  end
  
  def dist(other)
    return (phenotype - other.phenotype).abs    
  end
  
  def phenotype
    @decoded_value = BinarySolution.decode(@genome,@min,@max) if @decoded_value.nan?
    return @decoded_value
  end  
  
  # generic decode function for bitstring to float in [min,max]
  def self.decode(bitstring, min, max)
    sum = 0
    bitstring.each_with_index do |x, i|
      sum += ((x=='1') ? 1 : 0) * (2 ** i)
    end
    # rescale [0,2**L-1] to [min,max]
    return min + ((max-min) / ((2.0**bitstring.length) - 1.0)) * sum
  end
  
end


class M1
    
  def initialize
    @length = 16
    @min = 0.0
    @max = 1.0
    @optimal_coords = [0.1, 0.3, 0.5, 0.7, 0.9]
  end
  
  def cost(solution)
    solution.fitness = calculate(solution.phenotype)
  end
  
  def calculate(x)
    Math.sin(5.0 * Math::PI * x) ** 6.0
  end
  
  def choose_better(s1, s2)
    # maximizing fitness
    return s1.fitness > s2.fitness ? s1 : s2
  end
  
  def new_solution
    s = BinarySolution.new(@min, @max)
    s.initialize_random(@length)
    return s
  end
  
  def new_solution_recombine(parent1, parent2)
    s = BinarySolution.new(@min, @max)
    s.initialize_recombination(parent1, parent2)
    return s
  end
  
  def num_optima
    @optimal_coords.length
  end
  
  def found_all_optima?(population)
    num_optima_found(population) == num_optima
  end
  
  def num_optima_found(population)
    found = Array.new(num_optima) {|i| false}
    # mark all found optima
    population.each do |s| 
      @optimal_coords.each_with_index {|v, i| found[i]=true if (v-s.phenotype).abs<=0.00001} 
    end
    return found.inject(0) {|sum, x| sum + (x ? 1 : 0)}
  end
  
end



class DeterministicCrowdingGeneticAlgorithm
  attr_reader :population
    
  def evolve problem
    # store problem
    @problem = problem
    @population = Array.new(heuristic_population_size) {|i| @problem.new_solution}    
    # evaluate the base population
    @population.each {|s| @problem.cost(s)}
    # evolve until stop condition is triggered
    @generation = 0
    next_generation(@population) until stop_triggered?
  end
  
  def stop_triggered?
    (@generation==heuristic_total_generations) or @problem.found_all_optima?(@population)
  end
    
  def next_generation(pop)
    # shuffle the population
    # Random.shuffle_array(pop)
    # the entire population participates in reproduction
    (pop.length/2).times do |i|
      # select parents [[0,1],[2,3],etc]
      a = (i*2)
      b = (i*2)+1
      p1 = pop[a]
      p2 = pop[b]
      # create offspring
      o1 = @problem.new_solution_recombine(p1, p2)
      o2 = @problem.new_solution_recombine(p2, p1)
      # evaluate
      @problem.cost(o1)
      @problem.cost(o2)
      # compete for positions in the population based on similarity then fitness
      if (p1.dist(o1) + p2.dist(o2)) <= (p1.dist(o2) + p2.dist(o1))        
        pop[a] = @problem.choose_better(p1, o1)
        pop[b] = @problem.choose_better(p2, o2)
      else
        pop[a] = @problem.choose_better(p1, o2)
        pop[b] = @problem.choose_better(p2, o1)
      end
    end
    # one more generation has completed
    @generation += 1
    puts "#{@generation}, avg(#{average_fitness}), found #{@problem.num_optima_found(@population)}/#{@problem.num_optima}"
  end
  
  def heuristic_total_generations
    1000
  end
  
  def heuristic_population_size
    @problem.num_optima * 50
  end
  
  def average_fitness
    @population.inject(0) {|sum, x| sum+x.fitness} / @population.length.to_f
  end
    
end


# run it
Random.seed(Time.now.to_f)
problem = M1.new
algorithm = DeterministicCrowdingGeneticAlgorithm.new
algorithm.evolve problem
puts "Finished, Optima Found: #{problem.num_optima_found(algorithm.population)}/#{problem.num_optima}"

