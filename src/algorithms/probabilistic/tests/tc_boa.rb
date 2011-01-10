# Unit tests for boa.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../boa"

# some examples for K2 taken from: 
# http://web.cs.wpi.edu/~cs539/s05/Projects/k2_algorithm.pdf

class TC_BOA < Test::Unit::TestCase

  # test that the objective function behaves as expected
  def test_onemax
    assert_equal(0, onemax([0,0,0,0]))
    assert_equal(4, onemax([1,1,1,1]))
    assert_equal(2, onemax([1,0,1,0]))
  end

  # test basic construction of random bitstrings
  def test_random_bitstring
    assert_equal(10, random_bitstring(10).size)
    assert_equal(10, random_bitstring(10).select{|x| x==0 or x==1}.size)    
  end
  
  # test the approximate proportion of 1's and 0's
  def test_random_bitstring_ratio
    s = random_bitstring(1000)
    assert_in_delta(0.5, (s.select{|x| x==0}.size/1000.0), 0.05)
    assert_in_delta(0.5, (s.select{|x| x==1}.size/1000.0), 0.05)
  end

  # test if a path exists between two nodes
  def test_path_exists
    # no path
    assert_equal(false, path_exists?(0, 1, [{:out=>[]}, {:out=>[]}]) )
    # 1=>0 but not 0=>1
    assert_equal(false, path_exists?(0, 1, [{:out=>[]}, {:out=>[0]}]) )
    # cycle
    assert_equal(false, path_exists?(0, 1, [{:out=>[2]}, {:out=>[]}, {:out=>[0]}]) )
    # direct
    assert_equal(true, path_exists?(0, 1, [{:out=>[1]}, {:out=>[]}]) )
    # indirect
    assert_equal(true, path_exists?(0, 1, [{:out=>[2]}, {:out=>[]}, {:out=>[1]}]) )
    # indirect 2
    assert_equal(true, path_exists?(0, 2, [{:out=>[1]}, {:out=>[2]}, {:out=>[]}]) )    
    assert_equal(false, path_exists?(2, 0, [{:out=>[1]}, {:out=>[2]}, {:out=>[]}]) ) # not symmetrical
  end

  # tests whether an edge can be added
  def test_can_add_edge
    # path, not connected
    assert_equal(false, can_add_edge?(0, 1, [{:out=>[]}, {:out=>[0]}]) )
    # already exists
    assert_equal(false, can_add_edge?(0, 1, [{:out=>[1]}, {:out=>[]}]) )
    # path and already exists
    assert_equal(false, can_add_edge?(0, 1, [{:out=>[1]}, {:out=>[0]}]) )
    # no path and does not exist
    assert_equal(true, can_add_edge?(0, 1, [{:out=>[]}, {:out=>[]}]) )
    # indirect case - a bug i found during testing
    assert_equal(false, can_add_edge?(2, 0, [{:out=>[1]}, {:out=>[2]}, {:out=>[]}]) )
  end

  # test the collection of viable parents
  def test_get_viable_parents
    # all
    viable = get_viable_parents(0, [{:out=>[]}, {:out=>[]}, {:out=>[]}])
    assert_equal([1, 2], viable)
    # none
    viable = get_viable_parents(0, [{:out=>[2]}, {:out=>[0]}, {:out=>[]}])
    assert_equal(true, viable.empty?)
  end

  # test the factorial function
  def test_fact
    assert_equal(1, fact(0)) # this is expected!
    assert_equal(1, fact(1))
    assert_equal(2*1, fact(2))
    assert_equal(3*2*1, fact(3))
  end

  # test counts of arbitary associations
  def test_compute_count_for_edges
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # 0, 1
    rs = compute_count_for_edges(pop, [0,1])
    assert_equal(4, rs[0])
    assert_equal(1, rs[1])
    assert_equal(1, rs[2])
    assert_equal(4, rs[3])
    # 1, 2
    rs = compute_count_for_edges(pop, [1,2])
    assert_equal(4, rs[0])
    assert_equal(1, rs[1])
    assert_equal(0, rs[2])
    assert_equal(5, rs[3])
    # 0, 2    
    rs = compute_count_for_edges(pop, [0,2])
    assert_equal(3, rs[0])
    assert_equal(2, rs[1])
    assert_equal(1, rs[2])
    assert_equal(4, rs[3])
    # 0, 1, 2
    rs = compute_count_for_edges(pop, [0, 1,2])
    assert_equal(3, rs[0])
    assert_equal(1, rs[1])
    assert_equal(0, rs[2])
    assert_equal(1, rs[3])    
    assert_equal(1, rs[4])
    assert_equal(0, rs[5])
    assert_equal(0, rs[6])
    assert_equal(4, rs[7])
  end  
  
  # test k2 with specific in edges for node with prior in-edges
  def test_k2equation_multiple
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # 2, with 0,1 in-connections
    assert_in_delta(1.0/400.0, k2equation(2, [0, 1], pop), 1.0e-02)
    assert_in_delta(1.0/400.0, k2equation(2, [1, 0], pop), 1.0e-02) # symmetrical
  end
  
  # test k2 with specific in edges for node
  def test_k2equation_single
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # 1 with a 0 in-connection
    assert_in_delta(1.0/900.0, k2equation(1, [0], pop), 1.0e-08)
    assert_in_delta(1.0/900.0, k2equation(0, [1], pop), 1.0e-08) # symmetrical
    # 2 with a 0 in-connection
    assert_in_delta(1.0/1800.0, k2equation(2, [0], pop), 1.0e-04) 
    assert_in_delta(1.0/1800.0, k2equation(0, [2], pop), 1.0e-08) # symmetrical
    # 2 with a 1 in-connection
    assert_in_delta(1.0/180.0, k2equation(2, [1], pop), 1.0e-03)
    assert_in_delta(1.0/180.0, k2equation(1, [2], pop), 1.0e-08) # symmetrical
  end
  
  # test k2 with no in edges
  def test_k2equation_none
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # x1
    assert_in_delta(1.0/2772.0, k2equation(0, [], pop), 1.0e-08)
    # x2
    assert_in_delta(1.0/2772.0, k2equation(1, [], pop), 1.0e-08)
    # x3
    assert_in_delta(1.0/2310.0, k2equation(2, [], pop), 1.0e-08)
  end
  
  # test the calculation of gains
  def test_compute_gains
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # no viable
    graph = [{:out=>[],:in=>[1,2],:num=>0}, {:out=>[0], :in=>[]}, {:out=>[0], :in=>[]}]
    assert_equal([-1,-1,-1], compute_gains(graph[0], graph, pop, 99))
    #  two viable
    graph = [{:out=>[],:in=>[],:num=>0}, {:out=>[], :in=>[]}, {:out=>[], :in=>[]}]
    rs = compute_gains(graph[0], graph, pop, 99)
    assert_equal(-1, rs[0])
    assert_not_equal(-1, rs[1])
    assert_not_equal(-1, rs[2])
    # TODO tests the max edges
  end

  # test the construction of a network from a population
  # we have an additional connection - we are doing something slightly different here.
  def test_construct_network
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    rs = construct_network(pop, 3)
    assert_equal(3, rs.size)
    # expect: x1 => x2 => x3, also x1=>x3 
    # x1
    assert_equal(0, rs[0][:in].size)
    assert_equal(2, rs[0][:out].size)
    assert_equal(1, rs[0][:out][0])
    assert_equal(2, rs[0][:out][1])
    # x2
    assert_equal(1, rs[1][:in].size)
    assert_equal(0, rs[1][:in][0])
    assert_equal(1, rs[1][:out].size)
    assert_equal(2, rs[1][:out][0])
    # x3
    assert_equal(2, rs[2][:in].size)
    assert_equal(1, rs[2][:in][0])
    assert_equal(0, rs[2][:in][1])
    assert_equal(0, rs[2][:out].size)
  end

  # test the topological ordering of a graph
  def test_topological_ordering
    # root nodes come to the front, dependencies are re-ordted
    graph = [{:out=>[],:in=>[1],:num=>2}, {:out=>[1],:in=>[],:num=>0}, {:out=>[2],:in=>[0],:num=>1}]
    rs = topological_ordering(graph)
    assert_not_same(graph, rs)
    assert_equal(0, rs[0][:num])
    assert_equal(1, rs[1][:num])
    assert_equal(2, rs[2][:num])
    # dependencies are detected and re-ordered accordingly
    g = [{:out=>[1,2],:in=>[],:num=>0}, 
         {:out=>[2,3],:in=>[0],:num=>1}, 
         {:out=>[3],:in=>[0,1],:num=>2},
         {:out=>[],:in=>[1,2],:num=>3}]
    graph = [g[2], g[3], g[0], g[1]]
    rs = topological_ordering(graph)
    assert_not_same(graph, rs)
    assert_equal(0, rs[0][:num])
    assert_equal(1, rs[1][:num])
    assert_equal(2, rs[2][:num])
    assert_equal(3, rs[3][:num])
  end
  
  # test the calculation of the marginal probability of a bit
  def test_marginal_probability
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    assert_equal(0.5, marginal_probability(0, pop))
    assert_equal(0.5, marginal_probability(1, pop))
    assert_equal(0.6, marginal_probability(2, pop))
  end
  
  # test the calculation of a node's probability
  def test_calculate_probability
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # all marginals (independent)
    graph = [{:out=>[],:in=>[],:num=>0}, {:out=>[],:in=>[],:num=>1}, {:out=>[],:in=>[],:num=>2}]
    assert_equal(0.5, calculate_probability(graph[0], [nil,nil,nil], graph, pop))
    assert_equal(0.5, calculate_probability(graph[1], [nil,nil,nil], graph, pop))
    assert_equal(0.6, calculate_probability(graph[2], [nil,nil,nil], graph, pop))
    # single conditional 
    # Conditional: P(B|A) = P(A ^ B) / P(A)
    # Joint: P(A ^ B) = P(A|B) * P(B)
    graph = [{:out=>[1],:in=>[],:num=>0}, {:out=>[2],:in=>[0],:num=>1}, {:out=>[],:in=>[1],:num=>2}]
    # 0
    assert_equal(0.5, calculate_probability(graph[0], [nil,nil,nil], graph, pop))    
    # 1
    assert_in_delta(((4.0/5.0)*(5.0/10.0))/(5.0/10.0), calculate_probability(graph[1], [1,nil,nil], graph, pop), 1.0e-08)
    assert_in_delta(((1.0/5.0)*(5.0/10.0))/(5.0/10.0), calculate_probability(graph[1], [0,nil,nil], graph, pop), 1.0e-08)
    # 2
    assert_in_delta(((5.0/6.0)*(6.0/10.0))/(5.0/10.0), calculate_probability(graph[2], [nil,1,nil], graph, pop), 1.0e-08)
    assert_in_delta(((1.0/6.0)*(6.0/10.0))/(5.0/10.0), calculate_probability(graph[2], [nil,0,nil], graph, pop), 1.0e-08)    
    # two conditional
    # http://stats.stackexchange.com/questions/1564/how-can-i-calculate-the-conditional-probability-of-several-events
    # too much work! (did the frequency graph on paper)
    graph = [{:out=>[2],:in=>[],:num=>0}, {:out=>[2],:in=>[],:num=>1}, {:out=>[],:in=>[0,1],:num=>2}]
    # 111
    assert_equal(4.0/4.0, calculate_probability(graph[2], [1,1,nil], graph, pop)) # 1.0
    # 101
    assert_equal(0.0/1.0, calculate_probability(graph[2], [1,0,nil], graph, pop)) # 0.0
    # 011
    assert_equal(1.0/1.0, calculate_probability(graph[2], [0,1,nil], graph, pop)) # 1.0
    # 001
    assert_equal(1.0/4.0, calculate_probability(graph[2], [0,0,nil], graph, pop)) # 0.25
  end
  
  # test generating a single sample  
  def test_probabilistic_logic_sample
    # test all marginal, and all easy
    pop = [{:bitstring=>[1,1,1]},{:bitstring=>[1,0,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[1,0,1]}]
    graph = [{:out=>[],:in=>[],:num=>0}, {:out=>[],:in=>[],:num=>1}, {:out=>[],:in=>[],:num=>2}]
    trials, freq = 100, Array.new(3){0}
    trials.times do
      rs = probabilistic_logic_sample(graph, pop)
      assert_not_nil(rs[:bitstring])
      assert_equal(3, rs[:bitstring].size) 
      rs[:bitstring].size.times {|i| assert_not_nil(rs[:bitstring][i])}
      rs[:bitstring].each_with_index {|v,i| freq[i]+=v}
    end
    # TODO test conditional
  end

  # test the generation of samples from the network
  def test_sample_from_network
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    graph = [{:out=>[],:in=>[],:num=>0}, {:out=>[],:in=>[],:num=>1}, {:out=>[],:in=>[],:num=>2}]
    samples = sample_from_network(pop, graph, 50)
    assert_equal(50, samples.size)
    samples.each do |s| 
      assert_equal(3, s[:bitstring].size) 
      s[:bitstring].size.times {|i| assert_not_nil(s[:bitstring][i])}
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
     best = search(10, 20, 50, 15, 25)
   end  
   assert_not_nil(best[:cost])
   assert_in_delta(10, best[:cost], 1)
  end
  
end
