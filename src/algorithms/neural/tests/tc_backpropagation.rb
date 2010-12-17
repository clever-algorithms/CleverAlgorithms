# Unit tests for backpropagation.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require "../backpropagation"

class TC_BackPropagation < Test::Unit::TestCase
  
  # def test_random_vector
  #   fail("not written")
  # end
  # 
  # def test_normalize_class_index
  #   fail("not written")
  # end
  # 
  # def test_denormalize_class_index
  #   fail("not written")
  # end
  # 
  # def test_generate_random_pattern
  #   fail("not written")
  # end
  # 
  # def test_initialize_weights
  #   fail("not written")
  # end
    
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
    pattern = {:vector=>[0.1,0.1]}
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    out_actual, out_class = forward_propagate(network, pattern, domain)
    # input layer
    t1 = 0.02+0.02+0.2
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
    assert_equal(transfer(t3), out_actual) # 0.702556520749393
    assert_equal("B", out_class)
  end
  
  # test the calculation of error signals
  def test_backward_propagate_error
    pattern = {:vector=>[0.1,0.1], :class_norm=>1.0} # B
    n1 = {:weights=>[0.2,0.2,0.2], :output=>(0.02+0.02+0.2)}
    n2 = {:weights=>[0.3,0.3,0.3], :output=>(0.03+0.03+0.3)}
    n3 = {:weights=>[0.4,0.4,0.4], :output=>((0.4*transfer(n1[:output]))+(0.4*transfer(n2[:output]))+0.4)}
    network = [[n1,n2],[n3]]    
    backward_propagate_error(network, pattern)
    # output node
    e1 = (pattern[:class_norm]-n3[:output]) * transfer_derivative(n3[:output])
    assert_equal(e1, n3[:error_delta])
    # input nodes
    e2 = (0.4*e1) * transfer_derivative(n1[:output])
    assert_equal(e2, n1[:error_delta])
    e3 = (0.4*e1) * transfer_derivative(n2[:output])
    assert_equal(e3, n2[:error_delta])
  end
  
  # test the calculation of error derivatives
  def test_calculate_error_derivatives_for_weights
    pattern = {:vector=>[0.1,0.1]}
    n1 = {:weights=>[0.2,0.2,0.2], :error_delta=>0.5}
    n2 = {:weights=>[0.3,0.3,0.3], :error_delta=>-0.6}
    n3 = {:weights=>[0.4,0.4,0.4], :error_delta=>0.7}
    network = [[n1,n2],[n3]]    
    calculate_error_derivatives_for_weights(network, pattern)
    
  end
  
end