# Unit tests for learning_classifier_system.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../learning_classifier_system"

class TC_LearningClassifierSystem < Test::Unit::TestCase 
  
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
    # execute
    pop = nil
    silence_stream(STDOUT) do
      pop = search(6, 150, 2000, ['0','1'], 0.1, 0.2, 0.01, 50, 0.80, 0.04, 20)
    end    
    # check reuslt
    assert_in_delta(70, pop.size, 30)
    100.times do
      
    end
  end
  
end
