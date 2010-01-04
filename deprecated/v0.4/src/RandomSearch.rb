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


# Random Search


class SquaringFunction
  attr_reader :dimensions, :min, :max

  def initialize(dimensions=2)
    @dimensions = dimensions
    @min, @max = -5.12, +5.12
  end

  def evaluate(vector)
    vector.inject(0) {|sum, x| sum + (x ** 2.0)}
  end  

  def is_optimal?(scoring)
    scoring == optimal_score
  end

  def optimal_score
    0.0
  end
  
  # true if s1 has a better score than s2
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

class RandomSearchAlgorithm
  attr_accessor :max_iterations
  attr_reader :best_solution
  
  def initialize(max_iterations)
    @max_iterations = max_iterations
  end
  
  # execute a random search on the provided problem
  def search(problem)    
    @best_solution = nil
    curr_it = 0
    begin
      candidate = generate_random_solution(problem)
      evaluate_candidate_solution(candidate, problem)
      curr_it += 1
    end until should_stop?(curr_it, problem)
    return @best_solution
  end
  
  def should_stop?(curr_it, problem)
    (curr_it >= @max_iterations) or problem.is_optimal?(best_solution.score)
  end
  
  def generate_random_solution(problem)
    real_vector = Array.new(problem.dimensions) do
      next_bfloat(problem.min, problem.max)
    end
    return Solution.new(real_vector)
  end

  def next_bfloat(min, max)
    min + ((max - min) * rand)
  end
  
  def evaluate_candidate_solution(solution, problem)
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
algorithm = RandomSearchAlgorithm.new(1000) # limit to 1000 iterations 
problem = SquaringFunction.new(5) # create a problem with 5 dimensions
best = algorithm.search(problem) # execute the search
puts "Best Solution: #{best}" # display the best solution
