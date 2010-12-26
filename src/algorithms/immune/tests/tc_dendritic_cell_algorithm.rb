# Unit tests for dendritic_cell_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../dendritic_cell_algorithm"

class TC_DendriticCellAlgorithm < Test::Unit::TestCase 
  
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
    domain = {}
    domain["Normal"] = Array.new(50){|i| i}
    domain["Anomaly"] = Array.new(5){|i| (i+1)*10}
    domain["Normal"] = domain["Normal"] - domain["Anomaly"]
    cells = nil
    silence_stream(STDOUT) do
      cells = execute(domain, 100, 50, 0.7, 0.95, [5,15], 10)  
    end  
    # assert_in_delta(50, cells.size, 50)
    correct = nil
    silence_stream(STDOUT) do
      correct = test_system(cells, domain, 0.7, 0.95, 10)
    end
    assert_equal(2, correct.size)    
    assert_in_delta(100, correct[0], 10)
    assert_in_delta(100, correct[1], 10)
  end
  
end
