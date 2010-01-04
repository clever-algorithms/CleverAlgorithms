# Copyright (C) 2009  Jason Brownlee
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Tabu Search


class Berlin52TSP
  OPTIMAL_TOUR = [1,49,32,45,19,41,8,9,10,43,33,51,11,52,14,13,47,26,
    27,28,12,25,4,6,15,5,24,48,38,37,40,39,36,35,34,44,46,16,29,50,20,
    23,30,2,7,42,21,17,3,18,31,22]
        
  COORDINATES = [[565, 575],[25, 185],[345, 750],[945, 685],[845, 655],
  [880, 660],[25, 230],[525, 1000],[580, 1175],[650, 1130],[1605, 620], 
  [1220, 580],[1465, 200],[1530, 5],[845, 680],[725, 370],[145, 665],
  [415, 635],[510, 875], [560, 365],[300, 465],[520, 585],[480, 415],
  [835, 625],[975, 580],[1215, 245],[1320, 315],[1250, 400],[660, 180],
  [410, 250],[420, 555],[575, 665],[1150, 1160],[700, 580],[685, 595],
  [685, 610],[770, 610],[795, 645],[720, 635],[760, 650],[475, 960],
  [95, 260],[875, 920],[700, 500],[555, 815],[830, 485],[1170, 65],
  [830, 610],[605, 625],[595, 360],[1340, 725],[1740, 245]]
  
  attr_reader :num_cities

  def initialize()
    @num_cities = COORDINATES.length        
    @optimal_tour_length = evaluate(OPTIMAL_TOUR) # calculate
  end
  
  def evaluate(permutation)
    dist = 0    
    permutation.each_with_index do |c1, i|
      c2 = (i==@num_cities-1) ? permutation[0] : permutation[i+1] 
      dist += euc_2d(COORDINATES[c1-1], COORDINATES[c2-1])
    end
    return dist
  end
  
  def euc_2d(c1, c2)
    # As defined in TSPLIB'95 (EUC_2D)
    Math::sqrt((c1[0] - c2[0])**2 + (c1[1] - c2[1])**2).round
  end

  def is_optimal?(scoring)
    scoring == optimal_score
  end

  def optimal_score
    @optimal_tour_length
  end
  
  # true if s1 is better score than s2
  def is_better?(s1, s2)
    s1 < s2 # minimizing
  end
end

class Solution
  attr_reader :data
  attr_accessor :score, :count
  
  def initialize(data)
    @data = data
    @score = 0.0/0.0 # NaN
    @count = 0
  end
  
  def ==(other)
    # permutation is direction independant
    @data == other.data or @data.reverse == other.data
  end
  
  def to_s
    "[#{@data.inspect}] (#{@score})"
  end    
end

class TabuSearchAlgorithm
  attr_accessor :max_iterations
  attr_reader :best_solution
  
  def initialize(max_iterations)
    @max_iterations = max_iterations
    @tabu_tenure = 100 # maximum number of solutions on the list
    @aspiration_frequency = 5 # max tries to visit a taboo before allowing
  end
  
  # execute a search on the provided problem
  def search(problem)
    tabu_list = [] # prep the tabu list
    # random starting point
    current = generate_initial_solution(problem)
    tabu_list << current # make candidate taboo
    evaluate_candidate(current, problem)
    curr_it = 0       
    begin
      # generate new neighbour that is not tabo
      selection_ok = true
      begin
        selection_ok = true # optimism
        candidate = two_opt_solution(current) # generate
        # check tabu
        if tabu_list.include?(candidate)
          other = tabu_list.find {|t| t==candidate}
          if (other.count+=1) >= @aspiration_frequency
            puts "> we have an aspiration!!!"
            tabu_list.delete_if {|t| t==candidate} # ensure no duplicates
          else
            puts "> rejected tabu"
            selection_ok = false 
          end
        end
      end until selection_ok
      evaluate_candidate(candidate, problem) # evaluate
      # manage short term memory
      tabu_list << candidate # make candidate taboo
      tabu_list.delete_at(0) while tabu_list.length > @tabu_tenure
      # greedy acceptance
      current = candidate if problem.is_better?(candidate.score, current.score)
      curr_it += 1
    end until should_stop?(curr_it, problem)
    return @best_solution
  end
  
  def should_stop?(curr_it, problem)
    (curr_it >= @max_iterations) or problem.is_optimal?(best_solution.score)
  end
  
  def generate_initial_solution(problem)
    all = Array.new(problem.num_cities) {|i| (i+1)}
    permutation = Array.new(all.length) {|i| all.delete_at(rand(all.length))}
    return Solution.new(permutation)
  end

  def two_opt_solution(solution)
    perm = Array.new(solution.data) # copy
    # select a sub-sequence    
    c1, c2 = rand(perm.length), rand(perm.length)
    c2 = rand(perm.length) while c1 == c2
    # ensure c1 is low and c2 is high
    c1, c2 = c2, c1 if c2 < c1
    # reverse sub-sequence
    perm[c1...c2] = perm[c1...c2].reverse
    return Solution.new(perm)
  end

  def evaluate_candidate(solution, problem)
    solution.score = problem.evaluate(solution.data)
    # keep track of the best solution found
    if @best_solution.nil? or 
      problem.is_better?(solution.score, @best_solution.score)
      @best_solution = solution
      puts " > new best: #{solution.score}"               
    end
  end
end

srand(1) # set the random number seed to 1
algorithm = TabuSearchAlgorithm.new(2000) # limit to 2000 iterations 
problem = Berlin52TSP.new # create a problem
best = algorithm.search(problem) # execute the search
puts "Best Solution: #{best}" # display the best solution