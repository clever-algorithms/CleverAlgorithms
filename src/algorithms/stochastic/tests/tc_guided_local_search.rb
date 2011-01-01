# Unit tests for guided_local_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../guided_local_search"

class TC_GuidedLocalSearch < Test::Unit::TestCase

  # test the rounding in the euclidean distance
  def test_euc_2d
    assert_equal(0, euc_2d([0,0], [0,0]))
    assert_equal(0, euc_2d([1.1,1.1], [1.1,1.1]))
    assert_equal(1, euc_2d([1,1], [2,2]))
    assert_equal(3, euc_2d([-1,-1], [1,1]))
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

  # test the calculation of augmented cost
  def test_augmented_cost
    cities = [[0,0],[1,1],[2,2],[3,3],[4,4]]
    lambda = 10000.0/50.0
    # no penality
    rs = augmented_cost([0,1,2,3,4], Array.new(5){Array.new(5,0)}, cities, lambda)
    assert_equal(2, rs.size)
    assert_equal(10, rs[0])
    assert_equal(rs[0], rs[1])
    # uniform penalty
    rs = augmented_cost([0,1,2,3,4], Array.new(5){Array.new(5,0.5)}, cities, lambda)
    assert_equal(2, rs.size)
    assert_equal(10, rs[0])
    assert_equal(10 + ((0.5*lambda)*5), rs[1])
  end
  
  # test the calculation of cost and augmented cost
  def test_cost
    cities = [[0,0],[1,1],[2,2],[3,3],[4,4]]
    candidate = {:vector=>[0,1,2,3,4]}
    cost(candidate, Array.new(5){Array.new(5,0.5)}, cities, 1)
    assert_not_nil(candidate[:cost])
    assert_equal(10, candidate[:cost])
    assert_not_nil(candidate[:aug_cost])
    assert_equal(10 + ((0.5*1.0)*5), candidate[:aug_cost])
  end
  
  # test the local search procedure
  def test_local_search
    # improvement - no penalties
    best = {:vector=>[0,1,2,3,4]}
    cities = [[0,0],[3,3],[1,1],[2,2],[4,4]]
    cost(best, Array.new(5){Array.new(5,0.5)}, cities, 1)
    rs = local_search(best, cities, Array.new(5){Array.new(5,0)}, 20, 0)
    assert_not_nil(rs)
    assert_not_nil(rs[:vector])
    assert_not_nil(rs[:cost])
    assert_not_same(best, rs)
    assert_not_equal(best[:vector], rs[:vector])
    assert_not_equal(best[:cost], rs[:cost])
    # no improvement - no penalties
    best = {:vector=>[0,2,3,1,4], :cost=>10}
    rs = local_search(best, cities, Array.new(5){Array.new(5,0)}, 10, 0)
    assert_not_nil(rs)
    assert_equal(best[:cost], rs[:cost])
    # TODO test with penalties
  end
  
  # test the calculation of feature utilities
  def test_calculate_feature_utilities
    cities = [[0,0],[1,1],[2,2],[3,3],[4,4]]
    # no penalty
    utils = calculate_feature_utilities(Array.new(5){Array.new(5,0)}, cities, [0,1,2,3,4])
    assert_equal(5, utils.size)
    assert_equal(1.0/1.0, utils[0])
    assert_equal(1.0/1.0, utils[1])
    assert_equal(1.0/1.0, utils[2])
    assert_equal(1.0/1.0, utils[3])
    assert_equal(6.0/1.0, utils[4])
  end
  
  # test updating of penalties
  def test_update_penalties
    cities = [[0,0],[1,1],[2,2],[3,3],[4,4]]
    penalties = Array.new(5){Array.new(5,0)}
    update_penalties!(penalties, cities, [0,1,2,3,4], [1,1,1,1,6])
    assert_equal(1, penalties[0][4])
    assert_equal(0, penalties[4][0])
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
      best = search(100, berlin52, 20, 90)
    end  
    # better than a NN solution's cost
    assert_not_nil(best[:cost])
    assert_in_delta(7542, best[:cost], 3000)
  end
  
end
