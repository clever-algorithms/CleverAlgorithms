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
    c = new_classifier("000000", '1', 500, 99)
    assert_equal("000000", c[:condition])
    assert_equal("1", c[:action])
    assert_equal(500, c[:lasttime])    
    assert_not_nil(c[:prediction])
    assert_not_nil(c[:error])
    assert_not_nil(c[:fitness])
    assert_equal(99, c[:prediction])
    assert_equal(99, c[:error])
    assert_equal(99, c[:fitness])    
    assert_not_nil(c[:experience])
    assert_equal(0, c[:experience])
    assert_not_nil(c[:setsize])
    assert_equal(1, c[:setsize])
    assert_not_nil(c[:num])
    assert_equal(1, c[:num])
  end
  
  # test copying a classifier
  def test_copy_classifier
    parent = {:action=>"0", :condition=>"111111", :lasttime=>33, 
      :prediction=>5, :error=>2, :fitness=>7, :experience=>90, :setsize=>20, :num=>66}
    c = copy_classifier(parent)    
    # equal
    assert_equal(parent[:action], c[:action])
    assert_equal(parent[:condition], c[:condition])
    assert_equal(parent[:lasttime], c[:lasttime])
    assert_equal(parent[:prediction], c[:prediction])
    assert_equal(parent[:error], c[:error])
    assert_equal(parent[:fitness], c[:fitness])
    assert_not_equal(parent[:experience], c[:experience])
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
    classifier = {:setsize=>5, :num=>5, :fitness=>10, :experience=>20}
    rs = calculate_deletion_vote(classifier, pop, 50)
    assert_equal(25, rs)
    # above deletion threshold and more than average fitness
    pop = [{:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}]
    classifier = {:setsize=>5, :num=>5, :fitness=>10, :experience=>50}
    rs = calculate_deletion_vote(classifier, pop, 5)
    assert_equal(25, rs)
    # above deletion threshold and less than average fitness
    pop = [{:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}, {:fitness=>10, :num=>1}]
    classifier = {:setsize=>5, :num=>0.01, :fitness=>0.1, :experience=>50}
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
    pop = [{:setsize=>5, :num=>5, :fitness=>10, :experience=>50, :num=>5}, 
      {:setsize=>5, :num=>5, :fitness=>10, :experience=>50, :num=>5}, 
      {:setsize=>5, :num=>5, :fitness=>10, :experience=>50, :num=>5}]
    delete_from_pop(pop, 5, 10)
    assert_equal(14, pop.inject(0){|s,x| s+x[:num]})
    # delete and remove one
    pop = [{:setsize=>5, :num=>5, :fitness=>10, :experience=>50, :num=>1}, 
      {:setsize=>5, :num=>5, :fitness=>10, :experience=>50, :num=>1}, 
      {:setsize=>5, :num=>5, :fitness=>10, :experience=>50, :num=>1}]
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
    rs = generate_match_set("000000", pop, ['0', '1'], 5, 2, 50)
    assert_equal(2, rs.size)
    assert_equal(2, pop.size)
    assert_equal(pop, rs)
    # add to match set
    pop = [{:action=>'1', :condition=>"111111", :setsize=>5, :num=>5, :fitness=>10, :experience=>50, :num=>1}, 
      {:action=>'0', :condition=>"000000", :setsize=>5, :num=>5, :fitness=>10, :experience=>50, :num=>1}]
    rs = generate_match_set("000000", pop, ['0', '1'], 5, 5, 5)
    assert_equal(2, rs.size)
    assert_equal(3, pop.size)    
  end
  
  # test generate a prediction
  def test_generate_prediction
    match_set = [{:action=>'1', :fitness=>1, :prediction=>1}, {:action=>'0', :fitness=>1, :prediction=>1}]
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
    # TODO prediction is initially close to zero, can this be a problem?
  end
  
  # test select action
  def test_select_action
    # random action
    a = select_action({'1'=>{}, '0'=>{}}, 1.0)
    assert_equal(true, ['0', '1'].include?(a))
    # specific action (large weight)
    a = select_action({'1'=>{:weight=>1}, '0'=>{:weight=>100}}, 0.0)
    assert_equal('0', a)
    # TODO is weight meant to be maximizing?
  end
  
  # test update set
  def test_update_set
    # > lrate
    set = [{:experience=>1, :prediction=>1, :error=>0, :num=>1, :setsize=>1}]
    update_set(set, 10, 1)
    assert_equal(2, set[0][:experience])
    assert_equal(1+1*(10-1), set[0][:prediction])
    assert_equal((1*((10-1).abs-0)), set[0][:error])
    assert_equal(1+(1*0), set[0][:setsize])
    # < lrate
    set = [{:experience=>1, :prediction=>1, :error=>0, :num=>1, :setsize=>1}]
    update_set(set, 10, 0.1)
    assert_equal(2, set[0][:experience])
    assert_equal(1+(10-1)/2.0, set[0][:prediction])
    assert_equal(((10-1).abs)/2.0, set[0][:error])
    assert_equal(1+(0.0/2.0), set[0][:setsize])
  end
  
  # test update fitness
  def test_update_fitness
    
    # update_fitness(action_set, min_error, l_rate)
    
  end
  
  def test_can_run_genetic_algorithm
        
  end
  
  # test that members of the population are selected
  def test_binary_tournament
    pop = Array.new(10) {|i| {:fitness=>i} }
    10.times {assert(pop.include?(binary_tournament(pop)))}  
  end
  
  def test_mutation
    
  end
  
  # test uniform crossover
  def test_uniform_crossover
    p1 = "0000000000"
    p2 = "1111111111"    
    s = uniform_crossover(p1,p2)        
    s.size.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
  end  

  def test_insert_in_pop
    
  end
  
  def test_crossover
    
  end
  
  def test_run_genetic_algorithm
    
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
  # def test_execute
  #   # execute
  #   pop = nil
  #   silence_stream(STDOUT) do
  #     pop = execute(150, 2000, ['0','1'], 0.1, 0.2, 0.01, 50, 20)
  #   end    
  #   # check system
  #   assert_in_delta(70, pop.size, 30)
  #   # check capability
  #   correct = nil
  #   silence_stream(STDOUT) do
  #     correct = test_model(pop)
  #   end
  #   assert_not_nil(correct)
  #   assert_in_delta(100, correct, 10)
  # end
  
end
