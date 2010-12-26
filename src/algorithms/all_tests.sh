#!/bin/sh

LOG=all_tests.log

# evolutionary
function evolutionary { 
	ruby evolutionary/tests/tc_differential_evolution.rb | tee -a $LOG
	ruby evolutionary/tests/tc_evolution_strategies.rb | tee -a $LOG
	ruby evolutionary/tests/tc_evolution_programming.rb | tee -a $LOG
	ruby evolutionary/tests/tc_gene_expression_programming.rb | tee -a $LOG
	ruby evolutionary/tests/tc_genetic_algorithm.rb | tee -a $LOG
	ruby evolutionary/tests/tc_genetic_programming.rb | tee -a $LOG
	ruby evolutionary/tests/tc_grammatical_evolution.rb | tee -a $LOG
	ruby evolutionary/tests/tc_learning_classifier_system.rb | tee -a $LOG
	ruby evolutionary/tests/tc_nsga_ii.rb | tee -a $LOG
	ruby evolutionary/tests/tc_spea2.rb | tee -a $LOG
}

# immune 
function immune { 
	ruby immune/tests/tc_airs.rb | tee -a $LOG
	ruby immune/tests/tc_clonal_selection_algorithm.rb | tee -a $LOG
	ruby immune/tests/tc_dendritic_cell_algorithm.rb | tee -a $LOG
	ruby immune/tests/tc_negative_selection_algorithm.rb | tee -a $LOG
	ruby immune/tests/tc_optiainet.rb | tee -a $LOG
}

# neural
function neural { 
	ruby neural/tests/tc_backpropagation.rb | tee -a $LOG
	ruby neural/tests/tc_hopfield.rb | tee -a $LOG
	ruby neural/tests/tc_lvq.rb | tee -a $LOG
	ruby neural/tests/tc_perceptron.rb | tee -a $LOG
	ruby neural/tests/tc_som.rb | tee -a $LOG
}

# physical
function physical { 
	ruby physical/tests/tc_cultural_algorithm.rb | tee -a $LOG
	ruby physical/tests/tc_extremal_optimization.rb | tee -a $LOG
	ruby physical/tests/tc_harmony_search.rb | tee -a $LOG
	ruby physical/tests/tc_memetic_algorithm.rb | tee -a $LOG
	ruby physical/tests/tc_simulated_annealing.rb | tee -a $LOG
}

# probabilistic
function probabilistic { 
	ruby probabilistic/tests/tc_boa.rb | tee -a $LOG
	ruby probabilistic/tests/tc_compact_genetic_algorithm.rb | tee -a $LOG
	ruby probabilistic/tests/tc_cross_entropy_method.rb | tee -a $LOG
	ruby probabilistic/tests/tc_pbil.rb | tee -a $LOG
	ruby probabilistic/tests/tc_umda.rb | tee -a $LOG
}

# stochastic
function stochastic { 
	ruby stochastic/tests/tc_adaptive_random_search.rb | tee -a $LOG
	ruby stochastic/tests/tc_grasp.rb | tee -a $LOG
	ruby stochastic/tests/tc_guided_local_search.rb | tee -a $LOG
	ruby stochastic/tests/tc_iterated_local_search.rb | tee -a $LOG
	ruby stochastic/tests/tc_random_search.rb | tee -a $LOG
	ruby stochastic/tests/tc_reactive_tabu_search.rb | tee -a $LOG
	ruby stochastic/tests/tc_scatter_search.rb | tee -a $LOG
	ruby stochastic/tests/tc_stochastic_hill_climbing.rb | tee -a $LOG
	ruby stochastic/tests/tc_tabu_search.rb | tee -a $LOG
	ruby stochastic/tests/tc_variable_neighborhood_search.rb | tee -a $LOG
}

# swarm
function swarm { 
	ruby swarm/tests/tc_ant_colony_system.rb | tee -a $LOG
	ruby swarm/tests/tc_ant_system.rb | tee -a $LOG
	ruby swarm/tests/tc_bees_algorithm.rb | tee -a $LOG
	ruby swarm/tests/tc_bfoa.rb | tee -a $LOG
	ruby swarm/tests/tc_pso.rb | tee -a $LOG
}

# paradigms
function paradigms { 
	ruby ../programming_paradigms/tests/tc_flow.rb | tee -a $LOG
	ruby ../programming_paradigms/tests/tc_oop.rb | tee -a $LOG
}


# clear the log
date > $LOG

# execute
# evolutionary
# immune
# neural
# physical
# probabilistic
# stochastic
# swarm
paradigms

# summary
echo "\nSummary of Results:"
echo "------------------------------------------------------------"
cat all_tests.log | grep -E ' Error:| Failure:|No such file or directory'
