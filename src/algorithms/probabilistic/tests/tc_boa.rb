# Unit tests for boa.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../boa"

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
    pop = Array.new(10) {|i| {:fitness=>i} }
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
  end

  # test if edges are connected
  def test_connected
    # not connected
    assert_equal(false, connected?(0, 0, [{:out=>[]}]))
    assert_equal(false, connected?(0, 1, [{:out=>[]}, {:out=>[]}]))
    assert_equal(false, connected?(0, 1, [{:out=>[2]}, {:out=>[2]}, {:out=>[0,1]}]))
    # 1 is connected to 0, but not the other way around
    assert_equal(false, connected?(0, 1, [{:out=>[]}, {:out=>[0]}]))
    # connected
    assert_equal(true, connected?(0, 1, [{:out=>[1]}, {:out=>[]}]))
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
    pop = [{:bitstring=>"100"},{:bitstring=>"111"},
           {:bitstring=>"001"},{:bitstring=>"111"},
           {:bitstring=>"000"},{:bitstring=>"011"},
           {:bitstring=>"111"},{:bitstring=>"000"},
           {:bitstring=>"111"},{:bitstring=>"000"}]
    # 0, 1
    rs = compute_count_for_edges(0, pop, [1])
    assert_equal(4, rs[0])
    assert_equal(1, rs[1])
    assert_equal(1, rs[2])
    assert_equal(4, rs[3])
    # 0, 2    
    rs = compute_count_for_edges(0, pop, [2])
    assert_equal(3, rs[0])
    assert_equal(2, rs[1])
    assert_equal(1, rs[2])
    assert_equal(4, rs[3])
    # 0, 1, 2
    rs = compute_count_for_edges(0, pop, [1, 2])
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
    pop = [{:bitstring=>"100"},{:bitstring=>"111"},
           {:bitstring=>"001"},{:bitstring=>"111"},
           {:bitstring=>"000"},{:bitstring=>"011"},
           {:bitstring=>"111"},{:bitstring=>"000"},
           {:bitstring=>"111"},{:bitstring=>"000"}]
    # 2, with 0,1 in-connections
    assert_in_delta(1.0/400.0, k2equation(2, [0, 1], pop), 1.0e18)
    assert_in_delta(1.0/400.0, k2equation(2, [1, 0], pop), 1.0e18) # symmetrical
  end
  
  # test k2 with specific in edges for node
  def test_k2equation_single
    pop = [{:bitstring=>"100"},{:bitstring=>"111"},
           {:bitstring=>"001"},{:bitstring=>"111"},
           {:bitstring=>"000"},{:bitstring=>"011"},
           {:bitstring=>"111"},{:bitstring=>"000"},
           {:bitstring=>"111"},{:bitstring=>"000"}]
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
    pop = [{:bitstring=>"100"},{:bitstring=>"111"},
           {:bitstring=>"001"},{:bitstring=>"111"},
           {:bitstring=>"000"},{:bitstring=>"011"},
           {:bitstring=>"111"},{:bitstring=>"000"},
           {:bitstring=>"111"},{:bitstring=>"000"}]
    # x1
    assert_in_delta(1.0/2772.0, k2equation(0, [], pop), 1.0e18)
    # x2
    assert_in_delta(1.0/2772.0, k2equation(1, [], pop), 1.0e18)
    # x3
    assert_in_delta(1.0/2310.0, k2equation(2, [], pop), 1.0e18)
  end
  
  # test the calculation of gains
  def test_compute_gains
    pop = [{:bitstring=>"100"},{:bitstring=>"111"},
           {:bitstring=>"001"},{:bitstring=>"111"},
           {:bitstring=>"000"},{:bitstring=>"011"},
           {:bitstring=>"111"},{:bitstring=>"000"},
           {:bitstring=>"111"},{:bitstring=>"000"}]
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
  # example from http://web.cs.wpi.edu/~cs539/s05/Projects/k2_algorithm.pdf
  # a test of the K3 metric
  # def test_construct_network
  #   pop = [{:bitstring=>"100"},{:bitstring=>"111"},
  #          {:bitstring=>"001"},{:bitstring=>"111"},
  #          {:bitstring=>"000"},{:bitstring=>"011"},
  #          {:bitstring=>"111"},{:bitstring=>"000"},
  #          {:bitstring=>"111"},{:bitstring=>"000"}]
  #   rs = construct_network(pop, 3)
  #   assert_equal(3, rs.size)
  #   # expect: x1 => x2 => x3
  #   # x1
  #   assert_equal(0, rs[0][:in].size)
  #   assert_equal(1, rs[0][:out].size)
  #   assert_equal(1, rs[0][:out][0])
  #   # x2
  #   assert_equal(1, rs[1][:in].size)
  #   assert_equal(0, rs[1][:in][0])
  #   assert_equal(1, rs[1][:out].size)
  #   assert_equal(2, rs[1][:out][0])
  #   # x3
  #   assert_equal(1, rs[2][:in].size)
  #   assert_equal(1, rs[2][:in][0])
  #   assert_equal(0, rs[2][:out].size)
  # end
  
  # test sampling from the network
  def test_sample_from_network
#    fail("Test not written")
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
#    assert_not_nil(best[:fitness])
#    assert_equal(64, best[:fitness])
  end
  
end
