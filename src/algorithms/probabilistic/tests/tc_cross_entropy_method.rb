# Unit tests for cross_entropy_method.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../cross_entropy_method"

class TC_CompactGeneticAlgorithm < Test::Unit::TestCase

  # test the objective function
  def test_objective_function
    # integer
    assert_equal(99**2, objective_function([99]))
    # float
    assert_equal(0.1**2.0, objective_function([0.1]))
    # vector
    assert_equal(1**2+2**2+3**2, objective_function([1,2,3]))
  end
  
  # test the creation of random vars
  def test_random_variable
    # positive, zero offset
    x = random_variable([0, 20])
    assert_operator(x, :>=, 0)
    assert_operator(x, :<, 20)
    # negative
    x = random_variable([-20, -1])
    assert_operator(x, :>=, -20)
    assert_operator(x, :<, -1)
    # both
    x = random_variable([-10, 20])
    assert_operator(x, :>=, -10)
    assert_operator(x, :<, 20)
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
  
  # test the generation of new samples in the search space
  def test_generate_sample
    # middle
    s = generate_sample([[-1,1],[-1,1]], [0,0], [1,1])
    assert_equal(2, s[:vector].size)
    s[:vector].each do |x|
      assert_operator(x, :>=, -1)
      assert_operator(x, :<=, 1)
    end
    # side
    s = generate_sample([[-1,1],[-1,1]], [0.9,0.9], [1,1])
    assert_equal(2, s[:vector].size)
    s[:vector].each do |x|
      assert_operator(x, :>=, -1)
      assert_operator(x, :<=, 1)
    end
  end
  
  # test taking the mean of an attribute across vectors
  def test_mean_parameter
    samples = [{:vector=>[0,5,0,0,0]}, {:vector=>[0,10,10,0,0]}]
    # zero
    assert_equal(0, mean_attr(samples, 0))
    # value
    assert_equal(7.5, mean_attr(samples, 1))
    assert_equal(5, mean_attr(samples, 2))
  end
  
  # test the standard dev of an atttribute
  def test_stdev_parameter
    samples = [{:vector=>[0,0,0,0,0]}, {:vector=>[0,10,0,0,0]}]
    # zero
    assert_equal(0, stdev_attr(samples, 0, 0))
    # value
    assert_equal(5, stdev_attr(samples, 5, 1))
  end
  
  # test updating the distribution
  def test_update_distribution
    samples = [{:vector=>[0,0,0,0,0]}, {:vector=>[0,1,-1,0.5,-0.5]}]
    means, stdvs = [0,0], [1,1]
    update_distribution!(samples, 1.0, means, stdvs)
    # TODO this is weak, rewrite
    means.each_index do |i|
      assert_operator(means[i], :>=, -1)
      assert_operator(means[i], :<=, 1)
      assert_operator(stdvs[i], :>=, 0)
      assert_operator(stdvs[i], :<=, 1)
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
      best = search([[-5,5],[-5,5]], 100, 50, 5, 0.7)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 0.001)
  end
  
end
