# Unit tests for som.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../som"

class TC_SOM < Test::Unit::TestCase 
  
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
    # problem
    domain = [[0.0,1.0],[0.0,1.0]]
    shape = [[0.3,0.6],[0.3,0.6]]
    # compute
    codebooks = nil
    silence_stream(STDOUT) do
      codebooks = execute(domain, shape, 1000, 0.3, 5, 5, 4)
    end
    # verify structure
    assert_equal(20, codebooks.size)
    # test result
    assert_in_delta(0.0, test_network(codebooks, shape), 0.1)
  end
  
end
