# Unit tests for cultural_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../cultural_algorithm"

class TC_CulturalAlgorithm < Test::Unit::TestCase

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
  
  # test the variation function
  def test_mutate_with_inf
    c = {:vector=>[0,0]}
    rs = mutate_with_inf(c, {:normative=>[[0.25, 0.75], [0.25, 0.75]]}, [[0,1],[0,1]] )
    assert_not_equal([0,0], rs[:vector])
    rs[:vector].each do |x|
      assert_operator(x, :>=, 0.25)
      assert_operator(x, :<=, 0.75)
    end
  end
  
  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}  
  end
  
  # test the initialization of the beliefset
  def test_initialize_beliefspace
    minmax = [[0,1],[0,1]]
    bs = initialize_beliefspace(minmax)
    assert_nil(bs[:situational])
    assert_not_nil(bs[:normative])
    assert_equal(2, bs[:normative].size)
    assert_equal(minmax[0], bs[:normative][0])
    assert_equal(minmax[1], bs[:normative][1])
    assert_not_same(minmax[0], bs[:normative][0])
    assert_not_same(minmax[1], bs[:normative][1])
  end
  
  # test the update of the situational beliefspace
  def test_update_beliefspace_situational
    # update from nil
    bs = {:situational=>nil}
    update_beliefspace_situational!(bs, {:fitness=>0})
    # update via replace
    bs = {:situational=>{:fitness=>100}}
    update_beliefspace_situational!(bs, {:fitness=>0})
    assert_equal(0, bs[:situational][:fitness])
    # don't update
    bs = {:situational=>{:fitness=>0}}
    update_beliefspace_situational!(bs, {:fitness=>100})
    assert_equal(0, bs[:situational][:fitness])
  end
  
  # test the updating of the normative beliefset
  def test_update_beliefspace_normative
    bs = {:normative=>[[0,1],[0,1]]}
    pop = [{:vector=>[0.1,0.5]}, {:vector=>[0.5,0.9]}, {:vector=>[0.2,0.6]}]
    update_beliefspace_normative!(bs, pop)
    assert_equal([0.1, 0.5], bs[:normative][0])
    assert_equal([0.5, 0.9], bs[:normative][1])
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
      best = search(50, [[-5,5],[-5,5]], 50, 20)
    end  
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 0.1)
  end
  
end
