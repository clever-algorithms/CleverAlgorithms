# Unit tests for hopfield.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../hopfield"

class TC_Hopfield < Test::Unit::TestCase 
  
  # test the generation of random vectors
  def test_random_vector
    bounds, trials, size = [-3,3], 300, 20
    minmax = Array.new(size) {bounds}
    trials.times do 
      vector, sum = random_vector(minmax), 0.0
      assert_equal(size, vector.size)
      vector.each do |v|
        assert_operator(v, :>=, bounds[0])
        assert_operator(v, :<, bounds[1])
        sum += v
      end
      assert_in_delta(bounds[0]+((bounds[1]-bounds[0])/2.0), sum/trials.to_f, 0.1)
    end    
  end
  
  # test initialize weights
  def test_initialize_weights
    w = initialize_weights(1000)
    assert_equal(1000, w.size)
    w.each do |x|
      assert_operator(x, :>=, -5)
      assert_operator(x, :<, 5)
    end
  end
  
  def test_create_neuron
    
  end
  
  def test_transfer
    
  end
  
  def test_propagate_was_change
    
  end
  
  def test_get_output
    
  end
  
  def test_train_network
    
  end
  
  # test to binary
  def test_to_binary
    assert_equal([0], to_binary([-1]))
    assert_equal([1], to_binary([1]))
  end
  
  def test_print_patterns
    
  end
  
  def test_calculate_error
    
  end
  
  def test_perturb_pattern
    
  end
  
  def test_test_network
    
  end
  
  # helper for turning off STDOUT
  # File activesupport/lib/active_support/core_ext/kernel/reporting.rb
  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen('/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end
  
  # test that the algorithm can solve the problem
  def test_search    
    # test problem
    num_inputs = 9
    p1 = [[1,1,1],[1,-1,-1],[1,1,1]] # C
    p2 = [[1,-1,-1],[1,-1,-1],[1,1,1]] # L
    p3 = [[-1,1,-1],[-1,1,-1],[-1,1,-1]] # I
    patters = [p1, p2, p3] 
    # get output
    neurons = nil
    silence_stream(STDOUT) do
      neurons = execute(patters, num_inputs)
    end
    # test structure
    assert_equal(num_inputs, neurons.size)
    # test output
    patters.each do |pattern|
      vector = pattern.flatten
      output = get_output(neurons, vector)    
      vector.each_with_index do |x,i|
        assert_equal(x, output[i])
      end      
    end
  end
  
end
