# Unit tests for learning_classifier_system.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../learning_classifier_system"

class TC_LearningClassifierSystem < Test::Unit::TestCase 

  # test bit negation
  def test_neg
    assert_equal(1, neg(0))
    assert_equal(0, neg(1))
  end
  
  # test the target function
  def test_target_function
    # a few class 0
    assert_equal(0, target_function("000000"))
    assert_equal(0, target_function("011011"))
    # a few class 1
    assert_equal(1, target_function("011111"))
    assert_equal(1, target_function("100010"))
    assert_equal(1, target_function("110001"))
  end

  # tests the creation of a new classifier
  def test_new_classifier
    c = new_classifier("000000", '1', 500, 9, 8, 7)
    assert_equal("000000", c[:condition])
    assert_equal("1", c[:action])
    assert_equal(500, c[:lasttime])    
    assert_not_nil(c[:pred])
    assert_not_nil(c[:error])
    assert_not_nil(c[:fitness])
    assert_equal(9, c[:pred])
    assert_equal(8, c[:error])
    assert_equal(7, c[:fitness])    
    assert_not_nil(c[:exp])
    assert_equal(0, c[:exp])
    assert_not_nil(c[:setsize])
    assert_equal(1, c[:setsize])
    assert_not_nil(c[:num])
    assert_equal(1, c[:num])
  end
  
  # test copying a classifier
  def test_copy_classifier
    parent = {:action=>"0", :condition=>"111111", :lasttime=>33, 
      :pred=>5, :error=>2, :fitness=>7, :exp=>90, :setsize=>20, :num=>66}
    c = copy_classifier(parent)    
    # equal
    assert_equal(parent[:action], c[:action])
    assert_equal(parent[:condition], c[:condition])
    assert_equal(parent[:lasttime], c[:lasttime])
    assert_equal(parent[:pred], c[:pred])
    assert_equal(parent[:error], c[:error])
    assert_equal(parent[:fitness], c[:fitness])
    assert_not_equal(parent[:exp], c[:exp])
    assert_equal(parent[:setsize], c[:setsize])
    assert_not_equal(parent[:num], c[:num])
    # same
    assert_not_same(c, parent)
    assert_not_same(parent[:action], c[:action])
    assert_not_same(parent[:condition], c[:condition])
  end

  # test the creation of random strings
  def test_random_bitstring
    assert_equal(10, random_bitstring(10).size)
    assert_equal(0, random_bitstring(10).delete('0').delete('1').size)
  end

  # test the approximate proportion of 1's and 0's
  def test_random_bitstring_ratio
    s = random_bitstring(1000)
    assert_in_delta(0.5, (s.delete('1').size/1000.0), 0.05)
    assert_in_delta(0.5, (s.delete('0').size/1000.0), 0.05)
  end
  
  # test the ccalculation of the deletion vote
  def test_calculate_deletion_vote
    # below deletion thereshold
    pop = [{:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}]
    classifier = {:setsize=>5, :num=>5, :fitness=>10, :exp=>20}
    rs = calculate_deletion_vote(classifier, pop, 50)
    assert_equal(25, rs)
    # above deletion threshold and more than average fitness
    pop = [{:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}]
    classifier = {:setsize=>5, :num=>5, :fitness=>10, :exp=>50}
    rs = calculate_deletion_vote(classifier, pop, 5)
    assert_equal(25, rs)
    # above deletion threshold and less than average fitness
    pop = [{:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}]
    classifier = {:setsize=>5, :num=>0.01, :fitness=>0.1, :exp=>50}
    rs = calculate_deletion_vote(classifier, pop, 5)
    v = (classifier[:setsize]*classifier[:num])
    assert_equal(v*(10.0/(classifier[:fitness] / classifier[:num])), rs)
  end
  
  # test deleting from the population
  def test_delete_from_pop
    # too few
    pop = [{:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}]
    delete_from_pop(pop, 5, 10)
    assert_equal(3, pop.size)
    # delete, but not remove
    pop = [{:setsize=>5, :num=>5, :fitness=>10, :exp=>50, :num=>5}, 
      {:setsize=>5, :num=>5, :fitness=>10, :exp=>50, :num=>5}, 
      {:setsize=>5, :num=>5, :fitness=>10, :exp=>50, :num=>5}]
    delete_from_pop(pop, 5, 10)
    assert_equal(14, pop.inject(0){|s,x| s+x[:num]})
    # delete and remove one
    pop = [{:setsize=>5, :num=>5, :fitness=>10, :exp=>50, :num=>1}, 
      {:setsize=>5, :num=>5, :fitness=>10, :exp=>50, :num=>1}, 
      {:setsize=>5, :num=>5, :fitness=>10, :exp=>50, :num=>1}]
    delete_from_pop(pop, 2, 20)
    assert_equal(2, pop.size)
  end
  
  # test generating a random classifier
  def test_generate_random_classifier
    actions = ['1', '0']
    # no hash 
    rs = generate_random_classifier("000000", actions, 5, 0)
    assert_equal("000000", rs[:condition])
    assert_equal(true, actions.include?(rs[:action]))
    # all hash
    rs = generate_random_classifier("000000", actions, 5, 1)
    assert_equal("\#\#\#\#\#\#", rs[:condition])
    assert_equal(true, actions.include?(rs[:action]))
  end
  
  # test match condition
  def test_does_match
    # full match
    assert_equal(true, does_match?("000000", "000000"))
    # no match
    assert_equal(false, does_match?("100000", "000000"))
    # partial match
    assert_equal(true, does_match?("100000", "\#00000"))
    # full hash match
    assert_equal(true, does_match?("100000", "\#\#\#\#\#\#"))
  end
  
  # test get actions
  def test_get_actions
    # all 1's
    actions = get_actions([{:action=>'1'},{:action=>'1'},{:action=>'1'}])
    assert_equal(['1'], actions)
    # all 0's
    actions = get_actions([{:action=>'0'},{:action=>'0'},{:action=>'0'}])
    assert_equal(['0'], actions)
    # both
    actions = get_actions([{:action=>'0'},{:action=>'1'},{:action=>'0'}])
    assert_equal(['0', '1'], actions)
  end
  
  # test generate a match
  def test_generate_match_set
    # generate matchset from pop
    pop = [{:action=>'1', :condition=>"000000"}, {:action=>'0', :condition=>"000000"}]
    rs = generate_match_set("000000", pop, ['0', '1'], 5, 2)
    assert_equal(2, rs.size)
    assert_equal(2, pop.size)
    assert_equal(pop, rs)
    # add to match set
    pop = [{:action=>'1', :condition=>"111111", :setsize=>5, :num=>5, :fitness=>10, :exp=>50, :num=>1}, 
      {:action=>'0', :condition=>"000000", :setsize=>5, :num=>5, :fitness=>10, :exp=>50, :num=>1}]
    rs = generate_match_set("000000", pop, ['0', '1'], 5, 5)
    assert_equal(2, rs.size)
    assert_equal(3, pop.size)    
  end
  
  # test generate a prediction
  def test_generate_prediction
    match_set = [{:action=>'1', :fitness=>1.0, :pred=>1.0}, {:action=>'0', :fitness=>1.0, :pred=>1.0}]
    rs = generate_prediction(match_set)
    assert_equal(2, rs.size)
    rs.keys.each do |key|
      # exist
      assert_not_nil(rs[key][:sum])
      assert_not_nil(rs[key][:count])
      assert_not_nil(rs[key][:weight])
      # values
      assert_equal(1, rs[key][:sum])
      assert_equal(1, rs[key][:count])
      assert_equal(1, rs[key][:weight])
    end
  end
  
  # test select action
  def test_select_action
    # random action
    a = select_action({'1'=>{}, '0'=>{}}, true)
    assert_equal(true, ['0', '1'].include?(a))
    # specific action (large weight)
    a = select_action({'1'=>{:weight=>1}, '0'=>{:weight=>100}}, false)
    assert_equal('0', a)
    # assume a specific large weight action
    100.times do
      a = select_action({'1'=>{:weight=>1}, '0'=>{:weight=>100}})
      assert_equal('0', a)
    end    
    # TODO is weight meant to be maximizing?
  end
  
  # test update set
  def test_update_set
    # > lrate
    set = [{:exp=>1, :pred=>1, :error=>0, :num=>1, :setsize=>1}]
    update_set(set, 10, 1)
    assert_equal(2, set[0][:exp])
    assert_equal(1+1*(10-1), set[0][:pred])
    assert_equal((1*((10-1).abs-0)), set[0][:error])
    assert_equal(1+(1*0), set[0][:setsize])
    # < lrate
    set = [{:exp=>1, :pred=>1, :error=>0, :num=>1, :setsize=>1}]
    update_set(set, 10, 0.1)
    assert_equal(2, set[0][:exp])
    assert_equal(1+(10-1)/2.0, set[0][:pred])
    assert_equal(((10-1).abs)/2.0, set[0][:error])
    assert_equal(1+(0.0/2.0), set[0][:setsize])
  end
  
  # test update fitness
  def test_update_fitness
    # below min error
    set = [{:error=>0.5, :num=>1, :fitness=>1.0}, {:error=>0.5, :num=>1, :fitness=>0.5}]
    update_fitness(set, 1.0, 1.0, 0.1, -0.5)
    assert_equal(1.0+1.0*(1.0*1.0/2.0-1.0), set[0][:fitness])
    assert_equal(0.5+1.0*(1.0*1.0/2.0-0.5), set[1][:fitness])    
    # above min error
    set = [{:error=>1.0, :num=>1, :fitness=>1.0}, {:error=>1.5, :num=>1, :fitness=>0.5}]
    min_error, l_rate, alpha, v = 0.1, 1.0, 0.1, -0.5
    update_fitness(set, min_error, l_rate, alpha, v)
    a1 = (alpha*(1.0/min_error)**v)*set[0][:num].to_f
    a2 = (alpha*(1.5/min_error)**v)*set[1][:num].to_f
    sum = a1 + a2
    assert_equal(1.0+l_rate*(a1*set[0][:num].to_f/sum-1.0), set[0][:fitness])
    assert_equal(0.5+l_rate*(a2*set[1][:num].to_f/sum-0.5), set[1][:fitness])
  end
  
  # test run the genetic algorithm
  def test_can_run_genetic_algorithm
    # small action set
    assert_equal(false, can_run_genetic_algorithm([], 10, 1))
    assert_equal(false, can_run_genetic_algorithm([1], 10, 1))
    assert_equal(false, can_run_genetic_algorithm([1,2], 10, 1))
    # can run
    set = [{:lasttime=>40, :num=>1}, {:lasttime=>30, :num=>1}, {:lasttime=>20, :num=>1}]
    assert_equal(true, can_run_genetic_algorithm(set, 50, 10))
    # cannot run
    set = [{:lasttime=>45, :num=>1}, {:lasttime=>45, :num=>1}, {:lasttime=>45, :num=>1}]
    assert_equal(false, can_run_genetic_algorithm(set, 50, 10))    
  end
  
  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}  
  end
  
  # test mutation
  def test_mutation
    # no change
    c = {:condition=>"111111", :action=>'1'}
    mutation(c, ['1', '0'], "000000", rate=0.0)
    assert_equal("111111", c[:condition])
    assert_equal("1", c[:action])
    # all change (numbers to hash)
    c = {:condition=>"111111", :action=>'1'}
    mutation(c, ['1', '0'], "000000", rate=1.0)
    assert_equal("\#\#\#\#\#\#", c[:condition])
    assert_equal("0", c[:action])
    # all change (hash to numbers)
    c = {:condition=>"\#\#\#\#\#\#", :action=>'1'}
    mutation(c, ['1', '0'], "000000", rate=1.0)
    assert_equal("000000", c[:condition])
    assert_equal("0", c[:action])    
  end
  
  # test uniform crossover
  def test_uniform_crossover
    p1 = "0000000000"
    p2 = "1111111111"    
    s = uniform_crossover(p1,p2)        
    s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
  end  

  # test insertion into the population
  def test_insert_in_pop
    # increment
    pop = [{:condition=>"000000", :action=>'1', :num=>1}]
    cl = {:condition=>"000000", :action=>'1', :num=>1}
    insert_in_pop(cl, pop)
    assert_equal(1, pop.size)
    assert_equal(2, pop.first[:num])
    # add
    pop = [{:condition=>"000000", :action=>'1', :num=>1}]
    cl = {:condition=>"111111", :action=>'1', :num=>1}
    insert_in_pop(cl, pop)
    assert_equal(2, pop.size)
    assert_equal(1, pop[0][:num])
    assert_equal(1, pop[1][:num])
  end
  
  # test crossover
  # actions and nums and other data are assumed
  def test_crossover
    c1, c2 = {}, {}
    p1 = {:condition=>"000000",:action=>'1',:pred=>2,:error=>0.5,:fitness=>5}
    p2 = {:condition=>"111111",:action=>'0',:pred=>3,:error=>0.1,:fitness=>3}
    crossover(c1, c2, p1, p2)
    # c1
    c1[:condition].size.times do |i| 
      assert( (c1[:condition][i]==p1[:condition][i]) || (c1[:condition][i]==p2[:condition][i]) )
    end
    assert_equal((2.0+3.0)/2.0, c1[:pred])
    assert_equal(0.25*((0.5+0.1)/2.0), c1[:error])
    assert_equal(0.1*((5.0+3.0)/2.0), c1[:fitness])
    # c2
    c2[:condition].size.times do |i| 
      assert( (c2[:condition][i]==p1[:condition][i]) || (c2[:condition][i]==p2[:condition][i]) )
    end
    assert_equal((2.0+3.0)/2.0, c2[:pred])
    assert_equal(0.25*((0.5+0.1)/2.0), c2[:error])
    assert_equal(0.1*((5.0+3.0)/2.0), c2[:fitness])
  end
  
  # test running the GA
  def test_run_ga
    pop = [{:condition=>"000000", :action=>'1', :num=>1, :fitness=>0.1, 
              :pred=>0.3, :error=>0.1, :setsize=>1, :num=>1, :exp=>1}, 
           {:condition=>"111111", :action=>'0', :num=>1, :fitness=>0.2, 
              :pred=>0.3, :error=>0.1, :setsize=>1, :num=>1, :exp=>1}]
    run_ga(['0', '1'], pop, pop, "000000", 5, 2, 1.0)
    # popsize is reasonable
    assert_operator(pop.size, :>, 0)
    assert_in_delta(2, pop.inject(0){|s,x| s + x[:num]}, 1)
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
  
  # test the preparation of a model
  def test_train_model
    pop = nil
    silence_stream(STDOUT) do
      pop = train_model(50, 500, ['0', '1'], 20)
    end
    # got a pop
    assert_not_nil(pop)
    assert_operator(pop.size, :>, 0)
    assert_in_delta(50, pop.inject(0){|s,x| s + x[:num]}, 5)
    # pop is meaningful
    pop.each do |p|
      assert_equal(6, p[:condition].size)
      assert_equal(true, ['0', '1'].include?(p[:action]))
    end
  end
  
  # test the assessment of the model
  def test_test_model
    # perfect system
    rs = nil
    system = [
      {:condition=>"000\#\#\#", :action=>"0", :pred=>1.0, :fitness=>1.0}, 
      {:condition=>"001\#\#\#", :action=>"1", :pred=>1.0, :fitness=>1.0},
      {:condition=>"01\#0\#\#", :action=>"0", :pred=>1.0, :fitness=>1.0},
      {:condition=>"01\#1\#\#", :action=>"1", :pred=>1.0, :fitness=>1.0},
      {:condition=>"10\#\#0\#", :action=>"0", :pred=>1.0, :fitness=>1.0},
      {:condition=>"10\#\#1\#", :action=>"1", :pred=>1.0, :fitness=>1.0},
      {:condition=>"11\#\#\#0", :action=>"0", :pred=>1.0, :fitness=>1.0},
      {:condition=>"11\#\#\#1", :action=>"1", :pred=>1.0, :fitness=>1.0}
             ]
    silence_stream(STDOUT) do
      rs = test_model(system, 100)
    end
    assert_not_nil(rs)
    assert_equal(100, rs)
    # always zero
    rs = nil
    system = [{:condition=>"\#\#\#\#\#\#", :action=>"0", :pred=>1.0, :fitness=>1.0}]
    silence_stream(STDOUT) do
      rs = test_model(system, 100)
    end
    assert_not_nil(rs)
    assert_in_delta(50, rs, 15)
    # always one
    rs = nil
    system = [{:condition=>"\#\#\#\#\#\#", :action=>"1", :pred=>1.0, :fitness=>1.0}]
    silence_stream(STDOUT) do
      rs = test_model(system, 100)
    end
    assert_not_nil(rs)
    assert_in_delta(50, rs, 15)
  end
  
  # test that the algorithm can solve the problem
  def test_execute
    # execute
    pop = nil
    silence_stream(STDOUT) do
       pop = execute(200, 5000, ['0', '1'], 25)
    end    
    # check system
    micro = pop.inject(0){|s,x| s + x[:num]}
    assert_in_delta(200, micro, 5)
    # check capability
    correct = nil
    silence_stream(STDOUT) do
      correct = test_model(pop)
    end
    assert_not_nil(correct)
    assert_in_delta(50, correct, 5)
  end
  
end
