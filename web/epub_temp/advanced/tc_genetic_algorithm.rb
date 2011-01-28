# Unit tests for genetic_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../genetic_algorithm"

class TC_GeneticAlgorithm < Test::Unit::TestCase
      
  # test that the objective function behaves as expected
  def test_onemax
    assert_equal(0, onemax("0000"))
    assert_equal(4, onemax("1111"))
    assert_equal(2, onemax("1010"))
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

  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}  
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

  # test cloning with crossover
  def test_crossover_clone
    p1, p2 = "0000000000", "1111111111"
    100.times do
      s = crossover(p1, p2, 0)
      assert_equal(p1, s)
      assert_not_same(p1, s)  
    end
  end

  # test recombination with crossover
  def test_crossover_recombine
    p1, p2 = "0000000000", "1111111111"
    100.times do
      s = crossover(p1, p2, 1)
      assert_equal(p1.size, s.size)
      assert_not_equal(p1, s)
      assert_not_equal(p2, s)
      s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
    end
  end
  
  # test odd sized population
  def test_reproduce_odd
    pop = Array.new(9) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = reproduce(pop, pop.size, 0, 1)
    assert_equal(9, children.size)
  end  

  # test reproduce size mismatch
  def test_reproduce_mismatch
    pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = reproduce(pop, 9, 0, 0)
    assert_equal(9, children.size)
  end
end
