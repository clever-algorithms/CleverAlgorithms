# Island Population Model Genetic Algorithm - ruby
# Jason Brownlee

require 'utils'


# a generic binary string solution
class BinarySolution
    
  attr_reader :genome, :object_params
  attr_accessor :fitness
  
  def initialize(dimensions, min, max)
    @min, @max = min, max
    @fitness = Numbers::NAN
    @object_params = nil
    @dimensions = dimensions
  end
  
  def initialize_random    
    length = @dimensions * heuristic_gene_length
    @genome = Array.new(length) {|i| Random.next_bool ? "1" : "0"}
  end
  
  #  bits per objective parameter
  def heuristic_gene_length
    8
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
    "fitness=(#{@fitness})"
  end
  
  def heuristic_mutation_rate(length)
    (1.0 / length.to_f)
  end
  
  def phenotype
    if @object_params.nil? 
      @object_params = Array.new(@dimensions) do |i| 
        s = (i*heuristic_gene_length)
        e = s+heuristic_gene_length
        BinarySolution.decode(@genome[s...e],@min,@max)
      end
    end
    return @object_params
  end  
  
  # generic decode function for bitstring to float in [min,max]
  def self.decode(bitstring, min, max)
    sum = 0.0
    bitstring.each_with_index do |x, i|
      sum += ((x=='1') ? 1.0 : 0.0) * (2.0 ** i.to_f)
    end
    # rescale [0,2**L-1] to [min,max]
    return min + ((max-min) / ((2.0**bitstring.length.to_f) - 1.0)) * sum
  end
  
end


class SchwefelsFunction
  
  attr_reader :dimensions, :min, :max

  def initialize(dimensions=2)
    @dimensions = dimensions
    @min = -500
    @max = 500
  end
  
  def cost(solution)
    # onlu calculate as needed
    solution.fitness = calculate(solution.phenotype) if solution.fitness.nan?
  end

  def calculate(real_vector)
    real_vector.inject(0) {|sum, x| sum + -x * Math::sin(Math::sqrt(x.abs)) }
  end
  
  def is_optimal?(solution)
    return false if solution.nil?
    return solution.fitness == known_optimal_fitness
  end
  
  def known_optimal_fitness
    # really: 418.9829, reduced for rounding issues
    # (@dimensions.to_f * 418.9829 * -1.0)
    #  or
    return calculate(Array.new(@dimensions) {|i| 420.9687})
  end
  
  def choose_better s1, s2
    return s2 if s1.nil?
    return s1 if s2.nil?
    # minimizing
    return (s1.fitness <= s2.fitness) ? s1 : s2 
  end
  
  def new_solution
    s = BinarySolution.new(@dimensions, @min, @max)
    s.initialize_random
    return s
  end
  
  def new_solution_recombine(parent1, parent2)
    s = BinarySolution.new(@dimensions, @min, @max)
    s.initialize_recombination(parent1, parent2)
    return s
  end
  
end



class IslandGeneticAlgorithm
  attr_reader :population, :best_solution
  
  def evolve problem
    # store problem
    @problem = problem
    @best_solution = nil
    @islands = Array.new(heuristic_num_islands) do |i|
      Array.new(heuristic_population_size) {|j| @problem.new_solution} 
    end    
    # evolve until stop condition is triggered
    @generation = 0
    (@islands = evolve_islands(@islands)) until stop_triggered?
  end
  
  def stop_triggered?
    @problem.is_optimal?(@best_solution) or (@generation>=heuristic_total_generations)
  end
  
  def heuristic_num_islands
    4
  end
  
  def heuristic_generations_before_migration
    50
  end
  
  def heuristic_num_migrants
    (heuristic_population_size.to_f * 0.05).round
  end
    
  def evaluate_population(pop)
    pop.each do |solution| 
      @problem.cost(solution) 
      @best_solution = @problem.choose_better(@best_solution, solution)
    end
  end
  
  def evolve_islands(old_islands)    
    # create new population    
    new_islands = Array.new(old_islands.length) {|i| evolve_population(old_islands[i]) }
    # check for migration event
    if @generation!=0 and (@generation.modulo(heuristic_generations_before_migration) == 0)
      # select a random set of migrants (with reselection) from each island 
      migrants = Array.new(new_islands.length) do |i|
        Array.new(heuristic_num_migrants) {|j| new_islands[i][rand(new_islands[i].length)] }
      end      
      # emigrate migrants into their connected neighobur
      new_islands.each_with_index do |pop,i| 
        # select emigrants (ring structure)
        emigrants = (i==migrants.length-1) ? migrants[0] : migrants[i+1]
        emigrants.each {|e| pop[rand(pop.length)] = e}
      end
      puts "-> completed a migration"
    end
    # one more generation has completed
    @generation += 1  
    puts "#{@generation}, #{@best_solution}"      
    return new_islands
  end
  
  def evolve_population(population)
    # evaluate
    evaluate_population(population)
    # select
    Random.shuffle_array(population)
    selected = population.collect {|solution| tournament_select solution, population}
    Random.shuffle_array(selected)
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
        new_population[index] = solution
      end
    end
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
  
  def heuristic_total_generations
    return 1000
  end
  
  def heuristic_population_size
    (@problem.dimensions * 8) * 2
  end
  
  def heuristic_crossover_rate
    0.95
  end
  
  def heuristic_selection_num_bouts
    3
  end
  
  def average_fitness(pop)
    pop.inject(0) {|sum, x| sum+x.fitness} / pop.length.to_f
  end
    
end


# run it
seed = Time.now.to_f
Random.seed(seed)
puts "Random seed: #{seed}"
problem = SchwefelsFunction.new(10)
puts "Known Optima: #{problem.known_optimal_fitness}"
algorithm = IslandGeneticAlgorithm.new
algorithm.evolve(problem)
puts "Finished, best found: #{algorithm.best_solution}"
puts "Known Optima: #{problem.known_optimal_fitness}"
puts "ABS Error: #{(algorithm.best_solution.fitness-problem.known_optimal_fitness).abs}"
