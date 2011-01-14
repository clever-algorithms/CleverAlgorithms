# Unit tests for bfoa.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../bfoa"

class TC_BFOA < Test::Unit::TestCase

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

  # test generating a random direction
  def test_generate_random_direction
    rs = generate_random_direction(1000)
    assert_equal(1000, rs.size)
    rs.each do |x| 
      assert_operator(x, :>=, -1)
      assert_operator(x, :<=, 1)
    end
  end
  
  # test cell interactions
  def test_compute_cell_interaction
    # same
    rs = compute_cell_interaction({:vector=>[0,0]}, [{:vector=>[0,0]}], 1.0, 1.0)
    assert_equal(1.0, rs)
    # different
    rs = compute_cell_interaction({:vector=>[0,0]}, [{:vector=>[1,1]}], 1.0, 1.0)
    assert_in_delta(7.3, rs, 0.1)
  end
  
  # calculate combined forces
  def test_attract_repel
    # same
    rs = attract_repel({:vector=>[0,0]}, [{:vector=>[0,0]}], 1.0, 1.0, 1.0, 1.0)
    assert_equal(0.0, rs)
    # different
    rs = attract_repel({:vector=>[0,0]}, [{:vector=>[1,1]}], 1.0, 1.0, 1.0, 1.0)
    assert_equal(0.0, rs)
    # TODO test different attract repel scenarios
  end
  
  # test candidate evaluation
  def test_evaluate
    cell = {:vector=>[0,0]}
    evaluate(cell, [{:vector=>[0,0]},{:vector=>[1,1]}], 1.0, 1.0, 1.0, 1.0)
    assert_not_nil(cell[:cost])
    assert_not_nil(cell[:inter])
    assert_not_nil(cell[:fitness])
    assert_equal(cell[:cost]+cell[:inter], cell[:fitness])
  end
  
  # test cell tumble
  def test_tumble_cell
    # in bounds
    cell = tumble_cell([[0,1],[0,1]], {:vector=>[0.5,0.5]}, 0.1)
    assert_equal(2, cell[:vector].size)
    cell[:vector].each_index do |i|
      assert_operator(cell[:vector][i], :>=, 0)
      assert_operator(cell[:vector][i], :<=, 1)
    end
    # really large step size
    cell = tumble_cell([[0,1],[0,1]], {:vector=>[0.5,0.5]}, 100.0)
    assert_equal(2, cell[:vector].size)
    cell[:vector].each_index do |i|
      assert_operator(cell[:vector][i], :>=, 0)
      assert_operator(cell[:vector][i], :<=, 1)
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

  # test chemotaxis
  def test_chemotaxis
    rs = nil    
    silence_stream(STDOUT) do
      rs = chemotaxis([{:vector=>[0.5,0.5]},{:vector=>[1,1]}], [[0,1],[0,1]], 5, 10, 0.005,1.0, 1.0, 1.0, 1.0) 
    end  
    assert_not_nil(rs)
    assert_equal(2, rs.size)
    # best
    assert_not_nil(rs[0][:cost])
    # pop
    assert_equal(2, rs[1].size)    
  end
  
  # test that the algorithm can solve the problem
  def test_search    
    best = nil
    silence_stream(STDOUT) do
      best = search([[-5,5],[-5,5]], 20, 1, 4, 30, 4, 0.1, 0.1, 0.2, 0.1, 10, 0.25)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.01)
  end
  
end
