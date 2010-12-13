# Genetic Programming in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_num(min, max)
  return min + (max-min)*rand()
end

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
  if depth==max-1 or (depth>1 and rand()<0.1)
    t = terms[rand(terms.size)] 
    return ((t=='R') ? random_num(-5.0, +5.0) : t)
  end  
  depth += 1 
  arg1 = generate_random_program(max, funcs, terms, depth)
  arg2 = generate_random_program(max, funcs, terms, depth)
  return [funcs[rand(funcs.size)], arg1, arg2]
end

def count_nodes(node)
  return 1 if !node.kind_of? Array
  a1 = count_nodes(node[1])
  a2 = count_nodes(node[2])
  return a1+a2+1
end

def target_function(input)
  return input**2 + input + 1
end

def fitness(program, num_trials)
  sum_error = 0.0
  num_trials.times do |i|
    input = random_num(-1.0, 1.0)
    error = eval_program(program, {'X'=>input}) - target_function(input)
    sum_error += error**2.0
  end
  return Math.sqrt(sum_error/num_trials.to_f)
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
  current_node += 1
  return node,current_node if !node.kind_of? Array
  a1, current_node = replace_node(node[1], replacement, node_num, current_node)
  a2, current_node = replace_node(node[2], replacement, node_num, current_node)
  return [node[0], a1, a2], current_node
end

def copy_program(node)
  return node if !node.kind_of? Array
  return [node[0], copy_program(node[1]), copy_program(node[2])]
end

def get_node(node, node_num, current_node=0)
  return node,(current_node+1) if current_node == node_num
  current_node += 1
  return nil,current_node if !node.kind_of? Array
  a1, current_node = get_node(node[1], node_num, current_node)
  return a1,current_node if !a1.nil?
  a2, current_node = get_node(node[2], node_num, current_node)
  return a2,current_node if !a2.nil?
  return nil,current_node
end

def prune(node, max_depth, terms, depth=0)
  if depth >= max_depth-1
    t = terms[rand(terms.size)] 
    return ((t=='R') ? random_num(-5.0, +5.0) : t)
  end
  depth += 1
  return node if !node.kind_of? Array
  a1 = prune(node[1], max_depth, terms, depth)
  a2 = prune(node[2], max_depth, terms, depth)
  return [node[0], a1, a2]
end

def crossover(parent1, parent2, max_depth, terms)
  pt1, pt2 = rand(count_nodes(parent1)-2)+1, rand(count_nodes(parent2)-2)+1
  tree1, c1 = get_node(parent1, pt1)
  tree2, c2 = get_node(parent2, pt2)  
  child1, c1 = replace_node(parent1, copy_program(tree2), pt1)
  child1 = prune(child1, max_depth, terms)
  child2, c2 = replace_node(parent2, copy_program(tree1), pt2)
  child2 = prune(child2, max_depth, terms)
  return child1, child2
end

def mutation(parent, max_depth, functions, terms)  
  random_tree = generate_random_program(max_depth/2, functions, terms)
  point = rand(count_nodes(parent))
  child, count = replace_node(parent, random_tree, point)
  child = prune(child, max_depth, terms)
  return child
end

def search(max_generations, population_size, max_depth, num_trials, num_bouts, p_reproduction, p_crossover, p_mutation, functions, terminals)
  population = Array.new(population_size) do |i| 
    {:program=>generate_random_program(max_depth, functions, terminals)}
  end
  population.each{|c| c[:fitness] = fitness(c[:program], num_trials)}
  best = population.sort{|x,y| x[:fitness] <=> y[:fitness]}.first
  max_generations.times do |gen|
    children = []
    while children.size < population_size
      operation = rand()
      parent = tournament_selection(population, num_bouts)
      child = {}      
      if operation < p_reproduction
        child[:program] = copy_program(parent[:program])
      elsif operation < p_reproduction+p_crossover
        p2 = tournament_selection(population, num_bouts)
        c2 = {}
        child[:program], c2[:program] = crossover(parent[:program], p2[:program], max_depth, terminals)
        children << c2
      elsif operation < p_reproduction+p_crossover+p_mutation
        child[:program] = mutation(parent[:program], max_depth, functions, terminals)      
      end
      children << child if children.size < population_size      
    end    
    children.each{|c| c[:fitness] = fitness(c[:program], num_trials)}
    population = children
    population.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = population.first if population.first[:fitness] <= best[:fitness]
    puts " > gen #{gen}, fitness=#{best[:fitness]}"
    break if best[:fitness] == 0
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  terminals = ['X', 'R']
  functions = [:+, :-, :*, :/]
  # algorithm configuration
  max_generations = 100
  max_depth = 7
  population_size = 100
  num_trials = 15
  num_bouts = 5
  p_reproduction = 0.08
  p_crossover = 0.90
  p_mutation = 0.02
  # execute the algorithm
  best = search(max_generations, population_size, max_depth, num_trials, num_bouts, p_reproduction, p_crossover, p_mutation, functions, terminals)
  puts "done! Solution: f=#{best[:fitness]}, s=#{print_program(best[:program])}"
end