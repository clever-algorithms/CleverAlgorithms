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
  return arg1.__send__(node[0], arg2)
end

def generate_random_program
  
end

def reproduction(program)
  
end

def crossover(program1, program2)
  
end

def mutation(program)
  
end

def alter(program)
  
end

def search(max_generations, population_size, p_reproduction, p_crossover, p_mutation, p_alter, node_terminals, node_functions)
  
end

max_generations = 100
population_size = 100
p_reproduction = 0.08
p_crossover = 0.90
p_mutation = 0.01
p_alter = 0.01
node_terminals = {'X', 'R'}
node_functions = {:+, :-, :*, :/}

# best = search(max_generations, population_size, p_reproduction, p_crossover, p_mutation, p_alter, node_terminals, node_functions)
# puts "done! Solution: f=#{best[:fitness]}, s=#{print_program(best[:program])}"

optimal = [:+, [:+, [:*, 'X', 'X'], 'X'], 1]
puts print_program(optimal)

puts eval_program(optimal, {'X'=>1})