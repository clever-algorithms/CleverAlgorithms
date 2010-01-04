# Genetic Algorithm in Ruby
# Copyright (C) 2008 Jason Brownlee



class Sphere
  attr_reader :dimensions, :min, :max
  
  def initialize(dimensions=2)
    @dimensions = dimensions
    @min, @max = -5.12, +5.12
  end
  
  def num_bits
    @dimensions * bits_per_param
  end
  
  def bits_per_param
    16
  end
  
  def evaluate(vector)
    vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
  end  
  
  def is_optimal?(scoring)
    scoring == optimal_score
  end
  
  def optimal_score
    0.0
  end
  
  def maximizing?
    false
  end
end


class BinarySolution
  attr_reader :bitstring, :objective_params 
  attr_accessor :fitness
  
  def initialize(bitstring=nil)
    @bitstring, @fitness = bitstring, 0.0/0.0
  end
  
  def self.random_solution(problem)
    BinarySolution.new(Array.new(problem.num_bits) {|i| (rand<0.5) ? "1" : "0"})
  end
  
  def calculate_fitness(problem)
    @fitness = problem.evaluate(phenotype(problem)) if @fitness.nan?
  end
  
  def phenotype(problem)
    if @object_params.nil? 
      @object_params = Array.new(problem.dimensions) do |i| 
        s, e = (i * problem.bits_per_param), ((i+1) * problem.bits_per_param)
        BinarySolution.bcd(@bitstring[s...e], problem.min, problem.max)
      end
    end
    return @object_params
  end  
  
  def self.bcd(bitstring, min, max)
    sum = 0.0
    bitstring.each_with_index do |x, i|
      sum += ((x=='1') ? 1.0 : 0.0) * (2.0 ** i.to_f)
    end
    # rescale [0,2**L-1] to [min,max]
    return min + ((max-min) / ((2.0**bitstring.length.to_f) - 1.0)) * sum
  end
  
  def recombine(mrate, other=nil)
    cut = other.nil? ? @bitstring.length : rand(@bitstring.length - 2) + 1
    offspring = Array.new(@bitstring.length) do |i| 
      if (i<cut) 
        transcribe(@bitstring[i], mrate) 
      else
        transcribe(other.bitstring[i], mrate) 
      end
    end
    BinarySolution.new(offspring)
  end

  def transcribe(value, mrate)
    (rand < mrate) ? ((value == "1") ? "0" : "1" ) : value
  end
  
  def to_s
    "[#{@bitstring.collect{|x|x}}] (#{@fitness})"
  end
  
  def is_better?(problem, other)
    problem.maximizing? ? @fitness>other.fitness : @fitness<other.fitness
  end      
end

class GeneticAlgorithm
  attr_reader :config
  
  def initialize
    @config = {}
  end
  
  def configure(problem, max_generations)    
    @config[:mutation] = 1.0 / problem.num_bits.to_f
    @config[:crossover] = 0.95
    @config[:pop_size] = problem.num_bits * 3
    @config[:num_bouts] = 2
    @config[:max_generations] = max_generations
  end
  
  def evolve(problem)    
    pop = Array.new(@config[:pop_size]) do |i| 
      BinarySolution.random_solution(problem)
    end
    solution = pop[0]; gen = 0
    begin
      pop.each do |sol| 
        sol.calculate_fitness(problem) 
        solution = sol if sol.is_better?(problem, solution)
      end
      evolve_population(pop, problem)
      gen += 1
      puts "#{gen}, score:#{solution.fitness}"
    end until gen>=@config[:max_generations] or solution.fitness==problem.optimal_score
    return solution
  end
  
  def evolve_population(pop, problem)
    selected = pop.collect {|sol| tournament_select(sol, pop, problem)}
    selected.each_with_index do |sol, i|
      if (rand < @config[:crossover]) 
        other = (i.modulo(2)==0) ? selected[i+1] : selected[i-1]
        pop[i] = sol.recombine(@config[:mutation], other)
      else
        pop[i] = sol.recombine(@config[:mutation])
      end
    end
  end
  
  def tournament_select(base, pop, problem)
    @config[:num_bouts].times do    
      other = pop[rand(pop.length)]
      base = other if other.is_better?(problem, base)
    end
    return base
  end
end


# run it
seed = Time.now.to_f
srand(seed)
puts "Random seed: #{seed}"
problem = Sphere.new(3)
algorithm = GeneticAlgorithm.new
algorithm.configure(problem, 1000)
solution = algorithm.evolve(problem)
puts "Finished, solution:#{solution}, optimal:#{problem.optimal_score}"

