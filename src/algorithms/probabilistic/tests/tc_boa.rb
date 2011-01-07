:cost# Unit tests for boa.rb

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

  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:cost=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}  
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
    assert_in_delta(1.0/400.0, k2equation(2, [0, 1], pop), 1.0e18)
    assert_in_delta(1.0/400.0, k2equation(2, [1, 0], pop), 1.0e18) # symmetrical
  end
  
  # test k2 with specific in edges for node
  def test_k2equation_single
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # 1 with a 0 in-connection
    assert_in_delta(1.0/900.0, k2equation(1, [0], pop), 1.0e18)
    assert_in_delta(1.0/900.0, k2equation(0, [1], pop), 1.0e18) # symmetrical
    # 2 with a 0 in-connection
    assert_in_delta(1.0/1800.0, k2equation(2, [0], pop), 1.0e18) 
    assert_in_delta(1.0/1800.0, k2equation(0, [2], pop), 1.0e18) # symmetrical
    # 2 with a 1 in-connection
    assert_in_delta(1.0/180.0, k2equation(2, [1], pop), 1.0e18)
    assert_in_delta(1.0/180.0, k2equation(1, [2], pop), 1.0e18) # symmetrical
  end
  
  # test k2 with no in edges
  def test_k2equation_none
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # x1
    assert_in_delta(1.0/2772.0, k2equation(0, [], pop), 1.0e18)
    # x2
    assert_in_delta(1.0/2772.0, k2equation(1, [], pop), 1.0e18)
    # x3
    assert_in_delta(1.0/2310.0, k2equation(2, [], pop), 1.0e18)
  end
  
  # test the calculation of gains
  def test_compute_gains
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    # no viable
    graph = [{:out=>[],:in=>[1,2],:num=>0}, {:out=>[0]}, {:out=>[0]}]
    assert_equal([-1,-1,-1], compute_gains(graph[0], graph, pop))
    #  two viable
    graph = [{:out=>[],:in=>[],:num=>0}, {:out=>[]}, {:out=>[]}]
    rs = compute_gains(graph[0], graph, pop)
    assert_equal(-1, rs[0])
    assert_not_equal(-1, rs[1])
    assert_not_equal(-1, rs[2])
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
    # TODO
    # http://www.cs.ucsb.edu/~suri/cs130a/Graphs.txt
    # http://www.ics.uci.edu/~eppstein/161/960208.html
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
    # single conditionals 
    # P (A ^ B) = P(A) * P(B|A)
    graph = [{:out=>[1],:in=>[],:num=>0}, {:out=>[2],:in=>[0],:num=>1}, {:out=>[],:in=>[1],:num=>2}]
    # 0
    assert_equal(0.5, calculate_probability(graph[0], [nil,nil,nil], graph, pop))    
    # 1
    assert_equal((5.0/10.0) * (4.0/5.0), calculate_probability(graph[1], [1,nil,nil], graph, pop))
    assert_equal((5.0/10.0) * (1.0/5.0), calculate_probability(graph[1], [0,nil,nil], graph, pop))
    # 2
    assert_equal((5.0/10.0) * (5.0/5.0), calculate_probability(graph[2], [nil,1,nil], graph, pop))
    assert_equal((5.0/10.0) * (1.0/5.0), calculate_probability(graph[2], [nil,0,nil], graph, pop))
    # double conditional
    # P (A ^ B ^ C) = P(A) * P(B|A) * P(C|A ^ B)
    graph = [{:out=>[2],:in=>[],:num=>0}, {:out=>[2],:in=>[],:num=>1}, {:out=>[],:in=>[0,1],:num=>2}]
    # 111
    assert_equal((5.0/10.0) * (4.0/5.0) * (4.0/4.0), calculate_probability(graph[2], [1,1,nil], graph, pop)) # 0.4
    # 101
    assert_equal((5.0/10.0) * (1.0/5.0) * (0.0/1.0), calculate_probability(graph[2], [1,1,nil], graph, pop)) # 0
    # 011
    assert_equal((5.0/10.0) * (1.0/5.0) * (1.0/1.0), calculate_probability(graph[2], [1,1,nil], graph, pop)) # 0.1
    # 001
    assert_equal((5.0/10.0) * (4.0/5.0) * (1.0/4.0), calculate_probability(graph[2], [1,1,nil], graph, pop)) # 0.1
  end
  
  # test generating a single sample
  # TODO TODO
  # TODO also test that a set of generated samples match the expectations encoded into the graph/pop
  def TODOtest_probabilistic_logic_sample
    # all zeros
    graph = [{:num=>0,:prob=>0.0}, {:num=>1,:prob=>0.0}, {:num=>2,:prob=>0.0}]
    rs = generate_sample(graph)
    assert_equal(3, rs[:bitstring].size)
    assert_equal([0,0,0], rs[:bitstring])
    # all ones
    graph = [{:num=>0,:prob=>1.0}, {:num=>1,:prob=>1.0}, {:num=>2,:prob=>1.0}]
    rs = generate_sample(graph)
    assert_equal(3, rs[:bitstring].size)
    assert_equal([1,1,1], rs[:bitstring])
    # out of order alternating
    graph = [{:num=>1,:prob=>1.0}, {:num=>2,:prob=>0.0}, {:num=>0,:prob=>0.0}]
    rs = generate_sample(graph)
    assert_equal(3, rs[:bitstring].size)
    assert_equal([0,1,0], rs[:bitstring])
  end

  # test the generation of samples from the network
  # TODO TODO TODO 
  def test_sample_from_network
    pop = [{:bitstring=>[1,0,0]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,1]},{:bitstring=>[1,1,1]},
           {:bitstring=>[0,0,0]},{:bitstring=>[0,1,1]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]},
           {:bitstring=>[1,1,1]},{:bitstring=>[0,0,0]}]
    graph = [{:out=>[],:in=>[],:num=>0}, {:out=>[],:in=>[],:num=>1}, {:out=>[],:in=>[],:num=>2}]
#    samples = sample_from_network(pop, graph, 50)
#    assert_equal(50, samples.size)
#    samples.each do |s| 
#      assert_equal(3, s[:bitstring].size) 
#      s[:bitstring].size.times {|i| assert_not_nil(s[:bitstring][i])}
#    end
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
#    silence_stream(STDOUT) do
#      best = search(64, 50, 50)
#    end  
#    assert_not_nil(best[:cost])
#    assert_equal(64, best[:cost])
  end
  
end
