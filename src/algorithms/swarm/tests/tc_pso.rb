# Unit tests for pso.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 David Howden. Some Rights Reserved.
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../pso"

class TC_PSO < Test::Unit::TestCase

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

  # test that objective_function behaves as expected
  def test_objective_function
    # test with int
    vector = [-2, -1, 0, 7]
    expected = vector.inject(0.0) {|m,x| m + x*x }
    assert_equal(expected, objective_function(vector))
    #test with float
    vector = [-20.2, 9000]
    expected = vector.inject(0.0) {|m,x| m + x*x }
    assert_in_delta(expected, objective_function(vector), 0.01)
  end
  
  # test that the update_velocity function behaves as expected
  def test_update_velocity
    problem_size = 1
    search_space = Array.new(problem_size) {[-10, 10]}
    vel_space = [0]
    particle = create_particle(search_space, vel_space)
    gbest = create_particle(search_space, vel_space)
    # test vel updates
    do_test_update_velocity(5, particle, gbest, 0, 0, 0, 0, 0)
    do_test_update_velocity(5, particle, gbest, 0, 5, 0, 0, 5)
    do_test_update_velocity(50, particle, gbest, 0, 0, -10, 10, 0)
    do_test_update_velocity(5, particle, gbest, -10, 10, 10, 10, 5)
    do_test_update_velocity(50, particle, gbest, 0, 5, -5, 10, 7.5)
    do_test_update_velocity(50, particle, gbest, -2.5, -5, 0, 0, -2.5)
  end

  # Helper function for test_update_velocity
  # l_pos - local optima
  # g_pos - global optima
  # gbest - particle containing the global best
  # expected - value to be compared against for the assert
  def do_test_update_velocity(max_vel, particle, gbest, pos, vel, l_pos, g_pos, expected)
    sum = 0
    count = 0
    while count < 20000
      particle[:position],particle[:velocity] = [pos],[vel]
      particle[:b_position],gbest[:position] = [l_pos],[g_pos]
      update_velocity(particle, gbest, max_vel, 1, 1)
      assert_operator((particle[:velocity][0]).abs, :<=, max_vel)
      sum += particle[:velocity][0]
      count += 1
    end
    assert_in_delta(expected, (sum / count), 0.1)
  end

  # test that the update_position function behaves as expected
  def test_update_position
    problem_size = 2
    search_space = Array.new(problem_size) {[-10, 10]}
    particle = create_particle(search_space, [-1,1])
    # positive integers
    particle[:position] = [0,9]
    particle[:velocity] = [4,4]
    update_position(particle, search_space)
    assert_equal([4,7], particle[:position])
    # negative integers
    particle[:position] = [-8,-9]
    particle[:velocity] = [-2,-4]
    update_position(particle, search_space)
    assert_equal([-10,-7], particle[:position])
  end

  # test that the get_global_best function behaves as expected
  def test_get_global_best
    problem_size = 2
    search_space = Array.new(problem_size) {[-10, 10]}
    particle = create_particle(search_space, [-1,1])
    vel_space = [-1,1]
    pop_size = 100
    pop = Array.new(pop_size) {create_particle(search_space, vel_space)}
    # test ascending order
    pop.each_with_index {|p,i| pop[i][:cost] = i}
    gbest = get_global_best(pop, gbest)
    assert_equal(0, gbest[:cost])
    # test descending order
    pop.each_with_index {|p,i| pop[i][:cost] = pop_size-i}
    gbest = get_global_best(pop, gbest)
    assert_equal(0, gbest[:cost])
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
      best = search(200, [[-5,5],[-5,5]], [[-1,1],[-1,1]], 20, 20.0, 2, 2)
    end  
    assert_not_nil(best[:cost])
    assert_in_delta(0.0, best[:cost], 1.0)
  end	  
end
