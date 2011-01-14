# Artificial Immune Recognition System

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def generate_random_pattern(domain)  
  class_label = domain.keys[rand(domain.keys.size)]
  pattern = {:label=>class_label}
  pattern[:vector] = random_vector(domain[class_label])
  return pattern
end

def create_cell(vector, class_label)
  return {:label=>class_label, :vector=>vector}
end

def initialize_cells(domain)
  mem_cells = []
  domain.keys.each do |key|
    mem_cells << create_cell(random_vector([[0,1],[0,1]]), key)
  end
  return mem_cells
end

def distance(c1, c2)
  sum = 0.0
  c1.each_index {|i| sum += (c1[i]-c2[i])**2.0}  
  return Math.sqrt(sum)
end

def stimulate(cells, pattern)
  max_dist = distance([0.0,0.0], [1.0,1.0])
  cells.each do |cell|
    cell[:affinity] = distance(cell[:vector], pattern[:vector]) / max_dist
    cell[:stimulation] = 1.0 - cell[:affinity]
  end
end

def get_most_stimulated_cell(mem_cells, pattern)
  stimulate(mem_cells, pattern)
  return mem_cells.sort{|x,y| y[:stimulation] <=> x[:stimulation]}.first
end

def mutate_cell(cell, best_match)
  range = 1.0 - best_match[:stimulation]
  cell[:vector].each_with_index do |v,i|
    min = [(v-(range/2.0)), 0.0].max
    max = [(v+(range/2.0)), 1.0].min
    cell[:vector][i] = min + (rand() * (max-min))
  end
  return cell
end

def create_arb_pool(pattern, best_match, clone_rate, mutate_rate)
  pool = []
  pool << create_cell(best_match[:vector], best_match[:label])
  num_clones = (best_match[:stimulation] * clone_rate * mutate_rate).round
  num_clones.times do 
    cell = create_cell(best_match[:vector], best_match[:label])
    pool << mutate_cell(cell, best_match)
  end
  return pool
end

def competition_for_resournces(pool, clone_rate, max_res)
  pool.each {|cell| cell[:resources] = cell[:stimulation] * clone_rate}
  pool.sort!{|x,y| x[:resources] <=> y[:resources]}
  total_resources = pool.inject(0.0){|sum,cell| sum + cell[:resources]}
  while total_resources > max_res
    cell = pool.delete_at(pool.size-1)
    total_resources -= cell[:resources]
  end
end

def refine_arb_pool(pool, pattern, stim_thresh, clone_rate, max_res)  
  mean_stim, candidate = 0.0, nil
  begin
    stimulate(pool, pattern)
    candidate = pool.sort{|x,y| y[:stimulation] <=> x[:stimulation]}.first
    mean_stim = pool.inject(0.0){|s,c| s + c[:stimulation]} / pool.size
    if mean_stim < stim_thresh
      candidate = competition_for_resournces(pool, clone_rate, max_res)
      pool.size.times do |i|
        cell = create_cell(pool[i][:vector], pool[i][:label])
        mutate_cell(cell, pool[i])
        pool << cell
      end
    end
  end until mean_stim >= stim_thresh   
  return candidate
end

def add_candidate_to_memory_pool(candidate, best_match, mem_cells)
  if candidate[:stimulation] > best_match[:stimulation]
    mem_cells << candidate
  end
end

def classify_pattern(mem_cells, pattern)
  stimulate(mem_cells, pattern)
  return mem_cells.sort{|x,y| y[:stimulation] <=> x[:stimulation]}.first
end

def train_system(mem_cells, domain, num_patterns, clone_rate, mutate_rate, stim_thresh, max_res)
  num_patterns.times do |i|
    pattern = generate_random_pattern(domain)
    best_match = get_most_stimulated_cell(mem_cells, pattern)
    if best_match[:label] != pattern[:label]
      mem_cells << create_cell(pattern[:vector], pattern[:label])
    elsif best_match[:stimulation] < 1.0
      pool = create_arb_pool(pattern, best_match, clone_rate, mutate_rate)
      cand = refine_arb_pool(pool,pattern, stim_thresh, clone_rate, max_res)
      add_candidate_to_memory_pool(cand, best_match, mem_cells)
    end
    puts " > iter=#{i+1}, mem_cells=#{mem_cells.size}"
  end
end

def test_system(mem_cells, domain, num_trials=50)
  correct = 0
  num_trials.times do 
    pattern = generate_random_pattern(domain)
    best = classify_pattern(mem_cells, pattern)
    correct += 1 if best[:label] == pattern[:label]
  end
  puts "Finished test with a score of #{correct}/#{num_trials}"
  return correct
end

def execute(domain, num_patterns, clone_rate, mutate_rate, stim_thresh, max_res)  
  mem_cells = initialize_cells(domain)
  train_system(mem_cells, domain, num_patterns, clone_rate, mutate_rate, stim_thresh, max_res)
  test_system(mem_cells, domain)
  return mem_cells
end

if __FILE__ == $0
  # problem configuration
  domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
  num_patterns = 50
  # algorithm configuration
  clone_rate = 10
  mutate_rate = 2.0
  stim_thresh = 0.9
  max_res = 150
  # execute the algorithm
  execute(domain, num_patterns, clone_rate, mutate_rate, stim_thresh, max_res)
end