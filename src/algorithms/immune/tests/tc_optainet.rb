# Unit tests for optainet.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../optainet"

class TC_Optainet < Test::Unit::TestCase 

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
      assert_in_delta(bounds[0]+((bounds[1]-bounds[0])/2.0), sum/trials.to_f, 0.2)
    end    
  end
  
  # test default rand gaussian
  def test_random_gaussian_default
    mean, stdev = 0.0, 1.0
    all = []
    1000.times do
      all << random_gaussian(mean, stdev)
      assert_in_delta(mean, all.last, 6*stdev)
    end
    m = all.inject(0){|sum,x| sum + x} / all.size.to_f
    assert_in_delta(mean, m, 0.1)
  end
  
  # test rand gaussian in different range
  def test_random_gaussian_non_default
    mean, stdev = 50, 10
    all = []
    1000.times do
      all << random_gaussian(mean, stdev)
      assert_in_delta(mean, all.last, 6*stdev)
    end
    m = all.inject(0){|sum,x| sum + x} / all.size.to_f
    assert_in_delta(m, mean, 1.0)
  end
  
  # test vector cloning
  def test_clone
    v = {:vector=>Array.new(1000){|i| i}}
    c = clone(v)
    assert_equal(v[:vector].size, c[:vector].size)
    assert_not_same(v,c)
    assert_not_same(v[:vector],c[:vector])
    c[:vector].each_index {|i| assert_equal(v[:vector][i], c[:vector][i]) }
  end
  
  # test affinity proprtionate mutation rate
  def test_mutation_rate
    # larger the normalized cost, the smaller the mutation rate
    # easy decay factor
    assert_equal(1, mutation_rate(1, 0))
    assert_in_delta(0.6, mutation_rate(1, 0.5), 0.1)
    assert_in_delta(0.3, mutation_rate(1, 1), 0.1)
    # recommended decay factor
    assert_equal(0.01, mutation_rate(100, 0))
    assert_in_delta(0.006, mutation_rate(100, 0.5), 0.001)
    assert_in_delta(0.003, mutation_rate(100, 1), 0.001)
  end
  
  # test cell mutation
  def test_mutate
    # no mutation
    child = {:vector=>Array.new(1000){|i| i}}
    mutate(100, child, 1.0)
    child[:vector].each_index {|i| assert_in_delta(i, child[:vector][i], 0.1)}
    # full mutation
    child = {:vector=>Array.new(1000){|i| i}}
    mutate(100, child, 0.0)
    child[:vector].each_index {|i| assert_in_delta(i, child[:vector][i],0.1)}
  end
  
  # test the cloning of a cell
  def test_clone_cell
    parent = {:vector=>Array.new(1000){|i| i}, :norm_cost=>1.0}
    best = clone_cell(100, 50, parent)
    assert_not_nil(best)
    assert_not_nil(best[:vector])
    assert_not_nil(best[:cost])
    assert_equal(parent[:vector].size, best[:vector].size)
  end
  
  # test the calculation of normalized cost
  def test_calculate_normalized_cost
    # all ones - no range in cost
    pop = [{:cost=>1},{:cost=>1},{:cost=>1},{:cost=>1},{:cost=>1}]
    calculate_normalized_cost(pop)
    pop.each do |p|
      assert_not_nil(p[:norm_cost])
      assert_equal(1.0, p[:norm_cost])
    end
    pop = [{:cost=>10000},{:cost=>1000},{:cost=>100},{:cost=>10},{:cost=>1}]
    # normal
    calculate_normalized_cost(pop)
    pop.each do |p|
      assert_not_nil(p[:norm_cost])
      assert_operator(p[:norm_cost], :>=, 0.0)
      assert_operator(p[:norm_cost], :<=, 1.0)
    end
  end  
  
  # test average cost
  def test_average_cost
    # no variance
    pop = [{:cost=>1},{:cost=>1},{:cost=>1},{:cost=>1},{:cost=>1}]
    assert_equal(1, average_cost(pop))
    # large
    pop = [{:cost=>0},{:cost=>100}]
    assert_equal(50, average_cost(pop))
    # floats
    pop = [{:cost=>0.1},{:cost=>0.2}]
    assert_in_delta(0.15, average_cost(pop), 0.0000001)
  end
  
  # test euclidean distance
  def test_distance
    assert_equal(0, distance([0,0],[0,0]))
    assert_equal(0, distance([1,5],[1,5]))
    assert_in_delta(1.4, distance([1,1],[2,2]),0.1)    
  end
  
  # test getting the neighborhood of a cell
  def test_get_neighborhood
    # all
    pop = [{:vector=>[0,0,0,0]}, {:vector=>[1,1,1,1]}, {:vector=>[-1,-1,-1,-1]}]
    n = get_neighborhood({:vector=>[0,0,0,0]}, pop, 3)
    assert_equal(3, n.size)
    # none
    pop = [{:vector=>[0,0,0,0]}, {:vector=>[1,1,1,1]}, {:vector=>[-1,-1,-1,-1]}]
    n = get_neighborhood({:vector=>[6,6,6,6]}, pop, 1)
    assert_equal(0, n.size)
  end
  
  # test affinity based supression
  def test_affinity_supress
    pop = [{:vector=>[0,0,0,0],:cost=>9}, {:vector=>[1,1,1,1],:cost=>7}, {:vector=>[6,6,6,6],:cost=>8}]    
    # reduce one
    suppressed = affinity_supress(pop, 3)
    assert_equal(2, suppressed.size)
    assert_equal(pop[1], suppressed[0])
    assert_equal(pop[2], suppressed[1])
    # reduce all    
    suppressed = affinity_supress(pop, 100)
    assert_equal(1, suppressed.size)
    assert_equal(pop[1], suppressed.first)
    # reduce none
    suppressed = affinity_supress(pop, 0.1)
    assert_equal(3, suppressed.size)
    pop.each_index {|i| assert_equal(pop[i], suppressed[i])}
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
      best = search([[-5,5],[-5,5]], 150, 20, 2, 100, 1, 0.001)
    end
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.1)
  end
  
end
