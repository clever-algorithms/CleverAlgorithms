# Unit tests for harmony_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../harmony_search"

class TC_HarmontySearch < Test::Unit::TestCase

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
      best = search([[-5,5],[-5,5]], 100, 20, 0.95, 0.7, 0.5)
    end  
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 0.01)
  end
  
end
