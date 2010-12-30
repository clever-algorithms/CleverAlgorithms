# Unit tests for pbil.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../pbil"

class TC_PBIL < Test::Unit::TestCase

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

  # test updating the vector
  def test_update_vector
    # no update, no change
    vector = Array.new(1000){0.5}
    update_vector(vector, {:bitstring=>Array.new(1000){0}}, 0.0)
    vector.each{|x| assert_equal(0.5, x)}
    # no update, decay 
    vector = Array.new(1000){0.5}
    update_vector(vector, {:bitstring=>Array.new(1000){0}}, 0.5)
    vector.each{|x| assert_equal(0.5*0.5, x)}
    # update
    vector = Array.new(1000){0.5}
    update_vector(vector, {:bitstring=>Array.new(1000){0.8}}, 0.5)
    vector.each{|x| assert_equal(0.5*0.5+0.8*0.5, x)}
  end
  
  # test mutating the vector
  def test_mutate_vector
    # no change
    vector = Array.new(1000){0.5}
    mutate_vector(vector, {:bitstring=>Array.new(1000){0}}, 0.5, 0.0)
    vector.each{|x| assert_equal(0.5, x)}
    # all change
    vector = Array.new(1000){0.5}
    mutate_vector(vector, {:bitstring=>Array.new(1000){0}}, 0.5, 1.0)
    vector.each do |x| 
      assert_operator(x, :<=, 1.0)
      assert_operator(x, :>, 0.0)
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
      best = search(20, 100, 100, 1.0/20.0, 0.05, 0.1)
    end  
    assert_not_nil(best[:cost])
    assert_equal(20, best[:cost])
  end
  
end
