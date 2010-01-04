# Grammatical Evolution in Ruby
# Copyright (C) 2008 Jason Brownlee

# Change History
# 2008/12/09  JB  Created

# TODO
#  - penality function for functions that produce an NAN (currently crap evolution)
#  - addition of duplication and pruning functions


require 'utils'

# a generic binary string solution
class BinarySolution
    
  attr_reader :genome
  attr_accessor :fitness, :expression
  
  def initialize()
    @fitness = Numbers::NAN  
  end
  
  def initialize_random(length)
    @genome = Array.new(length) {|i| Random.next_bool ? "1" : "0"}
  end
  
  def initialize_from_parent(parent)
    # transcribe with coping errors
    length = parent.genome.length
    @genome = Array.new(length) {|i| transcribe(parent.genome[i], length)}
    # duplicate 
    
    # prune
  end
  
  def initialize_recombination(parent1, parent2)
    # handle variable length genomes
    lengths = [parent1.genome.length, parent2.genome.length]
    min, max = lengths.min, lengths.max
    cut = Random.next_int(min - 2) + 1
    # recombine the genomes with copy errors
    @genome = Array.new(max) {|i| (i<cut) ? transcribe(parent1.genome[i], max) : transcribe(parent2.genome[i], max)}
    # duplicate
    
    # prune
  end
  
  def heuristic_prune_rate
    1 
  end
  
  def heuristic_duplicate_rate
    1 
  end
  
  def heuristic_mutation_rate(length)
    (1.0 / length.to_f)
  end
  
  def transcribe(value, length)
    if Random.next_float < heuristic_mutation_rate(length)
      return ((value == "1") ? "0" : "1" )
    end
    return value
  end
  
  def read_next_int
    bitstring = Array.new(8)
    8.times do |i|
      bitstring[i] = @genome[@index]
      @index += 1
      reset_read if @index >= @genome.length
    end
    return decode_value(bitstring)
  end
  
  def reset_read
    @index = 0
  end
  
  # decodes to a number between 0 and 2**8 (256)
  def decode_value(bitstring)
    sum = 0
    bitstring.each_with_index do |x, i|
      sum += ((x=='1') ? 1 : 0) * (2 ** i)
    end
    return sum
  end
  
  def to_s
    "expression=#{@expression} fitness=(#{@fitness})"
    # "fitness=(#{@fitness})"
  end
  
end


class SymbolicRegressionProblem
    
  @@exp = [" EXP BINARY EXP ", " (EXP BINARY EXP) ", " UNIARY(EXP) ", " VAR "]
  @@op = ["+", "-", "/", "*" ]
  @@preop = ["Math.sin", "Math.cos", "Math.exp", "Math.log"]
  @@var = ["INPUT", "1.0"]
  @@all = {"EXP"=>@@exp, "BINARY"=>@@op, "UNIARY"=>@@preop, "VAR"=>@@var}
  @@start = "EXP"
  
  def initialize
    @min = -1.0
    @max = +1.0
  end

  def source(x)
    (x**4.0) + (x**3.0) + (x**2.0) + x
  end

  # count the number of '1' bits in a string
  def cost(solution)
    # reset the solution
    solution.reset_read
    # parse expression
    solution.expression = map(solution, @@start)    
    # sum errors in the model
    errors = 0.0    
    heuristic_num_exposures.times do |i|
      x = Random::next_float_bounded(@min, @max)
      exp = solution.expression.gsub(@@var[0], x.to_s)
      begin
        score = eval(exp)
      rescue
        score = Numbers::NAN
      end      
      errors += ((score.nan? ? 1.0 : score) - source(x)).abs
    end    
    solution.fitness = errors
  end
  
  # depth first  
  def map(solution, str, depth=0)   
    @@all.keys.each do |key|
      str = str.gsub(key) do |k| 
        set = @@all[k]
        if key=="EXP" and depth>=heuristic_max_depth
          map(solution, set[set.length - 1], depth+1)          
        else
          i = solution.read_next_int.modulo(set.length)
          map(solution, set[i], depth+1)
        end
      end
    end    
    return str
  end
  
  def choose_better(s1, s2)
    return s2 if s1.nil?
    return s1 if s2.nil?
    return (s1.fitness <= s2.fitness) ? s1 : s2  
  end
  
  def new_solution
    s = BinarySolution.new
    s.initialize_random(80)
    return s
  end
  
  def new_solution_copy(parent)
    s = BinarySolution.new
    s.initialize_from_parent(parent)
    return s
  end
  
  def new_solution_recombine(parent1, parent2)
    s = BinarySolution.new
    s.initialize_recombination(parent1, parent2)
    return s
  end
  
  def is_optimal?(solution)
    !solution.nil? and (solution.fitness == 0.0)
  end
  
  def heuristic_max_depth
    10
  end
  
  def heuristic_num_exposures
    10
  end
  
end


class GrammaticalEvolutionAlgorithm
  attr_reader :problem, :population, :generation, :best_solution
    
  def evolve problem
    # store problem
    @problem = problem
    # prepare the population and state
    @best_solution = nil
    @generation = 0
    @population = Array.new(heuristic_population_size) {|i| @problem.new_solution}
    # evolve until stop condition is triggered
    @population = evolve_population(@population) until should_stop?
  end
  
  def evaluate(pop)
    pop.each do |solution| 
      @problem.cost(solution) 
      @best_solution = @problem.choose_better(@best_solution, solution)
    end    
  end
  
  def evolve_population(population)
    # evaluate
    evaluate(population)
    # select
    selected = population.collect {|solution| tournament_select solution, population}
    # recombine and mutate
    new_population = Array.new(population.length)
    selected.each_with_index do |solution, index|
      # probabilistic crossover or promotion
      if Random.next_float < heuristic_crossover_rate        
        if index.modulo(2)==0
          new_population[index] = @problem.new_solution_recombine(solution, selected[index+1])
        else
          new_population[index] = @problem.new_solution_recombine(solution, selected[index-1])
        end
      else
        new_population[index] = @problem.new_solution_copy(solution)
      end
    end
    # one more generation has completed
    @generation += 1
    puts "#{@generation}, best: #{@best_solution}"    
    return new_population
  end
  
  # tournament selection with reselection
  def tournament_select(base, population)
    bouts = 1
    while bouts <= heuristic_selection_num_bouts do
      pos = Random.next_int(population.length)
      base = @problem.choose_better(base, population[pos])
      bouts += 1
    end
    return base
  end
  
  def should_stop?
    @problem.is_optimal?(@best_solution) or (@generation >= heuristic_total_generations)
  end
  
  def heuristic_total_generations
    return 200
  end
  
  def heuristic_population_size
    50
  end
  
  def heuristic_crossover_rate
    0.2
  end
  
  def heuristic_selection_num_bouts
    3
  end
  
end


# run it
Random.seed(Time.now.to_f)
problem = SymbolicRegressionProblem.new
algorithm = GrammaticalEvolutionAlgorithm.new
algorithm.evolve(problem)
puts "Finished, best solution: #{ algorithm.best_solution}"
puts "bitstring: #{algorithm.best_solution.genome}"
puts "expression: #{algorithm.best_solution.expression}"
