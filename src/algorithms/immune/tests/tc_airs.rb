# Unit tests for airs.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../airs"

class TC_AIRS < Test::Unit::TestCase 
  
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
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    cells = nil
    silence_stream(STDOUT) do
      cells = execute(domain, 100, 10, 2.0, 0.9, 150)
    end  
    assert_in_delta(50, cells.size, 50)
    correct = -1
    silence_stream(STDOUT) do
      correct = test_system(cells, domain)
    end
    assert_in_delta(50, correct, 5)
  end
  
end
