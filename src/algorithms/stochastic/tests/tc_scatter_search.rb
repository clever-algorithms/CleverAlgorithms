# Unit tests for scatter_search.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../scatter_search"

class TC_ScatterSearch < Test::Unit::TestCase

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

  # test the uniform sampling within bounds
  def test_rand_in_bounds
    # positive, zero offset
    x = rand_in_bounds(0, 20)
    assert_operator(x, :>=, 0)
    assert_operator(x, :<, 20)
    # negative
    x = rand_in_bounds(-20, -1)
    assert_operator(x, :>=, -20)
    assert_operator(x, :<, -1)
    # both
    x = rand_in_bounds(-10, 20)
    assert_operator(x, :>=, -10)
    assert_operator(x, :<, 20)
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

  # test the construction of a step
  def test_take_step
    # step within stepsize
    p = take_step([[0, 100]], [50], 3.3)
    assert_operator(p[0], :>=, 50-3.3)
    assert_operator(p[0], :<=, 50+3.3)    
    # snap to bounds
    p = take_step([[0, 1]], [0], 3.3)
    assert_operator(p[0], :>=, 0)
    assert_operator(p[0], :<, 1)
  end
  
  # test the local search procedure
  def test_local_search
    # improvement
    best = {:vector=>[1,1]}
    best[:cost] = objective_function(best[:vector])
    rs = local_search(best, [[-1,1],[-1,1]], 30, 0.005)
    assert_not_nil(rs)
    assert_not_nil(rs[:vector])
    assert_not_nil(rs[:cost])
    assert_not_same(best, rs)
    assert_not_equal(best[:vector], rs[:vector])
    assert_not_equal(best[:cost], rs[:cost])
    # no improvement
    best = {:vector=>[0,0], :cost=>0.0}
    rs = local_search(best, [[-1,1],[-1,1]], 30, 0.005)
    assert_not_nil(rs)
    assert_equal(best[:cost], rs[:cost])
  end
  
  # test the construction of the initial set
  def test_construct_initial_set
    set = construct_initial_set([[-1,1],[-1,1]], 10, 20, 0.005)
    assert_equal(10, set.size)
    set.each do |s|
      assert_not_nil(s[:vector])
      assert_not_nil(s[:cost])
      assert_equal(2, s[:vector].size)
    end
  end
  
  # test euclidean distance
  def test_euclidean_distance
    assert_equal(0, euclidean_distance([0,0],[0,0]))
    assert_equal(0, euclidean_distance([1,5],[1,5]))
    assert_in_delta(1.4, euclidean_distance([1,1],[2,2]),0.1)    
  end
  
  # test the distance of a vector against a ref set
  def test_distance
    # no distance
    set = [{:vector=>Array.new(10, 0)}, {:vector=>Array.new(10, 0)}]
    assert_equal(0, distance(Array.new(10, 0), set))
    # large distance
    set = [{:vector=>Array.new(2){-1}}, {:vector=>Array.new(2){1}}]
    assert_in_delta(1.4*2, distance(Array.new(2, 0), set), 0.1)
  end
  
  # test diversification
  def test_diversify
    set = [{:vector=>[0,0], :cost=>0}, {:vector=>[2,2], :cost=>1}, {:vector=>[100,100], :cost=>10}]
    rs = diversify(set, 1, 2)
    assert_equal(2, rs.size)
    assert_equal(2, rs[0].size)
    # select by cost
    assert_same(set.first, rs[0].first)
    # select by diversity
    assert_same(set[2], rs[0][1])
    assert_same(set.first, rs[1])    
  end

  # test the selection of subsets
  def test_select_subsets
    # with additions
    set = [{:new=>false,:vector=>[1]}, {:new=>true,:vector=>[2]}, {:new=>false,:vector=>[3]}]
    rs = select_subsets(set)
    assert_equal(2, rs.size)
    # all additions 
    set = [{:new=>true,:vector=>[1]}, {:new=>true,:vector=>[2]}, {:new=>true,:vector=>[3]}]
    rs = select_subsets(set)
    assert_equal(3, rs.size)
    # no additions
    set = [{:new=>false,:vector=>[1]}, {:new=>false,:vector=>[2]}, {:new=>false,:vector=>[3]}]
    rs = select_subsets(set)
    assert_equal(0, rs.size)
  end
  
  # test recombination
  def test_recombine
    children = recombine([{:vector=>[1,1]}, {:vector=>[10,10]}], [[0,10],[0,10]])
    assert_equal(2, children.size)
    children.each do |c|
      assert_not_nil(c[:vector])
      assert_not_nil(c[:cost])
      assert_equal(2, c[:vector].size)
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

  # test the exploration of subsets
  def test_explore_subsets
    # change
    pop = [{:vector=>[-1],:new=>true},{:vector=>[1],:new=>true}]
    pop.each {|p| p[:cost]=objective_function(p[:vector]) }
    c = nil
    silence_stream(STDOUT) {c = explore_subsets([[-1,1]], pop, 30, 0.005)}
    assert_not_nil(c)
    assert_equal(true, c)
    # no change
    pop = [{:vector=>[0],:cost=>0,:new=>true},{:vector=>[0],:cost=>0,:new=>true},{:vector=>[0],:cost=>0,:new=>true}]
    silence_stream(STDOUT) {c = explore_subsets([[-1,1]], pop, 30, 0.005)}
    assert_not_nil(c)
    assert_equal(false, c)
  end 
  
  # test that the algorithm can solve the problem
  def test_search    
    best = nil
    silence_stream(STDOUT) do
      best = search([[-5,5],[-5,5]], 100, 10, 20, 30, 0.05, 5)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.0001)
  end
  
end
