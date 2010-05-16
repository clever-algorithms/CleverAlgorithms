# Negative Selection Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

BITS_PER_PARAM = 8

def decode(bitstring, search_space)
  vector = []
  search_space.each_with_index do |bounds, i|
    off, sum, j = i*BITS_PER_PARAM, 0.0, 0    
    bitstring[off...(off+BITS_PER_PARAM)].reverse.each_char do |c|
      sum += ((c=='1') ? 1.0 : 0.0) * (2.0 ** j.to_f)
      j += 1
    end
    min, max = bounds
    vector << min + ((max-min)/((2.0**BITS_PER_PARAM.to_f)-1.0)) * sum
  end
  return vector
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def contains?(vector, space)
  vector.each_with_index do |v,i|
    return false if v<space[i][0] or v>space[i][1]
  end
  return true
end

def distance(bitstring1, bitstring2)
  sum, i = 0.0, 0
  bitstring1.each_char do |c|
    sum +=1 if c==bitstring2[i].chr
    i += 1.0
  end
  return sum.to_f/bitstring1.length.to_f
end

def matches?(bitstring, dataset, match_ratio)
  dataset.each do |pattern|
    score = distance(bitstring, pattern[:bitstring])
    return true if score >= match_ratio
  end
  return false
end

def generate_detectors(max_detectors, search_space, self_dataset, match_ratio)
  detectors = []
  begin
    detector = {}
    detector[:bitstring] = random_bitstring(search_space.length*BITS_PER_PARAM)
    if !matches?(detector[:bitstring], self_dataset, match_ratio)
      next if matches?(detector[:bitstring], detectors, 1.0)      
      detector[:vector] = decode(detector[:bitstring], search_space)
      
      # hack to generate perfect detectods
      next if contains?(detector[:vector], [[0.5,1],[0.5,1]])
      
      # puts "generated detector: v=#{detector[:vector].inspect}, s=#{detector[:bitstring]}"
      detectors << detector 
      
      # hack to test for bad detectors
      puts "BAD DETECTOR!" if contains?(detector[:vector], [[0.5,1],[0.5,1]])
    end
  end while detectors.size < max_detectors
  return detectors
end

def apply_detectors(num_test, detectors, search_space, self_space, match_ratio)
  correct = 0
  num_test.times do |i|
    input = {}
    input[:bitstring] = random_bitstring(search_space.length*BITS_PER_PARAM)
    input[:vector] = decode(input[:bitstring], search_space)
    predicted = matches?(input[:bitstring], detectors, match_ratio) ? "non-self" : "self"
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
    pattern[:bitstring] = random_bitstring(search_space.length*BITS_PER_PARAM)
    pattern[:vector] = decode(pattern[:bitstring], search_space)
    if contains?(pattern[:vector], self_space)
      self_dataset << pattern 
      # puts "generated self pattern: v=#{pattern[:vector].inspect}, s=#{pattern[:bitstring]}"
    end
  end while self_dataset.length < num_records
  return self_dataset
end

max_detectors = 50
max_self = 500
match_ratio = 0.98
num_test = 50
problem_size = 2
search_space = Array.new(problem_size) {[0.0, 1.0]}
self_space = Array.new(problem_size) {[0.5, 1.0]}
self_dataset = generate_self_dataset(max_self, self_space, search_space)
puts "Done: prepared #{self_dataset.size} self patterns."
detectors = generate_detectors(max_detectors, search_space, self_dataset, match_ratio)
puts "Done: prepared #{detectors.size} detectors."
apply_detectors(num_test, detectors, search_space, self_space, match_ratio)
puts "Done. completed testing."