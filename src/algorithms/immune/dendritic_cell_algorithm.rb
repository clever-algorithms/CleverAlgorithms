# Dendritic Cell Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(search_space)
  return Array.new(search_space.length) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def construct_pattern(class_label, domain, p_safe, p_danger)
  set = domain[class_label]
  selection = rand(set.size)
  pattern = {}
  pattern[:class_label] = class_label
  pattern[:input] = set[selection]
  pattern[:safe] = (rand() * p_safe * 100.0)
  pattern[:danger] = (rand() * p_danger * 100.0)  
  return pattern
end

def generate_pattern(domain, p_anomaly, p_normal)
  pattern = nil
  total = domain.keys.inject(0.0){|s,k| s+domain[k].size.to_f}
  if rand() < (domain["Anomaly"].size.to_f/total)
    pattern = construct_pattern("Anomaly", domain, 1.0-p_normal, p_anomaly)
  else
    pattern = construct_pattern("Normal", domain, p_normal, 1.0-p_anomaly)
  end
  return pattern
end

def initialize_cell(cell={})
  cell[:lifespan] = 100.0
  cell[:k] = 0.0
  cell[:cms] = 0.0
  return cell
end

def expose_cell(cell, pattern)
  cms = (pattern[:safe] + pattern[:danger]) 
  k = pattern[:danger] - (pattern[:safe] * 2.0)  
  cell[:cms] += cms
  cell[:k] += k
  cell[:lifespan] -= cms
end

def can_cell_migrate?(cell)
  return cell[:lifespan] <= 0.0
end

def expose_all_cells(cells, pattern)
  migrate = []
  cells.each do |cell|
    expose_cell(cell, pattern)
    if can_cell_migrate?(cell)
      migrate << cell
      cell[:class_label] = (cell[:k]>0) ? "Anomaly" : "Normal"
      cell[:input] = pattern[:input]
      # puts " > Migrated in=#{pattern[:input]}, class=#{cell[:class_label]}"
    end
  end
  return migrate
end

def train_system(domain, max_iter, num_cells, p_anomaly, p_normal)
  immature_cells = Array.new(num_cells){ initialize_cell() }
  migrated = []
  max_iter.times do |iter|
    pattern = generate_pattern(domain, p_anomaly, p_normal)
    migrants = expose_all_cells(immature_cells, pattern)
    migrants.each do |cell|
      immature_cells.delete(cell)
      immature_cells << initialize_cell()
      migrated << cell
    end
    puts "> iter=#{iter} new=#{migrants.size}, migrated=#{migrated.size}"
  end
  return migrated
end

def classify_pattern(migrated, pattern)
  response = {"Normal"=>0, "Anomaly"=>0}
  migrated.each do |cell|
    response[cell[:class_label]] += 1 if cell[:input] == pattern[:input]
  end
  return (response["Normal"]>response["Anomaly"]) ? "Normal" : "Anomaly"
end

def test_system(migrated, domain, p_anomaly, p_normal)
  correct = 0
  100.times do
    pattern = generate_pattern(domain, p_anomaly, p_normal)
    class_label = classify_pattern(migrated, pattern)
    correct += 1 if class_label == pattern[:class_label]
  end
  puts "Finished test with a score of #{correct}/#{100} (#{correct}%)"
end

def run(domain, max_iter, num_cells, p_anomaly, p_normal)  
  migrated = train_system(domain, max_iter, num_cells, p_anomaly, p_normal)
  test_system(migrated, domain, p_anomaly, p_normal)
end

if __FILE__ == $0
  domain = {}
  domain["Normal"] = Array.new(50){|i| i}
  domain["Anomaly"] = Array.new(5){|i| (i+1)*10}
  domain["Normal"] = domain["Normal"] - domain["Anomaly"]
  p_anomaly = 0.70
  p_normal = 0.95
  
  iterations = 100
  num_cells = 20

  run(domain, iterations, num_cells, p_anomaly, p_normal)
end