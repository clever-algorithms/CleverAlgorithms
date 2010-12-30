# Unit tests for cross_entropy_method.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../cross_entropy_method"

class TC_CompactGeneticAlgorithm < Test::Unit::TestCase

  # test the objective function
  def test_objective_function
    # integer
    assert_equal(99**2, objective_function([99]))
    # float
    assert_equal(0.1**2.0, objective_function([0.1]))
    # vector
    assert_equal(1**2+2**2+3**2, objective_function([1,2,3]))
  end

  # test default rand gaussian
  def test_random_gaussian_default
    mean, stdev = 0.0, 1.0
    a = []
    1000.times do
      r = random_gaussian(mean, stdev)
      assert_in_delta(mean, r, 4*stdev) # 4 stdevs
      a << r
    end
    mean = a.inject(0){|sum,x| sum + x} / a.size.to_f
    assert_in_delta(mean, mean, 0.1)
  end
  
  # test rand gaussian in different range
  def test_random_gaussian_non_default
    mean, stdev = 50, 10
    a = []
    1000.times do
      r = random_gaussian(mean, stdev)
      assert_in_delta(mean, r, 4*stdev) # 4 stdevs
      a << r
    end
    mean = a.inject(0){|sum,x| sum + x} / a.size.to_f
    assert_in_delta(mean, mean, 0.1)
  end  
  
  # TODO write tests
  
  
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
      best = search([[-5,5],[-5,5]], 100, 50, 5, 0.7)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.001)
  end
  
end
