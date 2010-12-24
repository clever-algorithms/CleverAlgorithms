# Genetic Algorithm in the Ruby Programming Language: Flow Programming

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require 'thread'

# Generic flow unit 
class FlowUnit
  attr_reader :queue_in, :queue_out, :thread
  
  def initialize(q_in=Queue.new, q_out=Queue.new)
    @queue_in, @queue_out = q_in, q_out
    start()
  end
  
  def run
    raise "FlowUnit not defined!"
  end    
  
  def start
    puts "Starting flow unit: #{self.class.name}!"
    @thread = Thread.new do 
      run() while true 
    end
  end
end

# Evaluation of solutions flow unit
class EvalFlowUnit < FlowUnit
  def onemax(bitstring)
    sum = 0
    bitstring.each_char {|x| sum+=1 if x=='1'}
    return sum
  end

  def run   
    data = @queue_in.pop    
    data[:fitness] = onemax(data[:bitstring])
    @queue_out.push(data)
  end
end

# Stop condition flow unit
class StopConditionUnit < FlowUnit
  attr_reader :best, :num_bits, :max_evaluations, :evals
  
  def initialize(q_in=Queue.new, q_out=Queue.new, max_evaluations=10000, num_bits=64)
    super(q_in, q_out)
    @best, @evals = nil, 0
    @num_bits = num_bits
    @max_evaluations = max_evaluations
  end
  
  def run
    data = @queue_in.pop
    if @best.nil? or data[:fitness] > @best[:fitness]
      @best = data 
      puts " >new best: #{@best[:fitness]}, #{@best[:bitstring]}"
    end
    @evals += 1
    if @best[:fitness]==@num_bits or @evals>=@max_evaluations
      puts "done! Solution: f=#{@best[:fitness]}, s=#{@best[:bitstring]}"
      @thread.exit() 
    end
    @queue_out.push(data)
  end
end

# Fitness-based selection flow unit
class SelectFlowUnit < FlowUnit
  def initialize(q_in=Queue.new, q_out=Queue.new, pop_size=100)
    super(q_in, q_out)
    @pop_size = 100
  end
  
  def binary_tournament(population)
    s1, s2 = population[rand(population.size)], population[rand(population.size)]
    return (s1[:fitness] > s2[:fitness]) ? s1 : s2
  end

  def run    
    population = Array.new
    population << @queue_in.pop while population.size < @pop_size    
    @pop_size.times do
      @queue_out.push(binary_tournament(population))
    end
  end
end

# Variation flow unit
class VariationFlowUnit < FlowUnit
  def initialize(q_in=Queue.new, q_out=Queue.new, crossover=0.98, mutation=1.0/64.0)
    super(q_in, q_out)
    @p_crossover = crossover
    @p_mutation = mutation
  end
  
  def uniform_crossover(parent1, parent2)
    return ""+parent1 if rand()>=@p_crossover
    child = ""
    parent1.length.times do |i| 
      child << ((rand()<0.5) ? parent1[i].chr : parent2[i].chr)
    end
    return child
  end

  def point_mutation(bitstring)
    child = ""
    bitstring.each_char do |bit|
      child << ((rand()<@p_mutation) ? ((bit=='1') ? "0" : "1") : bit)
    end
    return child
  end

  def reproduce(p1, p2)
    child = {}
    child[:bitstring] = uniform_crossover(p1[:bitstring], p2[:bitstring])
    child[:bitstring] = point_mutation(child[:bitstring])
    return child
  end

  def run
    parent1 = @queue_in.pop
    parent2 = @queue_in.pop    
    @queue_out.push(reproduce(parent1, parent2))
    @queue_out.push(reproduce(parent2, parent1))
  end
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def search(population_size=100)
  # create the pipeline
  eval = EvalFlowUnit.new
  stopcondition = StopConditionUnit.new(eval.queue_out) 
  select = SelectFlowUnit.new(stopcondition.queue_out)
  variation = VariationFlowUnit.new(select.queue_out, eval.queue_in) 
  # push random solutions into the pipeline
  population_size.times do 
    solution = {:bitstring=>random_bitstring(64)}
    eval.queue_in.push(solution)
  end
  stopcondition.thread.join  
  return stopcondition.best
end

if __FILE__ == $0
  best = search()
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:bitstring]}"
end
