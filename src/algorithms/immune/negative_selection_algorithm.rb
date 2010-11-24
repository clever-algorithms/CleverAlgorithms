# Negative Selection Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(search_space)
  return Array.new(search_space.length) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def contains?(vector, space)
  vector.each_with_index do |v,i|
    return false if v<space[i][0] or v>space[i][1]
  end
  return true
end

def euclidean_distance(v1, v2)
  sum = 0.0
  v1.each_with_index do |v, i|
    sum += (v1[i]-v2[i])**2.0
  end
  return Math.sqrt(sum)
end

def matches?(bitstring, dataset, min_distance)
  dataset.each do |pattern|
    score = euclidean_distance(bitstring, pattern[:vector])
    return true if score <= min_distance
  end
  return false
end

def generate_detectors(max_detectors, search_space, self_dataset, min_distance)
  detectors = []
  begin
    detector = {}
    detector[:vector] = random_vector(search_space)
    if !matches?(detector[:vector], self_dataset, min_distance)
      next if matches?(detector[:vector], detectors, 0.0)
      detectors << detector 
    end
  end while detectors.size < max_detectors
  return detectors
end

def apply_detectors(num_test, detectors, search_space, self_space, min_distance)
  correct = 0
  num_test.times do |i|
    input = {}
    input[:vector] = random_vector(search_space)
    predicted = matches?(input[:vector], detectors, min_distance) ? "non-self" : "self"
    actual = contains?(input[:vector], self_space) ? "self" : "non-self"
    result = (predicted==actual) ? "Correct" : "Incorrect"
    correct += 1.0 if predicted==actual
    puts "#{i+1}/#{num_test}: #{result} - predicted=#{predicted}, actual=#{actual}, vector=#{input[:vector].inspect}"
  end
  puts "Total Correct: #{correct}/#{num_test} (#{(correct/num_test.to_f)*100.0}%)"
end

def generate_self_dataset(num_records, self_space, search_space)
  self_dataset = []
  begin
    pattern = {}
    pattern[:vector] = random_vector(search_space)
    next if matches?(pattern[:vector], self_dataset, 0.0)
    if contains?(pattern[:vector], self_space)
      self_dataset << pattern 
    end
  end while self_dataset.length < num_records
  return self_dataset
end

def run_algorithm(search_space, self_space, max_detectors, max_self, min_distance, num_test)
  self_dataset = generate_self_dataset(max_self, self_space, search_space)
  puts "Done: prepared #{self_dataset.size} self patterns."
  detectors = generate_detectors(max_detectors, search_space, self_dataset, min_distance)
  puts "Done: prepared #{detectors.size} detectors."
  apply_detectors(num_test, detectors, search_space, self_space, min_distance)
  puts "Done. completed testing."
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {[0.0, 1.0]}
  self_space = Array.new(problem_size) {[0.5, 1.0]}
  max_self = 150
  # algorithm configuration
  max_detectors = 300  
  min_distance = 0.05
  num_test = 50
  # execute the algorithm
  run_algorithm(search_space, self_space, max_detectors, max_self, min_distance, num_test)
end