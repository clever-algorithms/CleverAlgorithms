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


# Multiple Restart Search


class SquaringFunction
  attr_reader :dimensions, :min, :max

  def initialize(dimensions=2)
    @dimensions = dimensions
    @min, @max = -5.12, +5.12
  end

  def evaluate(vector)
    vector.inject(0) {|sum, x| sum + (x ** 2.0)}
  end  
  
  def in_bounds?(vector)
    vector.each {|x| return false if x>@max or x<@min}
    return true    
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

class MultipleRestartSearchAlgorithm
  attr_accessor :max_iterations
  attr_reader :best_solution
  
  def initialize(max_restarts)
    @max_restarts = max_restarts
    @max_no_improvements = 100 # max steps for hill climber
  end
  
  # execute a random search on the provided problem
  def search(problem)    
    curr_it = 0
    begin
      # generate a random solution 
      current = generate_random_solution(problem)
      evaluate_candidate_solution(current, problem)
      # hill climb until convergence
      run_best = hill_climb(problem, current)
      curr_it += 1      
      puts "> finished run #{curr_it} with: #{run_best.score}"   
    end until should_stop?(curr_it, problem)
    return @best_solution
  end
  
  def should_stop?(curr_it, problem)
    (curr_it >= @max_restarts) or problem.is_optimal?(best_solution.score)
  end
  
  def generate_random_solution(problem)
    real_vector = Array.new(problem.dimensions) do
      next_bfloat(problem.min, problem.max)
    end
    return Solution.new(real_vector)
  end
  
  def hill_climb(problem, current)
    step_size = (problem.max-problem.min)*0.10
    no_improve_count = 0
    index = 0
    begin
      # take a step
      step1 = take_step(problem, current, step_size, index, true)
      evaluate_candidate_solution(step1, problem)
      step2 = take_step(problem, current, step_size, index, false)
      evaluate_candidate_solution(step2, problem)      
      # check for improvement
      if problem.is_better?(step1.score, current.score) or 
        problem.is_better?(step2.score, current.score)
        # store the best
        if problem.is_better?(step1.score, current.score)
          current = step1
        else
          current = step2
        end
        no_improve_count = 0 # reset
      else
        no_improve_count += 1 # count consecutative no improvements
      end
      index = (index==problem.dimensions-1) ? 0 : index+1
    end until no_improve_count >= @max_no_improvements
    return current
  end
  
  def take_step(problem, current, step_size, index, add)
    vector = nil
    begin # keep stepping until a valid point is generated
      offset = next_bfloat(0, step_size)
      vector = Array.new(current.data)
      vector[index] += (add) ? offset : -offset
    end until problem.in_bounds?(vector)
    return Solution.new(vector)
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
    end
  end  
end

srand(1) # set the random number seed to 1
algorithm = MultipleRestartSearchAlgorithm.new(10) # limit to 10 restarts
problem = SquaringFunction.new(5) # create a problem with 5 dimensions
best = algorithm.search(problem) # execute the search
puts "Best Solution: #{best}" # display the best solution