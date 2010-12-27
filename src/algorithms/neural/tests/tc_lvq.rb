# Unit tests for lvq.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../lvq"

class TC_LVQ < Test::Unit::TestCase 
  
  # TODO write tests
  
  
  # helper for turning off STDOUT
  # File activesupport/lib/active_support/core_ext/kernel/reporting.rb
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
    # domain
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    # compute
    codebooks = nil
    silence_stream(STDOUT) do
      codebooks = execute(domain, 1000, 10, 0.3)
    end
    # structure
    assert_equal(10, codebooks.size)
    # performance
    assert_in_delta(100, test_network(codebooks, domain, 100), 10)
  end
  
end
