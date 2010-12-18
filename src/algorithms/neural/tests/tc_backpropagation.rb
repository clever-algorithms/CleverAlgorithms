# Unit tests for backpropagation.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require "../backpropagation"

class TC_BackPropagation < Test::Unit::TestCase
  
  # test the generation of random vectors
  def test_random_vector
    bounds = [-3,3]
    minmax = Array.new(20) {bounds}
    300.times do 
      vector = random_vector(minmax)
      sum = 0.0
      assert_equal(20, vector.size)
      vector.each do |v|
        assert(v >= bounds[0])
        assert(v <= bounds[1])
        sum += v
      end
      assert_in_delta(bounds[0]+((bounds[1]-bounds[0])/2.0), sum/300.0, 0.1)
    end    
  end
  
  # test the generation of small random weights
  def test_initialize_weights
    weights = initialize_weights(100)
    # adds a bias
    assert_equal(101, weights.size)
    # check values in [-0.5,0.5]
    weights.each do |w|
      assert(w <= 0.5)
      assert(w > -0.5)
    end
  end

  # test weighted sum function
  def test_activate
    assert_equal(5.0, activate([1.0, 1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0]))
    assert_equal(2.5, activate([0.5, 0.5, 0.5, 0.5, 0.5], [1.0, 1.0, 1.0, 1.0]))
  end
  
  # test the transfer function
  def test_transfer
    # small values stay smallish
    assert_in_delta(0.73, transfer(1.0), 0.01)
    assert_in_delta(0.5, transfer(0.0), 0.001)
    # large/small values get squashed
    assert_in_delta(1.0, transfer(10.0), 0.0001)
    assert_in_delta(0.0, transfer(-10.0), 0.0001)
  end
  
  # test derivative of transfer function
  def test_transfer_derivative
    assert_equal(0.0, transfer_derivative(1.0))
    assert_equal(0.0, transfer_derivative(0.0))
    assert_equal(0.25, transfer_derivative(0.5))
  end
  
  # test the forward propagation of output
  def test_forward_propagate
    n1, n2, n3 = {:weights=>[0.2,0.2,0.2]}, {:weights=>[0.3,0.3,0.3]}, {:weights=>[0.4,0.4,0.4]}
    network = [[n1,n2],[n3]]
    output = forward_propagate(network, [0.1,0.1])
    # input layer
    t1 = (0.02+0.02+0.2)
    assert_equal(t1, n1[:activation])
    assert_equal(transfer(t1), n1[:output])
    t2 = 0.03+0.03+0.3
    assert_equal(t2, n2[:activation])
    assert_equal(transfer(t2), n2[:output])
    # hidden
    t3 = (0.4*transfer(t1))+(0.4*transfer(t2))+0.4
    assert_equal(t3, n3[:activation])
    assert_equal(transfer(t3), n3[:output])
    # outputs
    assert_equal(transfer(t3), output) # 0.702556520749393
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
    assert_equal(e1, n3[:error_delta])
    # input nodes
    e2 = (0.4*e1) * transfer_derivative(n1[:output])
    assert_equal(e2, n1[:error_delta])
    e3 = (0.4*e1) * transfer_derivative(n2[:output])
    assert_equal(e3, n2[:error_delta])
  end
  
  # test the calculation of error derivatives
  def test_calculate_error_derivatives_for_weights
    n1 = {:weights=>[0.2,0.2,0.2], :error_delta=>0.5, :output=>transfer(0.02+0.02+0.2)}
    n2 = {:weights=>[0.3,0.3,0.3], :error_delta=>-0.6, :output=>transfer(0.03+0.03+0.3)}
    n3 = {:weights=>[0.4,0.4,0.4], :error_delta=>0.7, :output=>transfer((0.4*n1[:output])+(0.4*n2[:output])+0.4)}
    network = [[n1,n2],[n3]]    
    vector = [0.1,0.1]
    calculate_error_derivatives_for_weights(network, vector)
    # n1 error
    assert_equal(n1[:weights].size, n1[:error_derivative].size)
    assert_equal(vector[0]*n1[:error_delta], n1[:error_derivative][0])
    assert_equal(vector[1]*n1[:error_delta], n1[:error_derivative][1])
    assert_equal(1*n1[:error_delta], n1[:error_derivative][2])
    # n2 error
    assert_equal(n2[:weights].size, n2[:error_derivative].size)
    assert_equal(vector[0]*n2[:error_delta], n2[:error_derivative][0])
    assert_equal(vector[1]*n2[:error_delta], n2[:error_derivative][1])
    assert_equal(1*n2[:error_delta], n2[:error_derivative][2])
    # n3 error
    assert_equal(n3[:weights].size, n3[:error_derivative].size)
    assert_equal(n1[:output]*n3[:error_delta], n3[:error_derivative][0])
    assert_equal(n2[:output]*n3[:error_delta], n3[:error_derivative][1])
    assert_equal(1*n3[:error_delta], n3[:error_derivative][2])
  end
  
  # test that weights are updated as expected
  def test_update_weights
    n1 = {:weights=>[0.2,0.2,0.2], :error_derivative=>[0.1, -0.5, 100.0]}
    network = [[n1]]
    update_weights(network, 1.0)
    assert_equal((0.2 + (0.1*1.0)), n1[:weights][0])
    assert_equal((0.2 + (-0.5*1.0)), n1[:weights][1])
    assert_equal((0.2 + (100*1.0)), n1[:weights][2])
  end
  
end