# Unit tests for genetic_programming.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../genetic_programming"

class TC_GeneticProgramming < Test::Unit::TestCase 
  
  # test the uniform sampling within bounds
  def test_rand_in_bounds
    # positive, zero offset
    x = rand_in_bounds(0, 20)
    assert_operator(x, :>=, 0)
    assert_operator(x, :<, 20)
    # negative
    x = rand_in_bounds(-20, -1)
    assert_operator(x, :>=, -20)
    assert_operator(x, :<, -1)
    # both
    x = rand_in_bounds(-10, 20)
    assert_operator(x, :>=, -10)
    assert_operator(x, :<, 20)
  end
  
  # test printing a program
  def test_print_program
    assert_equal("X",  print_program("X"))
    assert_equal("(+ X X)", print_program([:+, "X", "X"]))
    assert_equal("(+ (* X X) X)", print_program([:+, [:*, "X", "X"], "X"]))
  end
  
  # test the evaluation of programs
  def test_eval_program
    assert_equal(1, eval_program("1", {}))
    assert_equal(1, eval_program("X", {"X"=>1}))
    assert_equal(2, eval_program([:+, "X", "X"], {"X"=>1}))
    assert_equal(2, eval_program([:+, [:*, "X", "X"], "X"], {"X"=>1}))
    assert_equal(0, eval_program([:/, "X", "X"], {"X"=>0}))
  end
  
  # test the generation of programs
  def test_generate_random_program
    terminals = ['X', 'R']
    functions = [:+, :-, :*, :/]
    # one
    rs = generate_random_program(1, functions, terminals)
    assert(rs=='X' || rs.kind_of?(Float), "[#{rs}]")
    # two
    rs = generate_random_program(2, functions, terminals)
    assert(rs=='X' || rs.kind_of?(Float) || rs.size==3, "[#{rs}]")
  end
  
  # test counting nodes
  def test_count_nodes
    assert_equal(1, count_nodes("X"))
    assert_equal(3, count_nodes([:+, "X", "X"]))
    assert_equal(5, count_nodes([:+, [:*, "X", "X"], "X"]))
    assert_equal(5, count_nodes([:+, "X", [:*, "X", "X"]]))
  end
  
  # test the objective function
  def test_target_function
    assert_equal(1.0, target_function(0.0))
    assert_equal(3.0, target_function(1.0))
    assert_equal((2**2+2+1), target_function(2.0))
    assert_equal((99*99+99+1), target_function(99.0))
  end
  
  # test the fitness function
  def test_fitness
    # optima - zero error
    optima = [:+, [:*, 'X', 'X'], [:+, 'X', 1.0]]  
    assert_in_delta(0.0, fitness(optima), 0.0000001)
    # other
    other = [:+, [:*, 'X', 'X'], 'X']  
    assert_in_delta(1.0, fitness(other), 1.0)
  end
  
  # test tournament selection
  def test_tournament_selection
    pop = [{:fitness=>1}, {:fitness=>2}, {:fitness=>3}, {:fitness=>4}]
    20.times do      
      s = tournament_selection(pop, 2)
      assert_equal(true, pop.include?(s))
    end
    # Test that better solutions are slected as num bouts increases
  end
  
  # test the replacement of a node
  def test_replace_node
    p1 = [:+, 'X', 'X']
    p2 = [:+, [:*, 'X', 'X'], 'X']
    rs = replace_node(p1, p2[1], 1)
    assert_equal(2, rs.size)
    # our new node
    assert_equal([:+, [:*, 'X', 'X'], 'X'], rs[0])
    # a helper
    assert_equal(3, rs[1])
  end
  
  # test copy program
  def test_copy_program
    a = 'X'
    rs = copy_program(a)
    assert_equal(a, rs)
    assert_same(a, rs) # same
    a = [:+, 'X', 'X']
    rs = copy_program(a)
    assert_equal(a, rs)
    assert_not_same(a, rs)
    a = [:+, [:*, 'X', 'X'], [:+, 'X', 1.0]]
    rs = copy_program(a)
    assert_equal(a, rs)
    assert_not_same(a, rs)
  end
  
  # test getting a node
  def test_get_node
    # first
    rs = get_node([:+, 'X', 'X'], 0)
    assert_equal(2, rs.size)
    assert_equal([:+, 'X', 'X'], rs[0])
    assert_equal(1, rs[1])
    # last
    rs = get_node([:+, 'X', 'X'], 2)
    assert_equal(2, rs.size)
    assert_equal('X', rs[0])
    assert_equal(3, rs[1])
    # invalid
    rs = get_node([:+, 'X', 'X'], 3)
    assert_equal(2, rs.size)
    assert_equal(nil, rs[0])
    assert_equal(3, rs[1])
  end
  
  # test pruning a node
  def test_prune
    # trim 2 to 1
    rs = prune([:+, 'X', 'X'], 1, ['X'])
    assert_equal('X', rs)
    # trim 3 to 2
    rs = prune([:+, [:+, 'X', 'X'], 'X'], 2, ['X'])
    assert_equal([:+, 'X', 'X'], rs)
    # trim 4 to 3
    rs = prune([:+, [:+, [:+, 'X', 'X'], 'X'], 'X'], 3, ['X'])
    assert_equal([:+, [:+, 'X', 'X'], 'X'], rs)
  end
  
  # test crossover
  def test_crossover
    rs = crossover([:+, 'X', 'X'], [:*, 'X', 'X'], 20, ['X'])
    assert_equal(2, rs.size)
    # TODO can we test anything else useful? tree validity?
  end
  
  # test mutation
  def test_mutation
    rs = mutation([:+, 'X', 'X'], 20, [:+, :-, :*, :/], ['X', 'R'])  
    assert_not_nil(rs)
    # TODO can we test anything else useful? tree validity?
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
    terminals = ['X', 'R']
    functions = [:+, :-, :*, :/]  
    best = nil
    silence_stream(STDOUT) do
      best = search(50, 50, 6, 3, 0.08, 0.9, 0.02, functions, terminals)
    end  
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 0.5)
  end
  
end
