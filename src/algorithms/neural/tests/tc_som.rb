# Unit tests for som.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../som"

class TC_SOM < Test::Unit::TestCase 
  
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
    rs = nil
    silence_stream(STDOUT) do
      rs = test_network(codebooks, shape)
    end
    assert_in_delta(0.0, rs, 0.1)
  end
  
end
