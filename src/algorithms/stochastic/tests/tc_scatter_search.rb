# Unit tests for scatter_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../scatter_search"

class TC_ScatterSearch < Test::Unit::TestCase

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
  
  # test the local search procedure
  def test_local_search
    # improvement
    best = {:vector=>[1,1]}
    best[:cost] = objective_function(best[:vector])
    rs = local_search(best, [[-1,1],[-1,1]], 30, 0.005)
    assert_not_nil(rs)
    assert_not_nil(rs[:vector])
    assert_not_nil(rs[:cost])
    assert_not_same(best, rs)
    assert_not_equal(best[:vector], rs[:vector])
    assert_not_equal(best[:cost], rs[:cost])
    # no improvement
    best = {:vector=>[0,0], :cost=>0.0}
    rs = local_search(best, [[-1,1],[-1,1]], 30, 0.005)
    assert_not_nil(rs)
    assert_equal(best[:cost], rs[:cost])
  end
  
  def test_construct_initial_set
    
  end
  
  # test euclidean distance
  def test_euclidean_distance
    assert_equal(0, euclidean_distance([0,0],[0,0]))
    assert_equal(0, euclidean_distance([1,5],[1,5]))
    assert_in_delta(1.4, euclidean_distance([1,1],[2,2]),0.1)    
  end
  
  def test_distance
    
  end
  
  def test_diversify
    
  end
  
  def test_select_subsets
    
  end
  
  def test_recombine
    
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
      best = search([[-5,5],[-5,5]], 100, 10, 20, 30, 0.05, 5)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.0001)
  end
  
end
