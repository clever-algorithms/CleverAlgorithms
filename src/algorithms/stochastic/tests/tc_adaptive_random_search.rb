# Unit tests for adaptive_random_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../adaptive_random_search"

class TC_AdaptiveRandomSearch < Test::Unit::TestCase
    
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
      best = search(1000, [[-5,5],[-5,5]], 0.05, 1.3, 3.0, 10, 30)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.1)
  end
  
end
