# Unit tests for perceptron.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../perceptron"

class TC_Perceptron < Test::Unit::TestCase 
  
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
    domain = [[0,0,0], [0,1,1], [1,0,1], [1,1,1]]
    weights = nil
    silence_stream(STDOUT) do
      weights = compute(domain, 2, 20, 0.1)
    end
    assert_equal(4, test_weights(weights, domain, 2))
  end
  
end
