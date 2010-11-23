# Hopfield Network Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.length) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def initialize_weights(problem_size)
  minmax = Array.new(problem_size + 1) {[-0.5,0.5]}
  return random_vector(minmax)
end

def create_neuron(num_inputs)
  neuron = {}
  neuron[:weights] = initialize_weights(num_inputs)
  return neuron
end

# def update_weights(problem_size, weights, input, out_expected, output_actual, learning_rate)
#   problem_size.times do |i|
#     weights[i] += learning_rate * (out_expected - output_actual) * input[i]
#   end
#   weights[problem_size] += learning_rate * (out_expected - output_actual) * 1.0
# end

def calculate_activation(weights, vector)
  sum = 0.0
  vector.each_with_index do |input, i|
    sum += weights[i] * input.to_f
  end
  sum += weights[vector.length] * 1.0
  return sum
end

def transfer(activation)
  return (activation >= 0) ? 1 : 0
end

def get_output(neurons, pattern)
  output = Array.new(neurons.length)
  neurons.each_with_index do |neuron, i|
    activation = calculate_activation(neuron[:weights], pattern)
    output[i] = transfer(activation)
  end
  return output
end

def calculate_error(expected, actual)
  sum = 0
  expected.each_with_index do |v, i|
    sum += (expected[i] - actual[i]).abs
  end
  return sum
end

def train_network(neurons, patters, iterations, lrate)
  iterations.times do |epoch|
    error = 0.0
    patters.each do |pattern|
      vector = pattern.flatten
      output = get_output(neurons, vector)
      error += calculate_error(vector, output)
    end
    error /= patters.length.to_f
    puts "> epoch=#{epoch} error=#{error}"
  end  
end

def print_patterns(e, a)
  e1, e2, e3 = e[0..2].join(', '), e[3..5].join(', '), e[6..8].join(', ')
  a1, a2, a3 = a[0..2].join(', '), a[3..5].join(', '), a[6..8].join(', ')
  puts "Expected     Got"
  puts "#{e1}      #{a1}"
  puts "#{e2}      #{a2}"
  puts "#{e3}      #{a3}"
end

def test_network(neurons, patters)
  error = 0.0
  patters.each do |pattern|
    vector = pattern.flatten
    output = get_output(neurons, vector)
    error += calculate_error(vector, output)
    print_patterns(vector, output)    
  end
  error /= patters.length.to_f
  puts "Final Result: avg pattern error=#{error}"
end

def run(patters, num_inputs, iterations, learning_rate)
  neurons = Array.new(num_inputs) { create_neuron(num_inputs) }
  train_network(neurons, patters, iterations, learning_rate)
  test_network(neurons, patters)
end

if __FILE__ == $0
  # problem definition
  num_inputs = 9
  p1 = [[1,1,1],[1,0,0],[1,1,1]] # C
  p2 = [[1,0,0],[1,0,0],[1,1,1]] # L
  p3 = [[0,1,0],[0,1,0],[0,1,0]] # I
  patters = [p1, p2, p3]  
  # algorithm parameters
  learning_rate = 0.1
  iterations = 60
  # execute the algorithm
  run(patters, num_inputs, iterations, learning_rate)
end