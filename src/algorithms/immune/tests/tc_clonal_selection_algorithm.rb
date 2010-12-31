# Unit tests for clonal_selection_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../clonal_selection_algorithm"

class TC_ClonalSelectionAlgorithm < Test::Unit::TestCase 

  # test the objective function
  def test_objective_function
    # integer
    assert_equal(99**2, objective_function([99]))
    # float
    assert_equal(0.1**2.0, objective_function([0.1]))
    # vector
    assert_equal(1**2+2**2+3**2, objective_function([1,2,3]))
    # optima
    assert_equal(0, objective_function([0,0]))
  end
  
  # test decoding bits into floats
  def test_decode
    # zero
    v = decode("0000000000000000", [[0,1]], 16)
    assert_equal(1, v.size)
    assert_equal(0.0, v[0])
    # one
    v = decode("1111111111111111", [[0,1]], 16)
    assert_equal(1, v.size)
    assert_equal(1.0, v[0])
    # float #1
    v = decode("0000000000000001", [[0,1]], 16)
    assert_equal(1, v.size)
    a = 1.0 / ((2**16)-1)
    assert_equal(a*(2**0), v[0])
    # float #2
    v = decode("0000000000000010", [[0,1]], 16)
    assert_equal(1, v.size)
    assert_equal(a*(2**1), v[0])
    # float #3
    v = decode("0000000000000100", [[0,1]], 16)
    assert_equal(1, v.size)
    assert_equal(a*(2**2), v[0])
    # multiple floats
    v = decode("00000000000000001111111111111111", [[0,1],[0,1]], 16)
    assert_equal(2, v.size)
    assert_equal(0.0, v[0])
    assert_equal(1.0, v[1])
  end
  
  def test_evaluate
    
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
  
  # test point mutations at the limits
  def test_point_mutation
    assert_equal("0000000000", point_mutation("0000000000", 0))
    assert_equal("1111111111", point_mutation("1111111111", 0))
    assert_equal("1111111111", point_mutation("0000000000", 1))
    assert_equal("0000000000", point_mutation("1111111111", 1))
  end

  # test that the observed changes approximate the intended probability
  def test_point_mutation_ratio
    changes = 0
    100.times do
      s = point_mutation("0000000000", 0.5)
      changes += (10 - s.delete('1').size)
    end
    assert_in_delta(0.5, changes.to_f/(100*10), 0.05)
  end  
  
  def test_affinity_proportionate_mutation
    
  end
  
  def test_num_clones
    
  end
  
  def test_calculate_affinity
    
  end
  
  def test_clone_and_hypermutate
    
  end
  
  def test_random_insertion
    
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
  # def test_search    
  #   best = nil
  #   silence_stream(STDOUT) do
  #     best = search([[-5,5],[-5,5]], 100, 100, 0.1, 2.5, 1)
  #   end  
  #   assert_not_nil(best[:cost])
  #   assert_in_delta(0.0, best[:cost], 0.5)
  # end
  
end
