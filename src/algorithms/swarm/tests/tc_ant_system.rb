# Unit tests for ant_system.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../ant_system"

class TC_AntSystem < Test::Unit::TestCase

  # test the rounding in the euclidean distance
  def test_euc_2d
    assert_equal(0, euc_2d([0,0], [0,0]))
    assert_equal(0, euc_2d([1.1,1.1], [1.1,1.1]))
    assert_equal(1, euc_2d([1,1], [2,2]))
    assert_equal(3, euc_2d([-1,-1], [1,1]))
  end
  
  # test tour cost includes return to origin
  def test_cost
    cities = [[0,0], [1,1], [2,2], [3,3]]
    assert_equal(1*2, cost([0,1], cities))
    assert_equal(3+4, cost([0,1,2,3], cities))
    assert_equal(4*2, cost([0, 3], cities))
  end

  # test the construction of a random permutation
  def test_random_permutation
    cities = Array.new(10)
    100.times do
      p = random_permutation(cities)
      assert_equal(cities.size, p.size)
      [0,1,2,3,4,5,6,7,8,9].each {|x| assert(p.include?(x), "#{x}") }
    end
  end

  # test pheromone initialization
  def test_initialise_pheromone_matrix
    rs = initialise_pheromone_matrix(100, 10000)
    assert_equal(100, rs.size)
    rs.each do |x|
      assert_equal(100, x.size)
      x.each {|o| assert_equal(100.0/10000.0, o)}
    end
  end

  # test the calculation of choices
  def test_calculate_choices    
    cities = [[0,0],[1,2],[2,2],[3,3],[4,4]]
    pher = Array.new(5){|i| Array.new(5, 1.0)}
    # no exclusion
    rs = calculate_choices(cities, 0, [], pher, 1.0, 1.0)
    assert_equal(5, rs.size)
    rs.each do |x|
      assert_not_nil(x[:city])
      assert_not_nil(x[:history])
      assert_not_nil(x[:distance])
      assert_not_nil(x[:heuristic])
      assert_not_nil(x[:prob])
    end
    # exclusion
    rs = calculate_choices(cities, 0, [0,1], pher, 1.0, 1.0)
    assert_equal(3, rs.size)   
    rs.each do |x|
      assert_equal(true, [2,3,4].include?(x[:city]))
    end 
  end

  # test probabilistic selection
  def test_select_next_city
    # no choice
    choices = [{:prob=>0,:city=>1}, {:prob=>0,:city=>2}, {:prob=>0,:city=>3}]
    city = select_next_city(choices)
    assert_equal(city, choices.find {|x| x[:city]==city }[:city] )
    # choice 
    choices = [{:prob=>0.1,:city=>1}, {:prob=>0.2,:city=>2}, {:prob=>0.3,:city=>3}]
    city = select_next_city(choices)
    assert_equal(city, choices.find {|x| x[:city]==city }[:city] )
    # TODO test if probabilistic better decisions are made over many samples
  end

  # test probabilistic stepwise construction
  def test_stepwise_const
    cities = [[0,0],[1,2],[2,2],[3,3],[4,4]]
    pher = Array.new(5){|i| Array.new(5, 1.0)}
    # all greedy
    perm = stepwise_const(cities, pher, 1.0, 1.0)
    assert_equal(5, perm.size)
    perm.each{|x| assert_equal(true, [0,1,2,3,4].include?(x))}
    # no greedy
    perm = stepwise_const(cities, pher, 1.0, 0.0)
    assert_equal(5, perm.size)
    perm.each{|x| assert_equal(true, [0,1,2,3,4].include?(x))}
  end
  
  # test decay of pheromone
  def test_decay_pheromone
    # change
    pher = Array.new(5){|i| Array.new(5, 1.0)}
    decay_pheromone(pher, 0.5)
    pher.size.times do |x|
      pher.size.times do |y|
        assert_equal(0.5, pher[x][y])
      end
    end
  end
  
  # test updating pheromone
  def test_update_pheromone
    pher = Array.new(5){|i| Array.new(5, 1.0)}
    update_pheromone(pher, [ {:vector=>[0,1,2,3,4],:cost=>2.0}])
    edges = [[0,1],[1,2],[2,3],[3,4],[0,4]]
    pher.size.times do |x|
      pher.size.times do |y|
        if edges.include?([x,y]) or edges.include?([y,x])
          assert_equal(1.5, pher[x][y]) # replaced
        else
          assert_equal(1.0, pher[x][y]) # no change
        end
      end
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
    berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],
     [880,660],[25,230],[525,1000],[580,1175],[650,1130],[1605,620],
     [1220,580],[1465,200],[1530,5],[845,680],[725,370],[145,665],
     [415,635],[510,875],[560,365],[300,465],[520,585],[480,415],
     [835,625],[975,580],[1215,245],[1320,315],[1250,400],[660,180],
     [410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
     [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],
     [95,260],[875,920],[700,500],[555,815],[830,485],[1170,65],
     [830,610],[605,625],[595,360],[1340,725],[1740,245]]
    best = nil
    silence_stream(STDOUT) do
      best = search(berlin52, 30, 30, 0.5, 2.5, 1.0)
    end  
    # better than a NN solution's cost
    assert_not_nil(best[:cost])
    assert_in_delta(7542, best[:cost], 4000)
  end
  
end
