# Learning Classifier System in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def new_classifier(condition, action, gen)
  classifier = {}
  classifier[:action] = action
  classifier[:condition] = condition
  classifier[:lasttime] = gen
  classifier[:prediction] = 1.0
  classifier[:error] = 0.00001
  classifier[:fitness] = 1.0
  classifier[:experience] = 0.0
  classifier[:setsize] = 1.0
  classifier[:num] = 1.0
  return classifier
end

def copy_classifier(parent_classifier)
  classifier = {}
  classifier[:action] = ""+parent_classifier[:action]
  classifier[:condition] = ""+parent_classifier[:condition]
  classifier[:lasttime] = parent_classifier[:lasttime]
  classifier[:prediction] = parent_classifier[:prediction]
  classifier[:error] = parent_classifier[:error]
  classifier[:fitness] = parent_classifier[:fitness]
  classifier[:experience] = parent_classifier[:experience]
  classifier[:setsize] = parent_classifier[:setsize]
  classifier[:num] = parent_classifier[:num]
  return classifier
end

def generate_random_classifier(length, all_actions, gen)
  condition = (0...length).inject(""){|s,i|s+['1','0','#'][rand(3)]}
  action = all_actions[rand(all_actions.length)]
  return new_classifier(condition, action, gen)
end

def generate_problem_string(length)
  return (0...length).inject(""){|s,i| s+((rand<0.5) ? "1" : "0")}
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

def calculate_deletion_vote(classifier, pop, delete_threashold)
  vote = classifier[:setsize] * classifier[:num]
  avg_fit = pop.inject(0.0){|s,c| s+c[:fitness]}/pop.inject(0.0){|s,c| s+c[:num]}
  derated = classifier[:fitness] / classifier[:num]
  if classifier[:experience] > delete_threashold and derated < 0.1 * avg_fit
    vote *= avg_fit / derated
  end  
  return vote
end

def delete_from_population(population, max_classifiers, delete_threashold)
  total = population.inject(0.0) {|s,c| s+c[:num]}
  return if total < max_classifiers
  population.each {|c| c[:dvote] = calculate_deletion_vote(c, population, delete_threashold)}
  vote_sum = population.inject(0.0) {|s,c| s+c[:dvote]}
  point = rand() * vote_sum
  vote_sum, index = 0.0, 0
  population.each_with_index do |c,i|
    vote_sum += c[:dvote]
    if vote_sum > point
      index = i
      break
    end
  end
  if population[index][:num] > 1
    population[index][:num] -= 1
  else
    population.delete_at(index)
  end
end

def does_match(instance, condition)  
  c1, c2 = [], []
  instance.each_char {|c| c1<<c}
  condition.each_char {|c| c2<<c}
  c2.each_with_index do |c, i|
    return false if (c!='#' and c!=c1[i])
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

def generate_match_set(instance, population, all_actions, gen, max_classifiers, delete_threashold)
  match_set = population.select{|c| does_match(instance, c[:condition])}
  actions = get_actions(match_set)
  while actions.length < all_actions.length do
    c = nil
    begin
      c = generate_random_classifier(instance.length, all_actions, gen)
    end until does_match(instance, c[:condition]) and !actions.include?(c[:action])
    population << c
    match_set << c
    delete_from_population(population, max_classifiers, delete_threashold)
    actions = get_actions(match_set)
  end
  return match_set
end

def generate_prediction(instance, match_set) 
  prediction = {}
  match_set.each do |classifier|
    key = classifier[:action]
    prediction[key] = {:sum=>0,:count=>0,:weight=>0.0} if prediction[key].nil?
    prediction[key][:sum] += classifier[:prediction]*classifier[:fitness]
    prediction[key][:count] += classifier[:fitness]
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

def update_set(action_set, payoff, learning_rate)
  action_set.each do |c| 
    c[:experience] += 1.0
    if(c[:experience] < 1.0/learning_rate)
      c[:prediction] += (payoff-c[:prediction]) / c[:experience]
    else
      c[:prediction] += learning_rate*(payoff-c[:prediction])
    end    
    ##### DELETE
    raise "bad prediction_estimate" if c[:prediction].nan? or c[:prediction].infinite?
  
    if(c[:experience] < 1.0/learning_rate)
      c[:error] += ((payoff-c[:prediction]).abs.to_f-c[:error]) / c[:experience]
    else
      c[:error] += learning_rate*((payoff-c[:prediction]).abs.to_f-c[:error])
    end
    ##### DELETE
    raise "bad estimated_error" if c[:error].nan? or c[:error].infinite?
        
    sum = action_set.inject(0.0) {|s,classifier| s+classifier[:num]-c[:setsize]}    
    if(c[:experience] < 1.0/learning_rate)
      c[:setsize] += sum / c[:experience]
    else
      c[:setsize] += learning_rate*sum
    end
    ##### DELETE
    raise "bad action_set_size" if c[:setsize].nan? or c[:setsize].infinite?
  end
