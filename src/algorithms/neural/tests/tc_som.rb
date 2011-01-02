# Unit tests for som.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../som"

class TC_SOM < Test::Unit::TestCase 
  
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
  
  # test initializing vectors
  def test_initialize_vectors
    domain = [[0.0,1.0],[0.0,1.0]]
    vectors = initialize_vectors(domain, 10, 20)
    assert_equal(10*20, vectors.size)
    vectors.each do |p|      
      assert_not_nil(p[:vector])
      assert_not_nil(p[:coord])
      # vector
      p[:vector].each_with_index do |x, i|
        assert_operator(x, :>=, 0)
        assert_operator(x, :<=, 1)
      end
      # coord
      assert_equal(2, p[:coord].size)
      assert_operator(p[:coord][0], :>=, 0)
      assert_operator(p[:coord][0], :<, 10)
      assert_operator(p[:coord][1], :>=, 0)
      assert_operator(p[:coord][1], :<, 20)
    end
  end
  
  # test euclidean distance
  def test_euclidean_distance
    assert_equal(0, euclidean_distance([0,0],[0,0]))
    assert_equal(0, euclidean_distance([1,5],[1,5]))
    assert_in_delta(1.4, euclidean_distance([1,1],[2,2]),0.1)    
  end
  
  # test getting the BMU
  def test_get_best_matching_unit
    vectors = [{:vector=>[1,1]}, {:vector=>[0.5,0.5]}, {:vector=>[0,0]}]
    rs = get_best_matching_unit(vectors, [0.5,0.5])
    assert_equal(2, rs.size)
    assert_same(vectors[1], rs[0])
    assert_equal(0, rs[1])
  end
  
  # test getting vectors in the ne
  def test_get_vectors_in_neighborhood
    # none
    vectors = [{:coord=>[1,1]}, {:coord=>[0.5,0.5]}, {:coord=>[0,0]}]
    rs = get_vectors_in_neighborhood({:coord=>[10,10]}, vectors, 1)
    assert_equal(0, rs.size)
    # all
    vectors = [{:coord=>[1,1]}, {:coord=>[0.5,0.5]}, {:coord=>[0,0]}]
    rs = get_vectors_in_neighborhood({:coord=>[0.5,0.5]}, vectors, 0.1)
    assert_equal(1, rs.size)
    # some
    vectors = [{:coord=>[1,1]}, {:coord=>[0.5,0.5]}, {:coord=>[0,0]}]
    rs = get_vectors_in_neighborhood({:coord=>[0.5,0.5]}, vectors, 1)
    assert_equal(3, rs.size)
  end
  
  # test updating a vector
  def test_update_codebook_vector
    # no error
    c = {:vector=>[0.5,0.5]}
    update_codebook_vector(c, [0.5,0.5], 0.5)
    c[:vector].each {|x| assert_equal(0.5, x)}
    # lots of error
    c = {:vector=>[1,1]}
    update_codebook_vector(c, [0.5,0.5], 0.5)
    c[:vector].each {|x| assert_equal(0.75, x)}
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

  # test training the network
  def test_train_network
    vectors = [{:vector=>[0,0], :coord=>[0,0]}, {:vector=>[1,1], :coord=>[1,1]}]
    silence_stream(STDOUT) do
      train_network(vectors, [[0.25,0.75],[0.25,0.75]], 50, 0.5, 3)
    end
    # weights are changed!
    assert_not_equal([0,0], vectors[0][:vector])
    assert_not_equal([1,1], vectors[1][:vector])
  end
  
  # test vector summary
  def test_summarize_vectors
    # same    
    rs = nil
    silence_stream(STDOUT) do
      rs = summarize_vectors([{:vector=>[0.5,0.5]}, {:vector=>[0.5,0.5]}])
    end
    assert_not_nil(rs)
    rs.each do |de|
      assert_equal(0.5, de[0])
      assert_equal(0.5, de[1])
    end
    # some distribution
    rs = nil
    silence_stream(STDOUT) do
      rs = summarize_vectors([{:vector=>[1,1]}, {:vector=>[0,0]}])
    end
    assert_not_nil(rs)
    rs.each do |de|
      assert_equal(0, de[0])
      assert_equal(1, de[1])
    end
  end
  
  # test the assessment fo the network
  def test_test_network
    # no error
    error =nil
    silence_stream(STDOUT) do
      error = test_network([{:vector=>[0.5,0.5]}, {:vector=>[0.5,0.5]}], [[0.25,0.75],[0.25,0.75]], 100)
    end
    assert_not_nil(error)
    assert_in_delta(0, error, 0.2)
    # all error
    error = nil
    silence_stream(STDOUT) do
      error = test_network([{:vector=>[1,1]}, {:vector=>[0,0]}], [[0.5,0.5],[0.5,0.5]], 100)
    end
    assert_not_nil(error)
    assert_in_delta(0.5, error, 0.3)
  end

  # test that the algorithm can solve the problem
  def test_search    
    # problem
    domain = [[0.0,1.0],[0.0,1.0]]
    shape = [[0.3,0.6],[0.3,0.6]]
    # compute
    codebooks = nil
    silence_stream(STDOUT) do
      codebooks = execute(domain, shape, 1000, 0.3, 5, 5, 4)
    end
    # verify structure
    assert_equal(20, codebooks.size)
    # test result
    rs = nil
    silence_stream(STDOUT) do
      rs = test_network(codebooks, shape)
    end
    assert_in_delta(0.0, rs, 0.1)
  end
  
end
