# Unit tests for iterated_local_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../iterated_local_search"

class TC_IteratedLocalSearch < Test::Unit::TestCase

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
      other = stochastic_two_opt(perm)
      assert_equal(perm.size, other.size)
      assert_not_equal(perm, other)
      assert_not_same(perm, other)
      other.each {|x| assert(perm.include?(x), "#{x}") }
    end
  end

  # test the local search procedure
  def test_local_search
    # improvement
    best = {:vector=>[0,1,2,3,4]}
    cities = [[0,0],[3,3],[1,1],[2,2],[4,4]]
    best[:cost] = cost(best[:vector], cities)
    rs = local_search(best, cities, 20)
    assert_not_nil(rs)
    assert_not_nil(rs[:vector])
    assert_not_nil(rs[:cost])
    assert_not_same(best, rs)
    assert_not_equal(best[:vector], rs[:vector])
    assert_not_equal(best[:cost], rs[:cost])
    # no improvement
    best = {:vector=>[0,2,3,1,4]}
    best[:cost] = cost(best[:vector], cities)
    rs = local_search(best, cities, 10)
    assert_not_nil(rs)
    assert_equal(best[:cost], rs[:cost])
  end
  
  # test a double bridge move
  def test_double_bridge_move
    perm = Array.new(100){|i| i}
    100.times do
      rs = double_bridge_move(perm)
      assert_equal(perm.size, rs.size)
      perm.each{|x| assert(rs.include?(x)) }
    end
    # TODO test the offsets used internally
  end
  
  # test perturbation
  def test_perturbation
    cities = Array.new(100){[rand(), rand()]}
    best = {:vector=>Array.new(100){|i| i}}
    rs = perturbation(cities, best)
    assert_not_nil(rs)
    assert_not_nil(rs[:vector])
    assert_not_nil(rs[:cost])
    assert_equal(100, rs[:vector].length)
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
      best = search(berlin52, 100, 50)
    end  
    # better than a NN solution's cost
    assert_not_nil(best[:cost])
    assert_in_delta(7542, best[:cost], 3000)
  end
  
end
