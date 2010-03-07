# Genetic Programming in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def print_program(node)
  return node if !node.kind_of? Array
  return "(#{node[0]}, #{print_program(node[1])}, #{print_program(node[2])})"
end

def eval_program(node, map)
  if !node.kind_of? Array
    return map[node].to_f if !map[node].nil?
    return node.to_f
  end
  arg1, arg2 = eval_program(node[1], map), eval_program(node[2], map)
  return 0 if node[0] === :/ and arg2 == 0.0
  return arg1.__send__(node[0], arg2)
end

def generate_random_program(max, funcs, terms, depth=0)
  if depth >= max-1
    t = terms[rand(terms.length)] 
# TODO range in [-5, +5]
    return ((rand()<0.5) ? rand() : -rand()) if t == 'R' 
    return t
  end  
  arg1 = generate_random_program(max, funcs, terms, depth+1)
  arg2 = generate_random_program(max, funcs, terms, depth+1)
  return [funcs[rand(funcs.length)], arg1, arg2]
end

def program_sensis(node)
  return [0, 1] if !node.kind_of? Array
  a1, a2 = program_sensis(node[1]), program_sensis(node[2])
  return [1+a1[0]+a2[0], a1[1]+a1[1]]
end

def target_function(input)
  return input**2 + input + 1
end

def fitness(program, num_trials)
  sum_error = 0.0
  num_trials.times do |i|
# TODO range in [-1,1]    
    input = rand()
    error = eval_program(program, {'X'=>input}) - target_function(input)
    sum_error += error**2.0
  end
  return Math::sqrt(sum_error/num_trials.to_f)
end

def tournament_selection(population, num_bouts)
  best = population[rand(population.size)]
  (num_bouts-1).times do |i|
    candidate = population[rand(population.size)]
    best = candidate if candidate[:fitness] < best[:fitness]
  end
  return best
end

def replace_node(node, replacement, node_num, current_func=0)
  return replacement,(current_func+1) if current_func == node_num
  return node,(current_func+1) if !node.kind_of? Array
  a1, current_func = replace_node(node[1], replacement, node_num, current_func+1)
  a2, current_func = replace_node(node[2], replacement, node_num, current_func)
  return [node[0], a1, a2], current_func
end

def reproduction(program)
  return node if !node.kind_of? Array
  return [node[0], reproduction(node[1]), reproduction(node[2])]
end

def crossover(program1, program2)
  
end

def mutation(parent, max_depth, functions, terminals)
  sensis = program_sensis(parent)
  point = rand(sensis[0]+sensis[1])
  random_tree = generate_random_program(max_depth/2, functions, terminals)
  child, count = replace_node(parent, random_tree, point)
  return child
end

def alter(program)
  
end

def search(max_generations, population_size, max_depth, num_trials, num_bouts, p_reproduction, p_crossover, p_mutation, p_alter, functions, terminals)
  population = Array.new(population_size) do |i| 
    {:program=>generate_random_program(max_depth, functions, terminals)}
  end
  population.each{|c| c[:fitness] = fitness(c[:program], num_trials)}
  best = population.sort{|x,y| x[:fitness] <=> y[:fitness]}.first
  max_generations.times do |gen|
    # selected = Array.new(population_size){tournament_selection(population, num_bouts)}
    children = []
    while children.length < population_size
      
      
      # reproduction
    
      # crossover
    
      # mutation      
      candidate = tournament_selection(population, num_bouts)
      child = {}
      child[:program] = mutation(candidate[:program], max_depth, functions, terminals)
      children << child
    
      # TODO alteration
    end    
    children.each{|c| c[:fitness] = fitness(c[:program], num_trials)}
    population = children
    population.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = population.first if population.first[:fitness] < best[:fitness]
    puts " > gen #{gen}, fitness=#{best[:fitness]}"
  end
  
  return best
end

max_generations = 100
max_depth = 5
population_size = 100
num_trials = 10
num_bouts = 7
p_reproduction = 0.08
p_crossover = 0.90
p_mutation = 0.01
p_alter = 0.01
terminals = ['X', 'R']
functions = [:+, :-, :*, :/]

best = search(max_generations, population_size, max_depth, num_trials, num_bouts, p_reproduction, p_crossover, p_mutation, p_alter, functions, terminals)
puts "done! Solution: f=#{best[:fitness]}, s=#{print_program(best[:program])}"



# puts "=> optiomal:"
# optimal = [:+, [:+, [:*, 'X', 'X'], 'X'], 1]
# puts print_program(optimal)
# puts eval_program(optimal, {'X'=>1.0})
# puts "optimal fitness: #{fitness(optimal, num_trials)}"
# 
# puts "=> /0:"
# puts eval_program([:/, 'X', 'X'], {'X'=>0.0})
# 
# puts "=> random:"
# r = generate_random_program(max_depth, node_functions, node_terminals)
# puts print_program(r)
# puts eval_program(r, {'X'=>1.0})
