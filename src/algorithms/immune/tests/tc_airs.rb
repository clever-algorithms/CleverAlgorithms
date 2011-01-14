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
    assert_not_nil(p[:label])
    assert_not_nil(p[:vector])
    assert_equal(true, domain.keys.include?(p[:label]))
    p[:vector].each_with_index do |x, i|
      assert_operator(x, :>=, domain[p[:label]][i][0])
      assert_operator(x, :<=, domain[p[:label]][i][1])
    end
  end
  
  # test the creation of a cell
  def test_create_cell
    c = create_cell([1,2,3], "A")
    assert_equal([1,2,3], c[:vector])
    assert_equal("A", c[:label])
  end
  
  # test cell initialization
  def test_initialize_cells
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    c = initialize_cells(domain)
    assert_equal(2, c.size)
    c.each do |p|
      assert_equal(true, domain.keys.include?(p[:label]))
      p[:vector].each_with_index do |x, i|
        assert_operator(x, :>=, 0)
        assert_operator(x, :<=, 1)
      end
    end
  end
  
  # test euclidean distance
  def test_distance
    assert_equal(0, distance([0,0],[0,0]))
    assert_equal(0, distance([1,5],[1,5]))
    assert_in_delta(1.4, distance([1,1],[2,2]),0.1)    
  end
  
  # test cell stimulation
  def test_stimulate
    cells = [{:vector=>[0,0]}, {:vector=>[1,1]}]
    stimulate(cells, {:vector=>[0.5,0.5]})
    cells.each do |c|
      assert_not_nil(c[:affinity])      
      assert_operator(c[:affinity], :>=, 0)
      assert_operator(c[:affinity], :<=, 1)
      assert_not_nil(c[:stimulation])
      assert_operator(c[:stimulation], :>=, 0)
      assert_operator(c[:stimulation], :<=, 1)      
    end
  end
  
  # test getting the most stimulated cell
  def test_get_most_stimulated_cell
    cells = [{:vector=>[0,0]}, {:vector=>[1.1,1.1]}]
    c = get_most_stimulated_cell(cells, {:vector=>[0.5,0.5]})
    assert_equal(cells.first, c)
    assert_operator(cells[0][:stimulation], :>, cells[1][:stimulation])
    assert_operator(cells[0][:affinity], :<, cells[1][:affinity])
  end
  
  # test cell mutation
  def test_mutate_cell
    #  no range
    c = mutate_cell({:vector=>[0.5,0.5]}, 1)
    c[:vector].each_with_index do |x, i|
      assert_operator(x, :>=, 0)
      assert_operator(x, :<=, 1)
    end
    # too large
    c = mutate_cell({:vector=>[1,1]}, 0)
    c[:vector].each_with_index do |x, i|
      assert_operator(x, :>=, 0)
      assert_operator(x, :<=, 1)
    end
    # too small
    c = mutate_cell({:vector=>[0,0]}, 0)
    c[:vector].each_with_index do |x, i|
      assert_operator(x, :>=, 0)
      assert_operator(x, :<=, 1)
    end
  end
  
  # test creating the arb pool
  def test_create_arb_pool
    best = {:vector=>[0.5,0.5], :stimulation=>1.0, :label=>"A"}
    p = {:vector=>[0.0,0.0]}
    pool = create_arb_pool(p, best, 5, 2)
    assert_equal(10 + 1, pool.size)
    pool.each do |x|
      assert_not_nil(x[:vector])
      assert_not_nil(x[:label])
      assert_equal("A", x[:label])
    end
  end
  
  # test competition for resources
  def test_competition_for_resournces
    # trim done
    pool = [{:stimulation=>1}, {:stimulation=>2}, {:stimulation=>3}]
    competition_for_resournces(pool, 1, 10)
    assert_equal(3, pool.size)
    # pool equals resource size, no trim
    pool = [{:stimulation=>1}, {:stimulation=>2}, {:stimulation=>3}]
    competition_for_resournces(pool, 1, 6)
    assert_equal(3, pool.size)
    # trim last
    pool = [{:stimulation=>1}, {:stimulation=>2}, {:stimulation=>1}]
    competition_for_resournces(pool, 1, 3)
    assert_equal(2, pool.size)
  end
  
  # test refine arm pool
  def test_refine_arb_pool
    # sufficient stimulation
    pool = [{:vector=>[0.5,0.5]}, {:vector=>[0.6,0.6]}, {:vector=>[0.7,0.7]}]
    p = {:vector=>[0.0,0.0]}
    c = refine_arb_pool(pool, p, 0.0, 1, 10)
    assert_same(pool.first, c)
    assert_equal(3, pool.size)
    # insufficient stimulation
    pool = [{:vector=>[0.5,0.5]}, {:vector=>[0.6,0.6]}, {:vector=>[0.7,0.7]}]
    p = {:vector=>[0.0,0.0]}
    c = refine_arb_pool(pool, p, 0.9, 1, 10)
    assert_same(pool.first, c)
    assert_operator(pool.size, :>, 3)
  end
  
  # test adding a candidate to the memory pool
  def test_add_candidate_to_memory_pool
    # added
    memory = []
    add_candidate_to_memory_pool({:stimulation=>1}, {:stimulation=>0}, memory)
    assert_equal(1, memory.size)
    # not added
    memory = []
    add_candidate_to_memory_pool({:stimulation=>0}, {:stimulation=>1}, memory)
    assert_equal(0, memory.size)
  end

  # test the classification of a pattern
  def test_classify_pattern
    pool = [{:vector=>[0.5,0.5]}, {:vector=>[0.6,0.6]}, {:vector=>[0.7,0.7]}]
    p = {:vector=>[0.0,0.0]}
    rs = classify_pattern(pool, p)
    assert_equal(rs, pool.first)
  end

  # test the training of the system
  def test_train_system
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    pool = [{:vector=>[0,0],:label=>"A"}, {:vector=>[1,1],:label=>"B"}]
    silence_stream(STDOUT) {train_system(pool, domain, 20, 5, 2, 0.9, 20)}
    assert_operator(pool.size, :>, 2)
  end
  
  # test the assessment of the system
  def test_test_system
    domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
    pool = [{:vector=>[0.25,0.25],:label=>"A"}, {:vector=>[0.75,0.75],:label=>"B"}]
    rs = nil
    silence_stream(STDOUT) do
      rs = test_system(pool, domain, num_trials=50)
    end
    assert_not_nil(rs)
    assert_in_delta(50, rs, 50)
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
