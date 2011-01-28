# Cultural Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def rand_in_bounds(min, max)
  return min + ((max-min) * rand()) 
end

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    rand_in_bounds(minmax[i][0], minmax[i][1])
  end
end

def mutate_with_inf(candidate, beliefs, minmax)
  v = Array.new(candidate[:vector].size)
  candidate[:vector].each_with_index do |c,i|
    v[i]=rand_in_bounds(beliefs[:normative][i][0],beliefs[:normative][i][1])
    v[i] = minmax[i][0] if v[i] < minmax[i][0]
    v[i] = minmax[i][1] if v[i] > minmax[i][1]
  end
  return {:vector=>v}
end
  
def binary_tournament(pop)
  i, j = rand(pop.size), rand(pop.size)
  j = rand(pop.size) while j==i
  return (pop[i][:fitness] < pop[j][:fitness]) ? pop[i] : pop[j]
end

def initialize_beliefspace(search_space)
  belief_space = {}
  belief_space[:situational] = nil
  belief_space[:normative] = Array.new(search_space.size) do |i| 
    Array.new(search_space[i])  
  end
  return belief_space
end

def update_beliefspace_situational!(belief_space, best)
  curr_best = belief_space[:situational]
  if curr_best.nil? or best[:fitness] < curr_best[:fitness]
    belief_space[:situational] = best
  end
end

def update_beliefspace_normative!(belief_space, acc)
  belief_space[:normative].each_with_index do |bounds,i|
    bounds[0] = acc.min{|x,y| x[:vector][i]<=>y[:vector][i]}[:vector][i]
    bounds[1] = acc.max{|x,y| x[:vector][i]<=>y[:vector][i]}[:vector][i]
  end
end

def search(max_gens, search_space, pop_size, num_accepted)
  # initialize
  pop = Array.new(pop_size) { {:vector=>random_vector(search_space)} }
  belief_space = initialize_beliefspace(search_space)  
  # evaluate
  pop.each{|c| c[:fitness] = objective_function(c[:vector])}
  best = pop.sort{|x,y| x[:fitness] <=> y[:fitness]}.first
  # update situational knowledge
  update_beliefspace_situational!(belief_space, best)
  max_gens.times do |gen|
    # create next generation
    children = Array.new(pop_size) do |i| 
      mutate_with_inf(pop[i], belief_space, search_space) 
    end
    # evaluate
    children.each{|c| c[:fitness] = objective_function(c[:vector])}    
    best = children.sort{|x,y| x[:fitness] <=> y[:fitness]}.first
    # update situational knowledge
    update_beliefspace_situational!(belief_space, best)
    # select next generation    
    pop = Array.new(pop_size) { binary_tournament(children + pop) }
    # update normative knowledge
    pop.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    acccepted = pop[0...num_accepted]
    update_beliefspace_normative!(belief_space, acccepted)
    # user feedback
    puts " > generation=#{gen}, f=#{belief_space[:situational][:fitness]}"
  end  
  return belief_space[:situational]
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_gens = 200
  pop_size = 100
  num_accepted = (pop_size*0.20).round
  # execute the algorithm
  best = search(max_gens, search_space, pop_size, num_accepted)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector].inspect}"
end