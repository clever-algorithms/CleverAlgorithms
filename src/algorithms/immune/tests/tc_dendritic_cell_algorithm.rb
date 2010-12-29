# Unit tests for dendritic_cell_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../dendritic_cell_algorithm"

class TC_DendriticCellAlgorithm < Test::Unit::TestCase 
  
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
  
  # test the generation of random vectors
  def test_random_vector
    bounds, trials = [-3,3], 300
    minmax = Array.new(20) {bounds}
    trials.times do 
      vector = random_vector(minmax)
      sum = 0.0
      assert_equal(20, vector.size)
      vector.each do |v|
        assert_operator(v, :>=, bounds[0])
        assert_operator(v, :<, bounds[1])
        sum += v
      end
      assert_in_delta(bounds[0]+((bounds[1]-bounds[0])/2.0), sum/trials.to_f, 0.1)
    end    
  end
  
  # test the construction of patterns
  def test_construct_pattern
    domain = {"A"=>[10,11,12], "B"=>[1,2,3]}
    10.times do
      d = (rand()<0.5) ? "A" : "B"
      norm, anom = rand, rand
      p = construct_pattern(d, domain, norm, anom)
      # verify assignment
      assert_equal(d, p[:class_label])
      assert(domain[d].include?(p[:input]), "#{p[:input]}")
      assert_operator(p[:safe], :<, norm*100.0)
      assert_operator(p[:danger], :<, anom*100.0)
    end    
  end

  # test generation of patterns
  def test_generate_pattern
    domain = {"Anomaly"=>[10,20,30], "Normal"=>[1,2,3]}
    p_anom, p_norm = 0.5, 0.9
    # anomoly
    p = nil
    silence_stream(STDOUT) do
      p = generate_pattern(domain, p_anom, p_norm, 1.0)
    end
    # verify assignment
    assert_equal("Anomaly", p[:class_label])
    assert(domain["Anomaly"].include?(p[:input]), "#{p[:input]}")
    assert_operator(p[:danger], :<, p_anom*100)
    assert_operator(p[:safe], :<, (1.0-p_norm)*100)
    # normal
    # pattern = nil
    silence_stream(STDOUT) do
      p = generate_pattern(domain, p_anom, p_norm, 0.0)
    end
    # verify assignment
    assert_equal("Normal", p[:class_label])
    assert(domain["Normal"].include?(p[:input]), "#{p[:input]}")
    assert_operator(p[:danger], :<, (1.0-p_anom)*100)
    assert_operator(p[:safe], :<, p_norm*100)
  end
  
  # test the initialization of new cells
  def test_initialize_cell
    # new
    10.times do
      c = initialize_cell([10, 20])
      assert_equal(100, c[:lifespan])
      assert_equal(0, c[:k])
      assert_equal(0, c[:cms])
      assert_operator(c[:migration_threshold], :<, 20)
      assert_operator(c[:migration_threshold], :>=, 10)
      assert_equal({}, c[:antigen])
    end
    # existing    
    10.times do
      c = initialize_cell([0, 1])
      assert_not_nil(c)
      c = initialize_cell([10, 20], c)
      assert_equal(100, c[:lifespan])
      assert_equal(0, c[:k])
      assert_equal(0, c[:cms])
      assert_operator(c[:migration_threshold], :<, 20)
      assert_operator(c[:migration_threshold], :>=, 10)
      assert_equal({}, c[:antigen])
    end
  end
  
  # test storing antigen
  def test_store_antigen
    # new
    c = {:antigen=>{}}
    store_antigen(c, "A")
    assert_equal(1, c[:antigen]["A"])
    # existing
    c = {:antigen=>{"B"=>99}}
    store_antigen(c, "B")
    assert_equal(100, c[:antigen]["B"])
  end
  
  # test exposing a cell to input
  def test_expose_cell
    # normal
    c = {:cms=>0,:k=>0.1,:lifespan=>100,:antigen=>{}}
    expose_cell(c, 10, 0.9, {:input=>666}, [-5,5])
    assert_equal(10, c[:cms])
    assert_equal(1.0, c[:k])
    assert_equal(90, c[:lifespan])
    assert_equal(1, c[:antigen][666])
    # reinitialized
    c = {:cms=>0,:k=>0.1,:lifespan=>100,:antigen=>{}}
    expose_cell(c, 100, 0.9, {:input=>666}, [-5,5])
    assert_equal(0, c[:cms])
    assert_equal(0, c[:k])
    assert_equal(100, c[:lifespan])
    assert_equal(0, c[:antigen].size)
  end
  
  # test the decision to migrate a cell
  def test_can_cell_migrate
    # less than some antigen
    cell = {:cms=>1,:migration_threshold=>2,:antigen=>{99=>1}}
    assert_equal(false, can_cell_migrate?(cell))
    # equal, some antigen
    cell = {:cms=>0.1,:migration_threshold=>0.1,:antigen=>{99=>1}}
    assert_equal(true, can_cell_migrate?(cell))
    # more than, some antigen
    cell = {:cms=>100,:migration_threshold=>0.1,:antigen=>{99=>1}}
    assert_equal(true, can_cell_migrate?(cell))
    # equal, no antigen
    cell = {:cms=>3,:migration_threshold=>3,:antigen=>{}}
    assert_equal(false, can_cell_migrate?(cell))
    # more than, no antigen
    cell = {:cms=>33,:migration_threshold=>3,:antigen=>{}}
    assert_equal(false, can_cell_migrate?(cell))
  end
  
  # test exposing all cells
  def test_expose_all_cells
    pattern = {:input=>5, :safe=>90, :danger=>10}
    # no migration
    cells = [{:cms=>0,:k=>0.1,:lifespan=>200,:antigen=>{},:migration_threshold=>120},
      {:cms=>1,:k=>0.1,:lifespan=>200,:antigen=>{5=>1},:migration_threshold=>120}]
    migrated = expose_all_cells(cells, pattern, [0,1])
    assert_equal(0, migrated.size)
    # with migration (Normal)
    cells = [{:cms=>0,:k=>0.1,:lifespan=>200,:antigen=>{},:migration_threshold=>120},
      {:cms=>120,:k=>0.1,:lifespan=>200,:antigen=>{5=>1},:migration_threshold=>220}]
    migrated = expose_all_cells(cells, pattern, [0,1])
    assert_equal(1, migrated.size)
    c = migrated.first
    assert_equal(0.1+(10-(90*2)), c[:k])
    assert_equal(220, c[:cms])
    assert_equal("Normal", c[:class_label])
    # with migration (Anomaly)
    pattern = {:input=>5, :safe=>10, :danger=>90}
    cells = [{:cms=>0,:k=>0.1,:lifespan=>200,:antigen=>{},:migration_threshold=>120},
      {:cms=>120,:k=>0.1,:lifespan=>200,:antigen=>{5=>1},:migration_threshold=>220}]
    migrated = expose_all_cells(cells, pattern, [0,1])
    assert_equal(1, migrated.size)
    c = migrated.first
    assert_equal(0.1+(90-(10*2)), c[:k])
    assert_equal(220, c[:cms])
    assert_equal("Anomaly", c[:class_label])
  end
  
  def test_train_system
        
  end
  
  def test_classify_pattern
    
  end
  
  def test_test_system
    
  end
  

  
  # test that the algorithm can solve the problem
  def test_search    
    domain = {}
    domain["Normal"] = Array.new(50){|i| i}
    domain["Anomaly"] = Array.new(5){|i| (i+1)*10}
    domain["Normal"] = domain["Normal"] - domain["Anomaly"]
    assert_equal(46, domain["Normal"].size) # [0,49]
    assert_equal(5, domain["Anomaly"].size) # {10,20,30,40,50}
    cells = nil
    silence_stream(STDOUT) do
      cells = execute(domain, 100, 50, 0.7, 0.95, [5,15], 10)  
    end
    correct = nil
    silence_stream(STDOUT) do
      correct = test_system(cells, domain, 0.7, 0.95, 10)
    end
    assert_equal(2, correct.size)    
    assert_in_delta(100, correct[0], 10)
    assert_in_delta(100, correct[1], 10)
  end
  
end
