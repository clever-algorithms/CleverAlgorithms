# Evolution Strategies in Ruby
# Copyright (C) 2008 Jason Brownlee

# Change History
# 2008/12/05  JB  Solutions bounds checking parameterized
# 2008/12/04  JB  Created

require 'utils'

class ESSolution
  attr_reader :objective_params, :strategy_params
  attr_accessor :fitness
  
  def initialize()
    @fitness = Numbers::NAN
  end
  
  def initialize_random(length, min, max)
    # random objective parameters
    @objective_params = Array.new(length) {|i| Random.next_float_bounded(min, max)}
    # random strategy parameters
    @strategy_params = Array.new(length) {|i| Random.next_float_bounded(0, (max-min).to_f/2.0)}
  end
  
  def initialize_recombine(parent1, parent2, length, min, max)
    # populate strategy parameters
    @strategy_params = Array.new(length) do |i|
      transcribe_strategy(Random.next_bool ? parent1.strategy_params[i] : parent2.strategy_params[i], length)
    end
    # populate objective values
    @objective_params = Array.new(length) do |i|
      transcribe_objective(Random.next_bool ? parent1.objective_params[i] : parent2.objective_params[i], @strategy_params[i], min, max)
    end
  end
  
  def transcribe_strategy(x, length)
    x * Math::exp(heuristic_tau(length) * Random::next_gaussian) 
  end
  
  def transcribe_objective(x, stdev, min, max)
    o = x + stdev * Random::next_gaussian
    o = min if o < min
    o = max if o > max   
    return o
  end
  
  def <=>(solution)
    @fitness <=> solution.fitness
  end
  
  def to_s
    "f=(#{@fitness})"
  end
  
  def heuristic_tau(length)
    length.to_f ** (-1.0/2.0)
  end
    
end

class SchwefelsFunction
  
  attr_reader :dimensions, :min, :max

  def initialize(dimensions=2)
    @dimensions = dimensions
    @min = -500
    @max = 500
  end
  
  def cost(es_solution)
    es_solution.fitness = calculate(es_solution.objective_params)
  end

  def calculate(real_vector)
    real_vector.inject(0) {|sum, x| sum + -x * Math::sin(Math::sqrt(x.abs)) }
  end
  
  def is_optimal?(es_solution)
    return false if es_solution.nil?
    return es_solution.fitness <= known_optimal_fitness
  end
  
  def known_optimal_fitness
    # really: 418.9829, reduced for rounding issues
    (-(@dimensions).to_f * 418.982)
  end

  def is_maximizing?
    return false
  end
  
  def choose_better s1, s2
    return s2 if s1.nil?
    return s1 if s2.nil?
    # minimizing
    return (s1.fitness <= s2.fitness) ? s1 : s2 
  end
  
  def new_solution
    s = ESSolution.new
    s.initialize_random(@dimensions, @min, @max)
    return s
  end
  
  def new_solution_recombine(parent1, parent2)
    s = ESSolution.new
    s.initialize_recombine(parent1, parent2, @dimensions, @min, @max)
    return s
  end
  
end

class EvolutionStrategiesAlgorithm
  attr_reader :problem, :population, :generation, :best_solution, :plus_mode
    
  def initialize(plus_mode=true)
    @plus_mode = plus_mode
  end  
  
  def evolve(problem)
    # store problem
    @problem = problem
    # prepare the initial population
    initialize_population
    # evaluate the initial population
    evaluate_population(population)
    # evolve until stop condition is triggered
    while !should_stop? do
      if @plus_mode
        plus_es
      else
        comma_es
      end      
    end
  end
  
  # (mu,lambda)-ES
  def comma_es
    # direct replacement
    @population = evolve_population(@population)
    # evaluate the population 
    evaluate_population(@population)
  end
  
  # (mu+lambda)-ES
  def plus_es
    # create the new population
    new_population = evolve_population(@population)
    # evaluate the newly created candidate solutions
    evaluate_population(new_population)
    # combine the existing and new populations
    union = @population + new_population
    # rank by fitness evaluation (ascending numeric order)
    union.sort!
    # select the best of all available solutions
    @population.fill {|i| @problem.is_maximizing? ? union[union.length-1-i] : union[i] }    
  end
  
  def initialize_population
    @best_solution = nil
    @generation = 0
    @population = Array.new(heuristic_population_size)
    @population.fill {|index| @problem.new_solution}
  end
  
  def evaluate_population(pop)
    pop.each do |solution| 
      @problem.cost solution 
      @best_solution = @problem.choose_better @best_solution, solution
    end
  end
  
  def evolve_population(population)
    # shuffle the array to promote random pairings
    Random.shuffle_array(population)
    # recombine and mutate
    new_population = Array.new(population.length)
    population.each_with_index do |solution, index|
      if index.modulo(2)==0
        new_population[index] = @problem.new_solution_recombine(solution, population[index+1])
      else
        new_population[index] = @problem.new_solution_recombine(solution, population[index-1])
      end
    end
    # one more generation has completed
    @generation += 1
    puts "generation:#{@generation}, #{@best_solution}"    
    return new_population
  end
  
  def should_stop?
    return true if @problem.is_optimal?(@best_solution)
    return true if generation >= heuristic_total_generations
    return false
  end
  
  def heuristic_total_generations
    1000
  end
  
  def heuristic_population_size
    60
  end
  
end


# problem test
Random.seed(Time.now.to_f)
problem = SchwefelsFunction.new(3)
algorithm = EvolutionStrategiesAlgorithm.new(true)
algorithm.evolve(problem)
puts "Finished, best solution found: #{algorithm.best_solution}"
puts "Known Optimal Fitness: #{problem.known_optimal_fitness}"