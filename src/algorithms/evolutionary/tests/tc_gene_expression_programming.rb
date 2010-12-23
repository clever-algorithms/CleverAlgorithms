# Unit tests for gene_expression_programming.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
#require Pathname.new(File.dirname(__FILE__)) + "../gene_expression_programming"
require "../gene_expression_programming"

class TC_GeneExpressionProgramming < Test::Unit::TestCase
  
  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}
  end
  
  # test point mutations at the limits
#  def test_point_mutation
#    grammar = {"FUNC"=>["+","-","*","/"], "TERM"=>["x"]}
#    head = 3
#    assert_equal("***000", point_mutation(grammar, "***000000000", head, 0))
#    assert_not_equal("***000", point_mutation(grammar, "***000000000", head, 1))
#  end

  # test that the observed changes approximate the intended probability
#  def test_point_mutation_ratio
#    changes = 0
#    100.times do
#      s = point_mutation("0000000000", 0.5)
#      changes += (10 - s.delete('1').size)
#    end
#    assert_in_delta(0.5, changes.to_f/(100*10), 0.05)
#  end  
  
  # test recombination
  def test_uniform_crossover
    p1 = "0000000000"
    p2 = "1111111111"        
    assert_equal(p1, uniform_crossover(p1,p2,0))
    assert_not_same(p1, uniform_crossover(p1,p2,0))      
    s = uniform_crossover(p1,p2,1)        
    s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
  end
  
  def test_reproduce
    # TODO
  end
  
  def test_random_genome
    # TODO
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
    assert_in_delta(mean/total.to_f, 0.0, 0.1)
  end
  
  # test the computation of cost for decoded programs
  def test_cost
    # bad program
    assert_equal(9999999, cost("(x - x) / (x - x)", [-1, +1]))
    # optima
    optima = "( x * (x * (x * x))) + (x * (x * x)) + (x * x) + x"
    assert_in_delta(0.0, cost(optima, [-1, +1]), 0.00000001)
  end
  
  def test_breadth_first_mapping
    # TODO
  end
  
  def test_tree_to_string
    # TODO
  end
  
  # test the optimal solution evaluates correctly
  def test_evaluate
    grammar = {"FUNC"=>["+","-","*","/"], "TERM"=>["x"]}
    bounds = [1, 10]  
    optima = {:genome=>"+++***x*x*xxx*xxxxxxxxxxx"}
    evaluate(optima, grammar, bounds)
    assert_equal("(((((x * x) * x) * x) + ((x * x) * x)) + ((x * x) + x))", optima[:program])
    assert_in_delta(0.0, optima[:fitness], 0.00000001)
  end
  
  def test_search
    # TODO
  end
  
end
