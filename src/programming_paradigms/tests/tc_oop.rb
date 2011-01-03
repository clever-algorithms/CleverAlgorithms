# Unit tests for oop.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../oop"

class TC_GeneticAlgorithm < Test::Unit::TestCase

  # test that the objective function behaves as expected
  def test_onemax
    o = OneMax.new(4)
    assert_equal(0, o.assess({:bitstring=>"0000"}))
    assert_equal(4, o.assess({:bitstring=>"1111"}))
    assert_equal(2, o.assess({:bitstring=>"1010"}))
  end
  
  # test the is optimal function
  def test_is_optimal
    o = OneMax.new(4)
    assert_equal(true, o.is_optimal?({:fitness=>4}))
    assert_equal(false, o.is_optimal?({:fitness=>3}))
    assert_equal(false, o.is_optimal?({:fitness=>2}))
    assert_equal(false, o.is_optimal?({:fitness=>1}))
    assert_equal(false, o.is_optimal?({:fitness=>0}))
    assert_equal(false, o.is_optimal?({:fitness=>5}))
  end

  # test the creation of random strings
  def test_random_bitstring
    o = GeneticAlgorithm.new
    assert_equal(10, o.random_bitstring(10).size)
    assert_equal(0, o.random_bitstring(10).delete('0').delete('1').size)
  end

  # test the approximate proportion of 1's and 0's
  def test_random_bitstring_ratio
    o = GeneticAlgorithm.new
    s = o.random_bitstring(1000)
    assert_in_delta(0.5, (s.delete('1').size/1000.0), 0.05)
    assert_in_delta(0.5, (s.delete('0').size/1000.0), 0.05)
  end

  # test that members of the population are selected
  def test_binary_tournament
    o = GeneticAlgorithm.new(0,0,0.0) 
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(o.binary_tournament(pop)))}  
  end

  # test point mutations at the limits
  def test_point_mutation
    o = GeneticAlgorithm.new(0,0,0,0) 
    assert_equal("0000000000", o.point_mutation("0000000000"))
    assert_equal("1111111111", o.point_mutation("1111111111"))
    o = GeneticAlgorithm.new(0,0,0,1) 
    assert_equal("1111111111", o.point_mutation("0000000000"))
    assert_equal("0000000000", o.point_mutation("1111111111"))
  end

  # test that the observed changes approximate the intended probability
  def test_point_mutation_ratio
    o = GeneticAlgorithm.new(0,0,0,0.5) 
    changes = 0
    100.times do
      s = o.point_mutation("0000000000")
      changes += (10 - s.delete('1').size)
    end
    assert_in_delta(0.5, changes.to_f/(100*10), 0.05)
  end
  
  # test uniform crossover
  def test_uniform_crossover    
    p1 = "0000000000"
    p2 = "1111111111"       
    o = GeneticAlgorithm.new(0,0,0.0) 
    assert_equal(p1, o.uniform_crossover(p1,p2))
    o = GeneticAlgorithm.new(0,0,0.0) 
    assert_not_same(p1, o.uniform_crossover(p1,p2))
    o = GeneticAlgorithm.new(0,0,1.0) 
    s = o.uniform_crossover(p1,p2)        
    s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
  end
  
  # test reproduce function
  def test_reproduce
    # normal
    o = GeneticAlgorithm.new(0, 10, 0.95) 
    pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = o.reproduce(pop)
    assert_equal(pop.size, children.size)
    assert_not_same(pop, children)
    children.each_index {|i| assert_not_same(pop[i][:bitstring], children[i][:bitstring])}
    # odd sized pop
    o = GeneticAlgorithm.new(0, 9, 0.95) 
    pop = Array.new(9) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = o.reproduce(pop)
    assert_equal(pop.size, children.size)
    assert_not_same(pop, children)
    children.each_index {|i| assert_not_same(pop[i][:bitstring], children[i][:bitstring])}
    # odd sized pop, and mismatched
    o = GeneticAlgorithm.new(0, 9, 0.95) 
    pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = o.reproduce(pop)
    assert_equal(9, children.size)
    assert_not_same(pop, children)
    children.each_index {|i| assert_not_same(pop[i][:bitstring], children[i][:bitstring])}
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
    problem = OneMax.new
    strategy = GeneticAlgorithm.new    
    best = nil
    silence_stream(STDOUT) do
      best = strategy.execute(problem)  
    end  
    assert_not_nil(best[:fitness])
    assert_equal(64, best[:fitness])
  end
  
end
