# Dendritic Cell Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(search_space)
  return Array.new(search_space.size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def construct_pattern(class_label, domain, p_safe, p_danger)
  set = domain[class_label]
  selection = rand(set.size)
  pattern = {}
  pattern[:class_label] = class_label
  pattern[:input] = set[selection]
  pattern[:safe] = (rand() * p_safe * 100)
  pattern[:danger] = (rand() * p_danger * 100)  
  return pattern
end

def generate_pattern(domain, p_anomaly, p_normal)
  pattern = nil  
  if rand() < 0.5
    pattern = construct_pattern("Anomaly", domain, 1.0-p_normal, p_anomaly)
    puts ">Generated Anomoly [#{pattern[:input]}]"
  else
    pattern = construct_pattern("Normal", domain, p_normal, 1.0-p_anomaly)
  end
  return pattern
end

def initialize_cell(thresh, cell={})
  cell[:lifespan] = 100.0
  cell[:k] = 0.0
  cell[:cms] = 0.0
  cell[:migration_threshold] = thresh[0] + ((thresh[1]-thresh[0]) * rand()) 
  cell[:antigen] = {}
  return cell
end

def store_antigen(cell, input)
  if cell[:antigen][input].nil?
    cell[:antigen][input] = 1
  else
    cell[:antigen][input] += 1
  end
end

def expose_cell(cell, cms, k, pattern, threshold)
  cell[:cms] += cms
  cell[:k] += k
  cell[:lifespan] -= cms 
  store_antigen(cell, pattern[:input]) 
  if cell[:lifespan] <= 0
    initialize_cell(threshold, cell)
  end
end

def can_cell_migrate?(cell)
  return (cell[:cms]>=cell[:migration_threshold] and !cell[:antigen].empty?)
end

def expose_all_cells(cells, pattern, threshold)
  migrate = []
  cms = (pattern[:safe] + pattern[:danger]) 
  k = pattern[:danger] - (pattern[:safe] * 2.0)  
  cells.each do |cell|
    expose_cell(cell, cms, k, pattern, threshold)
    if can_cell_migrate?(cell)
      migrate << cell
      cell[:class_label] = (cell[:k]>0) ? "Anomaly" : "Normal"
    end
  end
  return migrate
end

def train_system(domain, max_iter, num_cells, p_anomaly, p_normal, threshold)
  immature_cells = Array.new(num_cells){ initialize_cell(threshold) }
  migrated = []
  max_iter.times do |iter|
    pattern = generate_pattern(domain, p_anomaly, p_normal)
    migrants = expose_all_cells(immature_cells, pattern, threshold)
    migrants.each do |cell|
      immature_cells.delete(cell)
      immature_cells << initialize_cell(threshold)
      migrated << cell
    end
    puts "> iter=#{iter} new=#{migrants.size}, migrated=#{migrated.size}"
  end
  return migrated
end

def classify_pattern(migrated, pattern, response_size)
  input = pattern[:input]
  num_cells, num_antigen = 0, 0
  migrated.each do |cell|
    if cell[:class_label] == "Anomoly" and !cell[:antigen][input].nil?
      num_cells += 1
      num_antigen += cell[:antigen][input]
    end
  end
  mcav = num_cells.to_f / num_antigen.to_f  
  return (mcav>0.5) ? "Anomaly" : "Normal"
end

def test_system(migrated, domain, p_anomaly, p_normal, response_size, trial_norm=100, trial_anom=100)
  correct_norm = 0
  trial_norm.times do
    pattern = construct_pattern("Normal", domain, p_normal, 1.0-p_anomaly)
    class_label = classify_pattern(migrated, pattern, response_size)
    correct_norm += 1 if class_label == "Normal"
  end
  puts "Finished testing Normal inputs #{correct_norm}/#{trial_norm}"
  correct_anom = 0
  trial_anom.times do
    pattern = construct_pattern("Anomaly", domain, 1.0-p_normal, p_anomaly)
    class_label = classify_pattern(migrated, pattern, response_size)
    correct_anom += 1 if class_label == "Anomaly"
  end
  puts "Finished testing Anomaly inputs #{correct_anom}/#{trial_anom}"
  return [correct_norm, correct_anom]
end

def execute(domain, max_iter, num_cells, p_anomaly, p_normal, threshold, response_size)  
  migrated = train_system(domain, max_iter, num_cells, p_anomaly, p_normal, threshold)
  test_system(migrated, domain, p_anomaly, p_normal, response_size)
  return migrated
end

if __FILE__ == $0
  # problem configuration
  domain = {}
  domain["Normal"] = Array.new(50){|i| i}
  domain["Anomaly"] = Array.new(5){|i| (i+1)*10}
  domain["Normal"] = domain["Normal"] - domain["Anomaly"]
  p_anomaly = 0.70
  p_normal = 0.95
  # algorithm configuration
  iterations = 100
  num_cells = 20
  threshold = [5,15]
  response_size = 10
  # execute the algorithm
  execute(domain, iterations, num_cells, p_anomaly, p_normal, threshold, response_size)
end