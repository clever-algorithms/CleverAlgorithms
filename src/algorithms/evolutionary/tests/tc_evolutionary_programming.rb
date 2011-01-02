# Unit tests for evolutionary_programming.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../evolutionary_programming"

class TC_EvolutionaryProgramming < Test::Unit::TestCase

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

  # test default rand gaussian
  def test_random_gaussian_default
    mean, stdev = 0.0, 1.0
    all = []
    1000.times do
      all << random_gaussian(mean, stdev)
      assert_in_delta(mean, all.last, 6*stdev)
    end
    m = all.inject(0){|sum,x| sum + x} / all.size.to_f
    assert_in_delta(mean, m, 0.1)
  end
  
  # test rand gaussian in different range
  def test_random_gaussian_non_default
    mean, stdev = 50, 10
    all = []
    1000.times do
      all << random_gaussian(mean, stdev)
      assert_in_delta(mean, all.last, 6*stdev)
    end
    m = all.inject(0){|sum,x| sum + x} / all.size.to_f
    assert_in_delta(m, mean, 1.0)
  end  

  # test mutation
  def test_mutate
    rs = mutate({:vector=>[0.5,0.5],:strategy=>[0.5,0.5]}, [[0,1],[0,1]])
    assert_not_nil(rs)
    assert_not_nil(rs[:vector])
    assert_not_nil(rs[:strategy])
    rs[:vector].each do |v|
      assert_operator(v, :>=, 0)
      assert_operator(v, :<=, 1)
    end
  end
  
  # test tournament
  def test_tournament
    # win
    candidate = {:fitness=>0}
    tournament(candidate, [{:fitness=>1}], 1)
    assert_not_nil(candidate[:wins])
    assert_equal(1, candidate[:wins])
    # loss
    candidate = {:fitness=>1}
    tournament(candidate, [{:fitness=>0}], 1)
    assert_not_nil(candidate[:wins])
    assert_equal(0, candidate[:wins])
  end
  
  # test initializing a new pop
  def test_init_population
    pop = init_population( [[0,1],[0,1]], 1000)
    assert_equal(1000, pop.size)
    pop.each do |p|
      assert_not_nil(p[:vector])
      assert_not_nil(p[:strategy])
      assert_not_nil(p[:fitness])
      assert_equal(2, p[:vector].size)
      assert_equal(2, p[:strategy].size)
      p[:vector].each do |v|
        assert_operator(v, :>=, 0)
        assert_operator(v, :<=, 1)
      end
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
      best = search(50, [[-5,5],[-5,5]], 50, 3)
    end  
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 0.001)
  end
  
end
