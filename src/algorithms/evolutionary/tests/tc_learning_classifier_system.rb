# Unit tests for learning_classifier_system.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../learning_classifier_system"

class TC_LearningClassifierSystem < Test::Unit::TestCase 

  # test bit negation
  def test_neg
    assert_equal(1, neg(0))
    assert_equal(0, neg(1))
  end
  
  # test the target function
  def test_target_function
    # a few class 0
    assert_equal(0, target_function("000000"))
    assert_equal(0, target_function("011011"))
    # a few class 1
    assert_equal(1, target_function("011111"))
    assert_equal(1, target_function("100010"))
    assert_equal(1, target_function("110001"))
  end

  def test_new_classifier
    
  end
  
  def test_copy_classifier
    
  end

  # test the creation of random strings
  def test_random_bitstring
    assert_equal(10, random_bitstring(10).size)
    assert_equal(0, random_bitstring(10).delete('0').delete('1').size)
  end

  # test the approximate proportion of 1's and 0's
  def test_random_bitstring_ratio
    s = random_bitstring(1000)
    assert_in_delta(0.5, (s.delete('1').size/1000.0), 0.05)
    assert_in_delta(0.5, (s.delete('0').size/1000.0), 0.05)
  end
  
  def test_calculate_deletion_vote
    
  end
  
  def test_delete_from_pop
    
  end
  
  def test_generate_random_classifier
    
  end
  
  def test_does_match
    
  end
  
  def test_get_actions
    
  end
  
  def test_generate_match_set
    
  end
  
  def test_generate_prediction
    
  end
  
  def test_select_action
    
  end
  
  def test_update_set
    
  end
  
  def test_update_fitness
    
  end
  
  def test_can_run_genetic_algorithm
        
  end
  
  def test_select_parent
    
  end
  
  def test_mutation
    
  end
  
  # test uniform crossover
  def test_uniform_crossover
    p1 = "0000000000"
    p2 = "1111111111"        
    assert_equal(p1, uniform_crossover(p1,p2,0))
    assert_not_same(p1, uniform_crossover(p1,p2,0))      
    s = uniform_crossover(p1,p2,1)        
    s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
  end  

  def test_insert_in_pop
    
  end
  
  def test_crossover
    
  end
  
  def test_run_genetic_algorithm
    
  end
  
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
  def test_execute
    # execute
    pop = nil
    silence_stream(STDOUT) do
      pop = execute(150, 2000, ['0','1'], 0.1, 0.2, 0.01, 50, 20)
    end    
    # check system
    assert_in_delta(70, pop.size, 30)
    # check capability
    correct = nil
    silence_stream(STDOUT) do
      correct = test_model(pop)
    end
    assert_not_nil(correct)
    assert_in_delta(100, correct, 10)
  end
  
end
