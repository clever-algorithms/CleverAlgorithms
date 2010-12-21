# Unit tests for extremal_optimization.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
#require Pathname.new(File.dirname(__FILE__)) + "../extremal_optimization"
require "../extremal_optimization"

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
  
  # test the creation of a nn solution
  def test_nearest_neighbor_solution
    cities = [[-2,-2], [1,1], [2,2], [4,4], [66,66]]
    perm = nearest_neighbor_solution(cities)
    assert_equal(5, perm.size)
    # TODO test that most edges are nearest neighbors
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
    components = [{}, {}, {}, {}, {}]
    sum = calculate_component_probabilities(components, 1.0)
    selection = make_selection(components, sum_probability)
  end

  def test_probabilistic_selection
    # TODO
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
  def test_create_new_permutation
    cities = [[-2,-2], [1,1], [2,2], [4,4], [66,66]]
    perm = create_new_permutation(cities, 1.3, [0, 1, 2, 3, 4])
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
    nn_solution = {:vector=>nearest_neighbor_solution(berlin52)}
    nn_solution[:cost] = cost(nn_solution[:vector], berlin52)
    best = nil
    silence_stream(STDOUT) do
      #best = search(berlin52, 100, 1.3)
    end    
    #assert(best[:cost] < nn_solution[:cost])
  end

end
