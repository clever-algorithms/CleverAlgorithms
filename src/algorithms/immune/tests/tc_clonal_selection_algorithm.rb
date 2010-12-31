# Unit tests for clonal_selection_algorithm.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../clonal_selection_algorithm"

class TC_ClonalSelectionAlgorithm < Test::Unit::TestCase 

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
  
  # test decoding bits into floats
  def test_decode
    # zero
    v = decode("0000000000000000", [[0,1]], 16)
    assert_equal(1, v.size)
    assert_equal(0.0, v[0])
    # one
    v = decode("1111111111111111", [[0,1]], 16)
    assert_equal(1, v.size)
    assert_equal(1.0, v[0])
    # float #1
    v = decode("0000000000000001", [[0,1]], 16)
    assert_equal(1, v.size)
    a = 1.0 / ((2**16)-1)
    assert_equal(a*(2**0), v[0])
    # float #2
    v = decode("0000000000000010", [[0,1]], 16)
    assert_equal(1, v.size)
    assert_equal(a*(2**1), v[0])
    # float #3
    v = decode("0000000000000100", [[0,1]], 16)
    assert_equal(1, v.size)
    assert_equal(a*(2**2), v[0])
    # multiple floats
    v = decode("00000000000000001111111111111111", [[0,1],[0,1]], 16)
    assert_equal(2, v.size)
    assert_equal(0.0, v[0])
    assert_equal(1.0, v[1])
  end
  
  # test solution evaluation
  def test_evaluate
    pop = [{:bitstring=>"00000000000000000000000000000000"}, {:bitstring=>"11111111111111111111111111111111"}]
    evaluate(pop, [[-1,1],[-1,1]], 16)
    pop.each do |p|
      assert_not_nil(p[:vector])
      assert_equal(2, p[:vector].size)
      assert_not_nil(p[:cost])
    end
  end

  # test the creation of random strings
  def test_random_bitstring
    assert_equal(10, random_bitstring(10).size)
    assert_equal(0, random_bitstring(10).delete('0').delete('1').size)
  end

  # test the approximate proportion of 1's and 0's
  def test_random_bitstring_ratio
    s = random_bitstring(1000)
    assert_in_delta(0.5, (s.delete('1').size/1000.0), 0.05)
    assert_in_delta(0.5, (s.delete('0').size/1000.0), 0.05)
  end
  
  # test point mutations at the limits
  def test_point_mutation
    assert_equal("0000000000", point_mutation("0000000000", 0))
    assert_equal("1111111111", point_mutation("1111111111", 0))
    assert_equal("1111111111", point_mutation("0000000000", 1))
    assert_equal("0000000000", point_mutation("1111111111", 1))
  end

  # test that the observed changes approximate the intended probability
  def test_point_mutation_ratio
    changes = 0
    100.times do
      s = point_mutation("0000000000", 0.5)
      changes += (10 - s.delete('1').size)
    end
    assert_in_delta(0.5, changes.to_f/(100*10), 0.05)
  end  
  
  # test calculation of mutation rate for affinities (not costs!)
  def test_calculate_mutation_rate
    # best - lowest rate
    assert_in_delta(0.0, calculate_mutation_rate({:affinity=>1.0}), 0.1)
    # middle
    assert_in_delta(0.3, calculate_mutation_rate({:affinity=>0.5}), 0.1)
    # worst - highest rate
    assert_equal(1.0, calculate_mutation_rate({:affinity=>0.0}))
  end
  
  # test calculation of the number of clones
  def test_num_clones
    assert_equal(100, num_clones(100, 1))
    assert_equal(10, num_clones(100, 0.1))
    assert_equal(200, num_clones(100, 2))
    # rounded
    assert_equal(12, num_clones(100, 0.123))
  end
  
  # test the calculation of affinity
  def test_calculate_affinity
    # all ones - no range in cost
    pop = [{:cost=>1},{:cost=>1},{:cost=>1},{:cost=>1},{:cost=>1}]
    calculate_affinity(pop)
    pop.each do |p|
      assert_not_nil(p[:affinity])
      assert_equal(1.0, p[:affinity])
    end
    pop = [{:cost=>10000},{:cost=>1000},{:cost=>100},{:cost=>10},{:cost=>1}]
    # normal
    calculate_affinity(pop)
    pop.each do |p|
      assert_not_nil(p[:affinity])
      assert_operator(p[:affinity], :>=, 0.0)
      assert_operator(p[:affinity], :<=, 1.0)
    end
  end
  
  # test variation
  def test_clone_and_hypermutate
    pop = [{:bitstring=>"000000", :cost=>0},{:bitstring=>"111111", :cost=>1}]
    clones = clone_and_hypermutate(pop, 10)
    assert_equal(40, clones.size)
    assert_equal(1.0, pop[0][:affinity])
    assert_equal(0.0, pop[1][:affinity])
    clones.each_with_index do |c, i|
      if i < 20
        # very low mutation, best affinity
        assert_not_same(c, pop[0])
      else
        # lots of change, worst affinity
        assert_not_same(c, pop[1])
        assert_not_equal(pop[1][:bitstring], c[:bitstring])
      end
    end
    # ensure pop was unchanged
    assert_equal(pop[0][:bitstring], "000000")
    assert_equal(pop[1][:bitstring], "111111")
  end
  
  # test random insertion
  def test_random_insertion
    pop = [{:bitstring=>"000000", :vector=>[0], :cost=>0},{:bitstring=>"111111", :vector=>[666], :cost=>1}]
    # less than pop
    p = random_insertion([[-1,1]], pop, 1, 6)
    assert_equal(pop.size, p.size)
    p.each do |x|
      assert_not_nil(x[:vector])
      assert_equal(1, x[:vector].size)
      assert_equal(6, x[:bitstring].size)
      assert_not_nil(x[:cost])
    end
    # more than pop
    p = random_insertion([[-1,1]], pop, 10000, 6)
    assert_equal(pop.size, p.size)
    p.each do |x|
      assert_not_nil(x[:vector])
      assert_equal(1, x[:vector].size)
      assert_equal(6, x[:bitstring].size)
      assert_not_nil(x[:cost])
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
      best = search([[-5,5],[-5,5]], 100, 50, 0.1, 1)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.001)
  end
  
end
