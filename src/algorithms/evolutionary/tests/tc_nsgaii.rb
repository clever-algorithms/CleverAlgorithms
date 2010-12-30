# Unit tests for nsga_ii.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../nsgaii"

class TC_NSGAII < Test::Unit::TestCase 
  
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
  
  # test the creation of random strings
  def test_random_bitstring
    assert_equal(10, random_bitstring(10).size)
    assert_equal(0, random_bitstring(10).delete('0').delete('1').size)
  end

  # test the approximate proportion of 1's and 0's
  def test_random_bitstring_ratio
    s = random_bitstring(1000)
    assert_in_delta(0.5, (s.delete('1').size/1000.0), 0.05)
    assert_in_delta(0.5, (s.delete('0').size/1000.0), 0.05)
  end
  
  # test uniform crossover
  def test_uniform_crossover
    p1 = "0000000000"
    p2 = "1111111111"        
    assert_equal(p1, uniform_crossover(p1,p2,0))
    assert_not_same(p1, uniform_crossover(p1,p2,0))      
    s = uniform_crossover(p1,p2,1)        
    s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
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
    pop_size = 50
    pop = nil
    silence_stream(STDOUT) do
      pop = search([[-10, 10]], 100, pop_size, 0.95)
    end    
    assert_equal(pop_size, pop.size)
    pop.each do |p|
      # in [0,2]
      assert_in_delta(1.0, p[:vector][0], 1.2)
      assert_not_nil(p[:objectives])
      assert_equal(2, p[:objectives].size)
    end    
  end
  
end
