# Unit tests for gene_expression_programming.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../gene_expression_programming"

class TC_GeneExpressionProgramming < Test::Unit::TestCase
  
  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}
  end
  
  # test point mutation
  def test_point_mutation
    grammar = {"FUNC"=>["A"], "TERM"=>["B"]}
    # no change
    20.times do
      assert_equal("AAAABBBBBBBB", point_mutation(grammar, "AAAABBBBBBBB", 4, 0))
    end
    # constrained change
    20.times do
      s = point_mutation(grammar, "AAAABBBBBBBB", 4, 1)
      assert_equal(12, s.length)
      s.size.times do |i|
        if i <= 3
          assert(grammar["FUNC"].include?(s[i].chr) || grammar["TERM"].include?(s[i].chr))
        else 
          assert(grammar["TERM"].include?(s[i].chr))
        end
      end
    end
  end
  
  # test recombination
  def test_crossover
    p1 = "0000000000"
    p2 = "1111111111"        
    assert_equal(p1, crossover(p1,p2,0))
    assert_not_same(p1, crossover(p1,p2,0))      
    s = crossover(p1,p2,1)        
    s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
  end
  
  # test reproduction with even sized pop
  def test_reproduce_even
    # create valid children
    grammar = {"FUNC"=>["A"], "TERM"=>["B", "C"]}
    selected = Array.new(20) { {:genome=>"AAAABBBBBBBB"} }
    children = reproduce(grammar, selected, selected.size, 1.0, 4)
    assert_equal(20, children.size)
    children.each do |c|
      s = c[:genome]
      assert_equal(12, s.length)
      s.size.times do |i|
        if i <= 3
          assert(grammar["FUNC"].include?(s[i].chr) || grammar["TERM"].include?(s[i].chr))
        else 
          assert(grammar["TERM"].include?(s[i].chr))
        end
      end    
    end
  end
  
  # test reproduction with odd sized pop
  def test_reproduce_odd
    # create valid children
    grammar = {"FUNC"=>["A"], "TERM"=>["B", "C"]}
    selected = Array.new(19) { {:genome=>"AAAABBBBBBBB"} }
    children = reproduce(grammar, selected, selected.size, 1.0, 4)
    assert_equal(19, children.size)
    children.each do |c|
      s = c[:genome]
      assert_equal(12, s.length)
      s.size.times do |i|
        if i <= 3
          assert(grammar["FUNC"].include?(s[i].chr) || grammar["TERM"].include?(s[i].chr))
        else 
          assert(grammar["TERM"].include?(s[i].chr))
        end
      end    
    end
  end
  
  # test that valid genomes are created
  def test_random_genome
    grammar = {"FUNC"=>["A", "B"], "TERM"=>["C", "D"]}
    20.times do
      s = random_genome(grammar, 4, 4*2)
      assert_equal(12, s.length)
      s.size.times do |i|
        if i <= 3
          assert(grammar["FUNC"].include?(s[i].chr) || grammar["TERM"].include?(s[i].chr))
        else 
          assert(grammar["TERM"].include?(s[i].chr))
        end
      end
    end
  end
  
  # test the target function
  def test_target_function
    assert_equal(0.0, target_function(0.0))
    assert_equal(4.0, target_function(1.0))
    assert_equal((2**4+2**3+2**2+2), target_function(2.0))
  end
  
  # test sampling from the domain
  def test_sample_from_bounds
    total, bounds = 200, [-1, +1]
    mean = 0.0
    total.times do
      x = sample_from_bounds(bounds)
      assert(x>=bounds[0], "x=#{x}")
      assert(x<=bounds[1], "x=#{x}")
      mean += x
    end
    assert_in_delta(mean/total.to_f, 0.0, 0.2)
  end
  
  # test the computation of cost for decoded programs
  def test_cost
    # bad program
    assert_equal(9999999, cost("(x - x) / (x - x)", [-1, +1]))
    # optima
    optima = "( x * (x * (x * x))) + (x * (x * x)) + (x * x) + x"
    assert_in_delta(0.0, cost(optima, [-1, +1]), 0.00000001)
  end
  
  # test the conversio of structure to tree
  def test_mapping
    grammar = {"FUNC"=>["+","-","*","/"], "TERM"=>["x"]}
    # single node
    node = mapping("x", grammar)
    assert_equal("x", node[:node])
    assert_nil(node[:left])
    assert_nil(node[:right])
    # left leaning tree 
    node = mapping("**xxx", grammar)
    assert_equal("*", node[:node])
    assert_equal("*", node[:left][:node])
    assert_equal("x", node[:right][:node])
    assert_equal("x", node[:left][:left][:node])
    assert_equal("x", node[:left][:right][:node])
    # right leaning tree
    node = mapping("*x*xx", grammar)
    assert_equal("*", node[:node])
    assert_equal("x", node[:left][:node])
    assert_equal("*", node[:right][:node])
    assert_equal("x", node[:right][:left][:node])
    assert_equal("x", node[:right][:right][:node])
  end
  
  # test the conversion of tree to expression
  def test_tree_to_string
    # simplest
    assert_equal("x", tree_to_string({:node=>"x"}))
    # simple addition expression
    assert_equal("(x + x)", tree_to_string({:node=>"+", :left=>{:node=>"x"}, :right=>{:node=>"x"}}))
    # expression with sub-expression
    assert_equal("(x + (x * x))", tree_to_string({:node=>"+", :left=>{:node=>"x"}, 
      :right=>{:node=>"*", :left=>{:node=>"x"}, :right=>{:node=>"x"} }}))
  end
  
  # test the optimal solution evaluates correctly
  def test_evaluate
    grammar = {"FUNC"=>["+","-","*","/"], "TERM"=>["x"]}
    bounds = [1, 10]  
    optima = {:genome=>"+++***x*x*xxx*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"} #l=48
    evaluate(optima, grammar, bounds)
    assert_equal("(((((x * x) * x) * x) + ((x * x) * x)) + ((x * x) + x))", optima[:program])
    assert_in_delta(0.0, optima[:fitness], 0.00000001)
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
  
  # test that the system can reliably solve the problem 
  def test_search
    grammar = {"FUNC"=>["+","*"], "TERM"=>["x"]}
    bounds = [1, 10]  
    head, tail = 20, 2*10
    best = nil
    silence_stream(STDOUT) do
      best = search(grammar, bounds, head, tail, 150, 85, 0.85)
    end
    assert_not_nil(best[:fitness])
    assert_in_delta(0.0, best[:fitness], 10.0)
  end  
end