end

def update_fitness(action_set, min_error, learning_rate)
  sum = 0.0
  accuracy = Array.new(action_set.length)
  action_set.each_with_index do |c,i|
    if c[:error] < min_error
      accuracy[i] = 1.0
    else
      accuracy[i] = 0.1 * (c[:error]/min_error)**-5.0
    end
    sum += accuracy[i] * c[:num]
  end
  action_set.each_with_index do |c,i|
    c[:fitness] += learning_rate * (accuracy[i] * c[:num] / sum - c[:fitness])
    ##### DELETE
    raise "bad fitness" if c[:fitness].nan? or c[:fitness].infinite?
  end
end

def can_run_genetic_algorithm(action_set, gen, ga_frequency)
  s1 = action_set.inject(0.0) {|s,c| s+c[:lasttime]*c[:num]}
  s2 = action_set.inject(0.0) {|s,c| s+c[:num]}
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
      choice = ['1','0','#']
      choice.delete(bit)
      child << choice[rand(choice.length)]
    else 
      child << bit 
    end
  end
  return child
end

def mutation(classifier, p_mutation, action_set)
  classifier[:condition] = point_mutation(classifier[:condition], p_mutation)
  if rand() < p_mutation
    new_action = nil
    begin
      new_action = action_set[rand(action_set.length)]
    end until new_action != classifier[:action]
    classifier[:action] = new_action
  end
end

def uniform_crossover(string1, string2)
  return Array.new(string1.length) do |i|
    ((rand()<0.5) ? string1[i] : string2[i])
  end
end

def insert_in_population(classifier, population)
  population.each do |c|    
    if classifier[:condition] == c[:condition] and classifier[:action] == c[:action]
      c[:num] += 1
      return
    end
  end
  population << classifier
end

def crossover(c1, c2, p1, p2)
  l = c1[:condition].length
  c1[:condition] = uniform_crossover(p1[:condition], p2[:condition])
  c2[:condition] = uniform_crossover(p1[:condition], p2[:condition]) 
  c1[:prediction] = (p1[:prediction]+p2[:prediction])/2.0
  c1[:error] = 0.25*(p1[:error]+p2[:error])/2.0
  c1[:fitness] = 0.1*(p1[:fitness]+p2[:fitness])/2.0    
  c2[:prediction] = c1[:prediction]
  c2[:error] = c1[:error]
  c2[:fitness] = c1[:fitness]
end

def run_genetic_algorithm(all_actions, population, action_set, instance, gen, 
    p_crossover, p_mutation, max_classifiers, delete_threashold)
  p1, p2 = binary_tournament(action_set), binary_tournament(action_set)
  c1, c2 = copy_classifier(p1), copy_classifier(p2)
  crossover(c1, c2, p1, p2) if rand() < p_crossover  
  [c1,c2].each do |c|
    mutation(c, p_mutation, all_actions)
    insert_in_population(c, population)
    delete_from_population(population, max_classifiers, delete_threashold)
  end  
end

def search(length, max_classifiers, max_generations, all_actions, p_explore, 
    learning_rate, min_error, ga_frequency, p_crossover, p_mutation, delete_threashold)
  pop, abs = [], 0.0
  # max_classifiers.times {pop<<generate_random_classifier(length, all_actions, 0)}
  max_generations.times do |gen|
    instance = generate_problem_string(length)
    match_set = generate_match_set(instance, pop, all_actions, gen, max_classifiers, delete_threashold)
    prediction_array = generate_prediction(instance, match_set)    
    explore, action = select_action(prediction_array, p_explore)
    action_set = match_set.select{|c| c[:action]==action}
    expected = target_function(instance)
    payoff = ((expected-action.to_i)==0) ? 300.0 : 1.0
    abs += (expected - action.to_i).abs.to_f
    update_set(action_set, payoff, learning_rate)
    update_fitness(action_set, min_error, learning_rate)
    if can_run_genetic_algorithm(action_set, gen, ga_frequency)
      action_set.each {|c| c[:lasttime] = gen}
      run_genetic_algorithm(all_actions, pop, action_set, instance, gen, p_crossover, 
        p_mutation, max_classifiers, delete_threashold)
    end
    if (gen+1).modulo(50)==0
      puts " >gen=#{gen+1} num=#{pop.size}, error=#{abs}/50 (#{(abs/50*100)}%)"
      abs = 0
    end
  end  
  return pop
end

max_generations = 10000
length = 6
all_actions = ['0', '1']
learning_rate = 0.2
min_error = 0.01
p_crossover = 0.80
p_mutation = 0.04
ga_frequency = 25
delete_threashold = 20
p_explore = 0.30
max_classifiers = 100

population = search(length, max_classifiers, max_generations, all_actions, p_explore, 
    learning_rate, min_error, ga_frequency, p_crossover, p_mutation, delete_threashold)
puts "done! Solution: classifiers=#{population.size}"