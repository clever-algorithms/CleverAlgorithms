# Learning Classifier System in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def neg(bit) 
  return (bit==1) ? 0 : 1 
end
  
def target_function(s)
  ints = Array.new(6){|i| s[i].chr.to_i}
  x0,x1,x2,x3,x4,x5 = ints
  return neg(x0)*neg(x1)*x2 + neg(x0)*x1*x3 + x0*neg(x1)*x4 + x0*x1*x5
end

def new_classifier(condition, action, gen, p1=10.0, e1=0.0, f1=10.0)
  other = {}
  other[:condition],other[:action],other[:lasttime] = condition, action, gen
  other[:pred], other[:error], other[:fitness] = p1, e1, f1
  other[:exp], other[:setsize], other[:num] = 0.0, 1.0, 1.0
  return other
end

def copy_classifier(parent)
  copy = {}  
  parent.keys.each do |k| 
    copy[k] = (parent[k].kind_of? String) ? ""+parent[k] : parent[k]
  end
  copy[:num],copy[:exp] = 1.0, 0.0
  return copy
end

def random_bitstring(size=6)
  return (0...size).inject(""){|s,i| s+((rand<0.5) ? "1" : "0")}
end

def calculate_deletion_vote(classifier, pop, del_thresh, f_thresh=0.1)
  vote = classifier[:setsize] * classifier[:num]
  total = pop.inject(0.0){|s,c| s+c[:num]}
  avg_fitness = pop.inject(0.0){|s,c| s + (c[:fitness]/total)}
  derated = classifier[:fitness] / classifier[:num].to_f
  if classifier[:exp]>del_thresh and derated<(f_thresh*avg_fitness)
    return vote * (avg_fitness / derated)
  end  
  return vote
end

def delete_from_pop(pop, pop_size, del_thresh=20.0)
  total = pop.inject(0) {|s,c| s+c[:num]}
  return if total <= pop_size
  pop.each {|c| c[:dvote] = calculate_deletion_vote(c, pop, del_thresh)}
  vote_sum = pop.inject(0.0) {|s,c| s+c[:dvote]}
  point = rand() * vote_sum
  vote_sum, index = 0.0, 0
  pop.each_with_index do |c,i|
    vote_sum += c[:dvote]
    if vote_sum >= point
      index = i
      break
    end
  end
  if pop[index][:num] > 1
    pop[index][:num] -= 1
  else
    pop.delete_at(index)
  end
end

def generate_random_classifier(input, actions, gen, rate=1.0/3.0)
  condition = ""
  input.size.times {|i| condition << ((rand<rate) ? '#' : input[i].chr)}
  action = actions[rand(actions.size)]
  return new_classifier(condition, action, gen)
end

def does_match?(input, condition)
  input.size.times do |i|
    return false if condition[i].chr!='#' and input[i].chr!=condition[i].chr
  end  
  return true
end

def get_actions(pop)
  actions = []
  pop.each do |c|
    actions << c[:action] if !actions.include?(c[:action])
  end
  return actions
end

def generate_match_set(input, pop, all_actions, gen, pop_size)
  match_set = pop.select{|c| does_match?(input, c[:condition])}
  actions = get_actions(match_set)
  while actions.size < all_actions.size do
    remaining = all_actions - actions
    classifier = generate_random_classifier(input, remaining, gen)
    pop << classifier
    match_set << classifier
    delete_from_pop(pop, pop_size)
    actions << classifier[:action]
  end
  return match_set
end

def generate_prediction(match_set)
  pred = {}
  match_set.each do |classifier|
    key = classifier[:action]
    pred[key] = {:sum=>0.0,:count=>0.0,:weight=>0.0} if pred[key].nil?
    pred[key][:sum] += classifier[:pred]*classifier[:fitness]
    pred[key][:count] += classifier[:fitness]
  end
  pred.keys.each do |key| 
    pred[key][:weight] = 0.0
    if pred[key][:count] > 0
      pred[key][:weight] = pred[key][:sum]/pred[key][:count]
    end    
  end
  return pred
end

def select_action(predictions, p_explore=false)
  keys = Array.new(predictions.keys)
  return keys[rand(keys.size)] if p_explore
  keys.sort!{|x,y| predictions[y][:weight]<=>predictions[x][:weight]}
  return keys.first
end

def update_set(action_set, reward, beta=0.2)  
  sum = action_set.inject(0.0) {|s,other| s+other[:num]}
  action_set.each do |c| 
    c[:exp] += 1.0   
    if c[:exp] < 1.0/beta
	      c[:error] = (c[:error]*(c[:exp]-1.0)+(reward-c[:pred]).abs)/c[:exp]
	      c[:pred] = (c[:pred] * (c[:exp]-1.0) + reward) / c[:exp]
	      c[:setsize] = (c[:setsize]*(c[:exp]-1.0)+sum) / c[:exp]
	  else
	      c[:error] += beta * ((reward-c[:pred]).abs - c[:error])
	      c[:pred] += beta * (reward-c[:pred])
	      c[:setsize] += beta * (sum - c[:setsize])
	  end    
  end
end

