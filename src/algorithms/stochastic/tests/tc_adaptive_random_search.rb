# Unit tests for adaptive_random_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../adaptive_random_search"

class TC_AdaptiveRandomSearch < Test::Unit::TestCase

  # test the objective function
  def test_objective_function
    # integer
    assert_equal(99**2, objective_function([99]))
    # float
    assert_equal(0.1**2.0, objective_function([0.1]))
    # vector
    assert_equal(1**2+2**2+3**2, objective_function([1,2,3]))
    # optima
    assert_equal(0, objective_function([0,0]))
  end

  # test the uniform sampling within bounds
  def test_rand_in_bounds
    # positive, zero offset
    x = rand_in_bounds(0, 20)
    assert_operator(x, :>=, 0)
    assert_operator(x, :<, 20)
    # negative
    x = rand_in_bounds(-20, -1)
    assert_operator(x, :>=, -20)
    assert_operator(x, :<, -1)
    # both
    x = rand_in_bounds(-10, 20)
    assert_operator(x, :>=, -10)
    assert_operator(x, :<, 20)
  end

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

  # test the construction of a step
  def test_take_step
    # step within stepsize
    p = take_step([[0, 100]], [50], 3.3)
    assert_operator(p[0], :>=, 50-3.3)
    assert_operator(p[0], :<=, 50+3.3)    
    # snap to bounds
    p = take_step([[0, 1]], [0], 3.3)
    assert_operator(p[0], :>=, 0)
    assert_operator(p[0], :<, 1)
  end
  
  # test the calculation of the large step size
  def test_large_step_size
    # test use small factor
    s = large_step_size(0, 1, 2, 3, 100)
    assert_equal(1*2, s)
    # test use large factor
    s = large_step_size(100, 1, 2, 3, 100)
    assert_equal(1*3, s)
  end
  
  # test the construction of steps
  def test_take_steps
    20.times do
      step1, step2 = take_steps([[0,10]], {:vector=>[5]}, 1, 3)
      # small
      assert_not_nil(step1[:vector])
      assert_not_nil(step1[:cost])
      assert_operator(step1[:vector][0], :>=, 5-1)
      assert_operator(step1[:vector][0], :<, 5+1)
      # large
      assert_not_nil(step2[:vector])
      assert_not_nil(step2[:cost])
      assert_operator(step2[:vector][0], :>=, 5-3)
      assert_operator(step2[:vector][0], :<, 5+3)
    end
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
  
  # test that the algorithm can solve the problem
  def test_search    
    best = nil
    silence_stream(STDOUT) do
      best = search(1000, [[-5,5],[-5,5]], 0.05, 1.3, 3.0, 10, 30)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.1)
  end
  
end
