# Hopfield Network Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
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
  neuron[:output] = -1
  return neuron
end

def transfer(activation)
  return (activation >= 0) ? 1 : -1
end

def propagate_was_change?(neurons, vector)
  i = rand(neurons.size)
  activation = 0
  neurons.each_with_index do |other, j|
    activation += other[:weight][i]*other[:output] if i!=j
  end
  output = transfer(activation)
  change = (output==neurons[i][:output])
  neurons[i][:output] = output
  return change
end

def get_output(neurons, pattern)
  vector = pattern.flatten
  neurons.each_with_index {|neuron,i| neuron[:output] = vector[i]}
  change = propagate(neurons, vector) while change
  return Array.new(neurons.size){|i| neurons[i][:output]}
end

def train_network(neurons, patters)
  neurons.each_with_index do |neuron, i|   
    for j in ((i+1)...neurons.size) do
      next if i==j
      wij = 0
      patters.each do |pattern|
        vector = pattern.flatten
        wij += vector[i]*vector[j]
      end
      neurons[i][:weights][j] = wij
      neurons[j][:weights][i] = wij
    end
  end
end

def to_binary(vector)
  return Array.new(vector.size){|i| ((vector[i]==-1) ? 0 : 1)}
end

def print_patterns(provided, expected, actual)
  p, e, a = to_binary(provided), to_binary(expected), to_binary(actual)
  p1, p2, p3 = p[0..2].join(', '), p[3..5].join(', '), p[6..8].join(', ')
  e1, e2, e3 = e[0..2].join(', '), e[3..5].join(', '), e[6..8].join(', ')
  a1, a2, a3 = a[0..2].join(', '), a[3..5].join(', '), a[6..8].join(', ')
  puts "Provided   Expected     Got"
  puts "#{p1}     #{e1}      #{a1}"
  puts "#{p2}     #{e2}      #{a2}"
  puts "#{p3}     #{e3}      #{a3}"
end

def calculate_error(expected, actual)
  sum = 0
  expected.each_with_index do |v, i|
    sum += (expected[i] - actual[i]).abs
  end
  return sum
end

def perturb_pattern(vector)
  perturbed = Array.new(vector.size)
  vector.each_with_index do |v,i|
    if rand() < (1.0/vector.size.to_f)*0.5
      perturbed[i] = ((vector[i]==1) ? -1 : 1)
    else
      perturbed[i] = vector[i]
    end
  end
  return perturbed
end

def test_network(neurons, patters)
  error = 0.0
  patters.each do |pattern|
    vector = pattern.flatten
    perturbed = perturb_pattern(vector)
    output = get_output(neurons, perturbed)
    error += calculate_error(vector, output)
    print_patterns(perturbed, vector, output)
  end
  error /= patters.size.to_f
  puts "Final Result: avg pattern error=#{error}"
end

def run(patters, num_inputs)
  neurons = Array.new(num_inputs) { create_neuron(num_inputs) }
  train_network(neurons, patters)
  test_network(neurons, patters)
end

if __FILE__ == $0
  # problem configuration
  num_inputs = 9
  p1 = [[1,1,1],[1,-1,-1],[1,1,1]] # C
  p2 = [[1,-1,-1],[1,-1,-1],[1,1,1]] # L
  p3 = [[-1,1,-1],[-1,1,-1],[-1,1,-1]] # I
  patters = [p1, p2, p3]  
  # execute the algorithm
  run(patters, num_inputs)
end