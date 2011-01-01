# Unit tests for harmony_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../harmony_search"

class TC_HarmontySearch < Test::Unit::TestCase

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

  # test the creation of a random candidate
  def test_create_random_harmony
    s = create_random_harmony([[0,1],[0,1]])
    assert_not_nil(s)
    assert_not_nil(s[:vector])
    assert_not_nil(s[:fitness])
    s[:vector].each do |x| 
      assert_operator(x, :>=, 0)
      assert_operator(x, :<=, 1)
    end
  end
  
  # test initializing memory
  def test_initialize_harmony_memory
    m = initialize_harmony_memory([[0,1],[0,1]], 10)
    assert_equal(10, m.size)
  end
  
  # test the creation of a harmony
  def test_create_harmony
    memory = [{:vector=>[0,0]}, {:vector=>[0,0]}, {:vector=>[0,0]}]
    # consideration, no adjustment
    rs = create_harmony([[0,1],[0,1]], memory, 1.0, 0.0, 0.005)
    assert_equal(2, rs[:vector].size)
    rs[:vector].each{|x| assert_equal(0, x)}
    # consideration, all adjustment
    rs = create_harmony([[0,1],[0,1]], memory, 1.0, 1.0, 0.005)
    assert_equal(2, rs[:vector].size)
    rs[:vector].each do |x| 
      assert_operator(x, :>=, 0)
      assert_operator(x, :<=, 1)
    end
    # no consideration
    rs = create_harmony([[0,1],[0,1]], memory, 0.0, 0.0, 0.005)
    assert_equal(2, rs[:vector].size)
    rs[:vector].each do |x| 
      assert_operator(x, :>=, 0)
      assert_operator(x, :<=, 1)
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
      best = search([[-5,5],[-5,5]], 100, 20, 0.95, 0.7, 0.5)
    end  
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 0.1)
  end
  
end
