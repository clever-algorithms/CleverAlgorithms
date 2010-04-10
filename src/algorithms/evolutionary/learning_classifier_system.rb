# Learning Classifier System in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def new_classifier(condition, action, gen)
  classifier = {}
  classifier[:action] = (rand()<0.5) ? '0' : '1'
  classifier[:condition] = (0...length).inject(""){|s,i|s<<['1','0','#'][rand(3)]}
  
  
  
  # last time used in a GA in an action set
  classifier[:last_match_time] = gen
  # p - average expected payoff
  classifier[:prediction_estimate] = 0.00001
  # eta - estimates errors made by predictions
  classifier[:estimated_error] = 0.00001
  # f - fitness
  classifier[:fitness] = 0.00001
  
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

def update_set(action_set, payoff, learning_rate, min_error)
  action_set.each do |c| 
    c[:experience] += 1.0
    if(c[:experience] < 1.0/learning_rate)
      c[:prediction_estimate] += (payoff-c[:prediction_estimate]) / c[:experience]
    else
      c[:prediction_estimate] += learning_rate*(payoff-c[:prediction_estimate])
    end    
    raise "bad prediction_estimate" if c[:prediction_estimate].nan? or c[:prediction_estimate].infinite?
  
    if(c[:experience] < 1.0/learning_rate)
      c[:estimated_error] += ((payoff-c[:prediction_estimate]).abs-c[:estimated_error]) / c[:experience]
    else
      c[:estimated_error] += learning_rate*((payoff-c[:prediction_estimate]).abs-c[:estimated_error])
    end
    raise "bad estimated_error" if c[:estimated_error].nan? or c[:estimated_error].infinite?
    
    if(c[:experience] < 1.0/learning_rate)
      classifier[:action_set_size] += (action_set.collect{|b| b[:num_classifier]-classifier[:action_set_size]}) / c[:experience]
    else
      classifier[:action_set_size] += learning_rate*(action_set.collect{|b| b[:num_classifier]-classifier[:action_set_size]})
    end
    raise "bad action_set_size" if c[:action_set_size].nan? or c[:action_set_size].infinite?
  end
end

def update_fitness(action_set, min_error, learning_rate, alpha, v)
  sum = 0
  accuracy = Arrau.new(action_set.length)
  action_set.each_with_index do |c,i|
    if c[:estimated_error] < min_error
      accuracy[i] = 1
    else
      accuracy[i] = alpha * (c[:estimated_error]/min_error)**-v
    end
    sum += accuracy[i] * c[:num_classifier]
  end
  action_set.each_with_index do |c,i|
    c[:fitness] += learning_rate * (accuracy[i] * c[:num_classifier] / sum - c[:fitness])
    raise "bad fitness" if c[:fitness].nan? or c[:fitness].infinite?
  end
end

def can_run_genetic_algorithm(action_set, gen, ga_frequency)
  s1 = action_set.inject(0) {|s,i| s += action_set[i][:last_match_time] * action_set[i][:num_classifier])}
  s2 = action_set.inject(0) {|s,i| s += action_set[i][:num_classifier])}
  if gen - (s1 / s2) > ga_frequency
    return true
  end
  return false
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
  return ""+parent1[:condition] if rand()>=p_crossover
  child = ""
  parent1[:condition].size.times do |i| 
    child << ((rand()<0.5) ? parent1[:condition][i] : parent2[:condition][i])
  end
  return child
end

def run_genetic_algorithm(population, action_set, instance, gen, p_crossover)
  p1, p2 = binary_tournament(action_set), binary_tournament(action_set)
  condition1,  = uniform_crossover(p1, p2, p_crossover)
  condition2 = uniform_crossover(p2, p1, p_crossover)  
  c1 = new_classifier(condition1, ""p1[:action], gen)
  c2 = new_classifier(condition2, ""p2[:action], gen)
  
end

def search(length, pop_size, max_generations, action_set, p_explore, learning_rate, min_error, alpha, v, ga_frequency, p_crossover)  
  population = []
  max_generations.times do |gen|
    instance = generate_problem_string(length)
    match_set = generate_match_set(instance, population, action_set, gen)
    prediction_array = generate_prediction(instance, match_set, action_set)    
    explore, action = select_action(prediction_array, p_explore)
    action_set = match_set.select{|c| c[:action]==action}
    # maximixing payoff, so wroing should equal zero
    payoff = 1.0 - (target_function(instance) - action).abs.to_f
    update_set(action_set, payoff, learning_rate, min_error)
    update_fitness(action_set, min_error, learning_rate, alpha, v)
    # do subsumption ???
    
    # run ga
    if can_run_genetic_algorithm(action_set, gen, ga_frequency)
      action_set.each do {|c| c[:last_match_time] = gen}
      run_genetic_algorithm(population, action_set, instance, p_crossover)
    end
    
    
    puts " > #{gen} "
  end
  
  return population
end



max_generations = 100
problem_size = 6
action_set = ['0', '1']
learning_rate = 0.1
min_error = 0.1
alpha = 0.1
v = 5
p_crossover = 0.95
p_mutation = 1.0/problem_size

#probability for exploration - look it up.
p_explore = 0.1
# num classifiers - what is used in some experiments?
pop_size = 100
# ???
ga_frequency = 10

population = search(problem_size, pop_size, max_generations, action_set, p_explore, 
  learning_rate, min_error, alpha, v, ga_frequency)
puts "done! Solution: "


# not decided yet
discount_factor = 0

p_crossover = 0.98
p_mutation = 1.0/problem_size
p_deletion = 0
