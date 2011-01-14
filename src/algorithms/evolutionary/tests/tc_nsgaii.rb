# Unit tests for nsga_ii.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../nsgaii"

class TC_NSGAII < Test::Unit::TestCase 
  
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
    assert_equal(false, dominates({:objectives=>[1,1]}, {:objectives=>[0,0]}))
    # equal
    assert_equal(true, dominates({:objectives=>[0,0]}, {:objectives=>[0,0]}))
    # bigger
    assert_equal(true, dominates({:objectives=>[0,0]}, {:objectives=>[1,1]}))
    # partial
    assert_equal(false, dominates({:objectives=>[0,1]}, {:objectives=>[1,0]}))
  end
  
  # test fast non-dominated sort
  def test_fast_nondominated_sort
    # one front
    pop = [{:objectives=>[1,1]}]
    rs = fast_nondominated_sort(pop)
    assert_equal(1, rs.size)
    # two fronts
    pop = [{:objectives=>[1,1]}, {:objectives=>[0,0]}]
    rs = fast_nondominated_sort(pop)
    assert_equal(2, rs.size)
    assert_equal(pop[1], rs[0][0])
    assert_equal(pop[0], rs[1][0])
    # two members of first front
    pop = [{:objectives=>[1,1]}, {:objectives=>[1,1]}]
    rs = fast_nondominated_sort(pop)
    assert_equal(1, rs.size)
    assert_equal(pop, rs.first)
    # TODO consider more complex examples
  end
  
  # test calculating the crowding distance
  def test_calculate_crowding_distance
    # no range
    pop = [{:objectives=>[1.0,1.0]}, {:objectives=>[1.0,1.0]}, {:objectives=>[1.0,1.0]}]
    calculate_crowding_distance(pop)
    assert_equal(1.0/0.0, pop[0][:dist])
    assert_equal(0.0, pop[1][:dist])
    assert_equal(1.0/0.0, pop[2][:dist])    
    # some range
    pop = [{:objectives=>[3.0,3.0]}, {:objectives=>[10.0,10.0]}, {:objectives=>[6.0,6.0]}]
    calculate_crowding_distance(pop)
    assert_equal(1.0/0.0, pop[0][:dist])
    assert_equal(((6.0-3.0)/7.0)*2.0, pop[1][:dist])
    assert_equal(1.0/0.0, pop[2][:dist])
  end
  
  # test crowded comparison
  def test_crowded_comparison_operator
    # same rank (prefer larger distance)
    assert_equal(1, crowded_comparison_operator({:dist=>1, :rank=>0}, {:dist=>2, :rank=>0}))
    assert_equal(-1, crowded_comparison_operator({:dist=>2, :rank=>0}, {:dist=>1, :rank=>0}))
    assert_equal(0, crowded_comparison_operator({:dist=>2, :rank=>0}, {:dist=>2, :rank=>0}))
    # different rank, perfer smaller rank
    assert_equal(-1, crowded_comparison_operator({:dist=>1, :rank=>0}, {:dist=>2, :rank=>1}))
    assert_equal(1, crowded_comparison_operator({:dist=>2, :rank=>1}, {:dist=>2, :rank=>0}))
  end
  
  # test better function
  def test_better
    # no distance (min rank)
    a, b = {:rank=>0}, {:rank=>0}
    assert_equal(b, better(a,b))
    a, b = {:rank=>0}, {:rank=>1}
    assert_equal(a, better(a,b))
    # distance and same rank (max dist)
    a, b = {:dist=>2, :rank=>0}, {:dist=>1, :rank=>0}
    assert_equal(a, better(a,b))
    a, b = {:dist=>1, :rank=>0}, {:dist=>2, :rank=>0}
    assert_equal(b, better(a,b))
    # distance and diff rank (min rank)
    a, b = {:dist=>2, :rank=>2}, {:dist=>1, :rank=>1}
    assert_equal(b, better(a,b)) 
    a, b = {:dist=>1, :rank=>1}, {:dist=>2, :rank=>2}
    assert_equal(a, better(a,b))
  end
  
  # test selecting parents
  def test_select_parents
    # exact fit
    fronts = [[{:dist=>0, :rank=>0, :objectives=>[0.0,0.0]}], [{:dist=>1, :rank=>1, :objectives=>[1.0,1.0]}]]
    rs = select_parents(fronts, 2)
    assert_equal(2, rs.size)
    assert_equal(fronts[0][0], rs[0])
    assert_equal(fronts[1][0], rs[1])
    # overlap
    fronts = [[{:dist=>0, :rank=>0, :objectives=>[0.0,0.0]}], 
      [{:dist=>0, :rank=>1, :objectives=>[1.0,1.0]}, {:dist=>1, :rank=>1, :objectives=>[1.0,1.0]}]]
    rs = select_parents(fronts, 2)
    assert_equal(2, rs.size)
    assert_equal({:dist=>1.0/0.0, :rank=>0, :objectives=>[0.0,0.0]}, rs[0])
    assert_equal({:dist=>1.0/0.0, :rank=>1, :objectives=>[1.0,1.0]}, rs[1])
  end
  
  # test the calculation of weighted sum
  def test_weighted_sum
    assert_equal(2, weighted_sum({:objectives=>[1,1]}))
    assert_equal(1, weighted_sum({:objectives=>[0,1]}))
    assert_equal(1, weighted_sum({:objectives=>[1,0]}))
    assert_equal(0, weighted_sum({:objectives=>[0,0]}))
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
    pop_size = 50
    pop = nil
    silence_stream(STDOUT) do
      pop = search([[-10, 10]], 100, pop_size, 0.95)
    end    
    assert_equal(pop_size, pop.size)
    pop.each do |p|
      # in [0,2]
      assert_in_delta(1.0, p[:vector][0], 1.2)
      assert_not_nil(p[:objectives])
      assert_equal(2, p[:objectives].size)
    end    
  end
  
end
