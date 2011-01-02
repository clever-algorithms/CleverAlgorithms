# Unit tests for perceptron.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../perceptron"

class TC_Perceptron < Test::Unit::TestCase 
  
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
  
  # test weight initialization
  def test_initialize_weights
    w = initialize_weights(10)
    assert_equal(11, w.size)
    w.each do |v|
      assert_operator(v, :>=, -1)
      assert_operator(v, :<, 1)
    end
  end
  
  # test weight updates
  def test_update_weights
    # no error, no change, one inputs
    w = [0.5,0.5,0.5]
    update_weights(2, w, [1,1], 1.0, 1.0, 0.9)
    w.each{|x| assert_equal(0.5, x)}
    # no error, no change, zero inputs
    w = [0.5,0.5,0.5]
    update_weights(2, w, [1,1], 0.0, 0.0, 0.9)
    w.each{|x| assert_equal(0.5, x)}
    # an update
    w = [0.5,0.5,0.5]
    update_weights(2, w, [1,1], 1.0, 0.0, 0.9)
    w.each{|x| assert_equal(1.4, x)}
  end
  
  # test weighted sum function
  def test_activate
    assert_equal(5.0, activate([1.0, 1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0]))
    assert_equal(2.5, activate([0.5, 0.5, 0.5, 0.5, 0.5], [1.0, 1.0, 1.0, 1.0]))
    assert_equal(-6.062263, activate([-6.072185,2.454509,-6.062263], [0, 0]))
  end
  
  # test the transfer function
  def test_transfer
    assert_equal(0, transfer(-1))
    assert_equal(1, transfer(0))
    assert_equal(1, transfer(1))
  end
  
  # test activation + transfer
  def test_get_output
    assert_equal(1, get_output([1,1,1], [1,1]))
    assert_equal(0, get_output([-1,-1,-1], [1,1]))
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

  # test the training of weights
  def test_train_weights
    domain = [[0,0,0], [0,1,1], [1,0,1], [1,1,1]]
    w = [-1,-1,-1]
    silence_stream(STDOUT) do
      train_weights(w, domain, 2, 10, 0.5)
    end
    w.each {|x| assert_not_equal(-1, x) }
  end

  # test the testing of weights
  def test_test_weights
    rs = nil
    domain = [[0,0,0], [0,1,1], [1,0,1], [1,1,1]]
    w = [0.5,0.5,-0.5]
    silence_stream(STDOUT) do
      rs = test_weights(w, domain, 2)
    end
    assert_equal(4, rs)
  end
  
  # test that the algorithm can solve the problem
  def test_search    
    domain = [[0,0,0], [0,1,1], [1,0,1], [1,1,1]]
    weights = nil
    silence_stream(STDOUT) do
      weights = execute(domain, 2, 20, 0.1)
    end
    assert_equal(3, weights.length)
    rs = nil
    silence_stream(STDOUT) do
      rs = test_weights(weights, domain, 2)
    end
    assert_equal(4, rs)
  end
  
end
