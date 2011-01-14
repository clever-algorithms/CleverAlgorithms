# Unit tests for backpropagation.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../backpropagation"

class TC_BackPropagation < Test::Unit::TestCase
  
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
  
  # test the generation of small random weights
  def test_initialize_weights
    weights = initialize_weights(100)
    # adds a bias
    assert_equal(100, weights.size)
    # check values in [-2,2]
    weights.each do |w|
      assert(w <= 2, "#{w}")
      assert(w >= -2, "#{w}")
    end
  end

  # test weighted sum function
  def test_activate
    assert_equal(5.0, activate([1.0, 1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0]))
    assert_equal(2.5, activate([0.5, 0.5, 0.5, 0.5, 0.5], [1.0, 1.0, 1.0, 1.0]))
    assert_equal(-6.062263, activate([-6.072185,2.454509,-6.062263], [0, 0]))
  end
  
  # test the transfer function
  def test_transfer
    # small values stay smallish
    assert_in_delta(0.73, transfer(1.0), 0.01)
    assert_in_delta(0.5, transfer(0.0), 0.001)
    # large/small values get squashed
    assert_in_delta(1.0, transfer(10.0), 0.0001)
    assert_in_delta(0.0, transfer(-10.0), 0.0001)
    assert_in_delta(0.00232, transfer(-6.062263), 0.00001)
  end
  
  # test derivative of transfer function
  def test_transfer_derivative
    assert_equal(0.0, transfer_derivative(1.0))
    assert_equal(0.0, transfer_derivative(0.0))
    assert_equal(0.25, transfer_derivative(0.5))
  end
  
  # test for propagatin a xor example
  # http://www.generation5.org/content/2001/xornet.asp
  def test_forward_propagate_xor
    n1 = {:weights=>[0.129952,-0.923123,0.341232]}
    n2 = {:weights=>[0.570345,-0.328932,-0.115223]}
    n3 = {:weights=>[0.164732,0.752621,-0.993423]}
    network = [[n1,n2],[n3]]
    output = forward_propagate(network, [0,0])
    # n1
    assert_in_delta(0.341232, n1[:activation], 0.000001)
    assert_in_delta(0.584490, n1[:output], 0.000001)
    # n2
    assert_in_delta(-0.115223, n2[:activation], 0.000001)
    assert_in_delta(0.471226, n2[:output], 0.000001)
    # n3
    assert_in_delta(-0.542484, n3[:activation], 0.000001)
    assert_in_delta(0.367610, n3[:output], 0.000001)
    # output
    assert_equal(output, n3[:output])
    assert_in_delta(0.367610, output, 0.000001)
  end
  
  # test the calculation of error signals
  def test_backward_propagate_error
    n1 = {:weights=>[0.2,0.2,0.2], :output=>transfer(0.02+0.02+0.2)}
    n2 = {:weights=>[0.3,0.3,0.3], :output=>transfer(0.03+0.03+0.3)}
    n3 = {:weights=>[0.4,0.4,0.4], :output=>transfer((0.4*n1[:output])+(0.4*n2[:output])+0.4)}
    expected = 1.0
    network = [[n1,n2],[n3]]    
    backward_propagate_error(network, expected)
    # output node
    e1 = (expected-n3[:output]) * transfer_derivative(n3[:output])
    assert_equal(e1, n3[:delta])
    # input nodes
    e2 = (0.4*e1) * transfer_derivative(n1[:output])
    assert_equal(e2, n1[:delta])
    e3 = (0.4*e1) * transfer_derivative(n2[:output])
    assert_equal(e3, n2[:delta])
  end
  
  # test the calculation of error signals for xor
  # http://www.generation5.org/content/2001/xornet.asp
  def test_backward_propagate_error_xor
    n1 = {:weights=>[0.129952,-0.923123,0.341232], :output=>0.584490}
    n2 = {:weights=>[0.570345,-0.328932,-0.115223], :output=>0.471226}
    n3 = {:weights=>[0.164732,0.752621,-0.993423], :output=>0.367610}
    expected = 0.0
    network = [[n1,n2],[n3]]    
    backward_propagate_error(network, expected)
    # output node
    assert_in_delta(-0.085459, n3[:delta], 0.000001)
    # input nodes
    assert_in_delta(-0.0034190, n1[:delta], 0.000001)
    assert_in_delta(-0.0160263, n2[:delta], 0.000001)
  end
  
  # test the calculation of error derivatives
  def test_calculate_error_derivatives_for_weights
    n1 = {:weights=>[0.2,0.2,0.2], :delta=>0.5, :output=>transfer(0.02+0.02+0.2), :deriv=>[0,0,0]}
    n2 = {:weights=>[0.3,0.3,0.3], :delta=>-0.6, :output=>transfer(0.03+0.03+0.3), :deriv=>[0,0,0]}
    n3 = {:weights=>[0.4,0.4,0.4], :delta=>0.7, :output=>transfer((0.4*n1[:output])+(0.4*n2[:output])+0.4), :deriv=>[0,0,0]}
    network = [[n1,n2],[n3]]    
    vector = [0.1,0.1]
    calculate_error_derivatives_for_weights(network, vector)
    # n1 error
    assert_equal(n1[:weights].size, n1[:deriv].size)
    assert_equal(vector[0]*n1[:delta], n1[:deriv][0])
    assert_equal(vector[1]*n1[:delta], n1[:deriv][1])
    assert_equal(1*n1[:delta], n1[:deriv][2])
    # n2 error
    assert_equal(n2[:weights].size, n2[:deriv].size)
    assert_equal(vector[0]*n2[:delta], n2[:deriv][0])
    assert_equal(vector[1]*n2[:delta], n2[:deriv][1])
    assert_equal(1*n2[:delta], n2[:deriv][2])
    # n3 error
    assert_equal(n3[:weights].size, n3[:deriv].size)
    assert_equal(n1[:output]*n3[:delta], n3[:deriv][0])
    assert_equal(n2[:output]*n3[:delta], n3[:deriv][1])
    assert_equal(1*n3[:delta], n3[:deriv][2])
  end
  
  # test the calculation of error derivatives for xor
  # http://www.generation5.org/content/2001/xornet.asp
  def test_calculate_error_derivatives_for_weights_xor
    n1 = {:weights=>[0.129952,-0.923123,0.341232], :output=>0.584490, :delta=>-0.0034190, :deriv=>[0,0,0]}
    n2 = {:weights=>[0.570345,-0.328932,-0.115223], :output=>0.471226, :delta=>-0.0160263, :deriv=>[0,0,0]}
    n3 = {:weights=>[0.164732,0.752621,-0.993423], :output=>0.367610, :delta=>-0.085459, :deriv=>[0,0,0]}
    network = [[n1,n2],[n3]]
    calculate_error_derivatives_for_weights(network, [0,0])
    # n1 
    assert_in_delta(0.0, n1[:deriv][0]*0.5, 0.000001)
    assert_in_delta(0.0, n1[:deriv][1]*0.5, 0.000001)
    assert_in_delta(-0.0017095, n1[:deriv][2]*0.5, 0.000001)
    # n2
    assert_in_delta(0.0, n2[:deriv][0]*0.5, 0.000001)
    assert_in_delta(0.0, n2[:deriv][1]*0.5, 0.000001)
    assert_in_delta(-0.0080132, n2[:deriv][2]*0.5, 0.000001)
    # n3
    assert_in_delta(-0.024975, n3[:deriv][0]*0.5, 0.000001)
    assert_in_delta(-0.020135, n3[:deriv][1]*0.5, 0.000001)
    assert_in_delta(-0.042730, n3[:deriv][2]*0.5, 0.000001)
  end
  
  # test that weights are updated as expected
  def test_update_weights
    n1 = {:weights=>[0.2,0.2,0.2], :deriv=>[0.1, -0.5, 100.0], :last_delta=>[0,0,0]}
    network = [[n1]]
    update_weights(network, 1.0, 0.0)
    assert_equal((0.2 + (0.1*1.0)), n1[:weights][0])
    assert_equal((0.2 + (-0.5*1.0)), n1[:weights][1])
    assert_equal((0.2 + (100*1.0)), n1[:weights][2])
  end

  # helper for turning off STDOUT
  # File activesupport/lib/active_support/core_ext/kernel/reporting.rb, line 39
  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen('/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end
  
  # test training the networ
  def test_train_network
    n1 = {:weights=>[-1, -1, 1], :last_delta=>[0,0,0], :deriv=>[0,0,0]}
    n2 = {:weights=>[-1, -1, 1], :last_delta=>[0,0,0], :deriv=>[0,0,0]}
    n3 = {:weights=>[-1, -1, 1], :last_delta=>[0,0,0], :deriv=>[0,0,0]}
    network = [[n1,n2],[n3]]
    domain = [[0,0,0], [0,1,1], [1,0,1], [1,1,0]]
    silence_stream(STDOUT) do
      train_network(network, domain, 2, 100, 0.5)
    end
    # test the network weights were changed
    assert_not_equal([-1, -1, 1], n1[:weights])
    assert_not_equal([-1, -1, 1], n2[:weights])
    assert_not_equal([-1, -1, 1], n3[:weights])
  end
  
  # test the network can compute correct outcomes 
  # based on http://www.generation5.org/content/2001/xornet.asp
  def test_test_network
    # note the order difference
    n1 = {:weights=>[-6.062263, -6.072185, 2.454509]}
    n2 = {:weights=>[-4.893081, -4.894898, 7.293063]}
    n3 = {:weights=>[-9.792470, 9.484580, -4.473972]}
    network = [[n1,n2],[n3]]    
    domain = [[0,0,0], [0,1,1], [1,0,1], [1,1,0]]
    # specifics
    assert_in_delta(0.017622, forward_propagate(network, domain[0]), 0.001)    
    assert_in_delta(0.981504, forward_propagate(network, domain[1]), 0.06)
    assert_in_delta(0.981491, forward_propagate(network, domain[2]), 0.06)
    assert_in_delta(0.022782, forward_propagate(network, domain[3]), 0.001)    
    # all 
    output = nil
    silence_stream(STDOUT) do
      output = test_network(network, domain, 2)
    end
    assert_equal(4, output)
  end
  
  # test that a neuron is created as expected
  def test_create_neuron
    assert_equal(2, create_neuron(1)[:weights].size)
    assert_equal(3, create_neuron(2)[:weights].size)
    assert_equal(11, create_neuron(10)[:weights].size)
  end
  
  # test that the system can learn xor
  def test_compute
    domain = [[0,0,0], [0,1,1], [1,0,1], [1,1,0]]
    network = nil 
    silence_stream(STDOUT) do
      network = execute(domain, 2, 2000, 4, 0.1)
    end     
    # structure    
    assert_equal(2, network.size)
    assert_equal(4, network[0].size)
    assert_equal(1, network[1].size)
    # output
    output = nil
    silence_stream(STDOUT) do
      output = test_network(network, domain, 2)
    end
    assert_equal(4, output)
  end
  
end
