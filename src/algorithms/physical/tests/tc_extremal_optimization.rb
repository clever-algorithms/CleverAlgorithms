# Unit tests for extremal_optimization.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../extremal_optimization"

class TC_ExtremalOptimization < Test::Unit::TestCase

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

  # test the neighbor city rank - best to worst
  def test_calculate_neighbour_rank
    # normal
    cities = [[-2,-2], [1,1], [2,2], [4,4], [66,66]]
    neighbors = calculate_neighbor_rank(2, cities)
    # always in descending order (best=>worst)
    assert_equal(true, neighbors.first[:distance] <= neighbors.last[:distance])
    # specifics
    assert_equal(4, neighbors.size)
    assert_equal(1, neighbors[0][:number])
    assert_equal(3, neighbors[1][:number])
    assert_equal(0, neighbors[2][:number])
    assert_equal(4, neighbors[3][:number])
    # test ignore
    neighbors = calculate_neighbor_rank(2, cities, [0, 1])
    assert_equal(2, neighbors.size)
    assert_equal(3, neighbors[0][:number])
    assert_equal(4, neighbors[1][:number])
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

  # test getting the edges for a city
  def test_get_edges_for_city
    assert_equal([2,4], get_edges_for_city(3, [1,2,3,4,5]))
    assert_equal([5,2], get_edges_for_city(1, [1,2,3,4,5]))
    assert_equal([4,1], get_edges_for_city(5, [1,2,3,4,5]))
  end

  # test the calculation of city fitness
  def test_calculate_city_fitness
    # best
    cities = [[1,1], [2,2], [3,3], [20,20], [30, 30]] # = 1.0
    assert_equal(3.0/(1.0+2.0), calculate_city_fitness([0,1,2,3,4], 1, cities))
    # worse
    cities = [[50,50], [2,2], [30,30], [1.5,1.5], [3, 3]] # = 0.428571429
    assert_equal(3.0/(3.0+4.0), calculate_city_fitness([0,1,2,3,4], 1, cities))
  end
  
  # test calculte city fitnesses - best-worst
  def test_calculate_city_fitnesses
    cities = [[50,50], [2,2], [30,30], [1.5,1.5], [3, 3]]
    perm = [0,1,2,3,4]
    fitnesses = calculate_city_fitnesses(cities, perm)
    # always in descending order (best=>worst)
    assert_equal(true, fitnesses.first[:fitness] >= fitnesses.last[:fitness])
    # specifics
    assert_equal(perm.size, fitnesses.size)
    assert_equal(0, fitnesses[0][:number]) 
    assert_equal(3, fitnesses[1][:number]) # 3/(3+2) => 0.6
    assert_equal(4, fitnesses[2][:number])
    assert_equal(1, fitnesses[3][:number])
    assert_equal(2, fitnesses[4][:number])    
  end

  # test the calculation of probabilities based on rank
  def test_calculate_component_probabilities
    components = [{}, {}, {}, {}, {}]
    sum = calculate_component_probabilities(components, 1.0)
    assert_equal(sum, components.inject(0.0) {|s,x| s + x[:prob]})
    components.each_with_index do |x, i|
      assert_equal((i+1.0)**-1.0, x[:prob])
    end
  end
  
  def test_make_selection
    components = [{:number=>0}, {:number=>1}, {:number=>2}, {:number=>3}, {:number=>4}]
    sum = calculate_component_probabilities(components, 1.0)
    selection = make_selection(components, sum)
    assert_equal(true, [0,1,2,3,4].include?(selection))
  end

  # test probabilistic selection
  def test_probabilistic_selection
    # no exclusion
    components = [{:number=>0}, {:number=>1}, {:number=>2}, {:number=>3}, {:number=>4}]
    rs = probabilistic_selection(components, 1.3)
    assert_equal(true, [0,1,2,3,4].include?(rs))
    # exclusion
    50.times do
      exclude = [rand(5)]
      rs = probabilistic_selection(components, 1.3, exclude)
      assert_equal(true, [0,1,2,3,4].include?(rs))
      assert_equal(false, exclude.include?(rs))
    end
  end
  
  # test probabilistic selection Tau biases 
  def test_probabilistic_selection_biases
    components = [{:number=>0}, {:number=>1}, {:number=>2}, {:number=>3}, {:number=>4}]
    # test strong bias towards selecting the worst
    sum = 0    
    200.times do
      rs = probabilistic_selection(components, 1.9)
      assert_equal(true, [0,1,2,3,4].include?(rs))
      sum += rs
    end
    assert_in_delta(0, sum.to_f/200.0, 1)
    # test bias towards random
    sum = 0    
    200.times do
      rs = probabilistic_selection(components, 0.1)
      assert_equal(true, [0,1,2,3,4].include?(rs))
      sum += rs
    end
    assert_in_delta(2, sum.to_f/200.0, 1)    
  end  

  # test the creating a new permutation
  def test_vary_permutation
    # connect 1-3, breaking 1-2
    assert_equal([0,1,3,2,4], vary_permutation([0,1,2,3,4], 1, 3, 2))
    # connect 3-1, breaking 3-2
    assert_equal([0,2,1,3,4], vary_permutation([0,1,2,3,4], 3, 1, 2))
    # connect 0-2, breaking 0-4
    assert_equal([1,0,2,3,4], vary_permutation([0,1,2,3,4], 0, 2, 4))
    # connect 0-2, breaking 0-1
    assert_equal([0,2,1,3,4], vary_permutation([0,1,2,3,4], 0, 2, 1))
    # connect 4-2, breaking 4-3
    assert_equal([0,1,3,2,4], vary_permutation([0,1,2,3,4], 4, 2, 3))
    # connect 4-2, breaking 4-0
    assert_equal([0,1,2,4,3], vary_permutation([0,1,2,3,4], 4, 2, 0))
  end
  
  def test_get_long_edge
    distances = [{:number=>0, :distance=>1.0}, {:number=>1, :distance=>2.0},
      {:number=>2, :distance=>3.0}, {:number=>3, :distance=>4.0}]
    assert_equal(3, get_long_edge([0, 3], distances))
    assert_equal(2, get_long_edge([2, 1], distances))
    assert_equal(3, get_long_edge([3, 1], distances))
  end
  
  # test the creation of a valid new permitation 
  def test_create_new_perm
    cities = [[-2,-2], [1,1], [2,2], [4,4], [66,66]]
    perm = create_new_perm(cities, 1.3, [0, 1, 2, 3, 4])
    assert_equal(5, perm.size)
    assert_not_equal([0, 1, 2, 3, 4], perm)
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
  
  # test the search - must do better than a raw NN solution
  def test_search
    berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],
     [525,1000],[580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],
     [845,680],[725,370],[145,665],[415,635],[510,875],[560,365],[300,465],
     [520,585],[480,415],[835,625],[975,580],[1215,245],[1320,315],[1250,400],
     [660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
     [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],
     [875,920],[700,500],[555,815],[830,485],[1170,65],[830,610],[605,625],
     [595,360],[1340,725],[1740,245]]  
    best = nil
    silence_stream(STDOUT) do
      best = search(berlin52, 250, 1.8)
    end    
    # better than an estimated NN solution
    assert_not_nil(best[:cost])
    assert_in_delta(7542, best[:cost], 4000)
  end

end
