# Genetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def binary_tournament(pop)
  i, j = rand(pop.size), rand(pop.size)
  return (pop[i][:fitness] < pop[j][:fitness]) ? pop[i] : pop[j]
end

def point_mutation(grammar, genome, head_length, rate=1.0/genome.size.to_f)
  child =""
  genome.size.times do |i|
    bit = genome[i].chr
    if rand() < rate
      if i < head_length
        selection = (rand() < 0.5) ? grammar["FUNC"]: grammar["TERM"]
        bit = selection[rand(selection.size)]
      else
        bit = grammar["TERM"][rand(grammar["TERM"].size)]
      end
    end
    child << bit
  end
  return child
end

def crossover(parent1, parent2, rate)
  return ""+parent1 if rand()>=rate
  child = ""
  parent1.size.times do |i| 
    child << ((rand()<0.5) ? parent1[i] : parent2[i])
  end
  return child
end

def reproduce(grammar, selected, pop_size, p_crossover, head_length)
  children = []  
  selected.each_with_index do |p1, i|    
    p2 = (i.modulo(2)==0) ? selected[i+1] : selected[i-1]
    p2 = selected[0] if i == selected.size-1
    child = {}
    child[:genome] = crossover(p1[:genome], p2[:genome], p_crossover)
    child[:genome] = point_mutation(grammar, child[:genome], head_length)
    children << child
  end
  return children
end

def random_genome(grammar, head_length, tail_length)
  s = ""
  head_length.times do 
    selection = (rand() < 0.5) ? grammar["FUNC"]: grammar["TERM"]
    s << selection[rand(selection.size)]
  end 
  tail_length.times { s << grammar["TERM"][rand(grammar["TERM"].size)]}
  return s
end

def target_function(x)
  return x**4.0 + x**3.0 + x**2.0 + x
end

def sample_from_bounds(bounds)
  return bounds[0] + ((bounds[1] - bounds[0]) * rand())
end

def cost(program, bounds, num_trials=30)
  errors = 0.0    
  num_trials.times do
    x = sample_from_bounds(bounds)
    expression, score = program.gsub("x", x.to_s), 0.0
    begin score = eval(expression) rescue score = 0.0/0.0 end
    return 9999999 if score.nan? or score.infinite?
    errors += (score - target_function(x)).abs
  end    
  return errors / num_trials.to_f
end

def mapping(genome, grammar)
  off, queue = 0, []
  root = {}
  root[:node] = genome[off].chr; off+=1
  queue.push(root)
  while !queue.empty? do
    current = queue.shift
    if grammar["FUNC"].include?(current[:node])
      current[:left] = {}
      current[:left][:node] = genome[off].chr; off+=1 
      queue.push(current[:left])
      current[:right] = {}
      current[:right][:node] = genome[off].chr; off+=1
      queue.push(current[:right])
    end
  end
  return root
end

def tree_to_string(exp)
  return exp[:node] if (exp[:left].nil? or exp[:right].nil?)
  left = tree_to_string(exp[:left])
  right = tree_to_string(exp[:right])
  return "(#{left} #{exp[:node]} #{right})"
end

def evaluate(candidate, grammar, bounds)
  candidate[:expression] = mapping(candidate[:genome], grammar)
  candidate[:program] = tree_to_string(candidate[:expression])
  candidate[:fitness] = cost(candidate[:program], bounds)
end

def search(grammar, bounds, h_length, t_length, max_gens, pop_size, p_cross)
  pop = Array.new(pop_size) do
    {:genome=>random_genome(grammar, h_length, t_length)}
  end
  pop.each{|c| evaluate(c, grammar, bounds)}
  best = pop.sort{|x,y| x[:fitness] <=> y[:fitness]}.first  
  max_gens.times do |gen|
    selected = Array.new(pop){|i| binary_tournament(pop)}
    children = reproduce(grammar, selected, pop_size, p_cross, h_length)    
    children.each{|c| evaluate(c, grammar, bounds)}
    children.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = children.first if children.first[:fitness] <= best[:fitness]
    pop = (children+pop).first(pop_size)
    puts " > gen=#{gen}, f=#{best[:fitness]}, g=#{best[:genome]}"
  end  
  return best
end

if __FILE__ == $0
  # problem configuration
  grammar = {"FUNC"=>["+","-","*","/"], "TERM"=>["x"]}
  bounds = [1.0, 10.0]
  # algorithm configuration
  h_length = 20
  t_length = h_length * (2-1) + 1
  max_gens = 150
  pop_size = 80
  p_cross = 0.85
  # execute the algorithm
  best = search(grammar, bounds, h_length, t_length, max_gens, pop_size, p_cross)
  puts "done! Solution: f=#{best[:fitness]}, program=#{best[:program]}"
end
