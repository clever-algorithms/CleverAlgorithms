# Unit tests for lvq.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../lvq"

class TC_LVQ < Test::Unit::TestCase 
  
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
      assert_in_delta(bounds[0]+((bounds[1]-bounds[0])/2.0), sum/trials.to_f, 0.15)
    end    
  end
  
  # test generating a random pattern
  def test_generate_random_pattern
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    p = generate_random_pattern(domain)
    assert_not_nil(p[:label])
    assert_not_nil(p[:vector])
    assert_equal(true, domain.keys.include?(p[:label]))
    p[:vector].each_with_index do |x, i|
      assert_operator(x, :>=, domain[p[:label]][i][0])
      assert_operator(x, :<=, domain[p[:label]][i][1])
    end
  end
  
  # test vector initialization
  def test_initialize_vectors
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    vectors = initialize_vectors(domain, 100)
    assert_equal(100, vectors.size)
    vectors.each do |ve|
      assert_not_nil(ve[:label])
      assert_not_nil(ve[:vector])
      assert_equal(true, domain.keys.include?(ve[:label]))
      ve[:vector].each_with_index do |x, i|
        # anywhere in the domain
        assert_operator(x, :>=, 0)
        assert_operator(x, :<=, 1)
      end
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
    rs = get_best_matching_unit(vectors, {:vector=>[0.5,0.5]})
    assert_same(vectors[1], rs)
  end
  
  # test updating a codebook vector
  def test_update_codebook_vector
    # same label
    bmu = {:vector=>[0.5,0.5], :label=>"A"}
    pattern = {:vector=>[1,1], :label=>"A"}
    update_codebook_vector(bmu, pattern, 1.0)
    bmu[:vector].each do |x|
      assert_equal(1.0, x)
    end
    # different label
    bmu = {:vector=>[0.5,0.5], :label=>"B"}
    pattern = {:vector=>[1,1], :label=>"A"}
    update_codebook_vector(bmu, pattern, 1.0)
    bmu[:vector].each do |x|
      assert_equal(0.0, x)
    end
  end

  # helper for turning off STDOUT
  # File activesupport/lib/active_support/core_ext/kernel/reporting.rb
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
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    vectors = [{:vector=>[0.5,0.5], :label=>"A"}, {:vector=>[0.5,0.5], :label=>"B"}]
    silence_stream(STDOUT) do
      train_network(vectors, domain, 100, 0.5)
    end
    vectors.each do |ve|
      ve[:vector].each do |x|
        assert_not_equal(0.5, x)
      end
    end
  end
  
  # test assessing the network
  def test_test_network
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    # perfect
    vectors = [{:vector=>[0,0], :label=>"A"}, {:vector=>[1,1], :label=>"B"}]
    rs = nil
    silence_stream(STDOUT) do
      rs = test_network(vectors, domain, 100)
    end
    assert_not_nil(rs)
    assert_equal(100, rs)
    # worst
    vectors = [{:vector=>[0,0], :label=>"B"}, {:vector=>[1,1], :label=>"A"}]
    rs = nil
    silence_stream(STDOUT) do
      rs = test_network(vectors, domain, 100)
    end
    assert_not_nil(rs)
    assert_equal(0, rs)
  end
    
  # test that the algorithm can solve the problem
  def test_search    
    # domain
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    # compute
    codebooks = nil
    silence_stream(STDOUT) do
      codebooks = execute(domain, 1000, 10, 0.3)
    end
    # structure
    assert_equal(10, codebooks.size)
    # performance
    rs = nil
    silence_stream(STDOUT) do
      rs = test_network(codebooks, domain, 100)
    end
    assert_in_delta(100, rs, 10)
  end
  
end
