# Unit tests for negative_selection_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../negative_selection_algorithm"

class TC_NegativeSelectionAlgorithm < Test::Unit::TestCase 
  
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
  
  # test euclidean distance
  def test_euclidean_distance
    assert_equal(0, euclidean_distance([0,0],[0,0]))
    assert_equal(0, euclidean_distance([1,5],[1,5]))
    assert_in_delta(1.4, euclidean_distance([1,1],[2,2]),0.1)    
  end
  
  # test the contains function
  def test_contains
    # in the search space
    assert_equal(true, contains?([0], [[0,1]]))
    assert_equal(true, contains?([1], [[0,1]]))
    assert_equal(true, contains?([0.5], [[0,1]]))
    # too high
    assert_equal(false, contains?([1.1], [[0,1]]))
    # too low
    assert_equal(false, contains?([-1.0], [[0,1]]))
  end
  
  # test if a pattern matches the dataset
  def test_matches
    # exact
    assert_equal(true, matches?([0,0], [{:vector=>[0,0]}], 0))
    # in margin
    assert_equal(true, matches?([1,1], [{:vector=>[0,0]}], 2))
    # out of margin
    assert_equal(false, matches?([10,10], [{:vector=>[0,0]}], 2))
  end
  
  # test the generation of detectors
  def test_generate_detectors
    s = [{:vector=>[1,1]}, {:vector=>[5,5]}]
    20.times do
      d = generate_detectors(50, [[0,10],[0,10]], s, 1.0)
      # size
      assert_equal(50, d.size)      
      d.each do |x|
        # not match self
        assert_equal(false, matches?(x[:vector], s, 1.0))
        # no duplicates
        d.each {|o| assert_equal(false, x[:vector]==o[:vector]) if x!=o }
      end
    end
  end
  
  # test the generation of a self dataset
  def test_generate_self_dataset
    rs = generate_self_dataset(100, [[0,1],[0,1]], [[0,10],[0,10]])
    assert_equal(100, rs.size)
    rs.each do |pattern|
      pattern[:vector].each do |x|
        assert_operator(x, :>=, 0)
        assert_operator(x, :<=, 1)        
      end
    end
  end
  
  # test the application of detectors
  def test_apply_detectors
    # incorrect
    rs = nil
    silence_stream(STDOUT) do
      s = [{:vector=>[1,1]}, {:vector=>[5,5]}]
      rs = apply_detectors([{:vector=>[0,0]}], [[0,10],[0,10]], s, 0)
    end
    assert_not_nil(rs)
    assert_equal(0, rs)
    # correct
    rs = nil
    silence_stream(STDOUT) do
      rs = apply_detectors([{:vector=>[0.5,0.5]}], [[0,1.1],[0,1.1]], [{:vector=>[1.1,1.1]}], 0.501)
    end
    assert_not_nil(rs)
    assert_in_delta(50, rs, 15)
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
    search_space = Array.new(2) {[0.0, 1.0]}
    self_space = Array.new(2) {[0.5, 1.0]}
    self_patterns = nil
    # create self patterns
    silence_stream(STDOUT) do
      self_patterns = generate_self_dataset(150, self_space, search_space)
    end  
    assert_in_delta(150, self_patterns.size, 0)
    detectors = nil
    # create detectors
    silence_stream(STDOUT) do
      detectors = execute(search_space, self_space, 300, 150, 0.05)
    end  
    assert_in_delta(300, detectors.size, 0)
    correct = -1
    # test detectors
    silence_stream(STDOUT) do
      correct = apply_detectors(detectors, search_space, self_patterns, 0.05)
    end
    assert_in_delta(50, correct, 10)
  end
  
end
