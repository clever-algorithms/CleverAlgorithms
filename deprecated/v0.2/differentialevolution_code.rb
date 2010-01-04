# Differential Evolution in Ruby
# Copyright (C) 2008 Jason Brownlee

# Change History
# 2008/12/08  JB  Created

require 'utils'


class DESolution
  attr_reader :vector
  attr_accessor :fitness
  
  def initialize()
    @fitness = Numbers::NAN
  end
  
  def initialize_random(length, min, max)
    # random objective parameters
    @vector = Array.new(length) {|i| Random.next_float_bounded(min, max)}
  end
  
  # DE/rand/1/bin
  def initialize_offspring(p0, p1, p2, p3, length, min, max)
    @vector = Array.new(length)
    forced_cross = rand(length)
    @vector.fill do |i|
      if (i==forced_cross or rand < heuristic_crossover_factor)
        transcribe(p3.vector[i] + heuristic_weighting_Factor * (p1.vector[i] - p2.vector[i]), min, max)
      else
        p0.vector[i]
      end
    end
  end
  
  def transcribe(x, min, max)
    return min if x < min
    return max if x > max
    return x
  end
  
  def to_s
    "f=(#{@fitness})"
  end

  def heuristic_crossover_factor
    0.9
  end
  
  def heuristic_weighting_Factor
    0.8
  end

end

class RosenbrocksValleyFunction
  attr_reader :dimensions, :min, :max

  def initialize(dimensions=2)
    @dimensions = dimensions
    @min = -2.048
    @max = +2.048
  end
  
  def cost(solution)
    solution.fitness = calculate(solution.vector)
  end

  # f2(x)=sum(100·(x(i+1)-x(i)^2)^2+(1-x(i))^2) i=1:n-1; -2.048<=x(i)<=2.048. 
  def calculate(v)
    sum = 0.0
    v.each_with_index do |x, i|
      sum += 100 * (((v[i+1] - (x**2.0)) ** 2.0) + ((1.0 - x) ** 2))  if i < v.length-1
    end
    return sum
  end
  
  def is_optimal?(solution)
    return false if solution.nil?
    return solution.fitness <= known_optimal_fitness
  end
  
  def known_optimal_fitness
    # f(x)=0; x(i)=1, i=1:n.
    calculate(Array.new(@dimensions){|i| 1.0 })
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
    s = DESolution.new
    s.initialize_random(@dimensions, @min, @max)
    return s
  end
  
  def new_solution_offspring(p0, p1, p2, p3)
    s = DESolution.new
    s.initialize_offspring(p0, p1, p2, p3, @dimensions, @min, @max)
    return s
  end  
end

class DifferentialEvolutionAlgorithm
  attr_reader :problem, :population, :generation, :best_solution
  
  def evolve(problem)
    # initialize the system
    @problem = problem
    @best_solution = nil
    @generation = 0
    # prepare the initial population
    @population = Array.new(heuristic_population_size) { |i| @problem.new_solution }
    # evaluate the initial population
    evaluate_population(population)
    # evolve until stop condition is triggered
    @population = evolve_population(@population) until should_stop?
  end
    
  def evaluate_population(pop)
    pop.each do |solution| 
      @problem.cost(solution) 
      @best_solution = @problem.choose_better(@best_solution, solution)
    end
  end
  
  def evolve_population(population)
    # create offspring
    offspring = Array.new(population.length)
    population.each_with_index do |current, index|
      p1 = p2 = p3 = -1
      p1 = rand(population.length) until p1!=index
      p2 = rand(population.length) until p2!=index and p2!=p1
      p3 = rand(population.length) until p3!=index and p3!=p1 and p3!=p2
      offspring[index] = @problem.new_solution_offspring(current, population[p1], population[p2], population[p3])
    end
    # evaluate
    evaluate_population(offspring)
    # compete for survival
    new_population = Array.new(population.length) {|i| @problem.choose_better(population[i], offspring[i])}
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
    @problem.dimensions * 10
  end
  
end


# problem test
srand(Time.now.to_f)
problem = RosenbrocksValleyFunction.new(5)
algorithm = DifferentialEvolutionAlgorithm.new
algorithm.evolve(problem)
puts "Finished, best solution found: #{algorithm.best_solution}"
puts "Known Optimal Fitness: #{problem.known_optimal_fitness}"