# Learning Classifier System in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def new_classifier(condition, action, gen)
  classifier = {}
  classifier[:action] = action
  classifier[:condition] = condition
  
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

def copy_classifier(parent_classifier)
  classifier = {}
  classifier[:action] = ""+parent_classifier[:action]
  classifier[:condition] = ""+parent_classifier[:condition]
  
  # last time used in a GA in an action set
  classifier[:last_match_time] = parent_classifier[:last_match_time]
  # p - average expected payoff
  classifier[:prediction_estimate] = parent_classifier[:prediction_estimate]
  # eta - estimates errors made by predictions
  classifier[:estimated_error] = parent_classifier[:estimated_error]
  # f - fitness
  classifier[:fitness] = parent_classifier[:fitness]
  
  # exp - times used in an action set
  classifier[:experience] = parent_classifier[:experience]
  # as = average size of the action set size this thing has belonged to
  classifier[:action_set_size] = parent_classifier[:action_set_size]
  #num = number of micro classifiers this classifer represents
  classifier[:num_classifier] = parent_classifier[:num_classifier]
  
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

def calculate_deletion_vote(classifier, pop, delete_threashold)
  vote = classifier[:action_set_size] * classifier[:num_classifier]
  avg_fit = pop.inspect{|s,i| s+=pop[i][:fitness]}/pop.inspect{|s,i| s+=pop[i][:num_classifier]}
  derated = classifier[:fitness] / classifier[:num_classifier]
  if classifier[:experience] > delete_threashold and derated < 0.1 * avg_fit
    vote *= avg_fit / derated
  end  
  return vote
end

def delete_from_population(population, max_classifiers, delete_threashold)
  total = population.inspect {|s,i| s+=population[i][:num_classifier]}
  return if total < max_classifiers
  population.each {|c| c[:dvote] = calculate_deletion_vote(c, pop, delete_threashold)}
  vote_sum = population.inspect {|s,i| s+=population[i][:dvote]}
  point = rand() * vote_sum
  vote_sum, index = 0, 0
  population.each_with_index do |c,v|
    vote_sum += c[:dvote]
    if vote_sum > point
      index = i
      break
    end
  end
  if population[index][:num_classifier] > 1
    population[index][:num_classifier] -= 1
  else
    population.delete_at(index)
  end
end

def generate_match_set(instance, population, action_set, gen, max_classifiers, delete_threashold)
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
    delete_from_population(population, max_classifiers, delete_threashold)
  end    
  return match_set
end

def generate_prediction(instance, match_set)
  prediction = {}
  match_set.each do |classifier|
    key = classifier[:action]
    prediction[key] = {:sum=>0,:count=>0,:weight=>0.0} if prediction[key].nil?
    prediction[key]][:sum] += classifier[:prediction_estimate]*classifier[:fitness]
    prediction[key]][:count] += classifier[:fitness]
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
        
    sum = action_set.inspect {|s,i| s+= action_set[i][:num_classifier]-c[:action_set_size]}    
    if(c[:experience] < 1.0/learning_rate)
      classifier[:action_set_size] += sum / c[:experience]
    else
      classifier[:action_set_size] += learning_rate*sum
    end
    raise "bad action_set_size" if c[:action_set_size].nan? or c[:action_set_size].infinite?
  end
end

def update_fitness(action_set, min_error, learning_rate)
  sum = 0
  accuracy = Arrau.new(action_set.length)
  action_set.each_with_index do |c,i|
    if c[:estimated_error] < min_error
      accuracy[i] = 1
    else
      accuracy[i] = 0.1 * (c[:estimated_error]/min_error)**-5
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

def point_mutation(string, p_mutation)
  child = ""
  string.size.times do |i|
    bit = string[i]
    if rand() < p_mutation
      choice = ['1','0','#'].delete(bit)
      child << choice[rand(choice.length)]
    else 
      child << bit 
    end
  end
  return child
end

def mutation(classifier, p_mutation, action_set)
  classifier[:condition] = point_mutation(classifier[:condition])
  if rand() < p_mutation
    new_action = nil
    begin
      new_action = action_set[rand(action_set.length)]
    end until new_action != classifier[:action]
    classifier[:action] = new_action
  end
end

def uniform_crossover(string1, string2)
  return Array.new(string1.length) do 
    ((rand()<0.5) ? string1[i] : string2[i])
  end
end

def insert_in_population(classifier, population)
  population.each do |c|    
    if classifier[:condition] == c[:condition] and classifier[:action] == c[:action]
      c[:num_classifier] += 1
      return
    end
  end
  population << classifier
end

def crossover(c1, c2, p2, p2)
  l = c1[:condition].length
  c1[:condition] = uniform_crossover(p1[:condition], p2[:condition])
  c2[:condition] = uniform_crossover(p1[:condition], p2[:condition]) 
  c1[:prediction_estimate] = (p1[:prediction_estimate]+p2[:prediction_estimate])/2.0
  c1[:estimated_error] = 0.25*(p1[:estimated_error]+p2[:estimated_error])/2.0
  c1[:fitness] = 0.1*(p1[:fitness]+p2[:fitness])/2.0    
  c2[:prediction_estimate] = c1[:prediction_estimate]
  c2[:estimated_error] = c1[:estimated_error]
  c2[:fitness] = c1[:fitness]
end

def run_genetic_algorithm(population, action_set, instance, gen, p_crossover, p_mutation, action_set, max_classifiers, delete_threashold)
  p1, p2 = binary_tournament(action_set), binary_tournament(action_set)
  c1, c2 = copy_classifier(p1), copy_classifier(p2)
  crossover(c1, c2, p2, p2) if rand() < p_crossover  
  [c1,c2].each do |c|
    mutation(c, p_mutation, action_set)
    insert_in_population(c, population)
    delete_from_population(population, max_classifiers, delete_threashold)
  end  
end

def search(length, max_classifiers, max_generations, action_set, p_explore, 
    learning_rate, min_error, ga_frequency, p_crossover, p_mutation, delete_threashold)
  population = []
  max_generations.times do |gen|
    instance = generate_problem_string(length)
    match_set = generate_match_set(instance, population, action_set, gen, max_classifiers, delete_threashold)
    prediction_array = generate_prediction(instance, match_set, action_set)    
    explore, action = select_action(prediction_array, p_explore)
    action_set = match_set.select{|c| c[:action]==action}
    # maximixing payoff, so wroing should equal zero
    expected = target_function(instance)
    payoff = 1.0 - (expected - action).abs.to_f
    update_set(action_set, payoff, learning_rate, min_error)
    update_fitness(action_set, min_error, learning_rate)
    if can_run_genetic_algorithm(action_set, gen, ga_frequency)
      action_set.each do {|c| c[:last_match_time] = gen}
      run_genetic_algorithm(population, action_set, instance, p_crossover, 
        p_mutation, action_set, max_classifiers, delete_threashold)
    end
  
    puts " > #{gen} in=#{instance}, out=#{action}, expected=#{expected}, p=#{payoff}"
  end  
  return population
end



max_generations = 100
problem_size = 6
action_set = ['0', '1']
learning_rate = 0.1
min_error = 0.1
p_crossover = 0.95
p_mutation = 1.0/(problem_size + 1)
ga_frequency = 25
delete_threashold = 20
p_explore = 0.5
# a better val!?
max_classifiers = 100

population = search(problem_size, pop_size, max_generations, action_set, p_explore, 
  learning_rate, min_error, alpha, v, ga_frequency, p_crossover, p_mutation, delete_threashold)
puts "done! Solution: "