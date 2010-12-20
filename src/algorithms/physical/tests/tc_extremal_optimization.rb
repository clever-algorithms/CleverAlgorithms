# Unit tests for extremal_optimization.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
#require Pathname.new(File.dirname(__FILE__)) + "../extremal_optimization"
require "../extremal_optimization"

class TC_ExtremalOptimization < Test::Unit::TestCase

  # test getting the edges for a city
  def test_get_edges_for_city
    assert_equal([2,4], get_edges_for_city(3, [1,2,3,4,5]))
    assert_equal([5,2], get_edges_for_city(1, [1,2,3,4,5]))
    assert_equal([4,1], get_edges_for_city(5, [1,2,3,4,5]))
  end

  # test the neighbour city rank
  def test_calculate_neighbour_rank
    
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
  
  # test calculte city fitnesses
  def test_calculate_city_fitnesses
    cities = [[50,50], [2,2], [30,30], [1.5,1.5], [3, 3]]
    perm = [0,1,2,3,4]
    fitnesses = calculate_city_fitnesses(cities, perm)
    assert_equal(perm.size, fitnesses.size)
    puts fitnesses.inspect
    assert_equal(0, fitnesses[0][:number]) 
    assert_equal(3, fitnesses[1][:number]) # 3/(3+2) => 0.6
    assert_equal(4, fitnesses[2][:number])
    assert_equal(1, fitnesses[3][:number])
    assert_equal(2, fitnesses[4][:number])
  end

  # test the updating of a permutation
  def test_update_permutation
    # connect cities 2, 4 together
    assert_equal([1,2,4,3,5], update_permutation([1,2,3,4,5], 2, 4))
    assert_equal([1,2,4,3,5], update_permutation([1,2,3,4,5], 4, 2))    
  end

end
