# Genetic Programming in Ruby
# Copyright (C) 2008 Jason Brownlee

# Change History
# 2008/12/06  JB  Created

# TODO
# - penalize functions that produce an NAN
# - working crossover operator


require 'utils'


class GPNode
  attr_accessor :value, :left, :right
  
  def initialize(value, left=nil, right=nil)
    @value, @left, @right = value, left, right
  end
  
  def is_leaf?
    @left.nil? and @right.nil?
  end
  
  def to_s
    (is_leaf? ? "#{@value}" : "(#{@value}, #{@left}, #{@right})")
  end
  
  def size
    1 + (is_leaf? ? 0 : (@left.size + @right.size))
  end
  
  def eval
    is_leaf? ? @value : @value.call(@left.eval, @right.eval)
  end
  
  def copy
    is_leaf? ? GPNode.new(@value) : GPNode.new(@value, @left.copy, @right.copy)
  end

  def to_array(array)
    # self
    array << self
    # children
    if !is_leaf?
      @left.to_array(array)
      @right.to_array(array)
    end
  end
  
  def get_node(index)
    arr = Array.new
    to_array(arr)
    return arr[index]
  end
  
  def replace(index, replacement, count=1)
    
  end
  
end


class GPSolution
  attr_accessor :fitness, :expression
  
  def initialize()
    @fitness = Numbers::NAN
  end
  
  def initialize_random(problem)
    @expression = random_expression(problem, problem.heuristic_max_depth)
  end
  
  def initialize_recombination(problem, parent1, parent2)
    pos1 = (Random::next_int(parent1.expression.size - 2) + 1)
    pos2 = (Random::next_int(parent2.expression.size - 2 ) + 1)
    # copy all of first parent 
    @expression = parent1.expression.copy    
    # replace crossover point with copy of second parent cross point
    # @expression.get_node(pos1-1).right = parent2.expression.get_node(pos2).copy
    # mutation the expression
    mutate_expression(problem, @expression)
  end
  
  def mutate_expression(problem, node)
    if Random.next_float < heuristic_mutation_rate
      if node.is_leaf? 
        node.value = problem.terminal_set[Random::next_int(problem.terminal_set.length)].call
      else
        node.value = problem.function_set[Random::next_int(problem.function_set.length)]
      end
    end
    if !node.is_leaf?
      mutate_expression(problem, node.left)
      mutate_expression(problem, node.right)
    end
  end
  
  def random_expression(problem, max_depth, curr_depth=1)
    if (curr_depth.to_f/max_depth.to_f) < Random::next_float
      func = problem.function_set[Random::next_int(problem.function_set.length)]
      return GPNode.new(func, random_expression(problem,max_depth,curr_depth+1), random_expression(problem,max_depth,curr_depth+1))
    else
      term = problem.terminal_set[Random::next_int(problem.terminal_set.length)]
      val = term.call
      return GPNode.new(val)
    end
  end
  
  def to_s
    "size=(#{@expression.size}), eval=(#{@expression.eval}) f=(#{@fitness})"
  end
  
  def heuristic_mutation_rate
    1.0 / @expression.size.to_f
  end

end

class ApproximatePI
  attr_reader :function_set, :terminal_set, :goal
  
  def initialize()
    @function_set = [ lambda{|a,b| a*b}, lambda{|a,b| a/b}, lambda{|a,b| a+b}, lambda{|a,b| a-b}]
    @terminal_set = [ lambda{Random::next_float} ]
    @goal = Math::PI #rounded to 3.14159
  end
    
  def cost(solution)
    # evaluate the expression
    value = solution.expression.eval
    # absolute difference from goal value
    solution.fitness = (round(@goal) - round(value)).abs
  end
    
  def is_optimal?(solution)
    solution.fitness == 0.0
  end
  
  def round(v)
    ((v * 100000.0).floor).to_f / 100000.0
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
    s = GPSolution.new
    s.initialize_random(self)
    return s
  end
  
  def new_solution_recombine(parent1, parent2)
    s = GPSolution.new
    s.initialize_recombination(self, parent1, parent2)
    return s
  end
  
  def heuristic_max_depth
    6
  end
  
end


class GeneticProgrammingAlgorithm
  attr_reader :problem, :population, :generation, :best_solution
    
  def initialize()
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
    # evaluate
    evaluate_population(population)
    # select
    selected = population.collect {|solution| tournament_select(solution, population)}
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
    # one more generation has completed
    @generation += 1
    puts "#{@generation}, best: #{@best_solution}"    
    return new_population
  end
    
  def should_stop?
    return true if @problem.is_optimal?(@best_solution)
    return true if generation >= heuristic_total_generations
    return false
  end
  
  # tournament selection with reselection
  def tournament_select(base, population)
    bouts = 1
    while bouts <= heuristic_selection_num_bouts do
      pos = Random.next_int(population.length)
      candidate = population[pos]
      base = @problem.choose_better(base, candidate)
      bouts += 1
    end
    return base
  end
  
  def heuristic_total_generations
    return 50
  end
  
  def heuristic_population_size
    200
  end
  
  def heuristic_crossover_rate
    0.90
  end
  
  def heuristic_selection_num_bouts
    7
  end
end

# problem test
Random.seed(Time.now.to_f)
problem = ApproximatePI.new
puts  "goal=(#{problem.goal}), rounded=#{problem.round(problem.goal)}"
algorithm = GeneticProgrammingAlgorithm.new
algorithm.evolve(problem)
puts "Best Solution: #{algorithm.best_solution}"

