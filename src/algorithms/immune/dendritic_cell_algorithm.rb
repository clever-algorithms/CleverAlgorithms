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
    pattern[:normal_signal] = rand() * (1.0-prob_normal_signal)
    pattern[:anomaly_signal] = rand() * prob_anomaly_signal
  else
    pattern = generate_specific_pattern("Normal", domain, "Anomaly")
    pattern[:normal_signal] = rand() * prob_normal_signal
    pattern[:anomaly_signal] = rand() * (1.0-prob_anomaly_signal)
  end
  return pattern
end

def initialize_cells(domain, num_cells)
  cells = []
  num_cells.times do 
    
  end
  return cells
end

def test_cells(codebook_vectors, domain)
  correct = 0
  100.times do 
    pattern = generate_random_pattern(domain)
    bmu = get_best_matching_unit(codebook_vectors, pattern)
    correct += 1 if bmu[:class_label] == pattern[:class_label]
  end
  puts "Finished test with a score of #{correct}/#{100} (#{(correct/100)*100}%)"
end

def run(domain, problem_size, iterations, num_cells, prob_anomaly, prob_ano_signal, prob_nor_signal)  
  cells = initialize_cells(domain, num_cells)
  iterations.times do |iter|
    pattern = generate_pattern(domain, prob_anomaly, prob_ano_signal, prob_nor_signal)

    puts "generated #{pattern[:class_label]}"
  end
end

if __FILE__ == $0
  problem_size = 2
  domain = {"Normal"=>[[0,1],[0,1]],"Anomaly"=>[[0.45,0.55],[0.45,0.55]]}
  iterations = 1000
  num_cells = 50
  prob_ano_signal = 0.70
  prob_nor_signal = 0.95
  prob_anomaly = 0.10

  run(domain, problem_size, iterations, num_cells, prob_anomaly, prob_ano_signal, prob_nor_signal)
end