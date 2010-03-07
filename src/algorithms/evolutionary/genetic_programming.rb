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

def replace_node(node, replacement, node_num, current_node=0)
  return replacement,(current_node+1) if current_node == node_num
  return node,(current_node+1) if !node.kind_of? Array
  a1, current_node = replace_node(node[1], replacement, node_num, current_node+1)
  a2, current_node = replace_node(node[2], replacement, node_num, current_node)
  return [node[0], a1, a2], current_node
end

def copy_program(node)
  return node if !node.kind_of? Array
  return [node[0], copy_program(node[1]), copy_program(node[2])]
end

def get_node(node, node_num, current_node=0)
  return node,(current_node+1) if current_node == node_num
  return nil,(current_node+1) if !node.kind_of? Array
  a1, current_node = getNode(node[1], node_num, current_node+1)
  return a1 if !a1.nil?
  a2, current_node = getNode(node[2], node_num, current_node)
  return a2 if !a2.nil?
  return nil
end

def crossover(parent1, parent2)
  sensis1, sensis2 = program_sensis(parent1), program_sensis(parent2)
  point1, point2 = rand(sensis1[0]+sensis1[1]), rand(sensis2[0]+sensis2[1])
  tree1, tree2 = get_node(parent1, point1), get_node(parent2, point2)
  # TODO remove this once we're happy!
  raise "Oh No" if tree1.nil? or tree2.nil?
  child1 = replace_node(parent1, copy_program(tree1), point1)
  child2 = replace_node(parent2, copy_program(tree2), point2)
  return child1, child2
end

def mutation(parent, max_depth, functions, terminals)
  sensis = program_sensis(parent)
  point = rand(sensis[0]+sensis[1])
  random_tree = generate_random_program(max_depth/2, functions, terminals)
  child = replace_node(parent, random_tree, point)
  return child
end

def search(max_generations, population_size, max_depth, num_trials, num_bouts, p_reproduction, p_crossover, p_mutation, p_alter, functions, terminals)
  population = Array.new(population_size) do |i| 
    {:program=>generate_random_program(max_depth, functions, terminals)}
  end
  population.each{|c| c[:fitness] = fitness(c[:program], num_trials)}
  best = population.sort{|x,y| x[:fitness] <=> y[:fitness]}.first
  max_generations.times do |gen|
    children = []
    while children.length < population_size
      # TODO probabilities
      
      # reproduction
      candidate = tournament_selection(population, num_bouts)
      child = {}
      child[:program] = copy_program(candidate[:program])
      children << child
    
      # crossover
      # p1 = tournament_selection(population, num_bouts)
      # p2 = tournament_selection(population, num_bouts)
      # child1, child2 = {}, {}
      # child1[:program], child2[:program] = crossover(p1, p2)
      # children << child1
      # children << child2
    
      # mutation      
      # candidate = tournament_selection(population, num_bouts)
      # child = {}
      # child[:program] = mutation(candidate[:program], max_depth, functions, terminals)
      # children << child
    
      # TODO alteration???
      
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