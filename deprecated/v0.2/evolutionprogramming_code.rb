# Evolutionary Programming in Ruby
# Copyright (C) 2008 Jason Brownlee

# Change History
# 2008/12/05  JB  Created

require 'utils'


class EPSolution
  attr_reader :objective_params, :strategy_params
  attr_accessor :fitness, :wins
  
  def initialize()
    @fitness = Numbers::NAN
    @wins = 0
  end
  
  def initialize_random(length, min, max)
    # random objective parameters
    @objective_params = Array.new(length) {|i| Random.next_float_bounded(min, max)}
    # random strategy parameters
    @strategy_params = Array.new(length) {|i| Random.next_float_bounded(0, (max-min).to_f/2.0)}
  end
  
  def initialize_offspring(parent, length, min, max)
    # populate strategy parameters
    g = Random::next_gaussian
    @strategy_params = Array.new(length) do |i|
      transcribe_strategy(parent.strategy_params[i], g, length)
    end
    # populate objective values
    @objective_params = Array.new(length) do |i|
      transcribe_objective(parent.objective_params[i], @strategy_params[i], min, max)
    end
  end
  
  def transcribe_strategy(x, g, dimensions)
    x * Math::exp((heuristic_rprime(dimensions) * g) + (heuristic_r(dimensions) * Random::next_gaussian))
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
  
  def heuristic_r(dimensions)
    Math::sqrt(2.0 * Math::sqrt(dimensions)) ** -1.0
  end
  
  def heuristic_rprime(dimensions)
    Math::sqrt(2.0 * dimensions) ** -1.0
  end  
end

class RastriginFunction
  attr_reader :dimensions, :min, :max

  def initialize(dimensions=2)
    @dimensions = dimensions
    @min = -5.12
    @max = +5.12
  end
  
  def cost(solution)
    solution.fitness = calculate(solution.objective_params)
  end

  # f(x)=10·n+sum(x(i)^2-10·cos(2·pi·x(i))), i=1:n; -5.12<=x(i)<=5.12.
  def calculate(v)
   v.inject(10.0 * @dimensions.to_f) {|sum, x| sum + (x**2.0) - 10.0 * Math.cos(2.0 * Math::PI * x) }
  end
  
  def is_optimal?(solution)
    return false if solution.nil?
    return solution.fitness <= known_optimal_fitness
  end
  
  def known_optimal_fitness
    # f(x)=0; x(i)=0, i=1:n.
    calculate(Array.new(@dimensions){|i| 0.0 })
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
  
  def is_better?(original, other)
    return true if other.fitness < original.fitness
    return false
  end
  
  def new_solution
    s = EPSolution.new
    s.initialize_random(@dimensions, @min, @max)
    return s
  end
  
  def new_solution_offspring(parent)
    s = EPSolution.new
    s.initialize_offspring(parent, @dimensions, @min, @max)
    return s
  end  
end

class EvolutionaryProgrammingAlgorithm
  attr_reader :problem, :population, :generation, :best_solution
  
  def evolve(problem)
    # store problem
    @problem = problem
    # prepare the initial population
    initialize_population
    # evaluate the initial population
    evaluate_population(population)
    # evolve until stop condition is triggered
    while !should_stop? do
      # create the new population
      @population = evolve_population(@population)
    end
  end
  
  def initialize_population
    @best_solution = nil
    @generation = 0
    @population = Array.new(heuristic_population_size) { |i| @problem.new_solution }
  end
  
  def evaluate_population(pop)
    pop.each do |solution| 
      @problem.cost(solution) 
      @best_solution = @problem.choose_better(@best_solution, solution)
    end
  end
  
  def evolve_population(population)
    # recombine and mutate
    offspring = Array.new(population.length) do |i|
      @problem.new_solution_offspring(population[i])
    end
    # evaluate the newly created candidate solutions
    evaluate_population(offspring)
    # combine the existing and new populations
    union = population + offspring
    # let the solutions compete for survival    
    competitive_tournaments(union)
    # shuffle the union in case few solutions win
    Random.shuffle_array(union)
    # order the union by wins desc
    union.sort! { |a,b| b.wins <=> a.wins }
    # select the winners for the new population
    winners = union[0...population.length]
    # one more generation has completed
    @generation += 1
    puts "generation:#{@generation}, #{@best_solution}"    
    return winners
  end
  
  def competitive_tournaments(pop)
    # clear wins
    pop.each {|s| s.wins = 0 }
    # to get a point, each solution must better than a set of random peers
    pop.each do |s|
      better = true
      heuristic_num_opponents.times do |i|
        pos = Random::next_int(pop.length)
        better = false if @problem.is_better?(s, pop[pos])
      end
      s.wins += 1 if better
    end
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
    50
  end
  
  def heuristic_num_opponents
    5
  end
  
end


# problem test
Random.seed(Time.now.to_f)
problem = RastriginFunction.new(2)
algorithm = EvolutionaryProgrammingAlgorithm.new
algorithm.evolve(problem)
puts "Finished, best solution found: #{algorithm.best_solution}"
puts "Known Optimal Fitness: #{problem.known_optimal_fitness}"

