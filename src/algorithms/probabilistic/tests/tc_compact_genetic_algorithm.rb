# Unit tests for compact_genetic_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../compact_genetic_algorithm"

class TC_CompactGeneticAlgorithm < Test::Unit::TestCase

  # test that the objective function behaves as expected
  def test_onemax
    assert_equal(0, onemax([0,0,0,0]))
    assert_equal(4, onemax([1,1,1,1]))
    assert_equal(2, onemax([1,0,1,0]))
  end

  # generate a candidate solution
  def test_generate_candidate
    # all 0
    s = generate_candidate(Array.new(1000){0})
    assert_not_nil(s)
    assert_not_nil(s[:cost])
    assert_equal(0, s[:cost])
    assert_equal(1000, s[:bitstring].length)
    # all 1
    s = generate_candidate(Array.new(1000){1})
    assert_not_nil(s)
    assert_not_nil(s[:cost])
    assert_equal(1000, s[:cost])
    assert_equal(1000, s[:bitstring].length)
    # all 50/50
    s = generate_candidate(Array.new(1000){0.5})
    assert_not_nil(s)
    assert_not_nil(s[:cost])
    assert_in_delta(500, s[:cost],50)
    assert_equal(1000, s[:bitstring].length)
  end
  
  # test vector updates
  def test_update_vector
    # update all bits
    vector = [0.5,0.5,0.5]
    update_vector(vector, {:bitstring=>[1,1,1]}, {:bitstring=>[0,0,0]}, 10)
    vector.each{|i| assert_equal(0.5+(0.1), vector[i])}
    # update no bits 
    vector = [0.5,0.5,0.5]
    update_vector(vector, {:bitstring=>[1,1,1]}, {:bitstring=>[1,1,1]}, 10)
    vector.each{|i| assert_equal(0.5, vector[i])}
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
      best = search(20, 200, 20)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(20, best[:cost],5)
  end
  
end
