# Unit tests for genetic_programming.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../genetic_programming"

class TC_GeneticProgramming < Test::Unit::TestCase 
  
  # test the uniform sampling within bounds
  def test_rand_in_bounds
    # positive, zero offset
    x = rand_in_bounds(0, 20)
    assert_operator(x, :>=, 0)
    assert_operator(x, :<, 20)
    # negative
    x = rand_in_bounds(-20, -1)
    assert_operator(x, :>=, -20)
    assert_operator(x, :<, -1)
    # both
    x = rand_in_bounds(-10, 20)
    assert_operator(x, :>=, -10)
    assert_operator(x, :<, 20)
  end
  
  def test_print_program
    
  end
  
  def test_eval_program
    
  end
  
  def test_generate_random_program
    
  end
  
  def test_count_nodes
    
  end
  
  # test the objective function
  def test_target_function
    assert_equal(1.0, target_function(0.0))
    assert_equal(3.0, target_function(1.0))
    assert_equal((2**2+2+1), target_function(2.0))
  end
  
  def test_fitness
    
  end
  
  def test_tournament_selection
    
  end
  
  def test_replace_node
    
  end
  
  def test_copy_program
    
  end
  
  def test_get_node
    
  end
  
  def test_prune
    
  end
  
  def test_crossover
    
  end
  
  def test_mutation
    
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
  def test_search    
    terminals = ['X', 'R']
    functions = [:+, :-, :*, :/]  
    best = nil
    silence_stream(STDOUT) do
      best = search(50, 50, 6, 3, 0.08, 0.9, 0.02, functions, terminals)
    end  
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 0.5)
  end
  
end
