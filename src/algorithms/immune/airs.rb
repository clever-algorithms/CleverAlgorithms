# Artificial Immune Recognition System

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.length) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def generate_random_pattern(domain)  
  class_label = domain.keys[rand(domain.keys.length)]
  pattern = {:class_label=>class_label}
  pattern[:vector] = random_vector(domain[class_label])
  return pattern
end

def create_cell(vector, class_label)
  return {:class_label=>class_label, :vector=>vector}
end

def initialize_cells(domain)
  memory_cells = []
  domain.keys.each do |key|
    memory_cells << create_cell(random_vector([[0,1],[0,1]]), key)
  end
  return memory_cells
end

def euclidean_distance(v1, v2)
  sum = 0.0
  v1.each_with_index do |v, i|
    sum += (v1[i]-v2[i])**2.0
  end
  return Math.sqrt(sum)
end

def stimulate(cells, pattern)
  max_affinity = euclidean_distance([0.0,0.0], [1.0,1.0])
  cells.each do |cell|
    cell[:affinity] = euclidean_distance(cell[:vector], pattern[:vector]) / max_affinity
    cell[:stimulation] = 1.0 - cell[:affinity]
  end
end

def get_most_stimulated_cell(memory_cells, pattern)
  stimulate(memory_cells, pattern)
  return memory_cells.sort{|x,y| y[:stimulation] <=> x[:stimulation]}.first
end

def mutate_cell(cell, best_match)
  range = 1.0 - best_match[:stimulation]
  cell[:vector].each_with_index do |v,i|
    min = [(v-(range/2.0)), 0.0].min
    max = [(v+(range/2.0)), 1.0].max
    cell[:vector][i] = min + (rand() * (max-min))
  end
  return cell
end

def create_arb_pool(pattern, best_match, clone_rate, mutate_rate)
  pool = []
  pool << create_cell(best_match[:vector], best_match[:class_label])
  num_clones = (best_match[:stimulation] * clone_rate * mutate_rate).round
  num_clones.times do 
    cell = create_cell(best_match[:vector], best_match[:class_label])
    mutate_cell(cell, best_match)
    pool << cell
  end
  return pool
end

def competition_for_resournces(pool, clone_rate, max_resources)
  pool.each {|cell| cell[:resources] = cell[:stimulation] * clone_rate}
  pool.sort!{|x,y| x[:resources] <=> y[:resources]}
  total_resources = pool.inject(0.0){|sum,cell| sum + cell[:resources]}
  while total_resources > max_resources
    cell = pool.delete_at(pool.length-1)
    total_resources -= cell[:resources]
  end
end

def refine_arb_pool(pool, pattern, stim_thresh, clone_rate, max_resources)  
  mean_stim, candidate = 0.0, nil
  begin
    stimulate(pool, pattern)
    candidate = pool.sort{|x,y| y[:stimulation] <=> x[:stimulation]}.first
    mean_stim = pool.inject(0.0){|sum,cell| sum + cell[:stimulation]} / pool.size.to_f
    if mean_stim < stim_thresh
      candidate = competition_for_resournces(pool, clone_rate, max_resources)
      pool.size.times do |i|
        cell = create_cell(pool[i][:vector], pool[i][:class_label])
        mutate_cell(cell, pool[i])
        pool << cell
      end
    end
  end until mean_stim >= stim_thresh   
  return candidate
end

def add_candidate_to_memory_pool(candidate, best_match, memory_cells)
  if candidate[:stimulation] > best_match[:stimulation]
    memory_cells << candidate
  end
end

def train_system(memory_cells, domain, num_patterns, clone_rate, mutate_rate, stim_thresh, max_resources)
  num_patterns.times do |i|
    pattern = generate_random_pattern(domain)
    best_match = get_most_stimulated_cell(memory_cells, pattern)
    if best_match[:class_label] != pattern[:class_label]
      memory_cells << create_cell(pattern[:vector], pattern[:class_label])
    elsif best_match[:stimulation] < 1.0
      pool = create_arb_pool(pattern, best_match, clone_rate, mutate_rate)
      candidate = refine_arb_pool(pool, pattern, stim_thresh, clone_rate, max_resources)
      add_candidate_to_memory_pool(candidate, best_match, memory_cells)
    end
    puts " > iteration#{i+1} memory_cells=#{memory_cells.size}"
  end
end

def classify_pattern(memory_cells, pattern)
  stimulate(memory_cells, pattern)
  return memory_cells.sort{|x,y| y[:stimulation] <=> x[:stimulation]}.first
end

def test_system(memory_cells, domain)
  correct = 0
  100.times do 
    pattern = generate_random_pattern(domain)
    best = classify_pattern(memory_cells, pattern)
    correct += 1 if best[:class_label] == pattern[:class_label]
  end
  puts "Finished test with a score of #{correct}/#{100} (#{correct}%)"
end

def run(domain, num_patterns, clone_rate, mutate_rate, stim_thresh, max_resources)  
  memory_cells = initialize_cells(domain)
  train_system(memory_cells, domain, num_patterns, clone_rate, mutate_rate, stim_thresh, max_resources)
  test_system(memory_cells, domain)
end

if __FILE__ == $0
  domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
  num_patterns = 100
  clone_rate = 10
  mutate_rate = 2.0
  stim_thresh = 0.9
  max_resources = 150

  run(domain, num_patterns, clone_rate, mutate_rate, stim_thresh, max_resources)
end