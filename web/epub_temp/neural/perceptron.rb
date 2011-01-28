# Perceptron Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def initialize_weights(problem_size)
  minmax = Array.new(problem_size + 1) {[-1.0,1.0]}
  return random_vector(minmax)
end

def update_weights(num_inputs, weights, input, out_exp, out_act, l_rate)
  num_inputs.times do |i|
    weights[i] += l_rate * (out_exp - out_act) * input[i]
  end
  weights[num_inputs] += l_rate * (out_exp - out_act) * 1.0
end

def activate(weights, vector)
  sum = weights[weights.size-1] * 1.0
  vector.each_with_index do |input, i|
    sum += weights[i] * input
  end
  return sum
end

def transfer(activation)
  return (activation >= 0) ? 1.0 : 0.0
end

def get_output(weights, vector)
  activation = activate(weights, vector)
  return transfer(activation)
end

def train_weights(weights, domain, num_inputs, iterations, lrate)
  iterations.times do |epoch|
    error = 0.0
    domain.each do |pattern|
      input = Array.new(num_inputs) {|k| pattern[k].to_f}
      output = get_output(weights, input)
      expected = pattern.last.to_f
      error += (output - expected).abs
      update_weights(num_inputs, weights, input, expected, output, lrate)
    end
    puts "> epoch=#{epoch}, error=#{error}"
  end
end

def test_weights(weights, domain, num_inputs)
  correct = 0
  domain.each do |pattern|
    input_vector = Array.new(num_inputs) {|k| pattern[k].to_f}
    output = get_output(weights, input_vector)
    correct += 1 if output.round == pattern.last
  end
  puts "Finished test with a score of #{correct}/#{domain.size}"
  return correct
end

def execute(domain, num_inputs, iterations, learning_rate)  
  weights = initialize_weights(num_inputs)
  train_weights(weights, domain, num_inputs, iterations, learning_rate)
  test_weights(weights, domain, num_inputs)
  return weights
end

if __FILE__ == $0
  # problem configuration
  or_problem = [[0,0,0], [0,1,1], [1,0,1], [1,1,1]]
  inputs = 2
  # algorithm configuration
  iterations = 20
  learning_rate = 0.1  
  # execute the algorithm
  execute(or_problem, inputs, iterations, learning_rate)
end