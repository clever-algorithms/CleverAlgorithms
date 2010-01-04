# Gene Expression Programming in Ruby
# Copyright (C) 2008 Jason Brownlee

# Change History
# 2008/12/10  JB  Created



require 'utils'

class GEPNode
  attr_accessor :value, :left, :right
  
  def initialize(value, left=nil, right=nil)
    @value, @left, @right = value, left, right
  end
  
  def is_leaf?
    @left.nil? and @right.nil?
  end
  
  def eval
    is_leaf? ? @value.call : @value.call(@left.eval, @right.eval)
  end
  
end

class GEPSolution    
  attr_reader :genome
  attr_accessor :fitness, :expression
  
  def initialize(head_symbols, tail_symbols)
    @fitness = Numbers::NAN
    @head_symbols = head_symbols
    @tail_symbols = tail_symbols
  end
  
  def initialize_random
    @genome = Array.new(heuristic_length) do |i|
      (i<heuristic_head_length) ? random_head_symbol : random_tail_symbol
    end
  end
  
  def random_head_symbol
    @head_symbols[Random.next_int(@head_symbols.length)]
  end
  
  def random_tail_symbol
    @tail_symbols[Random.next_int(@tail_symbols.length)]
  end
  
  def initialize_recombination(parent1, parent2)
    # select cut position
    cut = Random.next_int(heuristic_length - 2) + 1
    # recombine the genomes with copy errors
    @genome = Array.new(heuristic_length) do |i| 
      (i<cut) ? transcribe(i, parent1.genome[i]) : transcribe(i, parent2.genome[i])
    end
  end
  
  def transcribe(pos, value)
    if Random.next_float < heuristic_mutation_rate
      (pos<heuristic_head_length) ? random_head_symbol : random_tail_symbol
    else
      value
    end    
  end
  
  def to_s
    "#{@genome.collect{|x|x}} f=(#{@fitness})"
  end
  
  def heuristic_length
    heuristic_head_length + heuristic_tail_length
  end
  
  def heuristic_head_length
    24
  end
  
  def heuristic_tail_length
    heuristic_head_length * (2-1) + 1
  end
  
  def heuristic_mutation_rate
    1.0 / heuristic_length.to_f
  end
  
end


class SymbolicRegressionProblem
        
  def initialize
    @sample_points = Array.new(heuristic_num_points) {|i| Random.next_float_bounded(1, 20)}
    @point_index = 0
    @functions = {
      "*"=>lambda{|a,b| a*b},
      "/"=>lambda{|a,b| a/b},
      "+"=>lambda{|a,b| a+b},
      "-"=>lambda{|a,b| a-b}
      }
    @terminals = {
      "x"=>lambda{current_point}
    }
  end
  
  def head_symbols
    @functions.keys + @terminals.keys
  end
  
  def tail_symbols
    @terminals.keys
  end
  
  def lookup(symbol)
    @functions[symbol] || @terminals[symbol]
  end
    
  # y = a^4 + a^3 + a^2 +  a^1
  def source(x)
    (x**4.0) + (x**3.0) + (x**2.0) + x
  end
  
  def next_point    
    @point_index = (@point_index+1>=heuristic_num_points) ? 0 : (@point_index + 1)
  end
  
  def current_point
    @sample_points[@point_index]
  end

  def cost(solution)
    # parse expression
    # genome is reversed because stack behavior operates on the end of an array in ruby
    solution.expression = breadth_first_mapping(solution.genome.reverse)  
    # sum errors in the model
    sum_errors = 0.0    
    heuristic_num_points.times do |i|
      score = solution.expression.eval     
      score = 10.0 if (score.nan? or !score.finite?)
      sum_errors += (score - source(current_point)).abs
      next_point
    end    
    solution.fitness = sum_errors
  end
  
  # breadth first
  def breadth_first_mapping(symbols)
    queue = Array.new
    # create the root
    root = GEPNode.new(lookup(symbols.pop))
    # push root onto the queue
    queue.push(root)
    # process the queue until empty
    while !queue.empty? do
      # dequeue (start)
      curr = queue.shift
      # process children
      if curr.value.arity == 2
        #  create and enqueue (end) left
        curr.left = GEPNode.new(lookup(symbols.pop))
        queue.push(curr.left)
        # create and enqueue (end) right
        curr.right = GEPNode.new(lookup(symbols.pop))
        queue.push(curr.right)
      end
    end
    return root
  end
  
  def choose_better(s1, s2)
    return s2 if s1.nil?
    return s1 if s2.nil?
    return (s1.fitness <= s2.fitness) ? s1 : s2  
  end
  
  def new_solution
    s = GEPSolution.new(head_symbols, tail_symbols)
    s.initialize_random
    return s
  end
    
  def new_solution_recombine(parent1, parent2)
    s = GEPSolution.new(head_symbols, tail_symbols)
    s.initialize_recombination(parent1, parent2)
    return s
  end
  
  def is_optimal?(solution)
    !solution.nil? and (solution.fitness == 0.0)
  end
    
  def heuristic_num_points
    10
  end
  
end


class GeneExpressionProgrammingAlgorithm
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
        new_population[index] = solution
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
    return 100
  end
  
  def heuristic_population_size
    60
  end
  
  def heuristic_crossover_rate
    0.7
  end
  
  def heuristic_selection_num_bouts
    3
  end
  
end


# run it
seed = Time.now.to_f
puts "Random number seed: #{seed}"
Random.seed(seed)
problem = SymbolicRegressionProblem.new
algorithm = GeneExpressionProgrammingAlgorithm.new
algorithm.evolve(problem)
puts "Best of Run: #{algorithm.best_solution}"
