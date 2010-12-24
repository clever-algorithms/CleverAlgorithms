# Unit tests for pso.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 David Howden. Some Rights Reserved.
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../pso"

class TC_PSO < Test::Unit::TestCase

  # test that the random_vector function behaves as expected
  def test_random_vector
    problem_size = 50
    tolerance = 0.5

    do_test_random_vector(problem_size, -2, 2, tolerance)
    do_test_random_vector(problem_size, -7, -3, tolerance)
    do_test_random_vector(problem_size, 3, 7, tolerance)
    do_test_random_vector(problem_size, 0, 10, tolerance)
    do_test_random_vector(problem_size, -10, 0, tolerance)
  end

  #helper function for test_random_vector
  def do_test_random_vector(problem_size, lower_bound, upper_bound, tolerance)
    median = (lower_bound + upper_bound) / 2
    sum = 0

    search_space = Array.new(problem_size) {[lower_bound, upper_bound]}
    test_vector = random_vector(search_space)

    for i in test_vector
      assert_operator i, :>=, lower_bound
      assert_operator i, :<=, upper_bound
      sum = sum + i
    end

    assert_in_delta(median, (sum / problem_size), tolerance)
  end

  # test that objective_function behaves as expected
  def test_objective_function
    vector = [-2, -1, 0, 7]
    sum = 0

    for i in vector
      sum = sum + i * i
    end

    #test with int
    assert_equal objective_function(vector), sum

    vector = [-20.2, 9000]
    sum = 0

    for i in vector
      sum = sum + i * i
    end

    #test with float
    assert_in_delta objective_function(vector), sum, 0.01
  end
  
  # test that the update_velocity function behaves as expected
  def test_update_velocity
    problem_size = 1
    lower_bound = -10
    upper_bound = 10
    search_space = Array.new(problem_size) {[lower_bound, upper_bound]}
    vel_space = [0]

    particle = create_particle(search_space, vel_space)
    gbest = create_particle(search_space, vel_space)

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
      particle[:position] = [pos]
      particle[:velocity] = [vel]
      particle[:b_position] = [l_pos]
      gbest[:position] = [g_pos]

      update_velocity(particle, gbest, max_vel, 1, 1)
      assert_operator (particle[:velocity][0]).abs, :<=, max_vel
      sum += particle[:velocity][0]
      count += 1
    end
    assert_in_delta expected, (sum / count), 0.05
  end

  # test that the update_position function behaves as expected
  def test_update_position
    problem_size = 2
    lower_bound = -10
    upper_bound = 10
    search_space = Array.new(problem_size) {[lower_bound, upper_bound]}
    particle = create_particle(search_space, [-1,1])

    particle[:position] = [0,9]
    particle[:velocity] = [4,4]
    update_position(particle, search_space)
    assert_equal particle[:position], [4,7]

    particle[:position] = [9,0]
    particle[:velocity] = [4,4]
    update_position(particle, search_space)
    assert_equal particle[:position], [7,4]

    particle[:position] = [-10,0]
    particle[:velocity] = [0,-4]
    update_position(particle, search_space)
    assert_equal particle[:position], [-10,-4]

    particle[:position] = [-8,-9]
    particle[:velocity] = [-2,-4]
    update_position(particle, search_space)
    assert_equal particle[:position], [-10,-7]
  end

  # test that the get_global_best function behaves as expected
  def test_get_global_best
    problem_size = 2
    lower_bound = -10
    upper_bound = 10
    search_space = Array.new(problem_size) {[lower_bound, upper_bound]}
    particle = create_particle(search_space, [-1,1])
    vel_space = [-1,1]

    pop_size = 100
    pop = Array.new(pop_size) {create_particle(search_space, vel_space)}

    #test ascending order
    i = 0
    while i < pop_size
      pop[i][:cost] = i
      i += 1
    end
    gbest = get_global_best(pop, gbest)
    assert_equal(0, gbest[:cost])

    #test descending order
    i = 0
    while i < pop_size
      pop[i][:cost] = pop_size - i
      i += 1
    end
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
      best = search(100, [[-5,5],[-5,5]], [[-1,1],[-1,1]], 50, 5.0, 2, 2)
    end  
    assert_in_delta(0.0, best[:cost], 0.1)
  end	  
end
