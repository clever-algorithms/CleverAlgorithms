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
      assert_in_delta(bounds[0]+((bounds[1]-bounds[0])/2.0), sum/trials.to_f, 0.15)
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
  
  # test creating a neuron
  def test_create_neuron
    n = create_neuron(1000)
    assert_not_nil(n[:weights])
    assert_equal(1000, n[:weights].size)
  end
  
  def test_transfer
    assert_equal(-1, transfer(-1))
    assert_equal(1, transfer(0))
    assert_equal(1, transfer(1))
  end
  
  # test whether a propagation results in a change
  def test_propagate_was_change
    # change    
    neurons = [{:weights=>[0,0],:output=>-1}, {:weights=>[0,0],:output=>-1}]
    rs = propagate_was_change?(neurons)
    assert_equal(true, rs)
    assert_equal(true, neurons[0][:output]==1 || neurons[1][:output]==1)
    # no change
    neurons = [{:weights=>[0,0],:output=>1}, {:weights=>[1,1],:output=>1}]
    rs = propagate_was_change?(neurons)
    assert_equal(false, rs)
    assert_equal(1.0, neurons[0][:output])
    assert_equal(1.0, neurons[1][:output])
  end
  
  # test get output
  def test_get_output
    # no change
    n = [{:weights=>[1,1],:output=>1}, {:weights=>[1,1],:output=>1}]
    rs = get_output(n, [1,1])
    assert_equal([1,1], rs)
    # change
    n = [{:weights=>[1,1],:output=>1}, {:weights=>[1,1],:output=>1}]
    rs = get_output(n, [-1,-1])
    assert_equal([-1,-1], rs)
  end
  
  # test training the network
  def test_train_network
    n = [{:weights=>[1,1],:output=>1}, {:weights=>[1,1],:output=>1}]
    p = [[[-1,-1], [1,1]]]
    train_network(n, p)
    # weights changed
    n.each {|x| assert_not_equal([1,1], x[:weight])}
  end
  
  # test to binary
  def test_to_binary
    assert_equal([0], to_binary([-1]))
    assert_equal([1], to_binary([1]))
  end
  
  # test the printing of patterns
  def test_print_patterns
    # N/A
  end
  
  # test calculating error
  def test_calculate_error
    # no error
    assert_equal(0, calculate_error([-1,-1,-1], [-1,-1,-1]))
    # some error
    assert_equal(3, calculate_error([1,1,1], [-1,-1,-1]))
  end
  
  # test pattern perturbations
  def test_perturb_pattern
    # all
    assert_not_equal([-1,-1,-1,-1,-1,-1], perturb_pattern([1,1,1,1,1,1]))
    assert_not_equal([1,1,1,1,1,1], perturb_pattern([-1,-1,-1,-1,-1,-1]))
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

  # test the assessment of the network
  def test_test_network
    rs = nil
    n = [{:weights=>[1,1,1,1,1,1],:output=>1},
         {:weights=>[1,1,1,1,1,1],:output=>1},
         {:weights=>[1,1,1,1,1,1],:output=>1},
         {:weights=>[1,1,1,1,1,1],:output=>1},
         {:weights=>[1,1,1,1,1,1],:output=>1},
         {:weights=>[1,1,1,1,1,1],:output=>1}]
    p = [ [[1,1],[1,1],[1,1]] ]
    silence_stream(STDOUT) do
      rs = test_network(n, p)
    end
    assert_not_nil(rs)
    assert_in_delta(0, rs, 0)   
  end

  # test that the algorithm can solve the problem
  def test_search    
    # problem configuration
    num_inputs = 9
    p1 = [[1,1,1],[-1,1,-1],[-1,1,-1]] # T
    p2 = [[1,-1,1],[1,-1,1],[1,1,1]] # U
    patters = [p1, p2]  
    # execute the algorithm
    neurons = nil
    silence_stream(STDOUT) do
      neurons = execute(patters, num_inputs)
    end
    assert_not_nil(neurons)
    assert_equal(9, neurons.size)
    rs = nil
    silence_stream(STDOUT) do
      rs = test_network(neurons, patters)
    end
    assert_not_nil(rs)
    assert_equal(0, rs)
  end
  
end
