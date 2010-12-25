# Unit tests for spea2.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../spea2"

class TC_SPEA2 < Test::Unit::TestCase 
  
  # test 1st objective function
  def test_objective1
    # optima
    assert_equal(0, objective1([0,0])) # 0,0
    # limits
    assert_equal(2000000, objective1([-1000,-1000]))
    assert_equal(2000000, objective1([1000,1000]))
  end
  
  # test 2nd objective function
  def test_objective2
    # optima
    assert_equal(0, objective2([2,2])) # 2,2
    # limits
    assert_equal(2000000, objective1([-1000,-1000]))
    assert_equal(2000000, objective1([1000,1000]))
  end
  
  # test euclidean distance
  def test_euclidean_distance
    assert_equal(0, euclidean_distance([0,0],[0,0]))
    assert_equal(0, euclidean_distance([1,5],[1,5]))
    assert_in_delta(1.4, euclidean_distance([1,1],[2,2]),0.1)    
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
    pop = nil
    silence_stream(STDOUT) do
      pop = search([[-10,10]], 50, 50, 20, 0.95)
    end    
    assert_equal(20, pop.size)
    pop.each do |p|
      assert_not_nil(p[:objectives])
      assert_equal(2, p[:objectives].size)
      assert_in_delta(0.0, p[:objectives][0], 1)
      assert_in_delta(0.0, p[:objectives][1], 1)
    end    
  end
  
end
