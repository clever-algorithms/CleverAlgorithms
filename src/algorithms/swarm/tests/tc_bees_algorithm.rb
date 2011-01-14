# Unit tests for bees_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 David Howden. Some Rights Reserved.
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved.
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../bees_algorithm"

class TC_BeesAlgorithm < Test::Unit::TestCase

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
  
  # test the generation of random vectors
  def test_random_vector
    bounds, trials, size = [-3,3], 300, 20
    minmax = Array.new(size) {bounds}
    trials.times do 
      vector, sum = random_vector(minmax), 0.0
      assert_equal(size, vector.size)
      vector.each do |v|
        assert_operator(v, :>=, bounds[0])
        assert_operator(v, :<, bounds[1])
        sum += v
      end
      assert_in_delta(bounds[0]+((bounds[1]-bounds[0])/2.0), sum/trials.to_f, 0.1)
    end
  end

	# test that create_random_bee returns a correctly initialised bee
	def test_create_random_bee
		problem_size = 3
		search_space = Array.new(problem_size) {|i| [-1, 3]}
		pop = Array.new(1000) {|i| create_random_bee(search_space)}
		sum = pop.inject(0){|sum, bee| sum += bee[:vector].inject(0){|sum, dimension| sum+= dimension}}
		assert_in_delta (sum / (pop.size * problem_size)), 1, 0.1
	end
	
	# test that create_neighbourhood_bee centres bee on the correct site
	def test_create_neighbourhood_bee
		problem_size = 5
		search_space = Array.new(problem_size) {|i| [-10, 10]}
		site = Array.new(problem_size){|i| i}
		pop = Array.new(10000) {|i| create_neigh_bee(site, 4.5, search_space)}
		problem_size.times{|i| assert_in_delta pop.inject(0){|sum, bee| sum += bee[:vector][i]} / pop.size, i, 0.1}
	end
	
	# test that create_neighbourhood_bee stays within patch_size and does not exceed search_space boundary
	def test_create_neighbourhood_bee_bounds
		problem_size = 5
		patch_size = 2
		search_space = Array.new(problem_size) {|i| [0, 5]}
		site = Array.new(problem_size){|i| i}
		pop = Array.new(1000) {|i| create_neigh_bee(site, patch_size, search_space)}
		pop.each do |bee| 
			bee[:vector].each_with_index do |dimension, i|
				(i-patch_size<0) ? (assert_operator dimension, :>=, 0) : (assert_operator dimension, :>=, i-patch_size)
				(i+patch_size>5) ? (assert_operator dimension, :<=, 5) : (assert_operator dimension, :<=, i+patch_size)				
			end
		end
	end
	
  # test search neighbourhood
	def test_search_neigh
    rs = search_neigh({:vector=>[0.5,0.5]}, 10, 0.005, [[0,1],[0,1]])
    assert_not_nil(rs)
    assert_not_nil(rs[:vector])
    assert_not_nil(rs[:fitness])
    assert_equal(2, rs[:vector].size)
	end

  # test create scoute bees
  def test_create_scout_bees
    rs = create_scout_bees([[0,1],[0,1]], 10)
    assert_equal(10, rs.size)
    rs.each do |x|
      x[:vector].each do |v|
        assert_operator(v, :>=, 0)
        assert_operator(v, :<=, 1)
      end
    end
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
      best = search(50, [[-5,5],[-5,5]], 50, 5, 2, 3, 7, 2)
    end  
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 0.01)
  end	
  
end
