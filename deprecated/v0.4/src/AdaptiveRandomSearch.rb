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


# Adaptive Random Search


class ExponentFunction
  attr_reader :dimensions, :min, :max

  def initialize(dimensions=2)
    @dimensions = dimensions
    @min, @max = -5.12, +5.12
  end

  def evaluate(vector)
    vector.inject(0) {|sum, x| sum + (x ** 4.0)}
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

class AdaptiveRandomSearchAlgorithm
  attr_accessor :max_iterations
  attr_reader :best_solution
  
  def initialize(max_iterations)
    @max_iterations = max_iterations
    @small_factor = 1.3 # normal step size incrase(*) and decrease(/) rate
    @large_factor = 10 # step size factor increase for larger jump
    @large_factor_multiple = 100 # max steps before larger jump is tried
    @maximum_no_improvements = 50 # max non-improvement steps before size decreased
  end
  
  # execute the algorithm
  def search(problem)    
    # random starting point
    current = generate_random_solution(problem)
    evaluate_candidate_solution(current, problem)
    curr_it = 0
    step_size = (problem.max-problem.min)*0.1 # 10% of the domain
    no_change_cnt = 0
    begin
      # current step
      step = take_step(problem, current, step_size)
      evaluate_candidate_solution(step, problem)
      # take second larger step
      factor = @small_factor
      factor = @large_factor if curr_it.modulo(@large_factor_multiple) == 0
      larger_step_size = step_size * factor
      larger_step = take_step(problem, current, larger_step_size)
      evaluate_candidate_solution(larger_step, problem)
      # check for improvement
      if problem.is_better?(step.score, current.score) or 
        problem.is_better?(larger_step.score, current.score)        
        # select new step size if larger step is better
        if problem.is_better?(larger_step.score, step.score)
          step_size = larger_step_size # increase step size
          current = larger_step # new best solution
        else
          current = step # new best solution
        end
        no_change_cnt = 0 # reset counter
      # check for step size decrease
      elsif (no_change_cnt+=1) >= @maximum_no_improvements
        no_change_cnt = 0 # reset counter
        step_size /= @small_factor # decrease step size
      end
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
  
  def take_step(problem, current, step_size)
    vector = nil
    begin # keep stepping until a valid point is generated
      step = Array.new(problem.dimensions) do
        v = next_bfloat(-step_size, +step_size) 
      end
      data = current.data
      vector = Array.new(data.length) {|i| data[i] + step[i]}
    end while !problem.in_bounds?(vector)
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
      puts "> new best: #{solution.score}"               
    end
  end  
end

srand(1) # set the random number seed to 1
algorithm = AdaptiveRandomSearchAlgorithm.new(5000) # limit to 5000 iterations 
problem = ExponentFunction.new(5) # create a problem with 5 dimensions
best = algorithm.search(problem) # execute the search
puts "Best Solution: #{best}" # display the best solution
