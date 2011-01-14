# Unit tests for memetic_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../memetic_algorithm"

class TC_MemeticAlgorithm < Test::Unit::TestCase

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
  
  # test fitness assignment
  def test_fitness
    c = {:bitstring=>"0000000000000000"}
    fitness(c, [[0,1]], 16)
    assert_not_nil(c[:vector])
    assert_not_nil(c[:fitness])
    assert_equal(0, c[:vector][0])
    assert_equal(0, c[:fitness])
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
  
  # test uniform crossover
  def test_crossover
    p1 = "0000000000"
    p2 = "1111111111"        
    assert_equal(p1, crossover(p1,p2,0))
    assert_not_same(p1, crossover(p1,p2,0))      
    s = crossover(p1,p2,1)        
    s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
  end
  
  # test reproduce cloning case
  def test_reproduce_clone
    pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = reproduce(pop, pop.size, 0, 0)
    children.each_with_index do |c,i| 
      assert_equal(pop[i][:bitstring], c[:bitstring])
      assert_not_same(pop[i][:bitstring], c[:bitstring])  
    end
  end

  # test reproduce mutate case
  def test_reproduce_clone
    pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = reproduce(pop, pop.size, 0, 1)
    children.each_with_index do |c,i| 
      assert_not_equal(pop[i][:bitstring], c[:bitstring])
      assert_equal("1111111111", c[:bitstring])
      assert_not_same(pop[i][:bitstring], c[:bitstring])  
    end
  end
  
  # test odd sized population
  def test_reproduce_mismatch
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
  
  # test the bit climber
  def test_bitclimber
    # improvement
    c = {:bitstring=>"1010101010101010"}
    fitness(c, [[0,1]], 16)
    assert_in_delta(0.444, c[:fitness], 0.001)
    rs = bitclimber(c, [[0,1]], 1.0/16.0, 50, 16)
    assert_not_equal(rs, c)
    assert_operator(rs[:fitness], :<, c[:fitness])
    # no improvement
    c = {:bitstring=>"0000000000000000"}
    fitness(c, [[0,1]], 16)
    assert_equal(0, c[:fitness])
    rs = bitclimber(c, [[0,1]], 1.0/16.0, 50, 16)
    assert_equal(rs, c)
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
    best = nil
    silence_stream(STDOUT) do
      best = search(100, [[-5,5],[-5,5]], 50, 0.95, 0.05, 20, 0.5)
    end
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 0.0001)
  end
  
end
