# Learning Classifier System in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def onemax(bitstring)
  sum = 0
  bitstring.each_char {|x| sum+=1 if x=='1'}
  return sum
end

def binary_tournament(population)
  s1, s2 = population[rand(population.size)], population[rand(population.size)]
  return (s1[:fitness] > s2[:fitness]) ? s1 : s2
end

def point_mutation(bitstring, prob_mutation)
  child = ""
  bitstring.size.times do |i|
    bit = bitstring[i]
    child << ((rand()<prob_mutation) ? ((bit=='1') ? "0" : "1") : bit)
  end
  return child
end

def uniform_crossover(parent1, parent2, p_crossover)
  return ""+parent1[:bitstring] if rand()>=p_crossover
  child = ""
  parent1[:bitstring].size.times do |i| 
    child << ((rand()<0.5) ? parent1[:bitstring][i] : parent2[:bitstring][i])
  end
  return child
end

def reproduce(selected, population_size, p_crossover, p_mutation)
  children = []  
  selected.each_with_index do |p1, i|    
    p2 = (i.even?) ? selected[i+1] : selected[i-1]
    child = {}
    child[:bitstring] = uniform_crossover(p1, p2, p_crossover)
    child[:bitstring] = point_mutation(child[:bitstring], p_mutation)
    children << child
  end
  return children
end



def new_classifier(condition, action, gen)
  classifier = {}
  classifier[:action] = (rand()<0.5) ? '0' : '1'
  classifier[:condition] = (0...length).inject(""){|s,i|s<<['1','0','#'][rand(3)]}
  
  
  
  # last time used in a GA in an action set
  classifier[:last_match_time] = gen
  # p - average expected payoff
  classifier[:prediction_estimate] = 0
  # eta - estimates errors made by predictions
  classifier[:estimated_error] = 0
  # f - fitness
  classifier[:fitness] = 0
  
  # exp - times used in an action set
  classifier[:experience] = 0
  # as = average size of the action set size this thing has belonged to
  classifier[:action_set_size] = 1
  #num = number of micro classifiers this classifer represents
  classifier[:num_classifier] = 1
  
  
  return classifier
end

def generate_random_classifier(length, action_set, gen)
  condition = (0...length).inject(""){|s,i|s<<['1','0','#'][rand(3)]}
  action = action_set[rand(action_set.length)]
  return new_classifier(condition, action, gen)
end

def generate_problem_string(length)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def neg(bit) 
  return (bit==1) ? 0 : 1 
end
  
def target_function(bitstring)
  v = []
  bitstring.each_char {|c| v<<c.to_i}
  x0,x1,x2,x3,x4,x5 = v
  return neg(x0)*neg(x1)*x2 + neg(x0)*x1*x3 + x0*neg(x1)*x4 + x0*x1*x5
end

def does_match(instance, condition)
  count = 0
  condition.each_char do |s|
    return false if s!='#' and instance[count]!=s
    count += 1 
  end
  return true
end

def get_actions(population)
  return [] if population.empty?
  set = {}
  population.each do |classifier|
    key = classifier[:action]
    set[key] = 0 if set[key].nil?
    set[key] += 1
  end 
  return set.keys
end

def generate_match_set(instance, population, action_set, gen)
  match_set = []  
  population.each do |classifier|
    match_set << classifier if does_match(instance, classifier[:condition])
    break if get_actions(match_set).length >= action_set.length
  end
  actions, c = nil, nil
  while (actions=get_actions(match_set)).length < action_set.length
    begin
      c = generate_random_classifier(instance.length, action_set, gen)
    end until does_match(instance, c[:condition]) and !actions.include?(c[:action])
    population << c
    match_set << c 
  end    
  # delete from population ???

  return match_set
end

def generate_prediction(instance, match_set)
  prediction = {}
  match_set.each do |classifier|
    key = classifier[:action]
    prediction[key] = {:sum=>0,:count=>0,:weight=>0.0} if prediction[key].nil?
    prediction[key]][:sum] += classifier[:prediction_estimate]*classifier[:fitness]
    prediction[key]][:count] += classifier[:fitness]
    # why not just count, why fitness?
  end
  prediction.keys.each do |key| 
    prediction[key][:weight]=prediction[key][:sum]/prediction[key][:count]
  end
  return prediction
end

def select_action(prediction_array, p_explore)
  keys = prediction_array.keys
  return true, keys[rand(keys.length)] if rand() < p_explore    
  keys.sort!{|x,y| prediction_array[y][:weight]<=>prediction_array[x][:weight]}  
  return false, keys.first
end

def search(length, max_generations, action_set, p_explore)  
  population = []  
  max_generations.times do |gen|
    instance = generate_problem_string(length)
    match_set = generate_match_set(instance, population, action_set, gen)
    prediction_array = generate_prediction(instance, match_set, action_set)    
    explore, action = select_action(prediction_array, p_explore)
    action_set = match_set.select{|c| c[:action]==action}
    
    # do learning for last action

    # run ga?
    
    # store this action as last action
    
    puts " > #{gen} "
  end
  
  
end



max_generations = 100
problem_size = 6
action_set = ['0', '1']

#probability for exploration
p_explore = 0.1


population = search(problem_size, max_generations, action_set, p_explore)
puts "done! Solution: "


# not decided yet
pop_size = 100
learning_rate = 0.1
discount_factor = 0
ga_frequency = 0

p_crossover = 0.98
p_mutation = 1.0/problem_size
p_deletion = 0

# lots of others....

num_rules = 50
num_bits = 64

# best = search(max_generations, num_bits, population_size, p_crossover, p_mutation)
# puts "done! Solution: f=#{best[:fitness]}, s=#{best[:bitstring]}"


