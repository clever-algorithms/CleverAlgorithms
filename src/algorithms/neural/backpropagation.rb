# Backpropagation Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def normalize_class_index(class_no, domain)
  return (class_no.to_f/(domain.size-1).to_f)
end

def denormalize_class_index(normalized_class, domain)
  return (normalized_class*(domain.size-1).to_f).round.to_i
end

def generate_random_pattern(domain)  
  classes = domain.keys
  selected_class = rand(classes.size)
  pattern = {}
  pattern[:class_number] = selected_class
  pattern[:class_label] = classes[selected_class]
  pattern[:class_norm] = normalize_class_index(selected_class, domain)
  pattern[:vector] = random_vector(domain[classes[selected_class]])
  return pattern
end

def initialize_weights(problem_size)
  minmax = Array.new(problem_size + 1) {[-0.5,0.5]}
  return random_vector(minmax)
end

def activate(weights, vector)
  sum = 0.0
  vector.each_with_index do |input, i|
    sum += weights[i] * input
  end
  sum += weights[vector.size] * 1.0
  return sum
end

def transfer(activation)
  return 1.0 / (1.0 + Math.exp(-activation)) 
end

def transfer_derivative(output)
  return output * (1.0 - output)
end

def forward_propagate(network, pattern, domain)
  network.each_with_index do |layer, i|
    input = (i==0) ? pattern[:vector] : Array.new(network[i-1].size){|k| network[i-1][k][:output]}
    layer.each do |neuron|
      neuron[:activation] = activate(neuron[:weights], input)
      neuron[:output] = transfer(neuron[:activation])
    end
  end
  out_actual = network.last[0][:output]
  out_class = domain.keys[denormalize_class_index(out_actual, domain)]
  return [out_actual, out_class]
end

def backward_propagate_error(network, pattern)
  network.size.times do |n|
    index = network.size - 1 - n
    if index == network.size-1
      neuron = network[index][0] # assume one node in output layer
      error = (pattern[:class_norm] - neuron[:output])
      neuron[:error_delta] = error * transfer_derivative(neuron[:output])
    else
      network[index].each_with_index do |neuron, k|
        sum = 0.0
        # only sum errors weighted by connection to the current k'th neuron
        network[index+1].each do |next_neuron|
          sum += (next_neuron[:weights][k] * next_neuron[:error_delta])
        end
        neuron[:error_delta] = sum * transfer_derivative(neuron[:output])
      end            
    end
  end
end

def calculate_error_derivatives_for_weights(network, pattern)
  network.each_with_index do |layer, i|
    input = (i==0) ? pattern[:vector] : Array.new(network[i-1].size){|k| network[i-1][k][:output]}
    layer.each do |neuron|
      neuron[:error_derivative] = Array.new(neuron[:weights].size)
      input.each_with_index do |signal, j|
        neuron[:error_derivative][j] = neuron[:error_delta] * signal
      end
      neuron[:error_derivative][-1] = neuron[:error_delta] * 1.0
    end
  end
end

def update_weights(network, lrate)
  network.each do |layer|
    layer.each do |neuron|
      neuron[:weights].each_with_index do |w, j|
        neuron[:weights][j] = w + (lrate * neuron[:error_derivative][j])
      end
    end
  end
end

def train_network(network, domain, problem_size, iterations, lrate)
  iterations.times do |it|
    pattern = generate_random_pattern(domain)
    out_v, out_c = forward_propagate(network, pattern, domain)    
    puts "> train got=#{out_v}(#{out_c}), exp=#{pattern[:class_norm]}(#{pattern[:class_label]})"
    backward_propagate_error(network, pattern)
    calculate_error_derivatives_for_weights(network, pattern)
    update_weights(network, lrate)
  end
end

def test_network(network, domain)
  correct = 0
  100.times do 
    pattern = generate_random_pattern(domain)
    out_v, out_c = forward_propagate(network, pattern, domain)
    correct += 1 if out_c == pattern[:class_label]
  end
  puts "Finished test with a score of #{correct}/#{100} (#{correct}%)"
end

def create_neuron(num_inputs)
  return {:weights => initialize_weights(num_inputs)}
end

def run(domain, problem_size, iterations, hidden_layer_size, learning_rate)  
  network = []
  network << Array.new(problem_size){create_neuron(problem_size)}
  network << Array.new(hidden_layer_size){create_neuron(network.last.size)}
  network << Array.new(1){create_neuron(network.last.size)}
  puts "Network Topology: #{network.inject(""){|m,i| m + "#{i.size} "}}"
  train_network(network, domain, problem_size, iterations, learning_rate)  
  test_network(network, domain)
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
  # algorithm configuration
  learning_rate = 0.1
  hidden_layer_size = 3
  iterations = 100
  # execute the algorithm
  run(domain, problem_size, iterations, hidden_layer_size, learning_rate)
end