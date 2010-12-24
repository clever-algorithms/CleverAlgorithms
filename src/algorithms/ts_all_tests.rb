# Test Suite for all Clever Algorithms

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

# Evolutionary Algorithms
require File.expand_path(File.dirname(__FILE__)) + "/evolutionary/tests/tc_evolution_strategies"
require File.expand_path(File.dirname(__FILE__)) + "/evolutionary/tests/tc_gene_expression_programming"
require File.expand_path(File.dirname(__FILE__)) + "/evolutionary/tests/tc_genetic_algorithm"
require File.expand_path(File.dirname(__FILE__)) + "/evolutionary/tests/tc_grammatical_evolution"


# Immune Algorithms

# Neural Algorithms
require File.expand_path(File.dirname(__FILE__)) + "/neural/tests/tc_backpropagation"

# Physical Algorithms
require File.expand_path(File.dirname(__FILE__)) + "/physical/tests/tc_extremal_optimization"

# Stochastic Algorithms

# Probabilistic Algorithms

# Swarm Algroithms
require File.expand_path(File.dirname(__FILE__)) + "/swarm/tests/tc_pso"
require File.expand_path(File.dirname(__FILE__)) + "/swarm/tests/tc_bees_algorithm"

class TS_AllTests
  def self.suite
    suite = Test::Unit::TestSuite.new("Clever Algorithms")
    
    # Evolutionary Computation
    suite << TC_EvolutionStrategies.suite
    suite << TC_GeneticAlgorithm.suite
    suite << TC_GeneExpressionProgramming.suite
    suite << TC_GrammaticalEvolution.suite

    # Immune Algorithms

    # Neural Algorithms
    suite << TC_BackPropagation.suite
    
    # Physical Algorithms
    suite << TC_ExtremalOptimization.suite
    
    # Stochastic Algorithms

    # Probabilistic Algorithms

    # Swarm Algroithms
    suite << TC_Pso.suite
    suite << TC_BeesAlgorithm.suite
    
    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_AllTests)
