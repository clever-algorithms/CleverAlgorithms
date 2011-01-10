# Unit tests for reactive_tabu_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../reactive_tabu_search"

class TC_ReactiveTabuSearch < Test::Unit::TestCase

  # test the rounding in the euclidean distance
  def test_euc_2d
    assert_equal(0, euc_2d([0,0], [0,0]))
    assert_equal(0, euc_2d([1.1,1.1], [1.1,1.1]))
    assert_equal(1, euc_2d([1,1], [2,2]))
    assert_equal(3, euc_2d([-1,-1], [1,1]))
  end
  
  # test tour cost includes return to origin
  def test_cost
    cities = [[0,0], [1,1], [2,2], [3,3]]
    assert_equal(1*2, cost([0,1], cities))
    assert_equal(3+4, cost([0,1,2,3], cities))
    assert_equal(4*2, cost([0, 3], cities))
  end

  # test the construction of a random permutation
  def test_random_permutation
    cities = Array.new(10)
    100.times do
      p = random_permutation(cities)
      assert_equal(cities.size, p.size)
      [0,1,2,3,4,5,6,7,8,9].each {|x| assert(p.include?(x), "#{x}") }
    end
  end

  # test the two opt procedure
  def test_stochastic_two_opt
    perm = Array.new(10){|i| i}
    200.times do
      other, edges = stochastic_two_opt(perm)
      assert_equal(perm.size, other.size)
      assert_not_equal(perm, other)
      assert_not_same(perm, other)
      other.each {|x| assert(perm.include?(x), "#{x}") }
      # TODO test the edges
      assert_equal(2, edges.size)
    end
  end

  # test whether an edge is tabu
  def test_is_tabu
    # not tabu
    assert_equal(false, is_tabu?([0,1], [{:edge=>[],:iter=>1}], 10, 1)) 
    # is tabu and period has not expired
    assert_equal(true, is_tabu?([0,1], [{:edge=>[0,1],:iter=>9}], 10, 2)) 
    # is tabu, but period has expired
    assert_equal(false, is_tabu?([0,1], [{:edge=>[0,1],:iter=>1}], 10, 1)) 
  end

  # tests making an edge tabu
  def test_make_tabu
    # not on list
    list = []
    entry = make_tabu(list, [0,1], 10)
    assert_not_nil(entry)
    assert_not_nil(entry[:edge])
    assert_not_nil(entry[:iter])
    assert_equal(10, entry[:iter])
    assert_equal(1, list.size)
    assert_equal(true, list.include?(entry))
    # already on list
    list = [{:edge=>[0,1],:iter=>1}]
    entry = make_tabu(list, [0,1], 10)
    assert_not_nil(entry)
    assert_not_nil(entry[:edge])    
    assert_not_nil(entry[:iter])
    assert_equal(10, entry[:iter])
    assert_equal(1, list.size)
    assert_equal(true, list.include?(entry))
  end
  
  # test converting a permutation to an edge list
  def test_to_edge_list
    list = to_edge_list([0,1,2,3,4])
    assert_equal(5, list.size)
    # easy edge
    assert_equal(true, list.include?([0,1]))
    # edge case
    assert_equal(true, list.include?([0,4]))
  end
  
  # test if two permutations are the same
  def test_equivalent
    # different edges
    assert_equal(false, equivalent?([[0,1],[1,2],[0,2]], [[0,1],[1,3],[0,3]]))
    # same edges different order
    assert_equal(true, equivalent?([[0,1],[1,2],[0,2]], [[1,2],[0,2],[0,1]]))
    # same edges same order
    assert_equal(true, equivalent?([[0,1],[1,2],[0,2]], [[0,1],[1,2],[0,2]]))
  end
  
  # test the generation of permutations without tabu edges
  def test_generate_candidate
    cities = [[0,0], [1,1], [2,2], [3,3], [4,4]]
    # empty list
    rs, edges = generate_candidate({:vector=>[0,1,2,3,4]}, cities)
    assert_not_nil(rs)
    assert_not_nil(rs[:vector])
    assert_not_nil(rs[:cost])
    assert_equal(5, rs[:vector].size)
    assert_equal(2, edges.size)
  end
  
  # tests the retrival of a past visited candidate
  def test_get_candidate_entry
    # not visited before
    assert_nil(get_candidate_entry([], [0,1,2,3,4]))
    # visited before
    list = [{:iter=>1,:visits=>1,:edgelist=>[[0,1],[1,2],[0,2]]}]
    e = get_candidate_entry(list, [0,1,2])
    assert_not_nil(e)
    assert_same(e, list.first)
  end
  
  # tests the storing of a visited permutation
  def test_store_permutation
    list = []
    e = store_permutation(list, [0,1,2,3,4], 99)
    assert_not_nil(e)
    assert_not_nil(e[:iter])
    assert_not_nil(e[:visits])
    assert_not_nil(e[:edgelist])
    assert_equal(99, e[:iter])
    assert_equal(1, e[:visits])
    assert_equal(true, e[:edgelist].include?([0,4]))
  end
  
  # tests the partitioning of solutions into tabu and admissible based
  # on the edges changed to create them
  def test_sort_neighborhood
    # admissible candidate
    candidates = [[{},[[0,1],[1,2]]]]
    t, a = sort_neighborhood(candidates, [], 2, 10)
    assert_equal(0, t.size)
    assert_equal(1, a.size)
    assert_same(candidates.first, a.first)
    # tabu candidate
    candidates = [[{},[[0,1],[1,2]]]]
    t, a = sort_neighborhood(candidates, [{:edge=>[0,1],:iter=>9}], 2, 10)
    assert_equal(1, t.size)
    assert_equal(0, a.size)
    assert_same(candidates.first, t.first)
    # one of each
    candidates = [ [{},[[0,1],[1,2]]], [{},[[0,2],[1,2]]] ]
    t, a = sort_neighborhood(candidates, [{:edge=>[0,1],:iter=>9}], 2, 10)
    assert_equal(1, t.size)
    assert_equal(1, a.size)
    assert_same(candidates[0], t.first)
    assert_same(candidates[1], a.first)
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
    berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],
     [880,660],[25,230],[525,1000],[580,1175],[650,1130],[1605,620],
     [1220,580],[1465,200],[1530,5],[845,680],[725,370],[145,665],
     [415,635],[510,875],[560,365],[300,465],[520,585],[480,415],
     [835,625],[975,580],[1215,245],[1320,315],[1250,400],[660,180],
     [410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
     [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],
     [95,260],[875,920],[700,500],[555,815],[830,485],[1170,65],
     [830,610],[605,625],[595,360],[1340,725],[1740,245]]
    best = nil
    silence_stream(STDOUT) do
      best = search(berlin52, 50, 200, 1.3, 0.9)
    end  
    # better than a NN solution's cost
    assert_not_nil(best[:cost])
    assert_in_delta(7542, best[:cost], 3000)
  end
  
end
