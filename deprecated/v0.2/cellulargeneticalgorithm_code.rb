# Cellular Genetic Algorithm in Ruby
# Copyright (C) 2008 Jason Brownlee

# Change History
# 2008/12/11  JB  Created

require 'utils'

# a generic binary string solution
class BinarySolution
    
  attr_reader :genome
  attr_accessor :fitness
  
  def initialize()
    @fitness = Numbers::NAN
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
    "[#{@genome.collect{|x|x}}] f=(#{@fitness})"
  end
  
  def heuristic_mutation_rate(length)
    (1.0 / length.to_f)
  end
end

# an example problem domain called 'One Max'
class OneMaxProblem
  
  attr_reader :length
  
  def initialize length
    @length = length
  end
  
  # count the number of '1' bits in a string
  def cost(binary_solution)
    binary_solution.fitness = count_ones(binary_solution.genome)
  end
  
  def count_ones(bitstring)
    bitstring.inject(0) {|sum, x| sum + ((x=='1') ? 1 : 0)}
  end
  
  def to_s
    "One Max"
  end
  
  def is_maximizing?
    return true
  end
  
  def choose_better s1, s2
    return s2 if s1.nil?
    return s1 if s2.nil?
    
    if is_maximizing?
      s1.fitness >= s2.fitness ? s1 : s2
    else
      s1.fitness <= s2.fitness ? s1 : s2
    end        
  end
  
  def new_solution
    s = BinarySolution.new
    s.initialize_random @length
    return s
  end
  
  def new_solution_recombine parent1, parent2
    s = BinarySolution.new
    s.initialize_recombination parent1, parent2
    return s
  end
  
  def is_optimal? solution
    return false if solution.nil?
    return true if solution.fitness == @length
  end
  
end


class CellularGeneticAlgorithm
  attr_reader :best_solution
    
  def evolve problem
    # store problem
    @problem = problem
    # prepare the population and state
    @best_solution = nil
    @generation = 0
    edge = Math.sqrt(heuristic_population_size)
    @population = Array.new(edge) {|i| Array.new(edge) {|j| @problem.new_solution} }
    evaluate_pop_matrix(@population)
    # evolve until stop condition is triggered
    evolve_population(@population) until should_stop?
  end
  
  def evaluate_pop_matrix(pop)
    pop.each do |row| 
      row.each do |cell|
        evaluate_solution(cell)
      end
    end
  end  
  
  def evaluate_solution(cell)
    @problem.cost(cell) 
    @best_solution = @problem.choose_better(@best_solution, cell)    
  end
  
  def evolve_population(pop)
    # complete a fixed number of reproduction events
    heuristic_population_size.times do
      # select position
      x, y = Random.next_int(pop.length), Random.next_int(pop[0].length)
      # select random mate from the neighbourhood
      mate = select_random_neighbour(pop, x, y)
      # create offspring
      offspring = @problem.new_solution_recombine(pop[x][y], mate)
      evaluate_solution(offspring)
      # compete for position in population
      pop[x][y] = @problem.choose_better(pop[x][y], offspring)
    end
    # one more generation has completed
    @generation += 1
    puts "#{@generation}, best: #{@best_solution}"
  end
  
  # N, S, E, W (toroid)
  def select_random_neighbour(pop, x, y)
    neighbour = nil
    case rand(4)
      # north
      when 0: neighbour= (x==0) ? pop[pop.length-1][y] : pop[x-1][y]
      # south
      when 1: neighbour= (x==(pop.length-1)) ? pop[0][y] : pop[x+1][y]
      # west
      when 2: neighbour= (y==0) ? pop[x][pop[x].length-1] : pop[x][y-1]
      # east
      when 3: neighbour= (y==pop[x].length-1) ? pop[x][0] : pop[x][y+1]    
    end
    return neighbour
  end
    
  def should_stop?
    @problem.is_optimal?(@best_solution) or (@generation >= heuristic_total_generations)
  end
  
  def heuristic_total_generations
    1000
  end
  
  def heuristic_population_size
    100
  end
  
  def heuristic_selection_num_bouts
    3
  end
  
end


# run it
Random.seed(Time.now.to_f)
problem = OneMaxProblem.new(50)
algorithm = CellularGeneticAlgorithm.new
algorithm.evolve(problem)
puts "Best Found: #{algorithm.best_solution}"

