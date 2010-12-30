# Unit tests for stochastic_hill_climbing.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../stochastic_hill_climbing"

class TC_StochasticHillClimbing < Test::Unit::TestCase

  # test that the objective function behaves as expected
  def test_onemax
    assert_equal(0, onemax(["0","0","0","0"]))
    assert_equal(4, onemax(["1","1","1","1"]))
    assert_equal(2, onemax(["1","0","1","0"]))
  end

  # test basic construction of random bitstrings
  def test_random_bitstring
    assert_equal(10, random_bitstring(10).size)
    assert_equal(10, random_bitstring(10).select{|x| x=='0' or x=='1'}.size)    
  end
  
  # test the approximate proportion of 1's and 0's
  def test_random_bitstring_ratio
    s = random_bitstring(1000)
    assert_in_delta(0.5, (s.select{|x| x=='0'}.size/1000.0), 0.05)
    assert_in_delta(0.5, (s.select{|x| x=='1'}.size/1000.0), 0.05)
  end
  
  # test the construction of a random neighbour
  def test_random_neighbor
    parent = [0,0,0,0,0]
    100.times do
      rs = random_neighbor(parent)
      assert_equal(parent.size, rs.size)
      assert_not_equal(parent, rs)
      assert_not_same(parent, rs)
      diffs = 0
      parent.each_index {|i| diffs += 1 if parent[i]!=rs[i]}
      assert(1, diffs)
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
      best = search(100, 20)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(20, best[:cost],3)
  end
  
end
