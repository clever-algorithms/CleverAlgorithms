# Unit tests for differential_evolution.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../differential_evolution"

class TC_DifferentialEvolution < Test::Unit::TestCase

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
  
  # test the de procedure
  def test_de_rand_1_bin
    # no crossover
    rs = de_rand_1_bin({:vector=>[0,0]}, {:vector=>[0.1,0.1]}, {:vector=>[0.2,0.2]}, {:vector=>[0.3,0.3]}, 0, 0, [[0,1], [0,1]])
    assert_not_nil(rs[:vector])
    assert_equal(2, rs[:vector].size)
    rs[:vector].each do |v| 
      assert_operator(v, :>=, 0)
      assert_operator(v, :<, 1)
    end
    # all crossover
    100.times do
      p0, p1, p2, p3 = {:vector=>[0,0]}, {:vector=>[0.5,0.5]}, {:vector=>[0.2,0.2]}, {:vector=>[1,1]}
      rs = de_rand_1_bin(p0, p1, p2, p3, 0.5, 1.0, [[0,1], [0,1]])
      assert_not_nil(rs[:vector])
      assert_equal(2, rs[:vector].size)
      rs[:vector].each do |v| 
        assert_operator(v, :>=, 0)
        assert_operator(v, :<=, 1)
      end
    end
  end
  
  # test the selection of parents
  def test_select_parents
    100.times do
      pop = [{:a=>"a"}, {:b=>"b"}, {:c=>"c"}, {:d=>"d"}, {:e=>"e"} ,{:f=>"f"} ,{:g=>"g"}, {:h=>"h"}]
      current = rand(pop.size)
      rs = select_parents(pop, current)
      rs.each do |x|
        assert_not_nil(x)
        assert_not_equal(x, current)
        assert_operator(x, :>=, 0)
        assert_operator(x, :<, pop.size)
        assert_equal(1, rs.select{|v| v==x}.size )
      end
    end
  end
  
  # test creation of children
  def test_create_children
    pop = [{:vector=>[0,0]}, {:vector=>[0.5,0.5]}, {:vector=>[0.2,0.2]}, {:vector=>[1,1]}]
    children = create_children(pop, [[0,1], [0,1]], 0.5, 0.5)
    assert_equal(4, children.size)
    children.each_with_index do |child,i|
      assert_not_same(child, pop[i])
      assert_equal(2, child[:vector].size)
      child[:vector].each do |v| 
        assert_operator(v, :>=, 0)
        assert_operator(v, :<=, 1)
      end
    end
  end
  
  # test the selection of population
  def test_select_population
    # all parents
    parents = [{:cost=>0.1}, {:cost=>0.2}, {:cost=>0.3}]
    children = [{:cost=>1}, {:cost=>2}, {:cost=>3}]
    selected = select_population(parents, children)
    selected.each_with_index do |s,i|
      assert_equal(s, parents[i])
    end
    # all children
    parents = [{:cost=>1}, {:cost=>2}, {:cost=>3}]
    children = [{:cost=>0.1}, {:cost=>0.2}, {:cost=>0.3}]
    selected = select_population(parents, children)
    selected.each_with_index do |s,i|
      assert_equal(s, children[i])
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
      best = search(100, [[-5,5],[-5,5]], 50, 0.8, 0.9)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.001)
  end
  
end
