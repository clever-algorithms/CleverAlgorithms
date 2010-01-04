# Inspired Algorithms, http://InspiredAlgorithms.com
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


# Iterated Local Search

# a version of the problem with precalculated distance matrix and 
# nearest neighbour solution generation - may be useful 
class Berlin52TSPPreCalculated
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
    @distance_matrix = Array.new(@num_cities) {Array.new(@num_cities)}
    build_distance_matrix
    @optimal_tour_length = evaluate(OPTIMAL_TOUR) # calculate
  end
  
  def build_distance_matrix
    # symmetrical matrix along the diag
    @distance_matrix.each_with_index do |row, i|
      row.each_index do |j|
        row[j] = euc_2d(COORDINATES[i], COORDINATES[j])
      end
    end
  end

  def evaluate(permutation)
    dist = 0    
    permutation.each_with_index do |c1, i|
      c2 = (i==@num_cities-1) ? permutation[0] : permutation[i+1] 
      # dist += euc_2d(COORDINATES[c1-1], COORDINATES[c2-1])
      dist += @distance_matrix[c1-1][c2-1]
    end
    return dist
  end
  
  def euc_2d(c1, c2)
    # As defined in TSPLIB'95 (EUC_2D)
    Math::sqrt((c1[0] - c2[0])**2 + (c1[1] - c2[1])**2).round
  end
  
  def nearest_neighbor_permutation
    perm = []
    perm << (rand(@num_cities) + 1)
    # construct a NN tour
    (1...@num_cities).each do |i|
      from, to, dist = perm[i-1], -1, +(1.0/0.0) # pos inf
      @distance_matrix[from-1].each_with_index do |d, i|
        if !perm.include?(i+1)
          if d < dist
            dist, to = d, i+1            
          end
        end
      end
      perm << to # next point in permutation
    end        
    return perm
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


# problem used in the guide

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
  attr_accessor :score
  
  def initialize(data)
    @data = data
    @score = 0.0/0.0 # NaN
  end
  
  def to_s
    "[#{@data.inspect}] (#{@score})"
  end    
end

class IteratedLocalAlgorithm
  attr_accessor :max_iterations
  attr_reader :best_solution
  
  def initialize(max_iterations)
    @max_iterations = max_iterations
  end
  
  # execute a iterated local search on the provided problem
  def search(problem)
    # random starting point
    current = generate_initial_solution(problem)
    @best_solution = current
    evaluate_candidate_solution(current, problem)
    # local search
    local_best = local_search_solution(current, problem)
    current = local_best if problem.is_better?(local_best.score, current.score)
    curr_it = 0
    begin
      # generate perturbation
      pert_solution = perturb_solution(current)
      evaluate_candidate_solution(pert_solution, problem)
      # local search
      local_best = local_search_solution(pert_solution, problem)
      # greedy acceptance
      current = local_best if problem.is_better?(local_best.score, current.score)
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

  def perturb_solution(solution)    
    data =  solution.data
    length = data.length
    # double-bridge move (4-opt), break into 4 parts (a,b,c,d)
    pos1 = 1 + rand(length / 4)
    pos2 = pos1 + 1 + rand(length / 4)
    pos3 = pos2 + 1 + rand(length / 4)
    # put it back together (a,d,c,b)
    perm = data[0...pos1] + data[pos3...length] + 
      data[pos2...pos3] + data[pos1...pos2]
    return Solution.new(perm)
  end

  def local_search_solution(solution, problem)
    # greedy iterated 2-opt
    30.times do
      candidate = two_opt_solution(solution)
      evaluate_candidate_solution(candidate, problem)
      if problem.is_better?(candidate.score, solution.score)
        solution = candidate 
      end
    end
    return solution
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

  def evaluate_candidate_solution(solution, problem)
    solution.score = problem.evaluate(solution.data)
    # keep track of the best solution found
    if problem.is_better?(solution.score, @best_solution.score)
      @best_solution = solution
      puts " > new best: #{solution.score}"               
    end
  end
end

srand(1) # set the random number seed to 1
algorithm = IteratedLocalAlgorithm.new(1000) # limit to 1000 iterations 
problem = Berlin52TSP.new # create a problem
best = algorithm.search(problem) # execute the search
puts "Best Solution: #{best}" # display the best solution