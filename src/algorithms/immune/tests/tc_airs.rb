# Unit tests for airs.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../airs"

class TC_AIRS < Test::Unit::TestCase 
  
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
  
  # test generating a random pattern
  def test_generate_random_pattern
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    p = generate_random_pattern(domain)
    assert_not_nil(p[:class_label])
    assert_not_nil(p[:vector])
    assert_equal(true, domain.keys.include?(p[:class_label]))
    p[:vector].each_with_index do |x, i|
      assert_operator(x, :>=, domain[p[:class_label]][i][0])
      assert_operator(x, :<=, domain[p[:class_label]][i][1])
    end
  end
  
  # test the creation of a cell
  def test_create_cell
    c = create_cell([1,2,3], "A")
    assert_equal([1,2,3], c[:vector])
    assert_equal("A", c[:class_label])
  end
  
  # test cell initialization
  def test_initialize_cells
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    c = initialize_cells(domain)
    assert_equal(2, c.size)
    c.each do |p|
      assert_equal(true, domain.keys.include?(p[:class_label]))
      p[:vector].each_with_index do |x, i|
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
  
  def test_stimulate
    
  end
  
  def test_get_most_stimulated_cell
    
  end
  
  def test_mutate_cell
    
  end
  
  def test_create_arb_pool
    
  end
  
  def test_competition_for_resournces
    
  end
  
  def test_refine_arb_pool
    
  end
  
  def test_add_candidate_to_memory_pool
    
  end
  
  def test_train_system
    
  end
  
  def test_classify_pattern
    
  end
  
  def test_test_system
    
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
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    cells = nil
    silence_stream(STDOUT) do
      cells = execute(domain, 100, 10, 2.0, 0.9, 150)
    end  
    assert_in_delta(50, cells.size, 50)
    correct = -1
    silence_stream(STDOUT) do
      correct = test_system(cells, domain)
    end
    assert_in_delta(50, correct, 10)
  end
  
end
