# Unit tests for spea2.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../spea2"

class TC_SPEA2 < Test::Unit::TestCase 
  
  # test 1st objective function
  def test_objective1
    # optima
    assert_equal(0, objective1([0,0])) # 0,0
    # limits
    assert_equal(2000000, objective1([-1000,-1000]))
    assert_equal(2000000, objective1([1000,1000]))
  end
  
  # test 2nd objective function
  def test_objective2
    # optima
    assert_equal(0, objective2([2,2])) # 2,2
    # limits
    assert_equal(2000000, objective1([-1000,-1000]))
    assert_equal(2000000, objective1([1000,1000]))
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

  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}  
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
  
  # test reproduce function
  def test_reproduce
    # normal
    pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = reproduce(pop, pop.size, 1)
    assert_equal(pop.size, children.size)
    assert_not_same(pop, children)
    children.each_index {|i| assert_not_same(pop[i][:bitstring], children[i][:bitstring])}
    # odd sized pop
    pop = Array.new(9) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = reproduce(pop, pop.size, 0)
    assert_equal(pop.size, children.size)
    assert_not_same(pop, children)
    children.each_index {|i| assert_not_same(pop[i][:bitstring], children[i][:bitstring])}
    # odd sized pop, and mismatched
    pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>"0000000000"} }
    children = reproduce(pop, 9, 0)
    assert_equal(9, children.size)
    assert_not_same(pop, children)
    children.each_index {|i| assert_not_same(pop[i][:bitstring], children[i][:bitstring])}
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
  
  # test calculation of objectives
  def test_calculate_objectives  
    pop = [{:bitstring=>"11111111"},{:bitstring=>"00001111"}]  
    rs = calculate_objectives(pop, [[0,10]], 8)
    pop.each do |p|
      assert_not_nil(p[:vector])
      assert_equal(1, p[:vector].size)
      assert_not_nil(p[:objectives])
      assert_equal(2, p[:objectives].size)
    end
  end
  
  # test dominance test (smaller = better)
  # does p1 dominate p2?
  def test_dominates
    # smaller
    assert_equal(false, dominates?({:objectives=>[1,1]}, {:objectives=>[0,0]}))
    # equal
    assert_equal(true, dominates?({:objectives=>[0,0]}, {:objectives=>[0,0]}))
    # bigger
    assert_equal(true, dominates?({:objectives=>[0,0]}, {:objectives=>[1,1]}))
    # partial
    assert_equal(false, dominates?({:objectives=>[0,1]}, {:objectives=>[1,0]}))
  end
  
  # test the calculation of weighted sum
  def test_weighted_sum
    assert_equal(2, weighted_sum({:objectives=>[1,1]}))
    assert_equal(1, weighted_sum({:objectives=>[0,1]}))
    assert_equal(1, weighted_sum({:objectives=>[1,0]}))
    assert_equal(0, weighted_sum({:objectives=>[0,0]}))
  end

  # test euclidean distance
  def test_euclidean_distance
    assert_equal(0, euclidean_distance([0,0],[0,0]))
    assert_equal(0, euclidean_distance([1,5],[1,5]))
    assert_in_delta(1.4, euclidean_distance([1,1],[2,2]),0.1)    
  end  
  
  # test lists of dominated solutions
  def test_calculate_dominated
    pop = [{:objectives=>[1,1]}, {:objectives=>[0,0]}]
    calculate_dominated(pop)
    assert_equal(0, pop[0][:dom_set].size)
    assert_equal(1, pop[1][:dom_set].size)
    assert_equal(pop.first, pop[1][:dom_set].first)    
  end
  
  # test the calculation of raw fitness
  def test_calculate_raw_fitness
    # no dominated
    pop = [{:objectives=>[1,1], :dom_set=>[]}, {:objectives=>[0,0], :dom_set=>[]}]
    assert_equal(0, calculate_raw_fitness(pop[0], pop))
    # one dominated
    pop = [{:objectives=>[1,1], :dom_set=>[]}, {:objectives=>[2,2], :dom_set=>[]}, {:objectives=>[0,0], :dom_set=>[]}]
    pop[2][:dom_set] << pop[0]
    pop[2][:dom_set] << pop[1]
    pop[1][:dom_set] << pop[1]
    assert_equal(3, calculate_raw_fitness(pop[1], pop))
  end
  
  # test calculate density
  def test_calculate_density
    # same
    pop = [{:objectives=>[1,1]}, {:objectives=>[1,1]}]
    assert_equal(1.0/2.0, calculate_density(pop[0], pop))
    # different
    pop = [{:objectives=>[1,1]}, {:objectives=>[0,0]}]
    assert_in_delta(1.0/(1.0+2.0), calculate_density(pop[0], pop), 0.1)    
  end
  
  # test calculate fitness
  def test_calculate_fitness
    pop = [{:bitstring=>"11111111"}] 
    archive = [{:bitstring=>"00000000", :objectives=>[0,0]}]
    rs = calculate_fitness(pop, archive, [[0,1]], 8)
    (pop+archive).each do |p|
      assert_not_nil(p[:raw_fitness])
      assert_not_nil(p[:density])
      assert_not_nil(p[:fitness])
      assert_equal(p[:fitness], p[:raw_fitness]+p[:density])
    end
  end
  
  # test environmental selection
  def test_environmental_selection
    # do nothing
    rs = environmental_selection([{:fitness=>10}], [{:fitness=>0.5}], 1)
    assert_equal(1, rs.size)
    assert_equal({:fitness=>0.5}, rs.first)
    # env < archive
    rs = environmental_selection([{:fitness=>10}], [{:fitness=>1.1}], 1)
    assert_equal(1, rs.size)
    assert_equal({:fitness=>1.1}, rs.first)
    # env > archive
    rs = environmental_selection([{:fitness=>0.1, :objectives=>[0,0]}], [{:fitness=>0.5, :objectives=>[0,0]}], 1)
    assert_equal(1, rs.size)
    assert_equal(0.1, rs.first[:fitness])
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
    pop = nil
    silence_stream(STDOUT) do
      pop = search([[-10,10]], 50, 50, 40, 0.95)
    end    
    assert_equal(40, pop.size)
    pop.each do |p|
      # in [0,2]
      assert_in_delta(1.0, p[:vector][0], 1.0)
      assert_not_nil(p[:objectives])
      assert_equal(2, p[:objectives].size)
    end    
  end
  
end
