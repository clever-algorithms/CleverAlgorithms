# Dendritic Cell Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(search_space)
  return Array.new(search_space.length) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def contains_2d?(point, space)
  space.each_with_index do |minmax, i|
    return false if point[i]<minmax[0] and point[i]>minmax[1]
  end
  return true
end

def generate_specific_pattern(class_label, domain, exclude_label=nil)
  vector = nil
  begin
    vector = random_vector(domain[class_label])
  end while !exclude_label.nil? and !contains_2d?(vector, domain[exclude_label])
  pattern = {}
  pattern[:vector] = vector
  pattern[:class_label] = class_label
  return pattern
end

def generate_pattern(domain, prob_anomaly, prob_anomaly_signal, prob_normal_signal)
  pattern = nil
  if rand() < prob_anomaly
    pattern = generate_specific_pattern("Anomaly", domain)
    pattern[:safe] = rand() * (1.0-prob_normal_signal)
    pattern[:danger] = rand() * prob_anomaly_signal
  else
    pattern = generate_specific_pattern("Normal", domain, "Anomaly")
    pattern[:safe] = rand() * prob_normal_signal
    pattern[:danger] = rand() * (1.0-prob_anomaly_signal)
  end
  return pattern
end

def initialize_cell(cell={})
  # cell[:weights] = random_vector([[0,1],[0,1]])
  cell[:lifespan] = 100.0 # ???
  cell[:k] = 0.0
  cell[:cms] = 0.0
  cell[:output] = 0.0
  cell[:migrate_threshold] = rand()
end

def expose_cell(cell, pattern)
  cms = pattern[:safe] + pattern[:danger] 
  
  cell[:cms] += cms
  cell[:k] += pattern[:danger] - (pattern[:safe] * 2.0)
  cell[:output] = (cell[:weights][0] + cell[:cms]) + (cell[:weights][1] + cell[:k])
  
  cell[:lifespan] -= cms
  if cell[:lifespan] <= 0
    puts " > cell died, resetting..."
    initialize_cell(cell)
  end
  
end

def can_cell_migrate?(cell)
  return cell[:cms] <= cell[:migrate_threshold]
end

def run(domain, max_iter, num_cells, prob_anomaly, prob_ano_signal, prob_nor_signal)  
  cells = Array.new(num_cells){ initialize_cell() }
  tissue = []
  max_iter.times do |iter|
    pattern = generate_pattern(domain, prob_anomaly, prob_ano_signal, prob_nor_signal)
    cells.each {|cell| expose_cell(cell, pattern)}
    cells.each {|cell| tissue << cell if can_cell_migrate?(cell)} 
    tissue.each {|cell| cells.delete(cell)}
    
    
    puts "generated #{pattern[:class_label]}"
  end
end

if __FILE__ == $0
  domain = {"Normal"=>[[0,1],[0,1]],"Anomaly"=>[[0.45,0.55],[0.45,0.55]]}
  prob_ano_signal = 0.70
  prob_nor_signal = 0.95
  prob_anomaly = 0.10

  iterations = 1000
  num_cells = 50
  mcav = prob_anomaly

  run(domain, iterations, num_cells, prob_anomaly, prob_ano_signal, prob_nor_signal)
end