# Unit tests for umda.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../umda"

class TC_UMDA < Test::Unit::TestCase

  # test that the objective function behaves as expected
  def test_onemax
    assert_equal(0, onemax([0,0,0,0]))
    assert_equal(4, onemax([1,1,1,1]))
    assert_equal(2, onemax([1,0,1,0]))
  end
  
  # test basic construction of random bitstrings
  def test_random_bitstring
    assert_equal(10, random_bitstring(10).size)
    assert_equal(10, random_bitstring(10).select{|x| x==0 or x==1}.size)    
  end
  
  # test the approximate proportion of 1's and 0's
  def test_random_bitstring_ratio
    s = random_bitstring(1000)
    assert_in_delta(0.5, (s.select{|x| x==0}.size/1000.0), 0.05)
    assert_in_delta(0.5, (s.select{|x| x==1}.size/1000.0), 0.05)
  end  

  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}  
  end
  
  # test the reduction of a pop to a probability vector
  def test_calculate_bit_probabilities
    # all zeros
    pop = [{:bitstring=>Array.new(1000){0}}, {:bitstring=>Array.new(1000){0}}]
    v = calculate_bit_probabilities(pop)
    assert_equal(1000, v.size)
    v.each{|x| assert_equal(0, x)}
    # all ones
    pop = [{:bitstring=>Array.new(1000){1}}, {:bitstring=>Array.new(1000){1}}]
    v = calculate_bit_probabilities(pop)
    assert_equal(1000, v.size)
    v.each{|x| assert_equal(1, x)}
    # 50/50
    pop = [{:bitstring=>Array.new(1000){1}}, {:bitstring=>Array.new(1000){0}}]
    v = calculate_bit_probabilities(pop)
    assert_equal(1000, v.size)
    v.each{|x| assert_equal(0.5, x)}
  end
  
  # generate a candidate solution
  def test_generate_candidate
    # all 0
    s = generate_candidate(Array.new(1000){0})
    assert_not_nil(s)
    assert_equal(1000, s[:bitstring].length)
    s[:bitstring].each{|x| assert_equal(0, x)}
    # all 1
    s = generate_candidate(Array.new(1000){1})
    assert_not_nil(s)
    assert_equal(1000, s[:bitstring].length)
    s[:bitstring].each{|x| assert_equal(1, x)}
    # all 50/50
    s = generate_candidate(Array.new(1000){0.5})
    assert_not_nil(s)
    assert_equal(1000, s[:bitstring].length)
    assert_in_delta(500, s[:bitstring].inject(0){|sum,x| sum+x}, 50)
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
      best = search(20, 100, 50, 30)
    end
    assert_not_nil(best[:fitness])
    assert_equal(20, best[:fitness])
  end
  
end
