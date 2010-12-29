# Unit tests for genetic_algorithm.rb
# additional tests, because tc_genetic_algorithm.rb is used as an example in the book.

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../genetic_algorithm"

class TC_GeneticAlgorithm2 < Test::Unit::TestCase
      
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
      best = search(100, 64, 100, 0.95, 1.0/64.0)
    end  
    assert_not_nil(best[:fitness])
    assert_equal(64, best[:fitness])
  end
  
end
