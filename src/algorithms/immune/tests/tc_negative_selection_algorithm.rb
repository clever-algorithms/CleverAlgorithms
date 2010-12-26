# Unit tests for negative_selection_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../negative_selection_algorithm"

class TC_NegativeSelectionAlgorithm < Test::Unit::TestCase 
  
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
    search_space = Array.new(2) {[0.0, 1.0]}
    self_space = Array.new(2) {[0.5, 1.0]}
    detectors = nil
    silence_stream(STDOUT) do
      detectors = execute(search_space, self_space, 300, 150, 0.05)
    end  
    assert_in_delta(300, detectors.size, 0)
    correct = -1
    silence_stream(STDOUT) do
      correct = apply_detectors(detectors, search_space, self_space, 0.05)
    end
    assert_in_delta(50, correct, 5)
  end
  
end
