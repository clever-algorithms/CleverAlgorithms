# Unit tests for evolution_strategies.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require "test/unit"
require "../evolution_strategies"

class TC_EvolutionStrategies < Test::Unit::TestCase
  
  def test_random_gaussian_default
    mean, stdev = 0.0, 1.0
    a = []
    1000.times do
      r = random_gaussian(mean, stdev)
      assert_in_delta(mean, r, 4*stdev) # 4 stdevs
      a << r
    end
    mean = a.inject(0){|sum,x| sum + x} / a.size.to_f
    assert_in_delta(mean, mean, 0.1)
  end
  
  def test_random_gaussian_non_default
    mean, stdev = 50, 10
    a = []
    1000.times do
      r = random_gaussian(mean, stdev)
      assert_in_delta(mean, r, 4*stdev) # 4 stdevs
      a << r
    end
    mean = a.inject(0){|sum,x| sum + x} / a.size.to_f
    assert_in_delta(mean, mean, 0.1)
  end
  
end