def update_fitness(action_set, min_error=10, l_rate=0.2, alpha=0.1, v=-5.0)
  sum = 0.0
  acc = Array.new(action_set.size)
  action_set.each_with_index do |c,i|
    acc[i] = (c[:error]<min_error) ? 1.0 : alpha*(c[:error]/min_error)**v
    sum += acc[i] * c[:num].to_f
  end
  action_set.each_with_index do |c,i|
    c[:fitness] += l_rate * ((acc[i] * c[:num].to_f) / sum - c[:fitness])
  end
end

def can_run_genetic_algorithm(action_set, gen, ga_freq)
  return false if action_set.size <= 2
  total = action_set.inject(0.0) {|s,c| s+c[:lasttime]*c[:num]}
  sum = action_set.inject(0.0) {|s,c| s+c[:num]}
  return true if gen - (total/sum) > ga_freq
  return false
end

def binary_tournament(pop)
  i, j = rand(pop.size), rand(pop.size)
  j = rand(pop.size) while j==i
  return (pop[i][:fitness] > pop[j][:fitness]) ? pop[i] : pop[j]
end

def mutation(cl, action_set, input, rate=0.04)
  cl[:condition].size.times do |i|
    if rand() < rate
      cl[:condition][i] = (cl[:condition][i].chr=='#') ? input[i] : '#'
    end
  end
  if rand() < rate
    subset = action_set - [cl[:action]]
    cl[:action] = subset[rand(subset.size)]    
  end
end

def uniform_crossover(parent1, parent2)
  child = ""
  parent1.size.times do |i|
    child << ((rand()<0.5) ? parent1[i].chr : parent2[i].chr)
  end
  return child
end

def insert_in_pop(cla, pop)
  pop.each do |c|    
    if cla[:condition]==c[:condition] and cla[:action]==c[:action]
      c[:num] += 1
      return
    end
  end
  pop << cla
end

def crossover(c1, c2, p1, p2)
  c1[:condition] = uniform_crossover(p1[:condition], p2[:condition])
  c2[:condition] = uniform_crossover(p1[:condition], p2[:condition]) 
  c2[:pred] = c1[:pred] = (p1[:pred]+p2[:pred])/2.0
  c2[:error] = c1[:error] = 0.25*(p1[:error]+p2[:error])/2.0
  c2[:fitness] = c1[:fitness] = 0.1*(p1[:fitness]+p2[:fitness])/2.0
end

def run_ga(actions, pop, action_set, input, gen, pop_size, crate=0.8)
  p1, p2 = binary_tournament(action_set), binary_tournament(action_set)
  c1, c2 = copy_classifier(p1), copy_classifier(p2)
  crossover(c1, c2, p1, p2) if rand() < crate
  [c1,c2].each do |c|
    mutation(c, actions, input)
    insert_in_pop(c, pop)    
  end  
  while pop.inject(0) {|s,c| s+c[:num]} > pop_size
    delete_from_pop(pop, pop_size)
  end
end

def train_model(pop_size, max_gens, actions, ga_freq)
  pop, perf = [], []
  max_gens.times do |gen|
    explore = gen.modulo(2)==0
    input = random_bitstring()
    match_set = generate_match_set(input, pop, actions, gen, pop_size)
    pred_array = generate_prediction(match_set)    
    action = select_action(pred_array, explore)
    reward = (target_function(input)==action.to_i) ? 1000.0 : 0.0
    if explore
      action_set = match_set.select{|c| c[:action]==action}
      update_set(action_set, reward)
      update_fitness(action_set)
      if can_run_genetic_algorithm(action_set, gen, ga_freq)
        action_set.each {|c| c[:lasttime] = gen}
        run_ga(actions, pop, action_set, input, gen, pop_size)
      end
    else 
      e,a = (pred_array[action][:weight]-reward).abs, ((reward==1000.0)?1:0)
      perf << {:error=>e,:correct=>a}
      if perf.size >= 50
        err = (perf.inject(0){|s,x|s+x[:error]}/perf.size).round
        acc = perf.inject(0.0){|s,x|s+x[:correct]}/perf.size
        puts " >iter=#{gen+1} size=#{pop.size}, error=#{err}, acc=#{acc}"
        perf = []
      end
    end
  end  
  return pop
end

def test_model(system, num_trials=50)
  correct = 0
  num_trials.times do
    input = random_bitstring()
    match_set = system.select{|c| does_match?(input, c[:condition])}
    pred_array = generate_prediction(match_set)
    action = select_action(pred_array, false)
    correct += 1 if target_function(input) == action.to_i
  end
  puts "Done! classified correctly=#{correct}/#{num_trials}"
  return correct
end

def execute(pop_size, max_gens, actions, ga_freq)
  system = train_model(pop_size, max_gens, actions, ga_freq)
  test_model(system)
  return system
end

if __FILE__ == $0
  # problem configuration
  all_actions = ['0', '1']
  # algorithm configuration
  max_gens, pop_size = 5000, 200
  ga_freq = 25
  # execute the algorithm
  execute(pop_size, max_gens, all_actions, ga_freq)
end
