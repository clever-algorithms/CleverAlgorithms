# 
# Unit tests for genetic_algorithm.rb
# 

require "test/unit"
require "../genetic_algorithm"

# TODO figure out some ruby-fu to test the script functions without running it.

class TC_GeneticAlgorithm < Test::Unit::TestCase
      
      # test that the objective function behaves as expected
      def test_onemax
        assert_equal(0, onemax("0000"))
        assert_equal(4, onemax("1111"))
      end
      
      # test the creation of random strings
      def test_random_bitstring
        assert_equal(10, random_bitstring(10).length)
        assert_equal(0, random_bitstring(10).delete('0').delete('1').length)
      end
      
      # test the approximate proportion of 1's and 0's
      def test_random_bitstring_ratio
        s = random_bitstring(1000)
        assert_in_delta(0.5, (s.delete('1').length/1000.0), 0.05)
        assert_in_delta(0.5, (s.delete('0').length/1000.0), 0.05)
      end
      
      # test that members of the population are selected
      def test_binary_tournament
        pop = Array.new(10) {|i| {:fitness=>i} }
        10.times {assert(pop.include?(binary_tournament(pop)))}  
      end
      
      # test point mutations at the limits
      def test_point_mutation
        assert_equal("0000000000", point_mutation("0000000000", 0))
        assert_equal("1111111111", point_mutation("1111111111", 0))
        assert_equal("1111111111", point_mutation("0000000000", 1))
        assert_equal("0000000000", point_mutation("1111111111", 1))
      end
      
      # test that the observed changes approximate the intended probability
      def test_point_mutation_ratio
        changes = 0
        100.times do
          s = point_mutation("0000000000", 0.5)
          changes += (10 - s.delete('1').length)
        end
        assert_in_delta(0.5, changes.to_f/(100*10), 0.05)
      end
      
      # test recombination
      def test_uniform_crossover
        p1 = "0000000000"
        p2 = "1111111111"        
        assert_equal(p1, uniform_crossover(p1,p2,0))
        assert_not_same(p1, uniform_crossover(p1,p2,0))      
        s = uniform_crossover(p1,p2,1)        
        s.length.times {|i| assert( (p1[i]==s[i]) || (p2[i]==s[i]) ) }
      end
      
      # test reproduce cloning case
      def test_reproduce_clone
        pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>random_bitstring(10)} }
        children = reproduce(pop, pop.length, 0, 0)
        children.each_with_index do |c,i| 
          assert_equal(pop[i][:bitstring], c[:bitstring])
          assert_not_same(pop[i][:bitstring], c[:bitstring])  
        end
      end
      
      # test reproduce size mismatch
      def test_reproduce_mismatch
        pop = Array.new(10) {|i| {:fitness=>i,:bitstring=>random_bitstring(10)} }
        children = reproduce(pop, 9, 0, 0)
        assert_equal(9, children.length)
      end
end