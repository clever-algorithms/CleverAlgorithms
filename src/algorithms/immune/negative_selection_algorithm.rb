# Negative Selection Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.length) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def euclidean_distance(c1, c2)
  sum = 0.0
  c1.each_index {|i| sum += (c1[i]-c2[i])**2.0}  
  return Math.sqrt(sum)
end

def contains?(vector, space)
  vector.each_with_index do |v,i|
    return false if v<space[i][0] or v>space[i][1]
  end
  return true
end

def matches?(vector, dataset, min_distance)
  dataset.each do |pattern|
    dist = euclidean_distance(vector, pattern[:vector])
    return true if dist <= min_distance
  end
  return false
end

def generate_detectors(max_detectors, search_space, self_dataset, min_dist)
  detectors = []
  begin
    detector = {:vector=>random_vector(search_space)}
    if !matches?(detector[:vector], self_dataset, min_dist)
      detectors << detector if !matches?(detector[:vector], detectors, 0.0)
    end
  end while detectors.size < max_detectors
  return detectors
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

def apply_detectors(detectors, search_space, self_dataset, min_dist, num_trials=50)
  correct = 0
  num_trials.times do |i|
    input = {:vector=>random_vector(search_space)}
    actual = matches?(input[:vector], detectors, min_dist) ? "non-self" : "self"
    expected = matches?(input[:vector], self_dataset, min_dist) ? "self" : "non-self"
    correct += 1 if actual==expected
    puts "#{i+1}/#{num_trials}: predicted=#{actual}, expected=#{expected}"
  end
  puts "Done. Result: #{correct}/#{num_trials}"
  return correct
end

def execute(search_space, self_space, max_detectors, max_self, min_distance)
  self_dataset = generate_self_dataset(max_self, self_space, search_space)
  puts "Done: prepared #{self_dataset.size} self patterns."
  detectors = generate_detectors(max_detectors, search_space, self_dataset, min_distance)
  puts "Done: prepared #{detectors.size} detectors."
  apply_detectors(detectors, search_space, self_dataset, min_distance)
  return detectors
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
  # execute the algorithm
  execute(search_space, self_space, max_detectors, max_self, min_distance)
end