# Backpropagation Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.length) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def normalize_class_index(class_no, domain)
  return (class_no.to_f/(domain.length-1).to_f)
end

def denormalize_class_index(normalized_class, domain)
  return (normalized_class*(domain.length-1).to_f).round.to_i
end

def generate_random_pattern(domain)  
  classes = domain.keys
  selected_class = rand(classes.length)
  pattern = {}
  pattern[:class_number] = selected_class
  pattern[:class_label] = classes[selected_class]
  pattern[:class_norm] = normalize_class_index(selected_class, domain)
  pattern[:vector] = random_vector(domain[classes[selected_class]])
  return pattern
end

def initialize_weights(problem_size)
  minmax = Array.new(problem_size + 1) {[0,0.5]}
  return random_vector(minmax)
end

def update_weights(problem_size, weights, input, out_expected, output_actual, learning_rate)
  problem_size.times do |i|
    weights[i] += learning_rate * (out_expected - output_actual) * input[i]
  end
  weights[problem_size] += learning_rate * (out_expected - output_actual) * 1.0
end

def calculate_activation(weights, vector)
  sum = 0.0
  vector.each_with_index do |input, i|
    sum += weights[i] * input
  end
  sum += weights[vector.length] * 1.0
  return sum
end

def transfer(activation)
  return (activation >= 0) ? 1.0 : 0.0
end

def get_output(weights, pattern, domain)
  activation = calculate_activation(weights, pattern[:vector])
  out_actual = transfer(activation)
  out_class = domain.keys[denormalize_class_index(out_actual, domain)]
  return [out_actual, out_class]
end

def train_weights(weights, domain, problem_size, iterations, lrate)
  iterations.times do |epoch|
    pattern = generate_random_pattern(domain)
    out_v, out_c = get_output(weights, pattern, domain)    
    puts "> train got=#{out_v}(#{out_c}), exp=#{pattern[:class_norm]}(#{pattern[:class_label]})"    
    update_weights(problem_size, weights, pattern[:vector], pattern[:class_norm], out_v, lrate)
  end
end

def test_weights(weights, domain)
  correct = 0
  100.times do 
    pattern = generate_random_pattern(domain)
    out_v, out_c = get_output(weights, pattern, domain)
    correct += 1 if out_c == pattern[:class_label]
  end
  puts "Finished test with a score of #{correct}/#{100} (#{(correct/100)*100}%)"
end

def run(domain, problem_size, iterations, learning_rate)  
  weights = initialize_weights(problem_size)
  train_weights(weights, domain, problem_size, iterations, learning_rate)
  test_weights(weights, domain)
end

if __FILE__ == $0
  problem_size = 2
  domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
  learning_rate = 0.1
  iterations = 60

  run(domain, problem_size, iterations, learning_rate)
end